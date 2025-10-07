# 🎤 Voice Shiksha - AI-Powered Hindi Pronunciation Learning App

**Empowering speech practice for kids through advanced voice and pitch recognition technology.**

![Voice Shiksha Banner](https://img.shields.io/badge/Voice-Shiksha-pink?style=for-the-badge&logo=android)
![Flutter](https://img.shields.io/badge/Flutter-Mobile-blue?style=for-the-badge&logo=flutter)
![Flask](https://img.shields.io/badge/Flask-Backend-green?style=for-the-badge&logo=flask)
![TensorFlow](https://img.shields.io/badge/TensorFlow-AI-orange?style=for-the-badge&logo=tensorflow)

---

## 🌟 About the Project

**Voice Shiksha** is an innovative AI-powered mobile application designed to help children with hearing and speech disabilities practice Hindi pronunciation through real-time analysis and feedback. The app combines advanced machine learning techniques with an intuitive Flutter interface to provide comprehensive pronunciation coaching.

Whether it's learning to say "अ" (A) or improving vocal pitch accuracy, this app supports consistent practice and growth with kindness, clarity, and scientific precision.

## ✨ Key Features

### 🎯 Core Learning Features
- **Real-time Pronunciation Analysis** - Advanced AI analysis using TensorFlow and CREPE
- **Interactive Learning Interface** - Beautiful Flutter mobile app with child-friendly design
- **Reference Audio Playback** - Listen to correct pronunciations with the "Listen" button
- **Comprehensive Feedback** - Detailed scores (0-100), improvement suggestions, and voice coaching
- **Voice Characteristics Analysis** - Pitch, jitter, shimmer, and stability metrics
- **Progress Tracking** - Analysis history and detailed metrics dashboard

### 🔬 Technical Innovations
- **CREPE-based Pitch Extraction** - High-accuracy fundamental frequency detection
- **Multiple Similarity Metrics** - DTW, correlation, RMSE analysis for comprehensive comparison
- **Adaptive Thresholds** - Dynamic confidence and outlier filtering
- **Cross-platform Support** - Android and iOS compatibility
- **Cloud-ready Backend** - Easy deployment to Railway/Heroku for global accessibility

## 🏗️ System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│  Flutter App    │───▶│  Flask Backend  │───▶│  ML Analysis    │
│  (Mobile UI)    │    │  (REST API)     │    │  (TensorFlow)   │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        │                       │                       │
   ┌────▼────┐             ┌────▼────┐             ┌────▼────┐
   │Audio    │             │Audio    │             │CREPE    │
   │Recording│             │Storage  │             │Pitch    │
   │& Playback│            │& Serving│             │Analysis │
   └─────────┘             └─────────┘             └─────────┘
```

## 📊 Analysis Output Example

```
==================================================
📈 COMPREHENSIVE PITCH ANALYSIS
==================================================

🎯 Overall Score: 75.2/100 (Good Progress!)
📝 ✅ Good pronunciation! Keep practicing for perfection.

📊 Detailed Metrics:
   • DTW Similarity: 78.5/100
   • Feature Similarity: 72.1/100
   • Correlation: 0.801
   • RMSE Similarity: 75.3/100

🎵 Voice Characteristics:
   • Mean Pitch: 235.7 Hz
   • Pitch Range: 145.2 Hz
   • Jitter: 3.24%
   • Shimmer: 4.18%

💡 Specific Feedback:
   • 🔊 Your pitch level is good. Keep it consistent.
   • 📈 Excellent pitch stability - well done!
```

---

##  Features

-  **Interactive Alphabet Practice**  
  Users are guided to pronounce alphabets like **A**, **B**, **C**, etc., one by one.

-  **Voice Recording and Analysis**  
  Users can record their pronunciation and compare pitch and clarity with reference values.

-  **Pitch Matching Engine**  
  Uses tools like **CREPE**, **Librosa**, and **FastDTW** to match the pitch of spoken audio with expected values.

-  **CSV-Based Reference System**  
  Reference pitch values for each letter are stored in a CSV and compared with user input.

-  **Real-Time Feedback**  
  Get immediate success or retry feedback based on pronunciation accuracy.

-  **Child-Friendly Design**  
  A bright, simple, and colorful interface that’s easy for young learners to use without getting overwhelmed.

---
