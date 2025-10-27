#!/bin/bash
# ============================================================
# Run pl0_scanner on all .pl0 files in scanner/examples
# and count + locate token 32 ("t_error") occurrences
# ============================================================

set -e  # stop on fatal errors

# Adjust paths relative to this script's location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

SCANNER_BIN="$PROJECT_ROOT/cmake-build-debug/pl0_scanner"
SRC_DIR="$SCRIPT_DIR/examples"
OUTPUT_DIR="$SRC_DIR/output"
BUILD_DIR="$PROJECT_ROOT/cmake-build-debug"

if [ ! -x "$SCANNER_BIN" ]; then
    echo "❌ Scanner binary not found or not executable: $SCANNER_BIN"
    echo "➡️  Build the project first in CLion or run 'make build_scanner'."
    exit 1
fi

if [ ! -d "$SRC_DIR" ]; then
    echo "❌ Examples directory not found: $SRC_DIR"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "🔍 Testing all .pl0 files in: $SRC_DIR"
echo "📁 Output directory: $OUTPUT_DIR"
echo "----------------------------------------"

error_total=0
file_count=0

cd "$BUILD_DIR"  # Run from build directory

# Clean up any existing .pl0 files in build directory from previous runs
echo "🧹 Cleaning up previous test files..."
rm -f "$BUILD_DIR"/*.pl0

for pl0_file in "$SRC_DIR"/*.pl0; do
    [ -e "$pl0_file" ] || { echo "No .pl0 files found."; exit 0; }

    file_count=$((file_count + 1))
    base=$(basename "$pl0_file" .pl0)

    echo "▶ Running on $base.pl0..."

    # Copy the file to build directory
    cp "$pl0_file" "$BUILD_DIR/${base}.pl0"

    # Run the scanner with the filename (without .pl0 extension)
    "$SCANNER_BIN" "$base" > /dev/null 2>&1

    # Check the output file
    output_file="$BUILD_DIR/${base}.txt"

    if [ ! -f "$output_file" ]; then
        echo "❌  No output file generated for $base"
        continue
    fi

    # Move the output file to the output directory
    mv "$output_file" "$OUTPUT_DIR/${base}.txt"

    # Clean up the input file from build directory
    rm -f "$BUILD_DIR/${base}.pl0"

    # Find all line numbers containing token 32
    mapfile -t error_lines < <(grep -nE '(^|[^0-9])32([^0-9]|$)' "$OUTPUT_DIR/${base}.txt" 2>/dev/null || true)
    count=${#error_lines[@]}

    if [ "$count" -gt 0 ]; then
        echo "❌  $count error token(s) found in $base"
        echo "    → Line numbers:"
        for line in "${error_lines[@]}"; do
            echo "      ${line%%:*}"
        done
        error_total=$((error_total + count))
    else
        echo "✅  No errors in $base"
    fi
done

# Final cleanup (in case any files were missed)
rm -f "$BUILD_DIR"/*.pl0

echo "----------------------------------------"
if [ "$file_count" -eq 0 ]; then
    echo "⚠️  No .pl0 files processed."
elif [ "$error_total" -gt 0 ]; then
    echo "🚨  Total of $error_total error token(s) found across $file_count file(s)."
    echo "📁 Output files saved to: $OUTPUT_DIR"
else
    echo "🎉  All $file_count file(s) scanned successfully — no errors found!"
    echo "📁 Output files saved to: $OUTPUT_DIR"
fi