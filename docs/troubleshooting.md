# Troubleshooting

This document explains common problems when running the Mega Fintrade orchestration project locally.

---

## Problem 1 — Missing Local Config File

Error example:

    ERROR: Missing local config file.
    Expected file: config/pipeline.env

Cause:

    The private local config file does not exist yet.

Fix:

    cp config/pipeline.env.example config/pipeline.env
    code config/pipeline.env

Then confirm the repository paths, Docker Compose service names, and URLs match your local machine.

---

## Problem 2 — Repository Folder Not Found

Error example:

    ERROR: Python quant engine directory does not exist

Cause:

    One of the repository path values in config/pipeline.env is wrong.

Check these values:

    QUANT_ENGINE_DIR="../mega-fintrade-quant-engine"
    MARKET_ENGINE_CPP_DIR="../mega-fintrade-market-engine-cpp"
    BACKEND_JAVA_DIR="../mega-fintrade-backend-java"
    RISK_MONITOR_DOTNET_DIR="../mega-fintrade-risk-monitor-dotnet"

Fix:

    Update config/pipeline.env so the paths match your actual local folder names.

Recommended layout:

    mega-fintrade/
    ├── mega-fintrade-orchestration
    ├── mega-fintrade-quant-engine
    ├── mega-fintrade-market-engine-cpp
    ├── mega-fintrade-backend-java
    └── mega-fintrade-risk-monitor-dotnet

---

## Problem 3 — Docker Command Not Found

Error example:

    ERROR: Docker is not installed or not available in PATH.

Cause:

    Docker is not installed or Docker Desktop is not running.

Fix:

    1. Start Docker Desktop.
    2. Run:

        docker --version

    3. Run the prerequisite check again:

        ./scripts/check-prerequisites.sh

---

## Problem 4 — Docker Compose Plugin Not Available

Error example:

    Docker Compose plugin is not available. Expected command: docker compose

Cause:

    Docker is installed, but the Compose plugin is missing or Docker Desktop is not ready.

Fix:

    docker compose version

If this fails, restart Docker Desktop and try again.

---

## Problem 5 — Docker Compose File Not Found

Error example:

    Docker Compose file not found

Cause:

    One of the connected repositories does not have a supported Compose file name.

Supported file names:

    docker-compose.yml
    docker-compose.yaml
    compose.yml
    compose.yaml

Fix:

    Confirm the connected project has one of those files in its repository root.

---

## Problem 6 — Docker Compose Service Name Not Found

Error example:

    service not found

Cause:

    The service name in config/pipeline.env does not match the connected project's Docker Compose service name.

Fix:

    Open the connected repository's Docker Compose file and confirm the service name.

Common expected values:

    QUANT_ENGINE_PIPELINE_SERVICE="quant-engine-pipeline"
    QUANT_ENGINE_TEST_SERVICE="quant-engine-tests"
    MARKET_ENGINE_CPP_SINGLE_SERVICE="market-engine-single"
    MARKET_ENGINE_CPP_MULTI_SERVICE="market-engine-multi"
    MARKET_ENGINE_CPP_TEST_SERVICE="market-engine-tests"
    BACKEND_JAVA_DOCKER_SERVICE="backend"
    BACKEND_JAVA_DATABASE_SERVICE="postgres"
    RISK_MONITOR_DOTNET_DOCKER_SERVICE="mega-fintrade-risk-monitor"

---

## Problem 7 — Java Backend Is Not Reachable

Error example:

    Java backend is not reachable

Cause:

    The Java backend Docker service is not running, is still starting, or is using a different port.

Expected default URL:

    http://localhost:8080

Fix:

    ./scripts/start-services.sh

Then check:

    curl http://localhost:8080/api/reports/summary

A dedicated Project 1 health endpoint should be added later.

Recommended future endpoint:

    /api/health

---

## Problem 8 — .NET Risk Monitor Is Not Reachable

Error example:

    .NET risk monitor is not reachable

Cause:

    The .NET risk monitor Docker service is not running, is still starting, or is using a different port.

Expected default URL:

    http://localhost:5189

Fix:

    ./scripts/start-services.sh

Then check:

    curl http://localhost:5189/api/monitor/status

A dedicated Project 4 health endpoint should be added later.

Recommended future endpoint:

    /health

---

## Problem 9 — Raw Market Data File Not Found

Error example:

    ERROR: Raw market data output not found

Cause:

    The Python ingestion Docker command did not generate:

    data/raw/raw_market_data.csv

Possible reasons:

    1. The Project 2 Docker service did not mount the data folder.
    2. The configured ingestion command is wrong.
    3. Market data download failed.
    4. Project 2 code changed.

Fix:

    1. Check QUANT_INGESTION_COMMAND in config/pipeline.env.
    2. Confirm Project 2 Docker Compose mounts:

        ./data:/app/data

    3. Run the full pipeline again.

---

## Problem 10 — C++ Output Files Not Found

Error example:

    cleaned_market_data.csv not found
    daily_returns.csv not found

Cause:

    The C++ Docker job did not write expected output files to the host-mounted data folder.

Expected output files:

    mega-fintrade-market-engine-cpp/data/output/cleaned_market_data.csv
    mega-fintrade-market-engine-cpp/data/output/daily_returns.csv

Fix:

    Confirm Project 3 Docker Compose mounts:

        ./data:/app/data
        ./logs:/app/logs

Then rerun:

    ./scripts/run-full-pipeline.sh

---

## Problem 11 — Java Import Endpoint Fails

Error example:

    ERROR: Java backend import failed

Cause:

    The Java backend is running, but the import endpoint rejected one of the CSV files.

Common causes:

    1. CSV file is missing.
    2. CSV header does not match backend contract.
    3. Required numeric field is blank.
    4. Java backend Docker service cannot see the copied data/input files.

Fix:

    Check the latest backend audit:

        curl http://localhost:8080/api/import/audit

    Check rejected records:

        curl http://localhost:8080/api/import/rejections

    Check backend logs:

        docker logs mega-fintrade-backend-java --tail 120

---

## Problem 12 — Strategy Signal Header Rejected

Error example:

    Invalid CSV header

Cause:

    Project 2 generated a strategy_signals.csv file that does not match Project 1's expected import contract.

Expected header starts with:

    date,aapl_close,aapl_sma_short,aapl_sma_long,aapl_signal

Fix:

    Project 2 analytics export must produce backend-compatible lowercase headers and use sma_short and sma_long names.

---

## Problem 13 — Missing Moving Average Values

Error example:

    Missing required decimal field: aapl_sma_short

Cause:

    Early moving average rows can be blank because the short and long moving averages need enough history.

Fix:

    Project 2 analytics export should remove strategy signal rows that have missing required numeric values before writing strategy_signals.csv.

---

## Problem 14 — .NET Monitor Refresh Fails

Error example:

    WARNING: Optional endpoint failed

Cause:

    The .NET monitor refresh endpoint may not exist yet or may use a different path.

Default refresh endpoint:

    RISK_MONITOR_REFRESH_ENDPOINT="/api/monitor/run"

Fix:

    Confirm the correct monitor refresh endpoint and update config/pipeline.env if needed.

---

## Problem 15 — Old ImportFailure or CsvRejectionsFound Alerts Still Show

Cause:

    Project 4 may keep historical active alerts even after a newer successful Java import.

Current expected improvement:

    Project 4 should resolve or filter old ImportFailure and CsvRejectionsFound alerts after the latest Java import becomes SUCCESS.

This is a Project 4 improvement, not a Project 0 pipeline failure.

---

## Problem 16 — AI Advisor Check Is Skipped

Output example:

    AI advisor skipped because AI_ADVISOR_ENABLED=false

This is correct.

Project 5 AI advisor support is optional and should stay disabled by default.

Default setting:

    AI_ADVISOR_ENABLED="false"

When Project 5 exists later, this can be changed to:

    AI_ADVISOR_ENABLED="true"

---

## Problem 17 — Cleanup Deleted Generated CSV Files

This is expected.

The cleanup script removes known generated pipeline files such as:

    raw_market_data.csv
    cleaned_market_data.csv
    daily_returns.csv
    backtest_results.csv
    risk_metrics.csv
    strategy_signals.csv
    portfolio_equity_curve.csv

It should preserve:

    Source code files
    README files
    .gitkeep files
    sample CSV files
    configuration files

After cleanup, run the full pipeline again to regenerate the files:

    ./scripts/run-full-pipeline.sh