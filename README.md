# EchoMirror 🪞✨

An AI-powered self-reflection journal app that transforms your daily thoughts into surreal alternate-reality stories.

![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?style=flat&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 🌟 Features

- **Voice & Text Input** - Record reflections via voice (with real-time transcription) or type them directly
- **Emotion Detection** - On-device facial expression analysis using ML Kit
- **Sentiment Analysis** - Privacy-first text analysis running entirely on-device
- **Genre-Based Stories** - Transform your emotions into narratives across 4 unique genres:
  - 🌃 **Cyberpunk** - Neon-drenched dystopian adventures
  - ⚔️ **Fantasy** - Magical realms and ancient powers
  - 👁️ **Horror** - Eldritch mysteries and cosmic truths
  - 🌱 **Solarpunk** - Utopian futures in harmony with nature
- **AI Image Generation** - Create artwork for your stories via Replicate API
- **TTS Narration** - Listen to your echo stories with genre-appropriate voice styles
- **Share & Export** - Save and share your creations as images or PDFs

## 🔒 Privacy First

- **All core ML runs on-device** - Your reflections never leave your phone
- **Encrypted local storage** - Secure data with AES-256 encryption
- **No analytics without consent** - GDPR compliant design
- **Full data export/delete** - You own your data

## 📱 Screenshots

*Coming soon*

## 🚀 Getting Started

### Prerequisites

- Flutter 3.19+ with Dart 3.3+
- Android Studio / Xcode for platform builds
- (Optional) Replicate API key for image generation

### Installation

```bash
# Clone the repository
git clone https://github.com/middesurya/EchoMirror.git
cd EchoMirror

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Configuration

1. **Replicate API (Optional)**: For AI image generation, add your API key in Settings → Replicate API Key

## 🏗️ Architecture

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # App configuration
├── core/
│   ├── router/              # Navigation
│   ├── services/            # Business logic services
│   └── theme/               # Material 3 theming
├── features/
│   ├── home/                # Home screen
│   ├── reflection/          # Input screens
│   ├── output/              # Echo display
│   ├── history/             # Past reflections
│   └── settings/            # App settings
├── providers/               # Riverpod state management
└── shared/
    └── models/              # Data models
```

### Tech Stack

- **State Management**: Riverpod 2.5+
- **Storage**: Hive (local) + Flutter Secure Storage (encrypted)
- **ML**: Google ML Kit (face detection), rule-based sentiment analysis
- **Audio**: speech_to_text + flutter_tts + record
- **Image Generation**: Replicate API (Stable Diffusion XL)
- **UI**: Material 3 + flutter_animate

## 🧠 How It Works

1. **Input**: User shares their reflection via voice or text
2. **Analysis**: 
   - Speech-to-text transcription (on-device)
   - Optional face capture for emotion detection
   - Sentiment analysis extracts mood, keywords, themes
3. **Generation**: 
   - Emotion maps to narrative elements (archetype, setting, power)
   - Genre template weaves elements into a unique story
   - Optional AI image generation
4. **Output**: Full story display with narration and sharing options

## 🎭 Emotion → Narrative Mapping

| Emotion | Archetype | Setting | Power |
|---------|-----------|---------|-------|
| Happy | Radiant Hero | Golden Spire City | Luminescence |
| Sad | Wandering Poet | Rain-soaked Streets | Empathic Resonance |
| Angry | Storm Wielder | Volcanic Forge | Righteous Flame |
| Anxious | Labyrinth Walker | Infinite Maze | Prescient Sight |
| Neutral | Silent Observer | Liminal Twilight | Temporal Pause |

## 📝 TODO

- [ ] Add TFLite sentiment model for better accuracy
- [ ] Implement Lottie loading animations
- [ ] Add mood trends visualization
- [ ] Cloud backup (opt-in)
- [ ] Widget for home screen
- [ ] Watch app companion

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Surya Midde**
- GitHub: [@middesurya](https://github.com/middesurya)

---

*Transform your reflections into epic adventures. What story will your emotions tell today?* ✨
