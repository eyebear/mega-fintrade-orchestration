# Mega Fintrade Orchestration

`mega-fintrade-orchestration` is the top-level orchestration project for the Mega Fintrade Platform.

It provides scripts, configuration templates, and documentation for running the full local platform pipeline across the Python quant engine, C++ market engine, Java backend, and .NET risk monitor.

This repository does not replace the individual platform repositories. Instead, it acts as the control layer that connects them into one repeatable end-to-end workflow.

---

## Repository Scope

This repository provides orchestration scripts, configuration templates, and documentation for running the Mega Fintrade Platform locally.

It is designed as a control layer for the platform and does not contain the source code of the individual platform services.

Each service remains in its own repository.

---

## Platform Position

This repository controls the following platform components:

| Component | Repository | Main Role |
|---|---|---|
| Quant Engine | `mega-fintrade-quant-engine` | Downloads market data, runs quant analytics, and generates portfolio output files |
| Market Engine | `mega-fintrade-market-engine-cpp` | Processes raw market data, cleans records, and calculates daily returns |
| Backend Platform | `mega-fintrade-backend-java` | Imports processed CSV outputs, stores portfolio data, and exposes REST APIs |
| Risk Monitor | `mega-fintrade-risk-monitor-dotnet` | Monitors portfolio risk, evaluates alert rules, and provides dashboard views |

Future AI advisor functionality can be added later as an optional extension, but the core orchestration flow does not depend on AI.

---

## Purpose

The purpose of this project is to make the Mega Fintrade Platform easier to run as one connected system.

Instead of manually switching between multiple repositories and copying files by hand, this orchestration project is designed to provide one clear routine for the full local pipeline.

The intended local data flow is:

    Python Quant Engine
            ↓
    C++ Market Engine
            ↓
    Python Quant Analytics
            ↓
    Java Backend Import
            ↓
    .NET Risk Monitor
            ↓
    Dashboard

---

## Main Responsibilities

This orchestration project is responsible for coordinating the local platform workflow.

It is designed to handle:

1. Checking local prerequisites.
2. Loading local configuration.
3. Running Python market data ingestion.
4. Moving raw market data into the C++ market engine.
5. Building and running the C++ market engine.
6. Moving C++ output files back into the Python quant engine.
7. Running Python analytics.
8. Moving final CSV outputs into the Java backend.
9. Triggering Java backend import APIs.
10. Triggering .NET risk monitor refresh APIs.
11. Printing final service and dashboard URLs.

---

## Recommended Local Repository Layout

The orchestration project expects the platform repositories to sit beside each other under one parent folder.

Recommended structure:

    mega-fintrade/
    ├── mega-fintrade-orchestration
    ├── mega-fintrade-quant-engine
    ├── mega-fintrade-market-engine-cpp
    ├── mega-fintrade-backend-java
    └── mega-fintrade-risk-monitor-dotnet

This layout allows the orchestration scripts to use simple relative paths.

---

## Expected Data Flow

The platform is designed around CSV and API contracts between services.

High-level file movement:

| From | To | Purpose |
|---|---|---|
| Python Quant Engine | C++ Market Engine | Sends raw market data for cleaning and processing |
| C++ Market Engine | Python Quant Engine | Returns cleaned market data and daily returns |
| Python Quant Engine | Java Backend | Sends final analytics outputs for backend import |
| Java Backend | .NET Risk Monitor | Provides portfolio and risk data through REST APIs |
| .NET Risk Monitor | Dashboard | Displays risk status and monitoring results |

---

## Important Output Files

The platform workflow depends on a consistent set of generated CSV files.

Common files include:

| File | Produced By | Used By |
|---|---|---|
| `raw_market_data.csv` | Python Quant Engine | C++ Market Engine |
| `cleaned_market_data.csv` | C++ Market Engine | Python Quant Engine |
| `daily_returns.csv` | C++ Market Engine | Python Quant Engine |
| `backtest_results.csv` | Python Quant Engine | Java Backend |
| `risk_metrics.csv` | Python Quant Engine | Java Backend |
| `strategy_signals.csv` | Python Quant Engine | Java Backend |
| `portfolio_equity_curve.csv` | Python Quant Engine | Java Backend |

The orchestration scripts are responsible for moving these files to the correct locations during the local pipeline run.

---

## Planned Capabilities

The orchestration project is intended to provide the following capabilities.

### Configuration

| Capability | Purpose |
|---|---|
| Example environment file | Provides a template for local repository paths and service URLs |
| Local environment file | Allows each developer to use their own machine-specific paths |
| Backend URL configuration | Stores the Java backend API base URL |
| Risk monitor URL configuration | Stores the .NET risk monitor base URL |
| C++ mode configuration | Allows the user to select the C++ engine run mode |
| Optional AI configuration placeholder | Reserves future support for an AI advisor service |

### Prerequisite Checking

| Capability | Purpose |
|---|---|
| Repository folder check | Confirms all required platform repositories exist locally |
| Python check | Confirms the quant engine can run |
| CMake check | Confirms the C++ market engine can build |
| Docker check | Confirms local containerized services can run |
| Java backend health check | Confirms the backend API is reachable |
| .NET monitor health check | Confirms the risk monitor API is reachable |
| Optional AI check | Skips AI validation unless AI support is enabled |

### Full Pipeline Execution

| Capability | Purpose |
|---|---|
| Run Python ingestion | Generates raw market data |
| Copy raw data to C++ | Feeds the market engine |
| Build C++ engine | Compiles the market engine |
| Run C++ engine | Produces cleaned data and daily returns |
| Copy C++ outputs to Python | Feeds the analytics pipeline |
| Run Python analytics | Produces backend import files |
| Copy final CSV files to Java backend | Prepares backend ingestion |
| Trigger backend import | Imports generated CSV files |
| Trigger monitor refresh | Updates risk monitor data |
| Print final URLs | Shows the user where to check results |

### Cleanup

| Capability | Purpose |
|---|---|
| Clean generated Python files | Removes generated quant files |
| Clean generated C++ files | Removes generated market engine outputs |
| Clean copied backend input files | Removes copied import files |
| Preserve source and sample files | Prevents accidental deletion of important files |

### Documentation

| Document | Purpose |
|---|---|
| `docs/normal-routine.md` | Explains the standard local usage routine |
| `docs/pipeline-data-flow.md` | Explains how data moves across projects |
| `docs/troubleshooting.md` | Explains common local setup and runtime issues |

---

## Configuration Model

This project uses environment-style configuration files.

The public example file should be:

    config/pipeline.env.example

The local private file should be:

    config/pipeline.env

The local file should not be committed to Git.

Example configuration values:

    BACKEND_JAVA_DIR="../mega-fintrade-backend-java"
    QUANT_ENGINE_DIR="../mega-fintrade-quant-engine"
    MARKET_ENGINE_CPP_DIR="../mega-fintrade-market-engine-cpp"
    RISK_MONITOR_DOTNET_DIR="../mega-fintrade-risk-monitor-dotnet"

    JAVA_BACKEND_URL="http://localhost:8080"
    RISK_MONITOR_URL="http://localhost:5189"

    CPP_MODE="single"

    AI_ADVISOR_ENABLED="false"
    AI_ADVISOR_URL="http://localhost:7005"

The AI advisor settings are reserved for future expansion and should remain disabled by default.

---

## Normal Usage Goal

The final intended usage is:

    ./scripts/run-full-pipeline.sh

After the pipeline completes, the user should be able to open the local dashboard.

Default dashboard URL:

    http://localhost:5189/dashboard

The exact URL may depend on the local .NET risk monitor configuration.

---

## Technology Stack

This orchestration project connects a multi-language platform.

| Area | Technology |
|---|---|
| Orchestration | Bash |
| Configuration | Environment files |
| Quant engine | Python |
| Market engine | C++ and CMake |
| Backend ETL/API | Java, Spring Boot, Spring Batch |
| Risk monitor | C#, .NET, ASP.NET Core |
| Local services | Docker |
| Version control | Git and GitHub |

---

## Repository Contents

Expected repository structure:

    mega-fintrade-orchestration/
    ├── README.md
    ├── LICENSE
    ├── .gitignore
    ├── scripts/
    ├── config/
    └── docs/

This repository should only contain orchestration-related files.

It should not contain copied source code from the Python, C++, Java, or .NET repositories.

---

## Future AI Advisor Support

The platform may later include an optional AI advisor service.

That future service should be disabled by default in this orchestration project.

Suggested future configuration:

    AI_ADVISOR_ENABLED="false"
    AI_ADVISOR_URL="http://localhost:7005"

When disabled, all AI-related steps should be skipped.

When enabled later, the orchestration script can trigger the AI advisor after the core Projects 1–4 pipeline finishes successfully.

---

## License

This project is licensed under the MIT License.