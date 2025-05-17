# Backend Tests

This document explains how to run the backend tests for this project.

## Prerequisites

- Ensure you have a running PostgreSQL instance.
- Make sure you have `psql` installed and available in your PATH.

## Running the Tests

The backend tests are managed by the `run-test-suite.sh` script. This script will:

1.  Create a temporary template database.
2.  Seed this template database using the migrations located in `supabase/migrations/`.
3.  Execute each test file found in the `tests/` directory in parallel. Each test runs in its own database, which is a copy of the template database.
4.  Clean up by dropping the temporary template database after all tests have finished.

To run the tests, navigate to the `backend` directory and execute the following command:

```bash
./run-test-suite.sh --host <your_postgres_connection_url>
```

Replace `<your_postgres_connection_url>` with the actual connection URL for your PostgreSQL instance. For example:

```bash
./run-test-suite.sh --host postgresql://user:password@localhost:5432/mydatabase
```

**Note:** The database specified in the URL is used for administrative tasks like creating and dropping the test template database. The actual tests will run against temporary databases.

## Test Structure

- Test files are located in the `tests/` directory.
- The `seed-db.sh` script is used to set up the initial schema and data for the template database.
- The `spawn-test-worker.sh` script is responsible for creating a test-specific database from the template and running an individual test file. 

## Benchmark

On a test system, running the test suite resulted in the following performance:

```
./run-test-suite.sh --host <your_postgres_connection_url>

0.14s user 0.12s system 39% cpu 0.651 total
```

This benchmark reflects the time taken for database creation, seeding, running the tests in the `tests/` directory, and cleanup. 