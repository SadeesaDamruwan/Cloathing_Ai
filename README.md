# Clothing AI 👕🤖

**Clothing AI** is a full-stack, cross-platform mobile application built with Flutter and Firebase. It serves as a personal digital closet and an intelligent fashion assistant. By integrating the Cerebras LLM, real-time weather data, and the Google Serper API, the app provides smart, weather-contextualized outfit recommendations and live web shopping links.

## ✨ Key Features

* **Digital Closet Management:** Upload, categorize (Tops, Bottoms, Accessories), and manage clothing items using device cameras or gallery imports.
* **AI Personal Stylist:** Powered by the Cerebras LLM (Llama 3.1) to generate concise, highly personalized outfit combinations based *strictly* on the clothes in the user's digital closet.
* **Weather-Aware Recommendations:** Integrates the Open-Meteo API and Geolocator to suggest outfits appropriate for the user's exact local temperature.
* **Hands-Free Voice Controls:** Features native Speech-to-Text (STT) for voice prompting and On-Device Text-to-Speech (TTS) for the AI's responses.
* **Live Personal Shopper:** Connects to the Google Serper API to search the web and return purchase links for clothing items the user wants to buy.
* **Secure Cloud Syncing:** Utilizes Firebase Authentication and Cloud Firestore for secure, real-time data synchronization across sessions.
* **Custom Neumorphic UI:** A beautiful, soft-UI design language implemented globally across the app.

## 🏗️ Architecture

This project strictly follows **Clean Architecture** principles to separate concerns, ensure scalability, and make the codebase highly maintainable:

* **`presentation/`**: Contains all UI components, screens, and custom widgets (like the global `NeumorphicContainer`).
* **`data/models/`**: Houses the data blueprints (e.g., `UserModel`, `PostModel`) for parsing Firestore documents.
* **`data/services/`**: Contains the isolated business logic and external API integrations (`AuthService`, `DatabaseService`, `AiService`).

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing.

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest stable version)
* An active [Firebase Project](https://firebase.google.com/)
* API Keys for [Cerebras AI](https://cerebras.ai/) and [Serper (Google Search API)](https://serper.dev/)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/YourUsername/clothing-ai.git](https://github.com/YourUsername/clothing-ai.git)
    cd clothing-ai
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration:**
    * This project uses `flutterfire_cli`. Ensure your `firebase_options.dart` file is correctly configured for your specific Firebase project.
    * Ensure your Firestore Security Rules are set up to only allow authenticated users to read/write their own `user_closets` documents.

4.  **API Key Setup:**
    * Navigate to `lib/data/services/ai_service.dart`.
    * Replace the placeholder strings with your active Cerebras and Serper API keys:
        ```dart
        final String _cerebrasKey = "YOUR_CEREBRAS_API_KEY";
        final String _serperKey = "YOUR_SERPER_API_KEY";
        ```

5.  **Run the app:**
    ```bash
    flutter run
    ```

## 🛠️ Tech Stack

* **Framework:** Flutter / Dart
* **Backend:** Firebase (Authentication, Cloud Firestore, Storage)
* **AI / LLM:** Cerebras API (Llama 3.1 8B)
* **External APIs:** Open-Meteo API (Weather), Google Serper API (Shopping)
* **Key Packages:** `speech_to_text`, `flutter_tts`, `geolocator`, `image_picker`, `http`, `url_launcher`

## 👨‍💻 About the Author

**Sadeesa Damruwan (Kakashi_EvoX)**
Software Engineering undergraduate at NSBM Green University and founder of Technova Solutions. Passionate about cross-platform mobile development, clean code architecture, and integrating AI to solve real-world problems. When I'm not coding, I'm usually building PCs, hitting the gym, or playing Rainbow Six Siege.

* [GitHub](https://github.com/YourUsername)
* [LinkedIn](https://linkedin.com/in/YourProfile)
