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

stop_compose_project() {
  local name="$1"
  local repo_dir="$2"

  if [ ! -d "${repo_dir}" ]; then
    warn "${name} directory not found, skipped: ${repo_dir}"
    return 0
  fi

  local compose_file
  if ! compose_file="$(find_compose_file "${repo_dir}")"; then
    warn "No Docker Compose file found for ${name}, skipped: ${repo_dir}"
    return 0
  fi

  echo "Stopping ${name} Docker Compose project."
  echo "Compose file:"
  echo "  ${compose_file}"

  (
    cd "${repo_dir}"
    docker compose -f "${compose_file}" down
  )

  pass "${name} Docker Compose project stopped."
}

BACKEND_JAVA_ABS_DIR="$(resolve_path "${BACKEND_JAVA_DIR}")"
RISK_MONITOR_DOTNET_ABS_DIR="$(resolve_path "${RISK_MONITOR_DOTNET_DIR}")"

print_section "Mega Fintrade Docker service shutdown"

echo "This script stops long-running Docker services used by the Mega Fintrade orchestration project."
echo ""
echo "It stops:"
echo "  Java backend Docker Compose project"
echo "  .NET risk monitor Docker Compose project"
echo ""
echo "It does not delete generated CSV files."
echo "Use scripts/clean-generated-data.sh for generated file cleanup."

print_section "Stopping .NET risk monitor"

stop_compose_project ".NET risk monitor" "${RISK_MONITOR_DOTNET_ABS_DIR}"

print_section "Stopping Java backend"

stop_compose_project "Java backend" "${BACKEND_JAVA_ABS_DIR}"

print_section "Docker service shutdown completed"

echo "Long-running Mega Fintrade Docker services have been stopped."