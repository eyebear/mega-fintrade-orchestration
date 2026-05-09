#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_section() {
  echo ""
  echo "============================================================"
  echo "$1"
  echo "============================================================"
}

print_section "Mega Fintrade platform run"

echo "This script runs the normal Docker-based Mega Fintrade routine."
echo ""
echo "Routine:"
echo "  1. Start long-running Docker services"
echo "  2. Check prerequisites"
echo "  3. Run full Docker pipeline"
echo "  4. Print dashboard URL"

print_section "Step 1 — Start Docker services"

"${SCRIPT_DIR}/start-services.sh"

print_section "Step 2 — Check prerequisites"

"${SCRIPT_DIR}/check-prerequisites.sh"

print_section "Step 3 — Run full Docker pipeline"

"${SCRIPT_DIR}/run-full-pipeline.sh"

print_section "Mega Fintrade platform run completed"

echo "Open the dashboard:"
echo "  http://localhost:5189/dashboard"