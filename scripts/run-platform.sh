#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REFRESH_INTERVAL_SECONDS=3600

print_section() {
  echo ""
  echo "============================================================"
  echo "$1"
  echo "============================================================"
}

print_timestamp() {
  date "+%Y-%m-%d %H:%M:%S"
}

print_section "Mega Fintrade platform run"

echo "This script runs the normal Docker-based Mega Fintrade routine."
echo ""
echo "Routine:"
echo "  1. Start long-running Docker services"
echo "  2. Check prerequisites"
echo "  3. Run the full Docker pipeline immediately"
echo "  4. Refresh the full Docker pipeline every 1 hour"
echo "  5. Keep the dashboard available"
echo ""
echo "Manual stop:"
echo "  Press Control + C to stop the refresh loop."
echo ""
echo "After stopping the loop, stop long-running Docker services with:"
echo "  ./scripts/stop-services.sh"

print_section "Step 1 — Start Docker services"

"${SCRIPT_DIR}/start-services.sh"

print_section "Step 2 — Check prerequisites"

"${SCRIPT_DIR}/check-prerequisites.sh"

RUN_COUNT=1

while true; do
  print_section "Step 3 — Run full Docker pipeline"

  echo "Pipeline run number: ${RUN_COUNT}"
  echo "Started at: $(print_timestamp)"
  echo ""

  "${SCRIPT_DIR}/run-full-pipeline.sh"

  echo ""
  echo "Pipeline run number ${RUN_COUNT} completed at: $(print_timestamp)"
  echo ""
  echo "Dashboard:"
  echo "  http://localhost:5189/dashboard"
  echo ""
  echo "Next automatic refresh will run in 1 hour."
  echo "Press Control + C to stop the refresh loop."

  RUN_COUNT=$((RUN_COUNT + 1))

  sleep "${REFRESH_INTERVAL_SECONDS}"
done