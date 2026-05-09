# Normal Routine

This document explains the normal Docker-based local routine for running the Mega Fintrade Platform through the orchestration project.

The goal is to run the full platform without manually switching between multiple repositories.

---

## Recommended Local Folder Layout

The repositories should sit beside each other under one parent folder.

Recommended layout:

    mega-fintrade/
    ├── mega-fintrade-orchestration
    ├── mega-fintrade-quant-engine
    ├── mega-fintrade-market-engine-cpp
    ├── mega-fintrade-backend-java
    └── mega-fintrade-risk-monitor-dotnet

The orchestration scripts use the repository paths defined in:

    config/pipeline.env

---

## Docker-Only Runtime Rule

The orchestration project is designed to use Docker Compose for platform execution.

The orchestration scripts should not require bare-metal runtime commands such as:

    python3
    cmake
    mvn
    ./mvnw spring-boot:run
    dotnet run

The host machine still needs:

    docker
    docker compose
    curl

The language runtimes should live inside the connected project Docker images.

---

## Step 1 — Prepare Local Configuration

From the orchestration project root:

    cd mega-fintrade-orchestration

If the local config file does not exist yet, create it from the example file:

    cp config/pipeline.env.example config/pipeline.env

Then open it:

    code config/pipeline.env

Confirm these repository path values match your local folder layout:

    QUANT_ENGINE_DIR="../mega-fintrade-quant-engine"
    MARKET_ENGINE_CPP_DIR="../mega-fintrade-market-engine-cpp"
    BACKEND_JAVA_DIR="../mega-fintrade-backend-java"
    RISK_MONITOR_DOTNET_DIR="../mega-fintrade-risk-monitor-dotnet"

Confirm the local service URLs:

    JAVA_BACKEND_URL="http://localhost:8080"
    RISK_MONITOR_URL="http://localhost:5189"

Confirm the Docker Compose service names match the connected repositories:

    QUANT_ENGINE_PIPELINE_SERVICE="quant-engine-pipeline"
    MARKET_ENGINE_CPP_SINGLE_SERVICE="market-engine-single"
    MARKET_ENGINE_CPP_MULTI_SERVICE="market-engine-multi"
    BACKEND_JAVA_DOCKER_SERVICE="backend"
    RISK_MONITOR_DOTNET_DOCKER_SERVICE="mega-fintrade-risk-monitor"

Project 5 AI advisor support is optional and should stay disabled by default:

    AI_ADVISOR_ENABLED="false"

---

## Step 2 — Start Required Docker Services

Start the long-running Java backend and .NET risk monitor services:

    chmod +x scripts/start-services.sh
    ./scripts/start-services.sh

This starts:

    Project 1 — Java backend Docker service
    Project 4 — .NET risk monitor Docker service

The Java backend should become available at:

    http://localhost:8080

The .NET risk monitor should become available at:

    http://localhost:5189

The dashboard should become available at:

    http://localhost:5189/dashboard

---

## Step 3 — Check Prerequisites

From the orchestration project root, run:

    chmod +x scripts/check-prerequisites.sh
    ./scripts/check-prerequisites.sh

This checks:

    1. Required repository folders
    2. Docker installation
    3. Docker Compose plugin
    4. Docker Compose files
    5. Docker Compose service names
    6. Java backend reachability
    7. .NET risk monitor reachability
    8. Optional AI advisor behavior

Until Project 1 and Project 4 have dedicated health endpoints, the check script may use fallback service URLs.

---

## Step 4 — Run the Full Docker Pipeline

From the orchestration project root, run:

    chmod +x scripts/run-full-pipeline.sh
    ./scripts/run-full-pipeline.sh

The full Docker pipeline does this:

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

After the pipeline finishes, open the dashboard:

    http://localhost:5189/dashboard

---

## Step 5 — Normal One-Command Routine

After the local config is ready, the normal routine is:

    chmod +x scripts/run-platform.sh
    ./scripts/run-platform.sh

This runs:

    1. Service startup
    2. Prerequisite check
    3. Full Docker pipeline
    4. Final dashboard URL printout

---

## Step 6 — Clean Generated Files When Needed

To clean generated CSV files from the connected local repositories, run:

    chmod +x scripts/clean-generated-data.sh
    ./scripts/clean-generated-data.sh

The cleanup script removes known generated pipeline files.

It does not remove source code, README files, configuration files, `.gitkeep` files, or sample CSV files.

---

## Step 7 — Stop Docker Services When Needed

To stop long-running Docker services controlled by Project 0, run:

    chmod +x scripts/stop-services.sh
    ./scripts/stop-services.sh

This stops the Java backend Docker service and the .NET risk monitor Docker service.

---

## Expected Result

A successful full run should:

    1. Generate raw market data in the Python quant engine.
    2. Send raw market data to the C++ market engine.
    3. Generate cleaned market data and daily returns.
    4. Send C++ outputs back to the Python quant engine.
    5. Generate final analytics output files.
    6. Copy final CSV files into the Java backend input folder.
    7. Trigger the Java backend import API.
    8. Trigger the .NET monitor refresh endpoint.
    9. Print the dashboard URL.

The final dashboard URL is normally:

    http://localhost:5189/dashboard