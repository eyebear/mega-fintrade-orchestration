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
    pass "${name} directory found: ${path}"
  else
    fail "${name} directory not found: ${path}"
  fi
}

is_url_reachable() {
  local url="$1"

  curl --silent --fail --max-time 5 "${url}" >/dev/null 2>&1
}

wait_for_url() {
  local name="$1"
  local url="$2"
  local attempts="${DOCKER_SERVICE_WAIT_ATTEMPTS}"

  echo "Waiting for ${name}."
  echo "Health URL:"
  echo "  ${url}"

  for attempt in $(seq 1 "${attempts}"); do
    if is_url_reachable "${url}"; then
      pass "${name} is reachable: ${url}"
      return 0
    fi

    echo "Attempt ${attempt}/${attempts}: ${name} not ready yet."
    sleep 2
  done

  fail "${name} did not become reachable after ${attempts} attempts: ${url}"
}

start_compose_service() {
  local name="$1"
  local repo_dir="$2"
  local service_name="$3"

  check_directory "${name}" "${repo_dir}"

  local compose_file
  if ! compose_file="$(find_compose_file "${repo_dir}")"; then
    fail "${name} Docker Compose file not found in ${repo_dir}"
  fi

  echo "Starting ${name} with Docker Compose."
  echo "Compose file:"
  echo "  ${compose_file}"
  echo "Service:"
  echo "  ${service_name}"

  (
    cd "${repo_dir}"
    docker compose -f "${compose_file}" up -d --build "${service_name}"
  )

  pass "${name} Docker Compose startup command completed."
}

BACKEND_JAVA_ABS_DIR="$(resolve_path "${BACKEND_JAVA_DIR}")"
RISK_MONITOR_DOTNET_ABS_DIR="$(resolve_path "${RISK_MONITOR_DOTNET_DIR}")"

JAVA_BACKEND_HEALTH_URL="${JAVA_BACKEND_URL}${JAVA_BACKEND_HEALTH_ENDPOINT}"
RISK_MONITOR_HEALTH_URL="${RISK_MONITOR_URL}${RISK_MONITOR_HEALTH_ENDPOINT}"

print_section "Mega Fintrade Docker service startup"

echo "This script starts required Mega Fintrade long-running services using Docker Compose only."
echo ""
echo "No bare-metal Java, Maven, .NET, or dotnet run command is used."
echo ""
echo "Services:"
echo "  Java backend:       ${JAVA_BACKEND_URL}"
echo "  .NET risk monitor:  ${RISK_MONITOR_URL}"

print_section "Checking Docker requirements"

check_command "docker" "Docker"

if docker compose version >/dev/null 2>&1; then
  pass "Docker Compose plugin is available."
else
  fail "Docker Compose plugin is not available. Expected command: docker compose"
fi

print_section "Starting Java backend through Docker"

start_compose_service "Java backend" "${BACKEND_JAVA_ABS_DIR}" "${BACKEND_JAVA_DOCKER_SERVICE}"
wait_for_url "Java backend" "${JAVA_BACKEND_HEALTH_URL}"

print_section "Starting .NET risk monitor through Docker"

start_compose_service ".NET risk monitor" "${RISK_MONITOR_DOTNET_ABS_DIR}" "${RISK_MONITOR_DOTNET_DOCKER_SERVICE}"
wait_for_url ".NET risk monitor" "${RISK_MONITOR_HEALTH_URL}"

print_section "Docker service startup completed"

echo "Required Docker services are running and healthy."
echo ""
echo "Java backend:"
echo "  ${JAVA_BACKEND_URL}"
echo "Health:"
echo "  ${JAVA_BACKEND_HEALTH_URL}"
echo ""
echo ".NET risk monitor:"
echo "  ${RISK_MONITOR_URL}"
echo "Health:"
echo "  ${RISK_MONITOR_HEALTH_URL}"
echo ""
echo "Dashboard:"
echo "  ${RISK_MONITOR_URL}${RISK_MONITOR_DASHBOARD_PATH}"