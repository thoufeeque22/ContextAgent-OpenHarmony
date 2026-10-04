# ContextAgent 👁️ | HackYeah 2026

**ContextAgent** is an offline, privacy-first AI accessibility tool built natively for OpenHarmony. Developed for the **Huawei "Imagine What's Next"** challenge at HackYeah 2026.

## 🎯 The Problem
Visually impaired users rely on screen readers to navigate their devices. However, traditional screen readers are robotic, linear, and lack contextual understanding. Furthermore, parsing sensitive physical documents (like medical bills) or executing financial transactions often requires sending data to cloud-based AI models, creating massive privacy vulnerabilities.

## 💡 Our Solution
ContextAgent bridges the gap between the digital and physical worlds while maintaining 100% digital sovereignty. By natively integrating a local Large Language Model (LLM) and OpenHarmony hardware sensors, ContextAgent understands *what* the user is trying to do and *where* they physically are—all without ever sending a single byte of data to the cloud.

## ✨ Key Features (Designed for the Huawei Challenge)

1. **Digital Context (Bank Pekao Integration):** Instead of reading a UI tree line-by-line, the agent naturally summarizes complex screens. (e.g., *"You are on the Bank Pekao dashboard, your balance is 12,450 PLN"*).
2. **Agentic Action:** The AI doesn't just read—it securely acts. It uses a conversational state machine to acknowledge voice requests, identify the correct UI buttons (like "Transfer"), and request final voice confirmation before executing a financial action.
3. **Physical Hardware Awareness (`@ohos.sensor`):** ContextAgent integrates natively with the device's Accelerometer and Ambient Light sensors. If a visually impaired user drops or holds their device upside down, the OS-level sensor detects the gravity shift and the agent instantly issues an auditory warning.
4. **Privacy-First Document Scanning:** Scans highly sensitive physical documents (like medical bills) using offline OCR and summarizes them locally. Zero cloud data leaks.

## 🛠️ Tech Stack & Transparency Declaration

In accordance with HackYeah Challenge Rules (Section 4), we disclose the use of the following tools and third-party components:

*   **Platform:** OpenHarmony / HarmonyOS
*   **UI Framework:** ArkUI (ArkTS)
*   **Local AI Engine:** Ollama running `gemma4:latest` (bridged via OpenHarmony HTTP module)
*   **Hardware APIs:** `@ohos.sensor` (Accelerometer, AmbientLight)
*   **AI Assistance:** An AI coding assistant was utilized to help rapidly prototype the ArkTS boilerplate and UI styling during the 24-hour hackathon.

> **Note on Text-to-Speech (TTS):** For the purpose of this visual hackathon demonstration, the agent's auditory responses are printed to the on-screen Activity Log so judges can easily read the AI's reasoning. In a production deployment, this text stream is routed directly to OpenHarmony's native `textToSpeech` API.

## 🚀 How to Run (Development)

1. Clone this repository.
2. Open the project in **DevEco Studio (6.1.1+)**.
3. Ensure you have a local instance of [Ollama](https://ollama.com/) running on your host machine serving the `gemma4:latest` model on port `11434`.
4. Run the project on the DevEco Emulator (API 11/12). 
5. The app communicates with the host machine via the `10.0.2.2` emulator bridge.

---
*Built with ❤️ in Kraków for HackYeah 2026*
