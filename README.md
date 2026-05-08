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

This orchestration project handles:

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