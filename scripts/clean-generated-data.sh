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

resolve_path() {
  local path_value="$1"

  if [[ "${path_value}" = /* ]]; then
    echo "${path_value}"
  else
    echo "${PROJECT_ROOT}/${path_value}"
  fi
}

delete_file_if_exists() {
  local file_path="$1"

  if [ -f "${file_path}" ]; then
    rm "${file_path}"
    pass "Deleted file: ${file_path}"
  else
    warn "File not found, skipped: ${file_path}"
  fi
}

delete_directory_contents_if_exists() {
  local directory_path="$1"

  if [ -d "${directory_path}" ]; then
    find "${directory_path}" -type f \
      ! -name ".gitkeep" \
      ! -name "README.md" \
      ! -name "README.txt" \
      ! -name "*.sample.csv" \
      ! -name "sample_*.csv" \
      -delete

    pass "Cleaned generated files in directory: ${directory_path}"
  else
    warn "Directory not found, skipped: ${directory_path}"
  fi
}

QUANT_ENGINE_ABS_DIR="$(resolve_path "${QUANT_ENGINE_DIR}")"
MARKET_ENGINE_CPP_ABS_DIR="$(resolve_path "${MARKET_ENGINE_CPP_DIR}")"
BACKEND_JAVA_ABS_DIR="$(resolve_path "${BACKEND_JAVA_DIR}")"

QUANT_RAW_MARKET_DATA_FILE="${QUANT_ENGINE_ABS_DIR}/${QUANT_RAW_DATA_DIR}/${RAW_MARKET_DATA_FILE}"
QUANT_CLEANED_MARKET_DATA_FILE="${QUANT_ENGINE_ABS_DIR}/${QUANT_PROCESSED_DATA_DIR}/${CLEANED_MARKET_DATA_FILE}"
QUANT_DAILY_RETURNS_FILE="${QUANT_ENGINE_ABS_DIR}/${QUANT_PROCESSED_DATA_DIR}/${DAILY_RETURNS_FILE}"

QUANT_BACKTEST_RESULTS_FILE="${QUANT_ENGINE_ABS_DIR}/${QUANT_OUTPUT_DATA_DIR}/${BACKTEST_RESULTS_FILE}"
QUANT_RISK_METRICS_FILE="${QUANT_ENGINE_ABS_DIR}/${QUANT_OUTPUT_DATA_DIR}/${RISK_METRICS_FILE}"
QUANT_STRATEGY_SIGNALS_FILE="${QUANT_ENGINE_ABS_DIR}/${QUANT_OUTPUT_DATA_DIR}/${STRATEGY_SIGNALS_FILE}"
QUANT_PORTFOLIO_EQUITY_CURVE_FILE="${QUANT_ENGINE_ABS_DIR}/${QUANT_OUTPUT_DATA_DIR}/${PORTFOLIO_EQUITY_CURVE_FILE}"

CPP_RAW_MARKET_DATA_FILE="${MARKET_ENGINE_CPP_ABS_DIR}/${CPP_INPUT_DATA_DIR}/${RAW_MARKET_DATA_FILE}"
CPP_CLEANED_MARKET_DATA_FILE="${MARKET_ENGINE_CPP_ABS_DIR}/${CPP_OUTPUT_DATA_DIR}/${CLEANED_MARKET_DATA_FILE}"
CPP_DAILY_RETURNS_FILE="${MARKET_ENGINE_CPP_ABS_DIR}/${CPP_OUTPUT_DATA_DIR}/${DAILY_RETURNS_FILE}"
CPP_LOG_DIR="${MARKET_ENGINE_CPP_ABS_DIR}/logs"

JAVA_BACKTEST_RESULTS_FILE="${BACKEND_JAVA_ABS_DIR}/${JAVA_INPUT_DATA_DIR}/${BACKTEST_RESULTS_FILE}"
JAVA_RISK_METRICS_FILE="${BACKEND_JAVA_ABS_DIR}/${JAVA_INPUT_DATA_DIR}/${RISK_METRICS_FILE}"
JAVA_STRATEGY_SIGNALS_FILE="${BACKEND_JAVA_ABS_DIR}/${JAVA_INPUT_DATA_DIR}/${STRATEGY_SIGNALS_FILE}"
JAVA_PORTFOLIO_EQUITY_CURVE_FILE="${BACKEND_JAVA_ABS_DIR}/${JAVA_INPUT_DATA_DIR}/${PORTFOLIO_EQUITY_CURVE_FILE}"

print_section "Mega Fintrade generated data cleanup"

echo "This script removes generated pipeline files from the connected local repositories."
echo ""
echo "It only deletes known generated files and generated log contents."
echo "It does not delete source code, configuration files, README files, or sample CSV files."
echo ""
echo "Resolved repositories:"
echo "  Quant engine:       ${QUANT_ENGINE_ABS_DIR}"
echo "  C++ market engine:  ${MARKET_ENGINE_CPP_ABS_DIR}"
echo "  Java backend:       ${BACKEND_JAVA_ABS_DIR}"

print_section "Cleaning Python quant engine generated files"

delete_file_if_exists "${QUANT_RAW_MARKET_DATA_FILE}"
delete_file_if_exists "${QUANT_CLEANED_MARKET_DATA_FILE}"
delete_file_if_exists "${QUANT_DAILY_RETURNS_FILE}"
delete_file_if_exists "${QUANT_BACKTEST_RESULTS_FILE}"
delete_file_if_exists "${QUANT_RISK_METRICS_FILE}"
delete_file_if_exists "${QUANT_STRATEGY_SIGNALS_FILE}"
delete_file_if_exists "${QUANT_PORTFOLIO_EQUITY_CURVE_FILE}"

print_section "Cleaning C++ market engine generated files"

delete_file_if_exists "${CPP_RAW_MARKET_DATA_FILE}"
delete_file_if_exists "${CPP_CLEANED_MARKET_DATA_FILE}"
delete_file_if_exists "${CPP_DAILY_RETURNS_FILE}"

print_section "Cleaning C++ market engine logs"

delete_directory_contents_if_exists "${CPP_LOG_DIR}"

print_section "Cleaning Java backend copied input files"

delete_file_if_exists "${JAVA_BACKTEST_RESULTS_FILE}"
delete_file_if_exists "${JAVA_RISK_METRICS_FILE}"
delete_file_if_exists "${JAVA_STRATEGY_SIGNALS_FILE}"
delete_file_if_exists "${JAVA_PORTFOLIO_EQUITY_CURVE_FILE}"

print_section "Cleanup completed"

echo "Generated Mega Fintrade pipeline files have been cleaned."
echo ""
echo "Preserved file types:"
echo "  Source code files"
echo "  README files"
echo "  .gitkeep files"
echo "  sample CSV files"
echo "  configuration files"