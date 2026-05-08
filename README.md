# Mega Fintrade Orchestration

`mega-fintrade-orchestration` is Project 0 of the Mega Fintrade Platform.

This project is the top-level control and manual project for running the full Mega Fintrade Platform locally.

It does not replace the other Mega Fintrade repositories. Instead, it connects them together through scripts, configuration files, and documentation.

---

## Project Position

This repository is:

    Project 0 — mega-fintrade-orchestration

It controls the existing platform projects:

    Project 1 — mega-fintrade-backend-java
    Project 2 — mega-fintrade-quant-engine
    Project 3 — mega-fintrade-market-engine-cpp
    Project 4 — mega-fintrade-risk-monitor-dotnet

Future AI work will be added later as an optional Project 5 component.

---

## Purpose

The purpose of this project is to let the user run the full Mega Fintrade local pipeline with one clear routine.

The full platform data flow is:

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

This project provides the scripts and documentation needed to connect those parts.

---

## Main Responsibilities

This orchestration project will eventually handle:

    1. Checking local prerequisites
    2. Running the Python market data ingestion
    3. Moving raw market data into the C++ market engine
    4. Building and running the C++ market engine
    5. Moving C++ output files back into the Python quant engine
    6. Running Python analytics
    7. Moving final CSV outputs into the Java backend
    8. Triggering Java backend import APIs
    9. Triggering .NET risk monitor refresh APIs
    10. Printing the final dashboard URL

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

## Project 0 Build Plan

### Phase 1 — Project Setup

| Step | Task | Purpose |
|---|---|---|
| 1.1 | Create `mega-fintrade-orchestration` repo | Create the top-level orchestration project |
| 1.2 | Add root `README.md` | Explain the project purpose |
| 1.3 | Add `.gitignore` | Ignore local config and temporary files |
| 1.4 | Add `LICENSE` | Add project license |
| 1.5 | Create `scripts/`, `config/`, and `docs/` folders | Prepare project structure |

### Phase 2 — Configuration

| Step | Task | Purpose |
|---|---|---|
| 2.1 | Add `config/pipeline.env.example` | Store example repo paths and URLs |
| 2.2 | Support local `config/pipeline.env` | Allow user-specific local settings |
| 2.3 | Add repo path config | Point to the four existing repos |
| 2.4 | Add backend and monitor URLs | Store Java backend and .NET monitor URLs |
| 2.5 | Add C++ mode config | Let user choose C++ execution mode |
| 2.6 | Add future AI config placeholder | Reserve optional Project 5 settings |

### Phase 3 — Prerequisite Check Script

| Step | Task | Purpose |
|---|---|---|
| 3.1 | Add `scripts/check-prerequisites.sh` | Check local environment before running |
| 3.2 | Check required repo folders | Confirm all platform repos exist |
| 3.3 | Check Python | Required by the quant engine |
| 3.4 | Check CMake | Required by the C++ market engine |
| 3.5 | Check Docker | Required by local services |
| 3.6 | Check Java backend URL | Confirm backend is running |
| 3.7 | Check .NET monitor URL | Confirm risk monitor is running |
| 3.8 | Skip AI check when disabled | Keep Project 5 optional |

### Phase 4 — Full Pipeline Script

| Step | Task | Purpose |
|---|---|---|
| 4.1 | Add `scripts/run-full-pipeline.sh` | Main one-command runner |
| 4.2 | Run Python ingestion | Generate raw market data |
| 4.3 | Copy raw data to C++ engine | Feed C++ engine |
| 4.4 | Build C++ engine | Compile market engine |
| 4.5 | Run C++ engine | Generate cleaned data and daily returns |
| 4.6 | Copy C++ outputs back to Python | Feed Python analytics |
| 4.7 | Run Python quant pipeline | Generate backend import files |
| 4.8 | Copy Python outputs to Java backend | Prepare Java import |
| 4.9 | Trigger Java backend import | Import generated CSVs |
| 4.10 | Trigger .NET monitor run | Refresh dashboard data |
| 4.11 | Optionally trigger AI advisor later | Future Project 5 hook |
| 4.12 | Print final URLs | Show user where to check results |

### Phase 5 — Cleanup Script

| Step | Task | Purpose |
|---|---|---|
| 5.1 | Add `scripts/clean-generated-data.sh` | Clean generated files safely |
| 5.2 | Clean Python raw/output files | Remove generated Python files |
| 5.3 | Clean C++ input/output/log files | Remove generated C++ files |
| 5.4 | Clean Java input files | Remove copied import files |
| 5.5 | Preserve sample/source files | Avoid deleting important files |

### Phase 6 — Documentation

| Step | Task | Purpose |
|---|---|---|
| 6.1 | Add `docs/normal-routine.md` | Simple daily usage guide |
| 6.2 | Add `docs/pipeline-data-flow.md` | Explain file movement |
| 6.3 | Add `docs/troubleshooting.md` | Explain common errors |
| 6.4 | Update `README.md` | Main public manual |
| 6.5 | Document future Project 5 hook | Explain optional AI integration |

### Phase 7 — Final Test and Delivery

| Step | Task | Purpose |
|---|---|---|
| 7.1 | Test prerequisite script | Confirm setup check works |
| 7.2 | Test full pipeline script | Confirm end-to-end data flow works |
| 7.3 | Test Java backend import | Confirm CSV import works |
| 7.4 | Test .NET monitor refresh | Confirm monitor sees updated backend |
| 7.5 | Open dashboard | Confirm final result is visible |
| 7.6 | Commit and push | Finish Project 0 |

---

## Future Project 5 AI Advisor

Project 5 is planned as an optional future AI advisor component.

Project 0 should reserve configuration for Project 5, but AI must stay disabled by default.

Example future settings:

    AI_ADVISOR_ENABLED=false
    AI_ADVISOR_URL=http://localhost:7005

When AI is disabled, Project 0 skips all AI-related steps.

When AI is enabled later, Project 0 can trigger the Project 5 AI advisor after the core Projects 1–4 pipeline is complete.

---

## Normal Usage Goal

The final goal is that the user can run:

    ./scripts/run-full-pipeline.sh

Then open the dashboard:

    http://localhost:5189/dashboard

At the current stage, this script does not exist yet. It will be added in Phase 4.

---

## Technology Stack Covered

This orchestration project connects a multi-language platform:

| Area | Technology |
|---|---|
| Orchestration | Bash |
| Configuration | `.env` files |
| Quant engine | Python |
| Market engine | C++ and CMake |
| Backend ETL/API | Java, Spring Boot, Spring Batch |
| Risk monitor | C#, .NET, ASP.NET Core |
| Local services | Docker |
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