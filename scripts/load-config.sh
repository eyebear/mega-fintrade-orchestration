#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

CONFIG_FILE="${PROJECT_ROOT}/config/pipeline.env"

if [ ! -f "${CONFIG_FILE}" ]; then
  echo "ERROR: Missing local config file."
  echo "Expected file: ${CONFIG_FILE}"
  echo ""
  echo "Create it by running:"
  echo "cp config/pipeline.env.example config/pipeline.env"
  exit 1
fi

set -a
source "${CONFIG_FILE}"
set +a

require_config_value() {
  local variable_name="$1"
  local variable_value="${!variable_name}"

  if [ -z "${variable_value}" ]; then
    echo "ERROR: Missing required config value: ${variable_name}"
    echo "Please check: ${CONFIG_FILE}"
    exit 1
  fi
}

require_config_value "QUANT_ENGINE_DIR"
require_config_value "MARKET_ENGINE_CPP_DIR"
require_config_value "BACKEND_JAVA_DIR"
require_config_value "RISK_MONITOR_DOTNET_DIR"

require_config_value "JAVA_BACKEND_URL"
require_config_value "JAVA_BACKEND_IMPORT_ENDPOINT"
require_config_value "JAVA_BACKEND_HEALTH_ENDPOINT"
require_config_value "BACKEND_JAVA_DOCKER_SERVICE"
require_config_value "BACKEND_JAVA_DATABASE_SERVICE"

require_config_value "RISK_MONITOR_URL"
require_config_value "RISK_MONITOR_DASHBOARD_PATH"
require_config_value "RISK_MONITOR_REFRESH_ENDPOINT"
require_config_value "RISK_MONITOR_HEALTH_ENDPOINT"
require_config_value "RISK_MONITOR_DOTNET_DOCKER_SERVICE"

require_config_value "QUANT_ENGINE_PIPELINE_SERVICE"
require_config_value "QUANT_ENGINE_TEST_SERVICE"
require_config_value "QUANT_INGESTION_COMMAND"
require_config_value "QUANT_ANALYTICS_COMMAND"

require_config_value "MARKET_ENGINE_CPP_SINGLE_SERVICE"
require_config_value "MARKET_ENGINE_CPP_MULTI_SERVICE"
require_config_value "MARKET_ENGINE_CPP_TEST_SERVICE"
require_config_value "CPP_MODE"

require_config_value "RAW_MARKET_DATA_FILE"
require_config_value "CLEANED_MARKET_DATA_FILE"
require_config_value "DAILY_RETURNS_FILE"
require_config_value "BACKTEST_RESULTS_FILE"
require_config_value "RISK_METRICS_FILE"
require_config_value "STRATEGY_SIGNALS_FILE"
require_config_value "PORTFOLIO_EQUITY_CURVE_FILE"

require_config_value "QUANT_RAW_DATA_DIR"
require_config_value "QUANT_PROCESSED_DATA_DIR"
require_config_value "QUANT_OUTPUT_DATA_DIR"
require_config_value "CPP_INPUT_DATA_DIR"
require_config_value "CPP_OUTPUT_DATA_DIR"
require_config_value "JAVA_INPUT_DATA_DIR"

require_config_value "DOCKER_SERVICE_WAIT_ATTEMPTS"

require_config_value "AI_ADVISOR_ENABLED"
require_config_value "AI_ADVISOR_URL"
require_config_value "AI_ADVISOR_REFRESH_ENDPOINT"

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo "Mega Fintrade configuration loaded successfully."
  echo ""
  echo "Project root:"
  echo "  ${PROJECT_ROOT}"
  echo ""
  echo "Configured repositories:"
  echo "  Quant engine:        ${QUANT_ENGINE_DIR}"
  echo "  C++ market engine:   ${MARKET_ENGINE_CPP_DIR}"
  echo "  Java backend:        ${BACKEND_JAVA_DIR}"
  echo "  .NET risk monitor:   ${RISK_MONITOR_DOTNET_DIR}"
  echo ""
  echo "Configured services:"
  echo "  Java backend URL:    ${JAVA_BACKEND_URL}"
  echo "  Risk monitor URL:    ${RISK_MONITOR_URL}"
  echo ""
  echo "Docker Compose services:"
  echo "  Quant pipeline:      ${QUANT_ENGINE_PIPELINE_SERVICE}"
  echo "  Market single:       ${MARKET_ENGINE_CPP_SINGLE_SERVICE}"
  echo "  Market multi:        ${MARKET_ENGINE_CPP_MULTI_SERVICE}"
  echo "  Java backend:        ${BACKEND_JAVA_DOCKER_SERVICE}"
  echo "  Risk monitor:        ${RISK_MONITOR_DOTNET_DOCKER_SERVICE}"
  echo ""
  echo "Pipeline options:"
  echo "  C++ mode:            ${CPP_MODE}"
  echo "  AI advisor enabled:  ${AI_ADVISOR_ENABLED}"
fi