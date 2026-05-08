#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/load-config.sh"

validate_url() {
  local name="$1"
  local value="$2"

  if [[ ! "${value}" =~ ^http://localhost:[0-9]+$ && ! "${value}" =~ ^https://localhost:[0-9]+$ ]]; then
    echo "ERROR: Invalid URL format for ${name}: ${value}"
    echo "Expected format example: http://localhost:8080"
    exit 1
  fi
}

validate_path() {
  local name="$1"
  local value="$2"

  if [ -z "${value}" ]; then
    echo "ERROR: Missing endpoint path: ${name}"
    exit 1
  fi

  if [[ "${value}" != /* ]]; then
    echo "ERROR: Invalid endpoint path for ${name}: ${value}"
    echo "Endpoint paths must start with /"
    exit 1
  fi
}

validate_boolean() {
  local name="$1"
  local value="$2"

  if [ "${value}" != "true" ] && [ "${value}" != "false" ]; then
    echo "ERROR: Invalid boolean value for ${name}: ${value}"
    echo "Allowed values: true, false"
    exit 1
  fi
}

validate_cpp_mode() {
  local value="$1"

  case "${value}" in
    single)
      return 0
      ;;
    multi)
      return 0
      ;;
    *)
      echo "ERROR: Invalid CPP_MODE: ${value}"
      echo "Allowed values:"
      echo "  single"
      echo "  multi"
      echo ""
      echo "Please update CPP_MODE in config/pipeline.env."
      exit 1
      ;;
  esac
}

validate_ai_config() {
  validate_boolean "AI_ADVISOR_ENABLED" "${AI_ADVISOR_ENABLED}"

  if [ -z "${AI_ADVISOR_URL}" ]; then
    echo "ERROR: Missing AI_ADVISOR_URL."
    echo "Project 5 is optional, but the placeholder URL must still exist in config."
    echo "Use example value: http://localhost:7005"
    exit 1
  fi

  if [ -z "${AI_ADVISOR_REFRESH_ENDPOINT}" ]; then
    echo "ERROR: Missing AI_ADVISOR_REFRESH_ENDPOINT."
    echo "Project 5 is optional, but the placeholder endpoint must still exist in config."
    echo "Use example value: /api/advisor/run"
    exit 1
  fi

  validate_path "AI_ADVISOR_REFRESH_ENDPOINT" "${AI_ADVISOR_REFRESH_ENDPOINT}"

  if [ "${AI_ADVISOR_ENABLED}" = "true" ]; then
    validate_url "AI_ADVISOR_URL" "${AI_ADVISOR_URL}"
  fi
}

validate_url "JAVA_BACKEND_URL" "${JAVA_BACKEND_URL}"
validate_url "RISK_MONITOR_URL" "${RISK_MONITOR_URL}"

validate_path "JAVA_BACKEND_IMPORT_ENDPOINT" "${JAVA_BACKEND_IMPORT_ENDPOINT}"
validate_path "JAVA_BACKEND_HEALTH_ENDPOINT" "${JAVA_BACKEND_HEALTH_ENDPOINT}"
validate_path "RISK_MONITOR_DASHBOARD_PATH" "${RISK_MONITOR_DASHBOARD_PATH}"
validate_path "RISK_MONITOR_REFRESH_ENDPOINT" "${RISK_MONITOR_REFRESH_ENDPOINT}"
validate_path "RISK_MONITOR_HEALTH_ENDPOINT" "${RISK_MONITOR_HEALTH_ENDPOINT}"

validate_cpp_mode "${CPP_MODE}"
validate_ai_config

echo "Mega Fintrade configuration validation passed."
echo ""
echo "Validated service URLs:"
echo "  Java backend:      ${JAVA_BACKEND_URL}"
echo "  Risk monitor:      ${RISK_MONITOR_URL}"
echo ""
echo "Validated endpoint paths:"
echo "  Java import:       ${JAVA_BACKEND_IMPORT_ENDPOINT}"
echo "  Java health:       ${JAVA_BACKEND_HEALTH_ENDPOINT}"
echo "  Monitor dashboard: ${RISK_MONITOR_DASHBOARD_PATH}"
echo "  Monitor refresh:   ${RISK_MONITOR_REFRESH_ENDPOINT}"
echo "  Monitor health:    ${RISK_MONITOR_HEALTH_ENDPOINT}"
echo ""
echo "Validated options:"
echo "  C++ mode:          ${CPP_MODE}"
echo "  AI enabled:        ${AI_ADVISOR_ENABLED}"
echo ""

if [ "${AI_ADVISOR_ENABLED}" = "true" ]; then
  echo "AI advisor validation:"
  echo "  AI advisor URL:    ${AI_ADVISOR_URL}"
  echo "  AI refresh:        ${AI_ADVISOR_REFRESH_ENDPOINT}"
else
  echo "AI advisor validation:"
  echo "  Status:            skipped because AI_ADVISOR_ENABLED=false"
  echo "  Placeholder URL:   ${AI_ADVISOR_URL}"
  echo "  Placeholder path:  ${AI_ADVISOR_REFRESH_ENDPOINT}"
fi