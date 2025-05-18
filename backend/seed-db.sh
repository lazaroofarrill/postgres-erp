#!/bin/sh

set -euo pipefail

trap 'echo "Error at line $LINENO: command \"$BASH_COMMAND\" exited with status $?"' ERR


while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--host)
      HOST="$2"
      shift 2
      ;;
    -d|--dir)
      DIR="$2"
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
if [[ -z "$HOST" || -z "$DIR" ]]; then
  echo "❌ Both --host and --dir must be provided."
  echo "Usage: $0 --host <postgres_url> --dir <sql_directory>"
  exit 1
fi

if [[ ! -d "$DIR" ]]; then
  echo "❌ Directory not found: $DIR"
  exit 1
fi

# Execute
echo "🔁 Running SQL from directory: $DIR on $HOST"
cat "$DIR"/*.sql | psql "$HOST" -v ON_ERROR_STOP=1
echo "✅ Done."
