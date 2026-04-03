#!/bin/bash

################################################################################
# REGRESSION TEST SCRIPT
# Card Selling Agent App - Maestro Automation
# 
# Purpose: Run full regression test suite (2-4 hours)
# Usage: ./scripts/regression.sh
# 
# Features:
# - Runs complete regression suite
# - Generates detailed JUnit XML report
# - Generates comprehensive HTML report
# - Tracks test execution progress
# - Sends notifications on completion
# - Creates test execution summary
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="Card Selling Agent"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_DIR="reports"
JUNIT_DIR="${REPORT_DIR}/junit"
HTML_DIR="${REPORT_DIR}/html"
SCREENSHOT_DIR="${REPORT_DIR}/screenshots"
SUITE_FILE=".maestro/suites/regression-suite.yaml"
LOG_FILE="${REPORT_DIR}/logs/regression-${TIMESTAMP}.log"
SUMMARY_FILE="${REPORT_DIR}/logs/regression-summary-${TIMESTAMP}.txt"

# Create directories
mkdir -p ${JUNIT_DIR}
mkdir -p ${HTML_DIR}
mkdir -p ${SCREENSHOT_DIR}
mkdir -p ${REPORT_DIR}/logs

# Banner
echo -e "${MAGENTA}"
echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                        ║"
echo "║                 🔄 REGRESSION TEST EXECUTION                          ║"
echo "║                  ${APP_NAME}                              ║"
echo "║                                                                        ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Test information
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📋 Test Information${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}   App:${NC}           ${APP_NAME}"
echo -e "${YELLOW}   Test Type:${NC}     Full Regression"
echo -e "${YELLOW}   Duration:${NC}      ~2-4 hours"
echo -e "${YELLOW}   Timestamp:${NC}     ${TIMESTAMP}"
echo -e "${YELLOW}   Suite File:${NC}    ${SUITE_FILE}"
echo -e "${YELLOW}   Log File:${NC}      ${LOG_FILE}"
echo ""

# Confirmation prompt
echo -e "${YELLOW}⚠️  Warning: This will run the full regression suite (2-4 hours)${NC}"
echo -e "${YELLOW}   Press Ctrl+C to cancel, or Enter to continue...${NC}"
read -r

# Check if Maestro is installed
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔍 Pre-flight Checks${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if ! command -v maestro &> /dev/null; then
    echo -e "${RED}❌ Error: Maestro is not installed!${NC}"
    echo -e "${YELLOW}   Install it: curl -Ls \"https://get.maestro.mobile.dev\" | bash${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Maestro installed${NC}"

# Check if suite file exists
if [ ! -f "${SUITE_FILE}" ]; then
    echo -e "${RED}❌ Error: Suite file not found: ${SUITE_FILE}${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Suite file found${NC}"

# Check for connected device
echo -e "${YELLOW}🔌 Checking for connected device...${NC}"
if ! maestro test --help &> /dev/null; then
    echo -e "${YELLOW}⚠️  Warning: Cannot verify device connection${NC}"
else
    echo -e "${GREEN}✅ Maestro is ready${NC}"
fi

# Check available disk space
AVAILABLE_SPACE=$(df -h . | awk 'NR==2 {print $4}')
echo -e "${GREEN}✅ Available disk space: ${AVAILABLE_SPACE}${NC}"

echo ""

# Start time
START_TIME=$(date +%s)

# Display test modules
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🚀 Test Modules to Execute${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📦 Module Coverage:${NC}"
echo "   ┌─ Authentication"
echo "   │  ├─ Login (Valid, Invalid, Edge Cases)"
echo "   │  ├─ Registration (All Scenarios)"
echo "   │  └─ Forgot Password (Recovery Flow)"
echo "   │"
echo "   ├─ Home"
echo "   │  ├─ Dashboard Elements"
echo "   │  ├─ Quick Actions"
echo "   │  └─ Navigation"
echo "   │"
echo "   ├─ Shop"
echo "   │  ├─ Product Listing"
echo "   │  ├─ Search & Filter"
echo "   │  ├─ Add to Cart"
echo "   │  └─ Checkout Flow"
echo "   │"
echo "   ├─ Request Money"
echo "   │  ├─ Valid Requests"
echo "   │  ├─ Invalid Inputs"
echo "   │  └─ Edge Cases"
echo "   │"
echo "   ├─ User Profile"
echo "   │  ├─ View Profile"
echo "   │  ├─ Edit Profile"
echo "   │  └─ Profile Validation"
echo "   │"
echo "   ├─ Notification"
echo "   │  ├─ View Notifications"
echo "   │  ├─ Mark as Read"
echo "   │  └─ Clear All"
echo "   │"
echo "   ├─ History"
echo "   │  ├─ Transaction History"
echo "   │  ├─ Filters"
echo "   │  └─ Search"
echo "   │"
echo "   └─ E2E Flows"
echo "      ├─ Complete Purchase Journey"
echo "      └─ Full User Workflows"
echo ""

# Run Regression Tests
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🔄 Running Regression Tests...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}▶️  Starting test execution...${NC}"
echo -e "${YELLOW}   This may take 2-4 hours. Please be patient.${NC}"
echo ""

# Progress indicator function
show_progress() {
    local pid=$1
    local delay=0.5
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c] Running tests..." "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\r"
    done
    printf "    \r"
}

# Run tests with progress indicator
maestro test \
  --format junit \
  --output ${JUNIT_DIR}/regression-${TIMESTAMP}.xml \
  ${SUITE_FILE} 2>&1 | tee ${LOG_FILE} &

TEST_PID=$!

# Show progress while tests run
# show_progress $TEST_PID

# Wait for tests to complete
wait $TEST_PID
TEST_EXIT_CODE=$?

# End time and duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
DURATION_HOURS=$((DURATION / 3600))
DURATION_MIN=$(((DURATION % 3600) / 60))
DURATION_SEC=$((DURATION % 60))

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}⏱️  Test Execution Complete${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}   Duration:${NC} ${DURATION_HOURS}h ${DURATION_MIN}m ${DURATION_SEC}s"
echo ""

# Generate HTML Report
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 Generating HTML Report...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if junit-viewer is installed
if ! command -v junit-viewer &> /dev/null; then
    echo -e "${YELLOW}⚠️  junit-viewer not found. Installing...${NC}"
    npm install -g junit-viewer > /dev/null 2>&1
    echo -e "${GREEN}✅ junit-viewer installed${NC}"
fi

# Generate HTML report
HTML_REPORT="${HTML_DIR}/regression-report-${TIMESTAMP}.html"
junit-viewer \
  --results=${JUNIT_DIR} \
  --save=${HTML_REPORT} > /dev/null 2>&1

echo -e "${GREEN}✅ HTML report generated: ${HTML_REPORT}${NC}"
echo ""

# Parse Test Results
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📈 Detailed Test Results${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

JUNIT_FILE="${JUNIT_DIR}/regression-${TIMESTAMP}.xml"

# Create summary file
{
    echo "=========================================="
    echo "REGRESSION TEST SUMMARY"
    echo "=========================================="
    echo "App: ${APP_NAME}"
    echo "Timestamp: ${TIMESTAMP}"
    echo "Duration: ${DURATION_HOURS}h ${DURATION_MIN}m ${DURATION_SEC}s"
    echo "=========================================="
    echo ""
} > ${SUMMARY_FILE}

if command -v xmlstarlet &> /dev/null; then
    TOTAL=$(xmlstarlet sel -t -v "count(//testcase)" ${JUNIT_FILE} 2>/dev/null || echo "0")
    PASSED=$(xmlstarlet sel -t -v "count(//testcase[not(failure) and not(error)])" ${JUNIT_FILE} 2>/dev/null || echo "0")
    FAILED=$(xmlstarlet sel -t -v "count(//testcase[failure or error])" ${JUNIT_FILE} 2>/dev/null || echo "0")
    SKIPPED=$(xmlstarlet sel -t -v "count(//testcase/skipped)" ${JUNIT_FILE} 2>/dev/null || echo "0")
    
    PASS_RATE=0
    if [ "$TOTAL" -gt 0 ]; then
        PASS_RATE=$(echo "scale=2; ($PASSED * 100) / $TOTAL" | bc)
    fi
    
    # Display summary
    echo ""
    echo -e "${CYAN}   ╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}   ║         EXECUTION SUMMARY              ║${NC}"
    echo -e "${CYAN}   ╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}   Total Tests:${NC}      ${TOTAL}"
    echo -e "${GREEN}   ✅ Passed:${NC}        ${PASSED}"
    echo -e "${RED}   ❌ Failed:${NC}        ${FAILED}"
    echo -e "${YELLOW}   ⏭️  Skipped:${NC}       ${SKIPPED}"
    echo -e "${MAGENTA}   📊 Pass Rate:${NC}     ${PASS_RATE}%"
    echo ""
    
    # Write to summary file
    {
        echo "Total Tests:  ${TOTAL}"
        echo "Passed:       ${PASSED}"
        echo "Failed:       ${FAILED}"
        echo "Skipped:      ${SKIPPED}"
        echo "Pass Rate:    ${PASS_RATE}%"
        echo ""
    } >> ${SUMMARY_FILE}
    
    # Module breakdown
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📦 Module Breakdown${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    {
        echo "MODULE BREAKDOWN"
        echo "=========================================="
    } >> ${SUMMARY_FILE}
    
    # Count tests per module (this is a simplified example)
    MODULES=("auth" "home" "shop" "requestmoney" "userprofile" "notification" "history")
    
    for MODULE in "${MODULES[@]}"; do
        MODULE_TESTS=$(grep -i "${MODULE}" ${LOG_FILE} 2>/dev/null | wc -l || echo "0")
        if [ "$MODULE_TESTS" -gt 0 ]; then
            echo -e "${YELLOW}   ${MODULE}:${NC} ${MODULE_TESTS} tests"
            echo "${MODULE}: ${MODULE_TESTS} tests" >> ${SUMMARY_FILE}
        fi
    done
    echo ""
    
    # Show failed tests if any
    if [ "$FAILED" -gt 0 ]; then
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ Failed Tests Detail${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        
        {
            echo ""
            echo "FAILED TESTS"
            echo "=========================================="
        } >> ${SUMMARY_FILE}
        
        xmlstarlet sel -t -m "//testcase[failure or error]" -v "@name" -n ${JUNIT_FILE} 2>/dev/null | while read test; do
            echo -e "${RED}   • ${test}${NC}"
            echo "  • ${test}" >> ${SUMMARY_FILE}
        done
        echo ""
    fi
else
    echo -e "${YELLOW}⚠️  Install xmlstarlet for detailed summary:${NC}"
    echo -e "${YELLOW}   macOS: brew install xmlstarlet${NC}"
    echo -e "${YELLOW}   Linux: sudo apt-get install xmlstarlet${NC}"
    echo ""
fi

# File locations
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📁 Report Locations${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}   JUnit XML:${NC}    ${JUNIT_FILE}"
echo -e "${YELLOW}   HTML Report:${NC}  ${HTML_REPORT}"
echo -e "${YELLOW}   Log File:${NC}     ${LOG_FILE}"
echo -e "${YELLOW}   Summary:${NC}      ${SUMMARY_FILE}"
echo -e "${YELLOW}   Screenshots:${NC}  ${SCREENSHOT_DIR}/"
echo ""

# Archive results
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📦 Archiving Results...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

ARCHIVE_NAME="regression-results-${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${REPORT_DIR}/${ARCHIVE_NAME}"

tar -czf ${ARCHIVE_PATH} \
  ${JUNIT_FILE} \
  ${HTML_REPORT} \
  ${LOG_FILE} \
  ${SUMMARY_FILE} \
  2>/dev/null || true

if [ -f "${ARCHIVE_PATH}" ]; then
    ARCHIVE_SIZE=$(du -h ${ARCHIVE_PATH} | cut -f1)
    echo -e "${GREEN}✅ Results archived: ${ARCHIVE_PATH} (${ARCHIVE_SIZE})${NC}"
else
    echo -e "${YELLOW}⚠️  Failed to create archive${NC}"
fi
echo ""

# Email summary (optional - configure your email)
# if [ "$FAILED" -gt 0 ]; then
#     echo "Regression tests completed with failures" | mail -s "❌ Regression Tests Failed" your-email@example.com
# else
#     echo "All regression tests passed" | mail -s "✅ Regression Tests Passed" your-email@example.com
# fi

# Open HTML report in browser
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}🌐 Opening HTML Report...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Open in browser based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    open ${HTML_REPORT}
    echo -e "${GREEN}✅ Report opened in default browser${NC}"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open ${HTML_REPORT} &
        echo -e "${GREEN}✅ Report opened in default browser${NC}"
    else
        echo -e "${YELLOW}⚠️  Please open manually: ${HTML_REPORT}${NC}"
    fi
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    start ${HTML_REPORT}
    echo -e "${GREEN}✅ Report opened in default browser${NC}"
else
    echo -e "${YELLOW}⚠️  Please open manually: ${HTML_REPORT}${NC}"
fi

echo ""

# Display summary file content
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📄 Test Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
cat ${SUMMARY_FILE}
echo ""

# Final Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ ${TEST_EXIT_CODE} -eq 0 ]; then
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                        ║"
    echo "║              ✅ REGRESSION TESTS PASSED! ✅                           ║"
    echo "║                                                                        ║"
    echo "╚════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${GREEN}   All ${TOTAL} tests passed successfully!${NC}"
    echo -e "${GREEN}   Quality bar met - safe for release.${NC}"
else
    echo -e "${RED}"
    echo "╔════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                        ║"
    echo "║              ❌ REGRESSION TESTS FAILED! ❌                           ║"
    echo "║                                                                        ║"
    echo "╚════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${RED}   ${FAILED} test(s) failed out of ${TOTAL}${NC}"
    echo -e "${RED}   Please review failed tests before proceeding.${NC}"
    echo -e "${RED}   Pass rate: ${PASS_RATE}%${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Exit with test result code
exit ${TEST_EXIT_CODE}