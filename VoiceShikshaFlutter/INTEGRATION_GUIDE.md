# 🔧 Voice Shiksha - Integration & Troubleshooting Guide

## ✅ What We've Fixed

### 1. **UI Overflow Issues**
- ✅ Made layouts responsive with `MediaQuery`
- ✅ Added `FittedBox` and `Flexible` widgets
- ✅ Reduced font sizes and padding for smaller screens
- ✅ Used `SingleChildScrollView` for overflow handling

### 2. **Backend Integration** 
- ✅ Added CORS support for web requests
- ✅ Enhanced error handling and logging
- ✅ Improved API response format
- ✅ Added server health check endpoint
- ✅ Web-compatible audio service

## 🚀 How to Run the Integrated App

### **Option 1: Automated Setup**
```bash
# Run the setup script
F:\Projects\VoiceShiksha-main\start_full_app.bat
```

### **Option 2: Manual Setup**

#### **Step 1: Start Backend Server**
```bash
cd "F:\Projects\VoiceShiksha-main"
pip install flask-cors  # If not already installed
python app.py
```

#### **Step 2: Start Flutter App**
```bash
cd "F:\Projects\VoiceShiksha-main\VoiceShikshaFlutter"
H:\Requirements\FlutterSDK\flutter\bin\flutter.bat run -d chrome
```

## 🔍 Testing the Integration

1. **Backend Health Check**:
   - Open: http://localhost:5000
   - Should show: `{"message": "Voice Shiksha API is running!", "status": "healthy"}`

2. **Flutter App**:
   - Should open in Chrome automatically
   - Navigate to "🎤 Start Speaking"
   - Try recording a vowel sound

3. **Integration Test**:
   - Record pronunciation → Should send to Flask server
   - Server analyzes → Returns score and feedback
   - Flutter displays → Shows results in UI

## 🐛 Common Issues & Solutions

### **Issue 1: Flutter Import Errors**
```
Error: Package URIs must start with the package name followed by a '/'
```
**Solution**: Fixed - Updated import statements in `audio_service.dart`

### **Issue 2: CORS Errors in Web**
```
Access to XMLHttpRequest blocked by CORS policy
```
**Solution**: Added `flask-cors` to backend server

### **Issue 3: Permission Handler Web Issues**
```
Permission handler not compatible with web
```
**Solution**: Removed permission_handler, using browser permissions instead

### **Issue 4: UI Overflow on Small Screens**
```
RenderFlex overflowed by X pixels
```
**Solution**: Added responsive layouts with `FittedBox` and `Flexible`

### **Issue 5: Server Connection Failed**
```
Cannot connect to server at localhost:5000
```
**Solutions**:
- Ensure Flask server is running
- Check if port 5000 is available
- Verify firewall settings

## 📱 Platform-Specific Notes

### **Web (Chrome)**
- ✅ UI works perfectly
- ✅ Navigation and animations work
- ⚠️ Audio recording has limitations (browser permissions)
- ✅ Mock analysis results for testing

### **Android** (When properly set up)
- ✅ Full audio recording capabilities
- ✅ Real-time pronunciation analysis
- ✅ All features work natively

### **Desktop** (Windows)
- ✅ UI works well
- ✅ Audio recording possible
- ✅ Direct server communication

## 🎯 Integration Features

### **Frontend → Backend Flow**
1. User records audio in Flutter app
2. Audio saved as WAV file
3. HTTP POST to `/analyze_pronunciation`
4. Flask server processes with CREPE/Librosa
5. Returns JSON with score and feedback
6. Flutter displays results with animations

### **API Endpoints**

#### **GET /** - Health Check
```json
{
  "message": "Voice Shiksha API is running!",
  "status": "healthy",
  "endpoints": {
    "practice": "/practice",
    "analyze": "/analyze_pronunciation"
  }
}
```

#### **POST /analyze_pronunciation** - Main Analysis
**Request**:
- `audio`: WAV file
- `target`: Letter name (e.g., "A", "Aaa")

**Response**:
```json
{
  "success": true,
  "feedback": "✅ Excellent pronunciation! Pitch pattern matches very well.",
  "score": 87.5,
  "level": "Excellent",
  "detailed_feedback": {
    "pitch_level": "✅ Pitch level is appropriate.",
    "stability": "✅ Good pitch stability.",
    "similarities": { ... }
  }
}
```

## 🔧 Advanced Configuration

### **Change Server URL**
Edit `lib/services/pronunciation_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:5000';
```

### **Enable Debug Logging**
Both Flutter and Flask have detailed logging enabled:
- Flutter: Console logs with 🎤, 📁, ✅, ❌ emojis
- Flask: Request/response logging with colored output

### **Audio Format Support**
- Input: WebM (from browser)
- Processing: WAV (converted by pydub)
- Analysis: 16kHz, 16-bit PCM

## 🎉 Success Indicators

When everything works correctly, you should see:

1. **Flask Server Console**:
   ```
   🚀 Starting Voice Shiksha Flask server...
   📍 Server will be available at: http://localhost:5000
   📥 Received pronunciation analysis request
   🎯 Target letter: A
   ✅ Analysis completed successfully
   ```

2. **Flutter Console**:
   ```
   🎤 Starting pronunciation analysis for: A
   🔍 Checking server connection at: http://localhost:5000
   ✅ Server is reachable
   🚀 Sending request to: http://localhost:5000/analyze_pronunciation
   ✅ Server response status: 200
   ```

3. **Browser**:
   - Smooth animations and transitions
   - Responsive layout on all screen sizes
   - Clear feedback and scoring display

The integration is now complete and ready for testing! 🚀