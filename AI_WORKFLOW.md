# AI Workflow Documentation

This document fulfills the HackYeah 2026 requirement to disclose all AI models, agents, and workflows used during the development of this project.

## AI Models and Tools Used
- **Agent Framework:** Google Antigravity IDE Plugin
- **Local Model (Primary):** `gemma4:latest` (via Ollama running locally at `http://127.0.0.1:11434`)
- **Cloud Model (Fallback):** Gemini 3.1 Pro (High) 

## Development Workflow
1. **Ideation & Architecture:** 
   - The initial concept was heavily brainstormed with the AI agent to align with the "Intelligent Experiences" and "Human-Centric Technology" scoring criteria. 
   - The AI agent analyzed the hackathon brief and suggested a local-first accessibility agent to demonstrate OpenHarmony's digital sovereignty and privacy advantages.
2. **Implementation:** 
   - The AI agent, operating in "Speed Mode", scaffolded the ArkUI components and ArkTS logic.
   - All code generation was restricted to local execution using `gemma4:latest` to prevent cloud rate-limiting and ensure a secure, offline-first development process.
3. **Review & Validation:**
   - Generated ArkTS code was manually reviewed by the developer within DevEco Studio.
   - The UI was continuously tested using the DevEco Studio Previewer and OpenHarmony Emulator. 
   - Linter errors and ArkTS compilation failures were fed back to the AI agent for iterative fixing.

## On-Device AI Feature Integration
*Note: This section describes the AI feature within the application itself, not the development tools.*

- **Model:** Local inference engine designed for OpenHarmony.
- **Inference Flow:** The app retrieves contextual UI/sensor data via OpenHarmony APIs, constructs a minimal prompt, and passes it to the local inference engine.
- **Privacy Considerations:** Because all inference occurs on-device, no user context or accessibility data is ever transmitted over the network. This guarantees total privacy for the user.
- **Limitations:** Local models on mobile devices have restricted context windows; therefore, inputs are strictly truncated to the most relevant on-screen elements before summarization.
