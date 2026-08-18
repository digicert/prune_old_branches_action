#!/bin/bash

git config --global --add safe.directory /github/workspace

# Reject anything but plain integers before they hit arithmetic contexts (prevents injection).
for arg in "$1" "$2"; do
    if ! [[ "$arg" =~ ^[0-9]+$ ]]; then
        echo "Error: numDays and numTags must be non-negative integers, got: $arg" >&2
        exit 1
    fi
done

export IFS=$'\n'

SECONDS=$((86400 * $1))
TIME=$(($(date +%s) - $SECONDS))

OUT=""
FAILED=0

# Optional 4th argument: dry-run
DRY_RUN="${4:-true}"

# Returns non-zero if a real deletion was attempted and failed, so callers can skip recording it.
delete_branch() {
    if [[ "${DRY_RUN,,}" == "false" ]]; then
        if ! git push origin --delete "$1"; then
            echo "Error: failed to delete branch: $1" >&2
            return 1
        fi
    else
        echo "[DRY-RUN] Would delete branch: $1"
    fi
}

delete_tag() {
    if [[ "${DRY_RUN,,}" == "false" ]]; then
        if ! git push origin --delete "refs/tags/$1"; then
            echo "Error: failed to delete tag: $1" >&2
            return 1
        fi
    else
        echo "[DRY-RUN] Would delete tag: $1"
    fi
}

# Loop for deleting old branches
for i in $(git for-each-ref refs/remotes/origin --sort=committerdate \
    --format='%(HEAD)%(color:yellow)%(refname:short)%(color:reset) %(color:green)%(committerdate:raw)%(color:reset)')
do
    export IFS=$' '
    elements=($i)

    if [ "$TIME" -gt "${elements[1]}" ]
    then
        export IFS="/"
        inner_elements=(${elements[0]})

        if [[ ${inner_elements[1]} != "KEEP"* ]]
        then
            branch="${inner_elements[1]}"

            if delete_branch "$branch"; then
                OUT="${OUT}, ${branch}"
            else
                FAILED=$((FAILED + 1))
            fi
        fi
    fi
done

export IFS=$'\n'

# Loop for deleting old tags
TO_SKIP=$2
SKIP_PREFIX="${3:-}"

for n in $(git tag --sort=-creatordate)
do
    if [ "$TO_SKIP" -gt 0 ]
    then
        TO_SKIP=$((TO_SKIP - 1))
    else
        # Empty SKIP_PREFIX means no filtering
        if [[ -z "$SKIP_PREFIX" || "$n" != "$SKIP_PREFIX"* ]]
        then
            if delete_tag "$n"; then
                OUT="${OUT}, ${n}"
            else
                FAILED=$((FAILED + 1))
            fi
        else
            echo "skip deleting $n"
        fi
    fi
done

echo "${OUT}"
echo "::set-output name=branches::$OUT"

if [ "$FAILED" -gt 0 ]; then
    echo "Error: $FAILED deletion(s) failed" >&2
    exit 1
fi