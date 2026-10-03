# Contextual Accessibility Agent (OpenHarmony HackYeah 2026)

## Overview
This project is a **Local-First Contextual Accessibility Agent** designed specifically for OpenHarmony. It leverages on-device AI capabilities to provide real-time, privacy-preserving auditory assistance and contextual summaries for users with visual impairments or cognitive accessibility needs. 

By running entirely on-device (via local LLMs like Gemma 4), this application guarantees user privacy and operates without network latency—a critical requirement for digital sovereignty and human-centric accessibility tools.

## Hackathon Challenge Alignment
This solution addresses two core challenge areas:
1. **Intelligent Experiences:** Utilizes on-device AI and contextual awareness to parse complex screen information or sensor data into digestible auditory summaries.
2. **Human-Centric Technology:** Applies inclusive design to improve digital wellbeing and accessibility, ensuring users can interact with their environment and OS safely and privately.

## Key Features
- **Privacy-First On-Device AI:** Processes all contextual data locally without transmitting sensitive accessibility data to the cloud.
- **Contextual Summarization:** Reads the current OS state or app context and provides a clear, natural-language summary of what is on screen or happening nearby.
- **OpenHarmony Integration:** Built natively using ArkTS and ArkUI, utilizing OpenHarmony system capabilities to ensure a seamless, deeply integrated OS experience.

## Architecture & Implementation
*To be populated once DevEco Studio initialization is complete.*
- **Frontend:** ArkUI (Native OpenHarmony)
- **Logic:** ArkTS
- **AI Integration:** Local model inference handling OS context data.

## Setup & Build Instructions
1. Open this project in **DevEco Studio** (Requires DevEco Studio configured for API 20+).
2. Sync the project dependencies via `npm`/`ohpm`.
3. Launch the OpenHarmony/HarmonyOS Emulator (Phone/Tablet).
4. Build and run the `.hap` package.
