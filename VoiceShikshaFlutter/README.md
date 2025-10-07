# Voice Shiksha Flutter App

A Flutter mobile application for Voice Shiksha - empowering speech practice for kids through voice and pitch recognition.

## 🚀 Features

- **Interactive Voice Practice**: Record and analyze pronunciation of Hindi vowels
- **Real-time Feedback**: Get immediate feedback on pronunciation accuracy
- **Learning Module**: Study letters with visual aids and hints
- **Games & Activities**: Engaging voice-based games for learning
- **Progress Tracking**: Monitor learning progress and achievements
- **Child-Friendly UI**: Colorful, animated interface designed for children

## 📱 Screens

1. **Home Screen**: Main navigation hub with animated background
2. **Speak Screen**: Core pronunciation practice with recording
3. **Learn Screen**: Interactive letter learning with navigation
4. **Songs Screen**: Musical learning content (placeholder)
5. **Games Screen**: Voice-based learning games (placeholder)
6. **Progress Screen**: Learning analytics and achievements

## 🛠️ Technical Stack

- **Framework**: Flutter 3.x with Dart
- **State Management**: Built-in StatefulWidget
- **Audio Recording**: `record` package
- **HTTP Requests**: `dio` package for API communication
- **Permissions**: `permission_handler` for microphone access
- **UI**: Custom widgets with gradients and animations

## 📋 Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter plugin
- Android device/emulator with API level 21+

## 🔧 Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd VoiceShiksha-main/VoiceShikshaFlutter
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the Flask server** (required for pronunciation analysis):
   ```bash
   cd ../
   python app.py
   ```

4. **Run the Flutter app**:
   ```bash
   flutter run
   ```

## 🔗 Backend Integration

The app communicates with a Flask server running on `localhost:5000` for pronunciation analysis:

- **Endpoint**: `POST /analyze_pronunciation`
- **Payload**: Audio file + target letter
- **Response**: Analysis results with score and feedback

### Server Configuration

Update the server URL in `lib/services/pronunciation_service.dart` if needed:

```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:5000';
```

## 📱 Permissions

The app requires the following permissions:

- **RECORD_AUDIO**: For voice recording
- **INTERNET**: For server communication
- **WRITE_EXTERNAL_STORAGE**: For temporary audio files
- **READ_EXTERNAL_STORAGE**: For accessing audio files

## 🎨 UI Components

### Custom Widgets

- **AnimatedBackground**: Floating shapes with gradient background
- **GradientButton**: Customizable gradient buttons with animations
- **LetterCard**: Interactive letter display with recording status
- **RecordingButton**: Animated microphone button with pulse effects
- **FeedbackCard**: Score display with progress indicators

### Design System

- **Colors**: Purple gradient theme with accent colors
- **Typography**: Comic Sans-inspired friendly fonts
- **Animations**: Smooth transitions and micro-interactions
- **Layout**: Responsive design for various screen sizes

## 📊 Features in Detail

### Voice Recording & Analysis

```dart
// Start recording
await _audioService.startRecording(letterName);

// Stop recording and analyze
final recordingPath = await _audioService.stopRecording();
final result = await _analysisService.analyzePronunciation(
  audioFilePath: recordingPath,
  targetLetter: targetLetter,
);
```

### Progress Tracking

- Individual letter scores and attempts
- Overall performance metrics
- Achievement system
- Learning streak tracking

### Responsive Design

The app adapts to different screen sizes and orientations:

- Flexible layouts using `Expanded` and `Flexible`
- Responsive text sizing with `clamp()`
- Adaptive grid layouts for various devices

## 🔧 Development

### Adding New Letters

1. Update `lib/models/letter.dart`:
   ```dart
   static const List<Letter> hindiVowels = [
     Letter(
       character: "अ",
       hint: 'Say "A" like in "Apple"',
       pronunciation: "A",
       audioFile: "A.wav",
     ),
     // Add new letters here
   ];
   ```

2. Add corresponding audio files to backend

### Adding New Screens

1. Create screen file in `lib/screens/`
2. Import and add navigation in `home_screen.dart`
3. Update routing if using named routes

## 🧪 Testing

Run tests with:

```bash
flutter test
```

For widget testing, see examples in `test/` directory.

## 📦 Building

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
```

### Install on Device
```bash
flutter install
```

## 🔍 Troubleshooting

### Common Issues

1. **Server Connection Failed**:
   - Ensure Flask server is running on `localhost:5000`
   - Check network connectivity
   - Verify server URL in `pronunciation_service.dart`

2. **Recording Permission Denied**:
   - Grant microphone permission in device settings
   - Check `android/app/src/main/AndroidManifest.xml` permissions

3. **Audio Analysis Failed**:
   - Verify audio file format (WAV expected)
   - Check server logs for processing errors
   - Ensure target letter exists in CSV dataset

### Debug Mode

Enable debug logging in `main.dart`:

```dart
void main() {
  if (kDebugMode) {
    print('Debug mode enabled');
  }
  runApp(const VoiceShikshaApp());
}
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Community packages for audio recording and HTTP requests
- Design inspiration from child-friendly educational apps