#!/bin/bash

THREAD_LIST=$1
OUTPUT_DIR=$2

if [[ -z "$THREAD_LIST" ]]; then
    printf "Usage: $0 <thread list> [<output dir>]\n"
    exit 1
fi

if [[ ! -e "$THREAD_LIST" ]]; then
    printf "File does not exist: $THREAD_LIST\n"
    exit 1
fi

if [[ -z "$OUTPUT_DIR" ]]; then
    OUTPUT_DIR='.'
fi

THREAD_REGEX='^http://boards\.4chan\.org/([[:alnum:]]+)/thread/([[:digit:]]+)$'
ERROR_REGEX='^Thread does not exist: /([[:alnum:]]+)/([[:digit:]]+)$'

printf "$(sort $THREAD_LIST | uniq)\n" > "$THREAD_LIST"

errors=

while read url; do
    if [[ "$url" =~ $THREAD_REGEX ]]; then
        board="${BASH_REMATCH[1]}"
        thread_op="${BASH_REMATCH[2]}"
        output=$(pull-4chan-thread.pl $board $thread_op $OUTPUT_DIR)

        if [[ -n "$output" ]]; then
            errors+=("$output")
        fi
    fi
done < "$THREAD_LIST"

dead=''

for error in "${errors[@]}"; do
    if [[ "$error" =~ $ERROR_REGEX ]]; then
        board="${BASH_REMATCH[1]}"
        thread_op="${BASH_REMATCH[2]}"
        dead="${dead}http://boards.4chan.org/$board/thread/$thread_op\n"
    fi
done

if [[ -n "$dead" ]]; then
    printf "$(comm -23 <(sort $THREAD_LIST | uniq) <(printf $dead | sort | uniq))" > "$THREAD_LIST"
fi

exit 0
