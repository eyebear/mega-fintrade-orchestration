#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

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

warn() {
  echo "WARNING: $1"
}

fail() {
  echo "ERROR: $1"
  exit 1
}

resolve_path() {
  local path_value="$1"

  if [[ "${path_value}" = /* ]]; then
    echo "${path_value}"
  else
    echo "${PROJECT_ROOT}/${path_value}"
  fi
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

find_compose_file() {
  local repo_dir="$1"

  if [ -f "${repo_dir}/docker-compose.yml" ]; then
    echo "${repo_dir}/docker-compose.yml"
    return 0
  fi

  if [ -f "${repo_dir}/docker-compose.yaml" ]; then
    echo "${repo_dir}/docker-compose.yaml"
    return 0
  fi

  if [ -f "${repo_dir}/compose.yml" ]; then
    echo "${repo_dir}/compose.yml"
    return 0
  fi

  if [ -f "${repo_dir}/compose.yaml" ]; then
    echo "${repo_dir}/compose.yaml"
    return 0
  fi

  return 1
}

check_compose_file() {
  local name="$1"
  local repo_dir="$2"

  local compose_file
  if compose_file="$(find_compose_file "${repo_dir}")"; then
    pass "${name} Docker Compose file found: ${compose_file}"
  else
    fail "${name} Docker Compose file not found in ${repo_dir}"
  fi
}

check_compose_service() {
  local name="$1"
  local repo_dir="$2"
  local service_name="$3"

  local compose_file
  if ! compose_file="$(find_compose_file "${repo_dir}")"; then
    fail "${name} Docker Compose file not found in ${repo_dir}"
  fi

  if (
    cd "${repo_dir}"
    docker compose -f "${compose_file}" config --services | grep -Fx "${service_name}" >/dev/null 2>&1
  ); then
    pass "${name} service exists: ${service_name}"
  else
    echo "Available services in ${compose_file}:"
    (
      cd "${repo_dir}"
      docker compose -f "${compose_file}" config --services
    )
    fail "${name} service not found: ${service_name}"
  fi
}

is_url_reachable() {
  local url="$1"

  curl --silent --fail --max-time 5 "${url}" >/dev/null 2>&1
}

check_any_url_warning_only() {
  local name="$1"
  shift

  for url in "$@"; do
    if is_url_reachable "${url}"; then
      pass "${name} is reachable: ${url}"
      return 0
    fi
  done

  warn "${name} was not reachable through the configured check URLs."
  echo "Checked URLs:"
  for url in "$@"; do
    echo "  ${url}"
  done
  echo ""
  echo "Continuing because dedicated health endpoints will be added later."
}

QUANT_ENGINE_ABS_DIR="$(resolve_path "${QUANT_ENGINE_DIR}")"
MARKET_ENGINE_CPP_ABS_DIR="$(resolve_path "${MARKET_ENGINE_CPP_DIR}")"
BACKEND_JAVA_ABS_DIR="$(resolve_path "${BACKEND_JAVA_DIR}")"
RISK_MONITOR_DOTNET_ABS_DIR="$(resolve_path "${RISK_MONITOR_DOTNET_DIR}")"

print_section "Mega Fintrade prerequisite check"

echo "This script checks whether the local machine is ready to run the Docker-based Mega Fintrade orchestration pipeline."
echo ""
echo "No Python, CMake, Java, Maven, or .NET SDK is required on the host for service execution."
echo "Those runtimes should be inside the project Docker images."

print_section "Checking required repository folders"

check_directory "Python quant engine" "${QUANT_ENGINE_ABS_DIR}"
check_directory "C++ market engine" "${MARKET_ENGINE_CPP_ABS_DIR}"
check_directory "Java backend" "${BACKEND_JAVA_ABS_DIR}"
check_directory ".NET risk monitor" "${RISK_MONITOR_DOTNET_ABS_DIR}"

print_section "Checking required host command line tools"

check_command "docker" "Docker"
check_command "curl" "curl"

if docker compose version >/dev/null 2>&1; then
  pass "Docker Compose plugin is available."
else
  fail "Docker Compose plugin is not available. Expected command: docker compose"
fi

print_section "Checking Docker Compose files"

check_compose_file "Python quant engine" "${QUANT_ENGINE_ABS_DIR}"
check_compose_file "C++ market engine" "${MARKET_ENGINE_CPP_ABS_DIR}"
check_compose_file "Java backend" "${BACKEND_JAVA_ABS_DIR}"
check_compose_file ".NET risk monitor" "${RISK_MONITOR_DOTNET_ABS_DIR}"

print_section "Checking Docker Compose service names"

check_compose_service "Python quant engine pipeline" "${QUANT_ENGINE_ABS_DIR}" "${QUANT_ENGINE_PIPELINE_SERVICE}"
check_compose_service "Python quant engine tests" "${QUANT_ENGINE_ABS_DIR}" "${QUANT_ENGINE_TEST_SERVICE}"

check_compose_service "C++ market engine single" "${MARKET_ENGINE_CPP_ABS_DIR}" "${MARKET_ENGINE_CPP_SINGLE_SERVICE}"
check_compose_service "C++ market engine multi" "${MARKET_ENGINE_CPP_ABS_DIR}" "${MARKET_ENGINE_CPP_MULTI_SERVICE}"
check_compose_service "C++ market engine tests" "${MARKET_ENGINE_CPP_ABS_DIR}" "${MARKET_ENGINE_CPP_TEST_SERVICE}"

check_compose_service "Java backend database" "${BACKEND_JAVA_ABS_DIR}" "${BACKEND_JAVA_DATABASE_SERVICE}"
check_compose_service "Java backend service" "${BACKEND_JAVA_ABS_DIR}" "${BACKEND_JAVA_DOCKER_SERVICE}"

check_compose_service ".NET risk monitor service" "${RISK_MONITOR_DOTNET_ABS_DIR}" "${RISK_MONITOR_DOTNET_DOCKER_SERVICE}"

print_section "Checking Java backend service"

check_any_url_warning_only \
  "Java backend" \
  "${JAVA_BACKEND_URL}${JAVA_BACKEND_HEALTH_ENDPOINT}" \
  "${JAVA_BACKEND_URL}/api/reports/summary" \
  "${JAVA_BACKEND_URL}/api/import/audit"

print_section "Checking .NET risk monitor service"

check_any_url_warning_only \
  ".NET risk monitor" \
  "${RISK_MONITOR_URL}${RISK_MONITOR_HEALTH_ENDPOINT}" \
  "${RISK_MONITOR_URL}/api/monitor/status" \
  "${RISK_MONITOR_URL}${RISK_MONITOR_DASHBOARD_PATH}" \
  "${RISK_MONITOR_URL}"

print_section "Checking optional AI advisor service"

if [ "${AI_ADVISOR_ENABLED}" = "true" ]; then
  check_any_url_warning_only "AI advisor" "${AI_ADVISOR_URL}${AI_ADVISOR_REFRESH_ENDPOINT}"
else
  pass "AI advisor check skipped because AI_ADVISOR_ENABLED=false"
fi

print_section "Prerequisite check completed"

echo "Docker-based prerequisite structure is valid."
echo ""
echo "Configured platform services:"
echo "  Java backend:       ${JAVA_BACKEND_URL}"
echo "  Risk monitor:       ${RISK_MONITOR_URL}"
echo "  AI advisor enabled: ${AI_ADVISOR_ENABLED}"
echo ""
echo "Configured local repositories:"
echo "  Quant engine:       ${QUANT_ENGINE_ABS_DIR}"
echo "  C++ market engine:  ${MARKET_ENGINE_CPP_ABS_DIR}"
echo "  Java backend:       ${BACKEND_JAVA_ABS_DIR}"
echo "  .NET risk monitor:  ${RISK_MONITOR_DOTNET_ABS_DIR}"