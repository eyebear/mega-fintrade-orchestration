#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/validate-config.sh"

print_section() {
  echo ""
  echo "============================================================"
  echo "$1"
  echo "============================================================"
}

pass() {
  echo "PASS: $1"
}

fail() {
  echo "ERROR: $1"
  exit 1
}

check_command() {
  local command_name="$1"
  local display_name="$2"

  if command -v "${command_name}" >/dev/null 2>&1; then
    pass "${display_name} found: $(command -v "${command_name}")"
  else
    fail "${display_name} is not installed or not available in PATH."
  fi
}

check_directory() {
  local name="$1"
  local path="$2"

  if [ -d "${path}" ]; then
    pass "${name} directory exists: ${path}"
  else
    fail "${name} directory does not exist: ${path}"
  fi
}

check_url() {
  local name="$1"
  local url="$2"

  if curl --silent --fail --max-time 5 "${url}" >/dev/null 2>&1; then
    pass "${name} is reachable: ${url}"
  else
    fail "${name} is not reachable: ${url}"
  fi
}

print_section "Mega Fintrade prerequisite check"

echo "This script checks whether the local machine is ready to run the Mega Fintrade orchestration pipeline."

print_section "Checking required repository folders"

check_directory "Python quant engine" "${QUANT_ENGINE_DIR}"
check_directory "C++ market engine" "${MARKET_ENGINE_CPP_DIR}"
check_directory "Java backend" "${BACKEND_JAVA_DIR}"
check_directory ".NET risk monitor" "${RISK_MONITOR_DOTNET_DIR}"

print_section "Checking required command line tools"

check_command "python3" "Python 3"
check_command "cmake" "CMake"
check_command "docker" "Docker"
check_command "curl" "curl"

print_section "Checking Java backend service"

JAVA_BACKEND_HEALTH_URL="${JAVA_BACKEND_URL}${JAVA_BACKEND_HEALTH_ENDPOINT}"
check_url "Java backend health endpoint" "${JAVA_BACKEND_HEALTH_URL}"

print_section "Checking .NET risk monitor service"

RISK_MONITOR_HEALTH_URL="${RISK_MONITOR_URL}${RISK_MONITOR_HEALTH_ENDPOINT}"
check_url ".NET risk monitor health endpoint" "${RISK_MONITOR_HEALTH_URL}"

print_section "Checking optional AI advisor service"

if [ "${AI_ADVISOR_ENABLED}" = "true" ]; then
  AI_ADVISOR_REFRESH_URL="${AI_ADVISOR_URL}${AI_ADVISOR_REFRESH_ENDPOINT}"
  check_url "AI advisor endpoint" "${AI_ADVISOR_REFRESH_URL}"
else
  pass "AI advisor check skipped because AI_ADVISOR_ENABLED=false"
fi

print_section "Prerequisite check completed"

echo "All required prerequisites passed."
echo ""
echo "Configured platform services:"
echo "  Java backend:       ${JAVA_BACKEND_URL}"
echo "  Risk monitor:       ${RISK_MONITOR_URL}"
echo "  AI advisor enabled: ${AI_ADVISOR_ENABLED}"
echo ""
echo "Configured local repositories:"
echo "  Quant engine:       ${QUANT_ENGINE_DIR}"
echo "  C++ market engine:  ${MARKET_ENGINE_CPP_DIR}"
echo "  Java backend:       ${BACKEND_JAVA_DIR}"
echo "  .NET risk monitor:  ${RISK_MONITOR_DOTNET_DIR}"