package main

import (
	"bufio"
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"flag"
	"fmt"
	"io/fs"
	"log"
	"net/url"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	start := time.Now()
	defer func() {
		elapsed := time.Since(start).Milliseconds()

		fmt.Printf("Total test duration %dms\n", elapsed)
	}()
	connection_string := flag.String(
		"conn",
		"",
		"Administrative connection string",
	)

	test_directory := flag.String(
		"test-dir",
		"",
		"Directory where tests are located.",
	)

	migrations_directory := flag.String(
		"migrations-dir",
		"",
		"Directory where migrations to run are located",
	)

	flag.Parse()

	invalid_params := false
	if *connection_string == "" {
		fmt.Println("Error: --conn=<db_uri> is required")
		invalid_params = true
	}
	if *test_directory == "" {
		fmt.Println("Error: --test-dir=<test-directory> is required")
		invalid_params = true
	}
	if *migrations_directory == "" {
		fmt.Println("Error: --migrations-dir=<path-to-migrations> is required")
		invalid_params = true
	}

	if invalid_params {
		os.Exit(1)
	}

	config, err := pgxpool.ParseConfig(*connection_string)
	if err != nil {
		panic(err)
	}

	connection_pool, err := pgxpool.NewWithConfig(
		context.Background(),
		config,
	)
	if err != nil {
		panic(err)
	}
	defer connection_pool.Close()

	unique_db_name, err := generateRandomString(16)
	if err != nil {
		panic(err)
	}

	template_db_name := fmt.Sprintf(
		"template_%s",
		unique_db_name)

	_, err = connection_pool.Exec(
		context.Background(),
		fmt.Sprintf("CREATE DATABASE %s;", template_db_name),
	)
	if err != nil {
		if err != pgx.ErrNoRows {
			panic(err)
		}
	}
	defer func() {
		_, err = connection_pool.Exec(
			context.Background(),
			fmt.Sprintf("DROP DATABASE %s",
				template_db_name,
			),
		)
	}()

	template_connection_string, err := replaceDbName(
		*connection_string,
		template_db_name,
	)
	if err != nil {
		panic(err)
	}

	template_connection, err := pgx.Connect(
		context.Background(),
		template_connection_string,
	)
	if err != nil {
		panic(err)
	}

	err = seedDb(template_connection, *migrations_directory)
	if err != nil {
		panic(err)
	}

	err = template_connection.Close(context.Background())
	if err != nil {
		panic(err)
	}

	runTests(connection_pool, *test_directory, template_db_name)

}

func replaceDbName(connStr, newDb string) (string, error) {
	if connStr == "" {
		return "", errors.New("Invalid connection string")
	}
	if newDb == "" {
		return "", errors.New("Invalid new db name")
	}

	u, err := url.Parse(connStr)
	if err != nil {
		return "", err
	}

	u.Path = "/" + newDb

	return u.String(), nil
}

func runTests(conn *pgxpool.Pool, test_dir string, template_db_name string) error {
	var test_files []string

	err := filepath.WalkDir(test_dir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !d.IsDir() && strings.HasSuffix(
			strings.ToLower(d.Name()), ".sql",
		) {
			test_files = append(test_files, path)
		}
		return nil
	})
	if err != nil {
		return err
	}

	num_workers := runtime.NumCPU()
	fmt.Printf("Starting %d workers\n", num_workers)
	fmt.Printf("Running %d tests", len(test_files))

	jobs := make(chan int, len(test_files))
	var wg sync.WaitGroup
	for i := 1; i <= num_workers; i++ {
		wg.Add(1)
		go testWorker(
			i,
			jobs,
			&wg,
			test_files,
			conn,
			template_db_name,
		)
	}

	for idx := range test_files {
		jobs <- idx
	}
	close(jobs)
	wg.Wait()

	return nil
}

func testWorker(
	id int,
	jobs <-chan int,
	wg *sync.WaitGroup,
	test_files []string,
	conn *pgxpool.Pool, template_db_name string,
) {
	defer wg.Done()
	for job := range jobs {
		start := time.Now()
		file_path := test_files[job]

		test_content, err := os.ReadFile(file_path)
		if err != nil {
			log.Println(err)
			continue
		}

		random_name, err := generateRandomString(15)
		if err != nil {
			log.Println(err)
			continue
		}

		testdb_name := fmt.Sprintf(
			"test_case_%d_%s",
			job,
			random_name,
		)

		_, err = conn.Exec(
			context.Background(),
			fmt.Sprintf(
				"CREATE DATABASE %s TEMPLATE %s",
				testdb_name,
				template_db_name,
			),
		)
		if err != nil {
			log.Printf("job: %d -- %s", job, err)
			continue
		}

		testdb_connection_string, err := replaceDbName(
			conn.Config().ConnString(), testdb_name,
		)
		if err != nil {
			log.Print(err)
			continue
		}

		testdb_connection, err := pgx.Connect(
			context.Background(),
			testdb_connection_string,
		)
		if err != nil {
			log.Print(err)
			continue
		}

		var result string
		tag, err := testdb_connection.Exec(
			context.Background(),
			string(test_content),
		)
		if err != nil {
			result = err.Error()
		} else {
			result = tag.String()
		}

		var expected_results []string
		scanner := bufio.NewScanner(
			strings.NewReader(string(test_content)),
		)
		for scanner.Scan() {
			line := scanner.Text()
			if strings.HasPrefix(line, "-- expect:") {
				content := strings.TrimSpace(strings.TrimPrefix(line, "-- expect:"))
				expected_results = append(expected_results, content)
			}
		}

		red := "\033[31m"
		green := "\033[32m"
		reset := "\033[0m"

		test_passed := false
		for _, expect := range expected_results {
			if strings.Contains(result,
				strings.TrimSpace(
					strings.TrimPrefix(expect, "ERROR: "),
				),
			) {
				test_passed = true
			}
		}

		err = testdb_connection.Close(
			context.Background(),
		)
		if err != nil {
			log.Print(err)
		}

		_, err = conn.Exec(
			context.Background(),
			fmt.Sprintf(
				"DROP DATABASE %s",
				testdb_name,
			),
		)

		elapsed := time.Since(start).Milliseconds()

		if test_passed {
			fmt.Printf(
				"%sPASS %s%s %dms\n",
				green,
				file_path,
				reset,
				elapsed,
			)
		} else {
			fmt.Printf(
				"%sExpected\n%s%s\n",
				red,
				strings.Join(expected_results, "\n"),
				reset,
			)
			fmt.Printf(
				"%sReceived\n%s%s\n",
				red,
				result,
				reset,
			)
			fmt.Printf("%sFAIL %s%s %dms\n",
				red,
				file_path,
				reset,
				elapsed,
			)
		}

	}
}

func seedDb(conn *pgx.Conn, dir string) error {

	var builder strings.Builder

	err := filepath.WalkDir(dir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if !d.IsDir() && strings.HasSuffix(path, ".sql") {
			content, err := os.ReadFile(path)
			if err != nil {
				return err
			}
			builder.Write(content)
			builder.WriteString("\n")
		}

		return nil
	})
	if err != nil {
		return err
	}

	_, err = conn.Exec(context.Background(),
		builder.String(),
	)
	if err != nil {
		return err
	}

	return nil
}

func generateRandomString(nBytes int) (string, error) {
	b := make([]byte, nBytes)
	_, err := rand.Read(b)
	if err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}
