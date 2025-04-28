#!/bin/bash

# === FUNCTIONS ===
print_help() {
    echo "Usage: $0 [options] <search_string> <filename>"
    echo "Options:"
    echo "  -n    Show line numbers"
    echo "  -v    Invert match (show lines that do NOT match)"
    echo "  --help  Show this help message"
    exit 0
}

# === ARGUMENT HANDLING ===

SHOW_LINE_NUMBERS=false
INVERT_MATCH=false

# Parse options using getopts
while getopts ":nv-:" opt; do
    case "$opt" in
        n) SHOW_LINE_NUMBERS=true ;;
        v) INVERT_MATCH=true ;;
        -)
            case "$OPTARG" in
                help) print_help ;;
                *) echo "Unknown option: --$OPTARG" ; exit 1 ;;
            esac
            ;;
        \?) echo "Unknown option: -$OPTARG" ; exit 1 ;;
    esac
done

# Shift processed options
shift $((OPTIND-1))

# Now $1 = search string, $2 = filename
SEARCH="$1"
FILE="$2"

# === VALIDATION ===
if [[ -z "$SEARCH" || -z "$FILE" ]]; then
    echo "Error: Missing search string or filename."
    echo "Use --help for usage information."
    exit 1
fi

if [[ ! -f "$FILE" ]]; then
    echo "Error: File '$FILE' not found."
    exit 1
fi

# === CORE LOGIC ===

# Build grep options
GREP_OPTIONS="-i"  # case-insensitive
if $INVERT_MATCH; then
    GREP_OPTIONS="$GREP_OPTIONS -v"
fi

# Read file line-by-line
LINE_NUM=0
while IFS= read -r line; do
    LINE_NUM=$((LINE_NUM+1))
    echo "$line" | grep $GREP_OPTIONS -q -- "$SEARCH"
    MATCH=$?

    if [[ $MATCH -eq 0 ]]; then
        if $SHOW_LINE_NUMBERS; then
            echo "${LINE_NUM}:$line"
        else
            echo "$line"
        fi
    fi
done < "$FILE"
