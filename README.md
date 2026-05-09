# Mega Fintrade Orchestration

`mega-fintrade-orchestration` is Project 0 of the Mega Fintrade Platform.

This project is the top-level Docker orchestration and manual project for running the full Mega Fintrade Platform locally.

It does not replace the other Mega Fintrade repositories. Instead, it connects them together through Docker Compose, scripts, configuration files, and documentation.

---

## Project Position

This repository is:

    Project 0 — mega-fintrade-orchestration

It controls the existing platform projects:

    Project 1 — mega-fintrade-backend-java
    Project 2 — mega-fintrade-quant-engine
    Project 3 — mega-fintrade-market-engine-cpp
    Project 4 — mega-fintrade-risk-monitor-dotnet

Future AI work can be added later as an optional Project 5 component.

---

## Purpose

The purpose of this project is to let the user run the full Mega Fintrade local pipeline with one clear Docker-based routine.

The full platform data flow is:

    Python Quant Engine Docker job
            ↓
    C++ Market Engine Docker job
            ↓
    Python Quant Analytics Docker job
            ↓
    Java Backend Docker service
            ↓
    .NET Risk Monitor Docker service
            ↓
    Dashboard

This project provides the scripts and documentation needed to connect those parts.

---

## Main Responsibilities

This orchestration project handles:

    1. Loading local configuration
    2. Validating Docker Compose service names
    3. Starting long-running Docker services
    4. Checking real service health endpoints
    5. Running Python market data ingestion through Docker
    6. Moving raw market data into the C++ market engine
    7. Running the C++ market engine through Docker
    8. Moving C++ output files back into the Python quant engine
    9. Running Python analytics through Docker
    10. Moving final CSV outputs into the Java backend
    11. Triggering Java backend import APIs
    12. Triggering .NET risk monitor refresh APIs
    13. Printing the final dashboard URL
    14. Supporting automatic hourly refresh through the one-click platform runner

No bare-metal Python, CMake, Java, Maven, .NET, or dotnet run command is required by the orchestration scripts. The connected projects are expected to run through Docker Compose.

---

## Connected Repositories

This project expects the following repositories to exist beside it locally:

    mega-fintrade/
    ├── mega-fintrade-orchestration
    ├── mega-fintrade-quant-engine
    ├── mega-fintrade-market-engine-cpp
    ├── mega-fintrade-backend-java
    └── mega-fintrade-risk-monitor-dotnet

Recommended local folder layout:

    mega-fintrade/

The four platform projects should be cloned into the same parent folder as this orchestration project.

---

## Quick Start

From the orchestration project root, prepare the local configuration:

    cp config/pipeline.env.example config/pipeline.env
    code config/pipeline.env

Make all scripts executable:

    chmod +x scripts/*.sh

---

### Option A — Manual Refresh

Use this option when you want to control when new data is pulled, processed, imported, and monitored.

Start long-running Docker services:

    ./scripts/start-services.sh

Check prerequisites:

    ./scripts/check-prerequisites.sh

Run one full Docker pipeline refresh:

    ./scripts/run-full-pipeline.sh

Open the dashboard:

    http://localhost:5189/dashboard

When finished, stop long-running Docker services:

    ./scripts/stop-services.sh

---

### Option B — One-Click Periodic Refresh

Use this option for the normal one-command local platform routine.

Run:

    ./scripts/run-platform.sh

This command:

    1. Starts long-running Docker services
    2. Checks prerequisites
    3. Runs the full Docker pipeline immediately
    4. Refreshes the full pipeline every 1 hour
    5. Keeps the dashboard available

Open the dashboard:

    http://localhost:5189/dashboard

The one-click routine keeps running in the terminal.

To stop the automatic refresh loop, press:

    Control + C

After stopping the loop, stop long-running Docker services:

    ./scripts/stop-services.sh

---

## Service Health Endpoints

Project 0 uses real health endpoints to confirm that the long-running Docker services are ready.

Project 1 Java backend health endpoint:

    http://localhost:8080/api/health

Project 4 .NET risk monitor health endpoint:

    http://localhost:5189/health

These endpoints are used by:

    scripts/start-services.sh
    scripts/check-prerequisites.sh

---

## Configuration

The public configuration template is:

    config/pipeline.env.example

The private local configuration file is:

    config/pipeline.env

The local config file should not be committed.

Important repository path settings include:

    QUANT_ENGINE_DIR="../mega-fintrade-quant-engine"
    MARKET_ENGINE_CPP_DIR="../mega-fintrade-market-engine-cpp"
    BACKEND_JAVA_DIR="../mega-fintrade-backend-java"
    RISK_MONITOR_DOTNET_DIR="../mega-fintrade-risk-monitor-dotnet"

Important service URL settings include:

    JAVA_BACKEND_URL="http://localhost:8080"
    RISK_MONITOR_URL="http://localhost:5189"

Important health endpoint settings include:

    JAVA_BACKEND_HEALTH_ENDPOINT="/api/health"
    RISK_MONITOR_HEALTH_ENDPOINT="/health"

Important Docker Compose service settings include:

    QUANT_ENGINE_PIPELINE_SERVICE="quant-engine-pipeline"
    MARKET_ENGINE_CPP_SINGLE_SERVICE="market-engine-single"
    MARKET_ENGINE_CPP_MULTI_SERVICE="market-engine-multi"
    BACKEND_JAVA_DOCKER_SERVICE="backend"
    RISK_MONITOR_DOTNET_DOCKER_SERVICE="mega-fintrade-risk-monitor"

Project 5 AI advisor support is disabled by default:

    AI_ADVISOR_ENABLED="false"

---

## Scripts

| Script | Purpose |
|---|---|
| `scripts/load-config.sh` | Loads local pipeline configuration |
| `scripts/validate-config.sh` | Validates required configuration values |
| `scripts/start-services.sh` | Starts long-running Docker services and waits for real health endpoints |
| `scripts/check-prerequisites.sh` | Checks Docker, folders, Compose files, service names, and real health endpoints |
| `scripts/run-full-pipeline.sh` | Runs one manual full Docker-based platform pipeline refresh |
| `scripts/clean-generated-data.sh` | Removes generated pipeline files safely |
| `scripts/stop-services.sh` | Stops long-running Docker services |
| `scripts/run-platform.sh` | Starts services, checks prerequisites, runs the pipeline immediately, and refreshes every 1 hour |

---

## Documentation

| Document | Purpose |
|---|---|
| `docs/normal-routine.md` | Explains the standard local Docker usage routine |
| `docs/pipeline-data-flow.md` | Explains how files move through the platform |
| `docs/troubleshooting.md` | Explains common local setup and runtime problems |

---

## Future Project 5 AI Advisor

Project 5 is planned as an optional future AI advisor component.

Project 0 reserves configuration for Project 5, but AI should stay disabled by default.

Default future AI settings:

    AI_ADVISOR_ENABLED="false"
    AI_ADVISOR_URL="http://localhost:7005"
    AI_ADVISOR_REFRESH_ENDPOINT="/api/advisor/run"

When AI is disabled, Project 0 skips all AI-related steps.

When AI is enabled later, Project 0 can trigger the Project 5 AI advisor after the core Projects 1–4 pipeline is complete.

---

## Known Follow-Up Improvements

The platform currently works end-to-end through Docker orchestration.

Planned service-quality improvements include:

    1. Continue improving Project 4 alert lifecycle behavior.
    2. Add richer symbol-level dashboard cards when Project 1 exposes symbol-level report metrics.
    3. Add Project 5 AI advisor integration when the AI service is implemented.

---

## Technology Stack Covered

This orchestration project connects a multi-language platform:

| Area | Technology |
|---|---|
| Orchestration | Bash |
| Service runtime | Docker Compose |
| Configuration | `.env` files |
| Quant engine | Python |
| Market engine | C++ and CMake inside Docker |
| Backend ETL/API | Java, Spring Boot, Spring Batch |
| Risk monitor | C#, .NET, ASP.NET Core |
| Version control | Git and GitHub |

---

## Repository Type

This is a control repository.

It should contain:

    README.md
    LICENSE
    .gitignore
    scripts/
    config/
    docs/

It should not contain the full source code of the other projects.

Each platform project remains in its own repository.