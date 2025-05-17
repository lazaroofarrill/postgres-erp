#!/bin/sh
#

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    --host)
      HOST="$2"
      shift # past argument
      shift # past value
      ;;
    -f|--file)
      FILE="$2"
      shift # past argument
      shift # past value
      ;;
    *)
      echo "Unknown option: $1"
      shift
      ;;
  esac
done

if [[ -z "$HOST" ]]; then
  echo "Error: --host is required"
  exit 1
fi

if [[ -z "$FILE" ]]; then
  echo "Error: --file is required"
  exit 1
fi


EXPECT=$(cat "$FILE" | grep -iE  '^-- expect:' | sed -E 's/^-- *expect: *//I')

if [[ -z "$EXPECT" ]]; then
  echo "No -- expect found."
  exit 1
fi

OUTPUT=$(psql "$HOST" -f  "$FILE" 2>&1)

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [[ "$OUTPUT" == *"$EXPECT"* ]]; then
  echo -e "${GREEN} PASS ${FILE} ${NC}"
else
  echo -e "${RED} FAIL ${FILE} ${NC}\n"
  echo -e "${GREEN}expected: ${EXPECT} ${NC}"
  echo -e "${RED}received: ${OUTPUT} ${NC}"
fi
