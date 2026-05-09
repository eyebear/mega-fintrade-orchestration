# Pipeline Data Flow

This document explains how data moves through the Mega Fintrade Platform when using the orchestration project.

The orchestration project does not own the business logic of the platform. It coordinates the existing repositories and moves generated files between them.

---

## High-Level Flow

The intended local Docker pipeline is:

    Python Quant Engine Docker ingestion
            ↓
    C++ Market Engine Docker processing
            ↓
    Python Quant Engine Docker analytics
            ↓
    Java Backend Docker import
            ↓
    .NET Risk Monitor Docker refresh
            ↓
    Dashboard

Each project remains in its own repository.

The orchestration project controls the workflow through Docker Compose, scripts, and configuration.

---

## Connected Repositories

Recommended local folder layout:

    mega-fintrade/
    ├── mega-fintrade-orchestration
    ├── mega-fintrade-quant-engine
    ├── mega-fintrade-market-engine-cpp
    ├── mega-fintrade-backend-java
    └── mega-fintrade-risk-monitor-dotnet

Repository path settings are stored in:

    config/pipeline.env

---

## Docker Compose Role

Each connected project is expected to provide its own Docker Compose file.

Project 0 uses those Docker Compose files to run the correct service or job.

| Project | Docker role |
|---|---|
| Project 1 Java backend | Long-running Docker service |
| Project 2 Python quant engine | Docker job for ingestion and analytics |
| Project 3 C++ market engine | Docker job for market processing |
| Project 4 .NET risk monitor | Long-running Docker service |

Project 0 should not directly run bare-metal Python, CMake, Java, Maven, or .NET commands.

---

## File Movement Summary

| Step | From | To | File |
|---|---|---|---|
| 1 | Python Quant Engine | C++ Market Engine | `raw_market_data.csv` |
| 2 | C++ Market Engine | Python Quant Engine | `cleaned_market_data.csv` |
| 3 | C++ Market Engine | Python Quant Engine | `daily_returns.csv` |
| 4 | Python Quant Engine | Java Backend | `backtest_results.csv` |
| 5 | Python Quant Engine | Java Backend | `risk_metrics.csv` |
| 6 | Python Quant Engine | Java Backend | `strategy_signals.csv` |
| 7 | Python Quant Engine | Java Backend | `portfolio_equity_curve.csv` |

---

## Stage 1 — Python Market Data Ingestion

Project:

    mega-fintrade-quant-engine

Docker Compose service:

    quant-engine-pipeline

Configured command:

    QUANT_INGESTION_COMMAND

Purpose:

    Generate raw market data.

Expected output:

    data/raw/raw_market_data.csv

This file is the starting point for the C++ market engine.

---

## Stage 2 — Copy Raw Market Data to C++ Market Engine

Source file:

    mega-fintrade-quant-engine/data/raw/raw_market_data.csv

Target file:

    mega-fintrade-market-engine-cpp/data/input/raw_market_data.csv

Purpose:

    Feed raw market data into the C++ processing engine.

---

## Stage 3 — C++ Market Engine Processing

Project:

    mega-fintrade-market-engine-cpp

Docker Compose service:

    market-engine-single

or:

    market-engine-multi

The selected service is controlled by:

    CPP_MODE

Input file:

    data/input/raw_market_data.csv

Expected output files:

    data/output/cleaned_market_data.csv
    data/output/daily_returns.csv

Purpose:

    Clean raw market data and calculate daily returns.

---

## Stage 4 — Copy C++ Outputs Back to Python

Source files:

    mega-fintrade-market-engine-cpp/data/output/cleaned_market_data.csv
    mega-fintrade-market-engine-cpp/data/output/daily_returns.csv

Target files:

    mega-fintrade-quant-engine/data/processed/cleaned_market_data.csv
    mega-fintrade-quant-engine/data/processed/daily_returns.csv

Purpose:

    Feed cleaned market data and returns into the Python analytics pipeline.

---

## Stage 5 — Python Quant Analytics

Project:

    mega-fintrade-quant-engine

Docker Compose service:

    quant-engine-pipeline

Configured command:

    QUANT_ANALYTICS_COMMAND

Input files:

    data/processed/cleaned_market_data.csv
    data/processed/daily_returns.csv

Expected output files:

    data/output/backtest_results.csv
    data/output/risk_metrics.csv
    data/output/strategy_signals.csv
    data/output/portfolio_equity_curve.csv

Purpose:

    Generate the final analytics outputs that the Java backend imports.

---

## Stage 6 — Copy Python Outputs to Java Backend

Source files:

    mega-fintrade-quant-engine/data/output/backtest_results.csv
    mega-fintrade-quant-engine/data/output/risk_metrics.csv
    mega-fintrade-quant-engine/data/output/strategy_signals.csv
    mega-fintrade-quant-engine/data/output/portfolio_equity_curve.csv

Target files:

    mega-fintrade-backend-java/data/input/backtest_results.csv
    mega-fintrade-backend-java/data/input/risk_metrics.csv
    mega-fintrade-backend-java/data/input/strategy_signals.csv
    mega-fintrade-backend-java/data/input/portfolio_equity_curve.csv

Purpose:

    Prepare the Java backend import process.

The Java backend Docker service must mount or otherwise have access to this data folder.

---

## Stage 7 — Java Backend Import

Project:

    mega-fintrade-backend-java

Docker Compose service:

    backend

Default base URL:

    http://localhost:8080

Configured import endpoint:

    /api/import/all

Full default import URL:

    http://localhost:8080/api/import/all

Purpose:

    Import the generated CSV files into the backend system.

---

## Stage 8 — .NET Risk Monitor Refresh

Project:

    mega-fintrade-risk-monitor-dotnet

Docker Compose service:

    mega-fintrade-risk-monitor

Default base URL:

    http://localhost:5189

Configured refresh endpoint:

    /api/monitor/run

Full default refresh URL:

    http://localhost:5189/api/monitor/run

Purpose:

    Refresh risk monitor data after the backend import is complete.

---

## Stage 9 — Dashboard

Default dashboard URL:

    http://localhost:5189/dashboard

Purpose:

    Display the updated risk monitoring result.

---

## Future AI Advisor Hook

Project 5 AI advisor support is optional.

Default AI setting:

    AI_ADVISOR_ENABLED="false"

When AI is disabled, the orchestration script skips all AI advisor steps.

When AI is enabled later, the orchestration script can trigger the AI advisor after the core Projects 1–4 pipeline completes.

Suggested future AI settings:

    AI_ADVISOR_ENABLED="false"
    AI_ADVISOR_URL="http://localhost:7005"
    AI_ADVISOR_REFRESH_ENDPOINT="/api/advisor/run"

---

## Important Rule

The orchestration project should not duplicate source code from the connected repositories.

It should only contain:

    README.md
    LICENSE
    .gitignore
    scripts/
    config/
    docs/

Each platform service remains in its own repository.