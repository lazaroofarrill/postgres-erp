#!/bin/sh

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--host)
      HOST="$2"
      shift 2
      ;;
    --file)
      TEST_FILE="$2"
      shift 2
      ;;
    --template)
      TEMPLATE_DB_NAME="$2"
      shift 2
      ;;
    *)
      echo "❌ Unknown option: $1"
      echo "Usage: $0 --host <postgres_url> --dir <sql_directory>"
      exit 1
      ;;
  esac
done

TEST_CASE_DB_NAME="test_case_$(uuidgen | sed 's/-/_/g')"
psql "$HOST" -c "CREATE DATABASE $TEST_CASE_DB_NAME TEMPLATE $TEMPLATE_DB_NAME;" >> /dev/null
# echo "processing: $test_file"

TEST_CASE_DB_CONN=$(echo "$HOST" | sed -E "s|(postgresql://[^/]+/)[^?]+|\1${TEST_CASE_DB_NAME}|")
./run-db-test.sh --host "$TEST_CASE_DB_CONN" --file "$TEST_FILE"

psql "$HOST" -c "DROP DATABASE $TEST_CASE_DB_NAME;" >> /dev/null
