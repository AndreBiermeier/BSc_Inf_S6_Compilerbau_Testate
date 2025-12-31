#!/bin/bash
# ============================================================
# Run pl0_scanner on all test PL/0 files and compare with expected output
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

SCANNER_BIN="$PROJECT_ROOT/cmake-build-debug/pl0_scanner"
TEST_DIR="$SCRIPT_DIR/test-cases"
OUTPUT_DIR="$TEST_DIR/output"
EXPECTED_DIR="$TEST_DIR/expected"
BUILD_DIR="$PROJECT_ROOT/cmake-build-debug"

if [ ! -x "$SCANNER_BIN" ]; then
    echo "❌ Scanner binary not found or not executable: $SCANNER_BIN"
    echo "➡️  Build the project first with 'make build_scanner'."
    exit 1
fi

# Create directories
mkdir -p "$TEST_DIR" "$OUTPUT_DIR" "$EXPECTED_DIR"

echo "🧪 PL/0 Scanner Test Suite"
echo "📁 Test directory: $TEST_DIR"
echo "📁 Build directory: $BUILD_DIR"
echo "----------------------------------------"

# Debug: Show what files exist
echo "📂 Test files found:"
ls "$TEST_DIR"/*.pl0 2>/dev/null || echo "   No .pl0 files found"
echo "📂 Expected files found:"
ls "$EXPECTED_DIR"/*-expected.txt 2>/dev/null || echo "   No expected files found"
echo ""

cd "$BUILD_DIR"
rm -f "$BUILD_DIR"/*.pl0

total_tests=0
passed_tests=0
failed_tests=""

# Find all test files and run them
for test_file in "$TEST_DIR"/*.pl0; do
    [ -f "$test_file" ] || { echo "No test files found"; break; }

    base=$(basename "$test_file" .pl0)
    expected_file="$EXPECTED_DIR/${base}-expected.txt"

    # Skip if no expected file exists
    if [ ! -f "$expected_file" ]; then
        echo "⚠️  Skipping $base.pl0: No expected file found at $expected_file"
        continue
    fi

    total_tests=$((total_tests + 1))
    echo "▶ Test $total_tests: $base"
    echo "   Input: $test_file"
    echo "   Expected: $expected_file"

    # Copy and run the test
    cp "$test_file" "$BUILD_DIR/${base}.pl0"
    echo "   Running: $SCANNER_BIN $base"
    "$SCANNER_BIN" "$base" > /dev/null 2>&1

    # Move output and clean up
    if [ -f "$BUILD_DIR/${base}.txt" ]; then
        mv "$BUILD_DIR/${base}.txt" "$OUTPUT_DIR/${base}.txt"
        echo "   Output generated: $OUTPUT_DIR/${base}.txt"
    else
        echo "   ❌ No output file generated at $BUILD_DIR/${base}.txt"
    fi
    rm -f "$BUILD_DIR/${base}.pl0"

    # Check if output was generated
    if [ ! -f "$OUTPUT_DIR/${base}.txt" ]; then
        echo "❌ FAILED: No output generated"
        failed_tests="$failed_tests$base (no output)"$'\n'
        echo ""
        continue
    fi

    # Compare with expected output
    if diff -q "$OUTPUT_DIR/${base}.txt" "$expected_file" > /dev/null; then
        echo "✅ PASSED"
        passed_tests=$((passed_tests + 1))
    else
        echo "❌ FAILED"
        failed_tests="$failed_tests$base"$'\n'
        echo "   Differences:"
        diff "$OUTPUT_DIR/${base}.txt" "$expected_file" || true
    fi

    echo ""
done

echo "----------------------------------------"
if [ $total_tests -eq 0 ]; then
    echo "⚠️  No tests found."
else
    echo "📊 Results: $passed_tests/$total_tests tests passed"

    if [ -z "$failed_tests" ]; then
        echo "🎉 All tests passed! Your scanner is working correctly."
    else
        echo "⚠️  Failed tests:"
        echo "$failed_tests"
        exit 1
    fi
fi