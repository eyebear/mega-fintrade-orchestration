#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_DIR="${PROJECT_ROOT}/logs"
CPP_MARKET_ENGINE_LOG_FILE="${LOG_DIR}/cpp-market-engine-run.log"

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

check_directory() {
  local name="$1"
  local path="$2"

  if [ -d "${path}" ]; then
    pass "${name} directory found: ${path}"
  else
    fail "${name} directory not found: ${path}"
  fi
}

check_file() {
  local name="$1"
  local path="$2"

  if [ -f "${path}" ]; then
    pass "${name} found: ${path}"
  else
    fail "${name} not found: ${path}"
  fi
}

copy_file() {
  local source_file="$1"
  local target_file="$2"

  check_file "Source file" "${source_file}"

  mkdir -p "$(dirname "${target_file}")"
  cp "${source_file}" "${target_file}"

  pass "Copied ${source_file} to ${target_file}"
}

docker_compose_build_service() {
  local name="$1"
  local repo_dir="$2"
  local service_name="$3"

  local compose_file
  if ! compose_file="$(find_compose_file "${repo_dir}")"; then
    fail "No Docker Compose file found for ${name} in ${repo_dir}"
  fi

  echo "Building ${name} Docker service."
  echo "Compose file:"
  echo "  ${compose_file}"
  echo "Service:"
  echo "  ${service_name}"

  (
    cd "${repo_dir}"
    docker compose -f "${compose_file}" build "${service_name}"
  )

  pass "${name} Docker build completed."
}

docker_compose_run_service_command() {
  local name="$1"
  local repo_dir="$2"
  local service_name="$3"
  local command_text="$4"

  local compose_file
  if ! compose_file="$(find_compose_file "${repo_dir}")"; then
    fail "No Docker Compose file found for ${name} in ${repo_dir}"
  fi

  echo "Running ${name} Docker service with command override."
  echo "Compose file:"
  echo "  ${compose_file}"
  echo "Service:"
  echo "  ${service_name}"
  echo "Command:"
  echo "  ${command_text}"

  (
    cd "${repo_dir}"
    docker compose -f "${compose_file}" run --rm "${service_name}" sh -lc "${command_text}"
  )

  pass "${name} Docker command completed."
}

docker_compose_run_service_default_quiet() {
  local name="$1"
  local repo_dir="$2"
  local service_name="$3"
  local log_file="$4"

  local compose_file
  if ! compose_file="$(find_compose_file "${repo_dir}")"; then
    fail "No Docker Compose file found for ${name} in ${repo_dir}"
  fi

  mkdir -p "$(dirname "${log_file}")"

  echo "Running ${name} Docker service with default compose command."
  echo "Compose file:"
  echo "  ${compose_file}"
  echo "Service:"
  echo "  ${service_name}"
  echo "Terminal output:"
  echo "  Suppressed."
  echo "Log file:"
  echo "  ${log_file}"

  if (
    cd "${repo_dir}"
    docker compose -f "${compose_file}" run --rm "${service_name}"
  ) > "${log_file}" 2>&1; then
    pass "${name} Docker run completed."
    echo "Full ${name} log saved to:"
    echo "  ${log_file}"
  else
    echo ""
    echo "${name} failed. Last 80 log lines:"
    tail -n 80 "${log_file}" || true
    fail "${name} Docker run failed. Full log: ${log_file}"
  fi
}

post_url() {
  local name="$1"
  local url="$2"

  echo "Calling ${name}: ${url}"

  if curl --silent --fail --max-time 30 -X POST "${url}" >/dev/null 2>&1; then
    pass "${name} completed successfully"
  else
    fail "${name} failed: ${url}"
  fi
}

post_url_optional() {
  local name="$1"
  local url="$2"

  echo "Calling optional endpoint ${name}: ${url}"

  if curl --silent --fail --max-time 30 -X POST "${url}" >/dev/null 2>&1; then
    pass "${name} completed successfully"
  else
    warn "Optional endpoint failed: ${url}"
    warn "Continuing because this step is optional."
  fi
}

select_cpp_service() {
  if [ "${CPP_MODE}" = "multi" ]; then
    echo "${MARKET_ENGINE_CPP_MULTI_SERVICE}"
  else
    echo "${MARKET_ENGINE_CPP_SINGLE_SERVICE}"
  fi
}

QUANT_ENGINE_ABS_DIR="$(resolve_path "${QUANT_ENGINE_DIR}")"
MARKET_ENGINE_CPP_ABS_DIR="$(resolve_path "${MARKET_ENGINE_CPP_DIR}")"
BACKEND_JAVA_ABS_DIR="$(resolve_path "${BACKEND_JAVA_DIR}")"
RISK_MONITOR_DOTNET_ABS_DIR="$(resolve_path "${RISK_MONITOR_DOTNET_DIR}")"

CPP_SELECTED_SERVICE="$(select_cpp_service)"

QUANT_RAW_MARKET_DATA_FILE="${QUANT_ENGINE_ABS_DIR}/${QUANT_RAW_DATA_DIR}/${RAW_MARKET_DATA_FILE}"
CPP_RAW_MARKET_DATA_FILE="${MARKET_ENGINE_CPP_ABS_DIR}/${CPP_INPUT_DATA_DIR}/${RAW_MARKET_DATA_FILE}"

CPP_CLEANED_MARKET_DATA_FILE="${MARKET_ENGINE_CPP_ABS_DIR}/${CPP_OUTPUT_DATA_DIR}/${CLEANED_MARKET_DATA_FILE}"
CPP_DAILY_RETURNS_FILE="${MARKET_ENGINE_CPP_ABS_DIR}/${CPP_OUTPUT_DATA_DIR}/${DAILY_RETURNS_FILE}"

QUANT_CLEANED_MARKET_DATA_FILE="${QUANT_ENGINE_ABS_DIR}/${QUANT_PROCESSED_DATA_DIR}/${CLEANED_MARKET_DATA_FILE}"
QUANT_DAILY_RETURNS_FILE="${QUANT_ENGINE_ABS_DIR}/${QUANT_PROCESSED_DATA_DIR}/${DAILY_RETURNS_FILE}"

QUANT_BACKTEST_RESULTS_FILE="${QUANT_ENGINE_ABS_DIR}/${QUANT_OUTPUT_DATA_DIR}/${BACKTEST_RESULTS_FILE}"
QUANT_RISK_METRICS_FILE="${QUANT_ENGINE_ABS_DIR}/${QUANT_OUTPUT_DATA_DIR}/${RISK_METRICS_FILE}"
QUANT_STRATEGY_SIGNALS_FILE="${QUANT_ENGINE_ABS_DIR}/${QUANT_OUTPUT_DATA_DIR}/${STRATEGY_SIGNALS_FILE}"
QUANT_PORTFOLIO_EQUITY_CURVE_FILE="${QUANT_ENGINE_ABS_DIR}/${QUANT_OUTPUT_DATA_DIR}/${PORTFOLIO_EQUITY_CURVE_FILE}"

JAVA_BACKTEST_RESULTS_FILE="${BACKEND_JAVA_ABS_DIR}/${JAVA_INPUT_DATA_DIR}/${BACKTEST_RESULTS_FILE}"
JAVA_RISK_METRICS_FILE="${BACKEND_JAVA_ABS_DIR}/${JAVA_INPUT_DATA_DIR}/${RISK_METRICS_FILE}"
JAVA_STRATEGY_SIGNALS_FILE="${BACKEND_JAVA_ABS_DIR}/${JAVA_INPUT_DATA_DIR}/${STRATEGY_SIGNALS_FILE}"
JAVA_PORTFOLIO_EQUITY_CURVE_FILE="${BACKEND_JAVA_ABS_DIR}/${JAVA_INPUT_DATA_DIR}/${PORTFOLIO_EQUITY_CURVE_FILE}"

JAVA_IMPORT_URL="${JAVA_BACKEND_URL}${JAVA_BACKEND_IMPORT_ENDPOINT}"
RISK_MONITOR_REFRESH_URL="${RISK_MONITOR_URL}${RISK_MONITOR_REFRESH_ENDPOINT}"
RISK_MONITOR_DASHBOARD_URL="${RISK_MONITOR_URL}${RISK_MONITOR_DASHBOARD_PATH}"

print_section "Mega Fintrade full Docker pipeline"

echo "This script runs the local Mega Fintrade platform pipeline using Docker Compose services."
echo ""
echo "No bare-metal Python, CMake, Java, Maven, .NET, or dotnet run command is used by this script."
echo ""
echo "Project root:"
echo "  ${PROJECT_ROOT}"
echo ""
echo "Resolved repositories:"
echo "  Quant engine:       ${QUANT_ENGINE_ABS_DIR}"
echo "  C++ market engine:  ${MARKET_ENGINE_CPP_ABS_DIR}"
echo "  Java backend:       ${BACKEND_JAVA_ABS_DIR}"
echo "  .NET risk monitor:  ${RISK_MONITOR_DOTNET_ABS_DIR}"
echo ""
echo "Docker services:"
echo "  Quant pipeline:     ${QUANT_ENGINE_PIPELINE_SERVICE}"
echo "  C++ market engine:  ${CPP_SELECTED_SERVICE}"
echo "  Java backend:       ${BACKEND_JAVA_DOCKER_SERVICE}"
echo "  Risk monitor:       ${RISK_MONITOR_DOTNET_DOCKER_SERVICE}"

print_section "Checking required repository folders"

check_directory "Python quant engine" "${QUANT_ENGINE_ABS_DIR}"
check_directory "C++ market engine" "${MARKET_ENGINE_CPP_ABS_DIR}"
check_directory "Java backend" "${BACKEND_JAVA_ABS_DIR}"
check_directory ".NET risk monitor" "${RISK_MONITOR_DOTNET_ABS_DIR}"

print_section "Step 1 — Run Python market data ingestion through Docker"

docker_compose_build_service \
  "Python quant engine" \
  "${QUANT_ENGINE_ABS_DIR}" \
  "${QUANT_ENGINE_PIPELINE_SERVICE}"

docker_compose_run_service_command \
  "Python market data ingestion" \
  "${QUANT_ENGINE_ABS_DIR}" \
  "${QUANT_ENGINE_PIPELINE_SERVICE}" \
  "${QUANT_INGESTION_COMMAND}"

check_file "Raw market data output" "${QUANT_RAW_MARKET_DATA_FILE}"

print_section "Step 2 — Copy raw market data to C++ market engine"

copy_file "${QUANT_RAW_MARKET_DATA_FILE}" "${CPP_RAW_MARKET_DATA_FILE}"

print_section "Step 3 — Build C++ market engine through Docker"

docker_compose_build_service \
  "C++ market engine" \
  "${MARKET_ENGINE_CPP_ABS_DIR}" \
  "${CPP_SELECTED_SERVICE}"

print_section "Step 4 — Run C++ market engine through Docker"

docker_compose_run_service_default_quiet \
  "C++ market engine" \
  "${MARKET_ENGINE_CPP_ABS_DIR}" \
  "${CPP_SELECTED_SERVICE}" \
  "${CPP_MARKET_ENGINE_LOG_FILE}"

check_file "Cleaned market data output" "${CPP_CLEANED_MARKET_DATA_FILE}"
check_file "Daily returns output" "${CPP_DAILY_RETURNS_FILE}"

print_section "Step 5 — Copy C++ outputs back to Python quant engine"

copy_file "${CPP_CLEANED_MARKET_DATA_FILE}" "${QUANT_CLEANED_MARKET_DATA_FILE}"
copy_file "${CPP_DAILY_RETURNS_FILE}" "${QUANT_DAILY_RETURNS_FILE}"

print_section "Step 6 — Run Python quant analytics pipeline through Docker"

docker_compose_run_service_command \
  "Python quant analytics" \
  "${QUANT_ENGINE_ABS_DIR}" \
  "${QUANT_ENGINE_PIPELINE_SERVICE}" \
  "${QUANT_ANALYTICS_COMMAND}"

check_file "Backtest results output" "${QUANT_BACKTEST_RESULTS_FILE}"
check_file "Risk metrics output" "${QUANT_RISK_METRICS_FILE}"
check_file "Strategy signals output" "${QUANT_STRATEGY_SIGNALS_FILE}"
check_file "Portfolio equity curve output" "${QUANT_PORTFOLIO_EQUITY_CURVE_FILE}"

print_section "Step 7 — Copy Python outputs to Java backend"

copy_file "${QUANT_BACKTEST_RESULTS_FILE}" "${JAVA_BACKTEST_RESULTS_FILE}"
copy_file "${QUANT_RISK_METRICS_FILE}" "${JAVA_RISK_METRICS_FILE}"
copy_file "${QUANT_STRATEGY_SIGNALS_FILE}" "${JAVA_STRATEGY_SIGNALS_FILE}"
copy_file "${QUANT_PORTFOLIO_EQUITY_CURVE_FILE}" "${JAVA_PORTFOLIO_EQUITY_CURVE_FILE}"

print_section "Step 8 — Trigger Java backend import"

post_url "Java backend import" "${JAVA_IMPORT_URL}"

print_section "Step 9 — Trigger .NET risk monitor refresh"

post_url_optional ".NET risk monitor refresh" "${RISK_MONITOR_REFRESH_URL}"

print_section "Step 10 — Optional AI advisor hook"

if [ "${AI_ADVISOR_ENABLED}" = "true" ]; then
  AI_ADVISOR_REFRESH_URL="${AI_ADVISOR_URL}${AI_ADVISOR_REFRESH_ENDPOINT}"
  post_url_optional "AI advisor refresh" "${AI_ADVISOR_REFRESH_URL}"
else
  pass "AI advisor skipped because AI_ADVISOR_ENABLED=false"
fi

print_section "Full Docker pipeline completed"

echo "Mega Fintrade Docker pipeline completed."
echo ""
echo "Check the dashboard:"
echo "  ${RISK_MONITOR_DASHBOARD_URL}"
echo ""
echo "Generated backend input files:"
echo "  ${JAVA_BACKTEST_RESULTS_FILE}"
echo "  ${JAVA_RISK_METRICS_FILE}"
echo "  ${JAVA_STRATEGY_SIGNALS_FILE}"
echo "  ${JAVA_PORTFOLIO_EQUITY_CURVE_FILE}"
echo ""
echo "C++ market engine log:"
echo "  ${CPP_MARKET_ENGINE_LOG_FILE}"