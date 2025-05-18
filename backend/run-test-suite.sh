#!/bin/sh
#

cd $(dirname $0)

set -euo pipefail

trap 'echo "Error at line $LINENO: command \"$BASH_COMMAND\" exited with status $?"' ERR

alias "date_in_ms=date +%s%3N"
start_time=$(date_in_ms)

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--host)
      HOST="$2"
      shift 2
      ;;
    *)
      echo "❌ Unknown option: $1"
      echo "Usage: $0 --host <postgres_url> --dir <sql_directory>"
      exit 1
      ;;
  esac
done

# Validate inputs
if [[ -z "$HOST"  ]]; then
  echo "❌ Both --host must be provided."
  echo "Usage: $0 --host <postgres_url>"
  exit 1
fi

TEMPLATE_DB_NAME="test_template_$(uuidgen | sed 's/-/_/g')"

psql "$HOST" -c "CREATE DATABASE $TEMPLATE_DB_NAME;" >> /dev/null

TEMPLATE_DB_CONN=$(echo "$HOST" | sed -E "s|(postgresql://[^/]+/)[^?]+|\1${TEMPLATE_DB_NAME}|")

./seed-db.sh --host "$TEMPLATE_DB_CONN" --dir ./supabase/migrations >> /dev/null

setup_end=$(date_in_ms)

setup_duration=$((setup_end - start_time))

echo "Test setup duration ${setup_duration}ms"

for test_file in ./tests/*;do
  if [[ -f "$test_file" ]]; then
    ./spawn-test-worker.sh --host "$HOST" \
     --template "$TEMPLATE_DB_NAME" \
     --file "$test_file" &
  fi
done

wait

psql "$HOST" -c "DROP DATABASE $TEMPLATE_DB_NAME;" >> /dev/null

end_time=$(date_in_ms)

total_duration=$((end_time - start_time))

echo "Total testing time: ${total_duration}ms"
