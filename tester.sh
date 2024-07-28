#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Counter for failed tests and string to hold failed test numbers
FAILED_TESTS=0
FAILED_TEST_NUMBERS_FILE=$(mktemp)

# JSON result file
JSON_RESULT_FILE="test_results.json"

echo -e "${PURPLE}
 _____    ______  _______  ______     ______  _______  ______   _    _   ______ _______  _    _   ______   ______  ______    1
| | \ \  | |  | |   | |   | |  | |   / |        | |   | |  | \ | |  | | | |       | |   | |  | | | |  | \ | |     / |
| |  | | | |__| |   | |   | |__| |   '------.   | |   | |__| | | |  | | | |       | |   | |  | | | |__| | | |---- '------.
|_|_/_/  |_|  |_|   |_|   |_|  |_|    ____|_/   |_|   |_|  \_\ \_|__|_| |_|____   |_|   \_|__|_| |_|  \_\ |_|____  ____|_/

 _   _   _   ______ _______   2   ______   ______   ______  _____  ______   ______    2024
| | | | | | | |       | |        / |      | |  | \ | |  | \  | |  | |  \ \ | | ____
| | | | | | | |----   | |        '------. | |__|_/ | |__| |  | |  | |  | | | |  | |
|_|_|_|_|_/ |_|____   |_|         ____|_/ |_|      |_|  \_\ _|_|_ |_|  |_| |_|__|_

${NC}"

# Initialize the JSON result file
echo "{" > "$JSON_RESULT_FILE"

# Function to run a single test
run_test() {
    local inFile=$1
    local outFileDir=$2
    local failedTestsFile=$3
    local failedTestNumbersFile=$4
    local jsonFile=$5

    local testNumber=$(basename "$inFile" .in)
    local resultFile="${outFileDir}/${testNumber}.result"
    local expectedFile="${outFileDir}/${testNumber}.out"
    local valgrindLogFile="${inFile}.valgrind_log"

    echo -e "${BLUE}Running test $testNumber >>>${NC}"

    # Normalize line endings and trim trailing whitespace for the input file, result file, and the expected file
    dos2unix "$inFile"
    dos2unix "$expectedFile"
    sed -i 's/[ \t]*$//' "$inFile"
    sed -i 's/[ \t]*$//' "$expectedFile"

    # Run the test simulation and output results to a file, recording the time taken
    start_time=$(date +%s%N)
    ./FileTester < "$inFile" > "$resultFile"
    end_time=$(date +%s%N)
    elapsed=$(( (end_time - start_time) / 1000000 ))

    echo "Test $testNumber execution time: ${elapsed}ms"

    # Compare the generated result with the expected result
    if diff "$expectedFile" "$resultFile" > /dev/null; then
        echo -e "Test Simulation: ${GREEN}pass${NC},"
    else
        echo -e "Test Simulation: ${RED}fail${NC}"
        echo 1 >> "$failedTestsFile"
        echo "$testNumber" >> "$failedTestNumbersFile"
    fi

    # Check if the test execution time is within the acceptable limit
    if [ $elapsed -le 8000 ]; then
        echo -e "Time Complexity (≤ 8 sec): ${GREEN}pass${NC},"
    else
        echo -e "Time Complexity (≤ 8 sec): ${RED}fail${NC}"
        echo 1 >> "$failedTestsFile"
        echo "$testNumber" >> "$failedTestNumbersFile"
    fi

    # Run Valgrind to check for memory leaks
    valgrind --log-file="$valgrindLogFile" --leak-check=full ./FileTester < "$inFile" > /dev/null 2>&1

    # Check Valgrind's output for the absence of memory leaks
    if grep -q "ERROR SUMMARY: 0 errors" "$valgrindLogFile"; then
        echo -e "Memory Leak: ${GREEN}pass${NC}\n"
    else
        echo -e "Memory Leak: ${RED}fail${NC}\n"
        cat "$valgrindLogFile"
        echo 1 >> "$failedTestsFile"
        echo "$testNumber" >> "$failedTestNumbersFile"
    fi

    # Remove Valgrind log file after checking
    rm -f "$valgrindLogFile"

    # Append the execution time to the temporary JSON result file
    echo "\"${testNumber}\": ${elapsed}," >> "$jsonFile"
}

export -f run_test
export GREEN RED BLUE NC

# Temporary files for storing results
FAILED_TESTS_FILE=$(mktemp)
JSON_TEMP_FILE=$(mktemp)

# Main loop for running tests in parallel
find fileTests/inFiles -name "*.in" ! -path "fileTests/inFiles/fleet/*" | parallel -j $(nproc) run_test {} fileTests/outFiles "$FAILED_TESTS_FILE" "$FAILED_TEST_NUMBERS_FILE" "$JSON_TEMP_FILE"
find fileTests/inFiles/fleet -name "*.in" | parallel -j $(nproc) run_test {} fileTests/outFiles/fleet "$FAILED_TESTS_FILE" "$FAILED_TEST_NUMBERS_FILE" "$JSON_TEMP_FILE"

# Aggregate results
FAILED_TESTS=$(wc -l < "$FAILED_TESTS_FILE")
FAILED_TEST_NUMBERS=$(cat "$FAILED_TEST_NUMBERS_FILE")

# Remove the trailing comma from the temporary JSON result file
sed -i '$ s/,$//' "$JSON_TEMP_FILE"

# Append the temporary JSON results to the final JSON result file
cat "$JSON_TEMP_FILE" >> "$JSON_RESULT_FILE"
echo "}" >> "$JSON_RESULT_FILE"

# Clean up temporary files
rm -f "$FAILED_TESTS_FILE" "$FAILED_TEST_NUMBERS_FILE" "$JSON_TEMP_FILE"

# Final output, showing whether all tests passed or some failed
if [ "$FAILED_TESTS" -eq 0 ]; then
    echo -e "${GREEN}

██     ██  ██████  ███    ██  ██████  ██         ██   ██         ███████ ██      ██ ███    ███  █████  ███    ██
██     ██ ██    ██ ████   ██ ██       ██          ██ ██          ██      ██      ██ ████  ████ ██   ██ ████   ██
██  █  ██ ██    ██ ██ ██  ██ ██   ███ ██           ███           ███████ ██      ██ ██ ████ ██ ███████ ██ ██  ██
██ ███ ██ ██    ██ ██  ██ ██ ██    ██ ██          ██ ██               ██ ██      ██ ██  ██  ██ ██   ██ ██  ██ ██
 ███ ███   ██████  ██   ████  ██████  ██         ██   ██         ███████ ███████ ██ ██      ██ ██   ██ ██   ████

${NC}"
else
    echo -e "${RED}
 _____    ______  _______  ______     ______  _______  ______   _    _   ______ _______  _    _   ______   ______  ______    1
| | \ \  | |  | |   | |   | |  | |   / |        | |   | |  | \ | |  | | | |       | |   | |  | | | |  | \ | |     / |
| |  | | | |__| |   | |   | |__| |   '------.   | |   | |__| | | |  | | | |       | |   | |  | | | |__| | | |---- '------.
|_|_/_/  |_|  |_|   |_|   |_|  |_|    ____|_/   |_|   |_|  \_\ \_|__|_| |_|____   |_|   \_|__|_| |_|  \_\ |_|____  ____|_/

 _   _   _   ______ _______   2   ______   ______   ______  _____  ______   ______    2024
| | | | | | | |       | |        / |      | |  | \ | |  | \  | |  | |  \ \ | | ____
| | | | | | | |----   | |        '------. | |__|_/ | |__| |  | |  | |  | | | |  | |
|_|_|_|_|_/ |_|____   |_|         ____|_/ |_|      |_|  \_\ _|_|_ |_|  |_| |_|__|_
    "
    echo -e "\n${RED}Failed $FAILED_TESTS tests.${NC}"
    echo -e "Failed tests: \n${FAILED_TEST_NUMBERS}${NC}\n"
    echo "To see the differences for a failed test, use the diff.sh script. For example:"
    echo -e "${BLUE}./diff.sh <test_number>${NC}"
    echo "Make sure you have given execute permission to the script before using it. Run the following command to do so:"
    echo -e "${BLUE}chmod +x diff.sh${NC}"
fi
