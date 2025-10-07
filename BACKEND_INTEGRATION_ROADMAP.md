# 🎯 Voice Shiksha - Backend Integration Roadmap

## **PHASE 1: Core Features (Weeks 1-2)**

### **Feature 1: Voice Recording & Pronunciation Analysis** ✅ CURRENT
**Status**: Partially Complete
**Frontend Components**:
- ✅ AudioService for recording
- ✅ RecordingButton UI
- ✅ PronunciationAnalysisService
- ✅ FeedbackCard display

**Backend Components**:
- ✅ `/analyze_pronunciation` endpoint
- ✅ CREPE pitch analysis
- ✅ Audio conversion (WebM → WAV)
- ✅ Enhanced feedback system

**Remaining Tasks**:
- [ ] Test on actual Android device
- [ ] Optimize audio quality settings
- [ ] Handle different audio formats
- [ ] Add audio compression

---

### **Feature 2: Progress Tracking & Analytics** ❌ TO IMPLEMENT
**Frontend Components Needed**:
```dart
// Models
class UserProgress {
  String userId;
  String letterName;
  List<AttemptResult> attempts;
  double bestScore;
  DateTime lastPracticed;
}

class AttemptResult {
  DateTime timestamp;
  double score;
  String level;
  Map<String, dynamic> detailedFeedback;
}

// Services
class ProgressService {
  Future<void> saveAttempt(String letter, AnalysisResult result);
  Future<UserProgress> getProgressForLetter(String letter);
  Future<List<UserProgress>> getAllProgress();
  Future<Map<String, dynamic>> getOverallStats();
}
```

**Backend Components Needed**:
```python
# Database Models
class User(db.Model):
    id = db.Column(db.String(36), primary_key=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class PronunciationAttempt(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.String(36), db.ForeignKey('user.id'))
    letter = db.Column(db.String(10), nullable=False)
    score = db.Column(db.Float, nullable=False)
    level = db.Column(db.String(20), nullable=False)
    feedback = db.Column(db.JSON)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

# API Endpoints
@app.route('/api/progress/<user_id>', methods=['GET'])
@app.route('/api/progress/<user_id>/letter/<letter>', methods=['GET'])
@app.route('/api/attempt', methods=['POST'])
```

**Integration Tasks**:
1. Add SQLite database to Flask app
2. Create user identification system
3. Implement progress saving after analysis
4. Create progress retrieval endpoints
5. Update Flutter UI to save/display progress

---

## **PHASE 2: Learning Enhancement (Weeks 3-4)**

### **Feature 3: Audio Reference Playback** ❌ TO IMPLEMENT
**Frontend Components Needed**:
```dart
class AudioReferenceService {
  Future<void> playReference(String letterName);
  Future<void> downloadReference(String letterName);
  Future<bool> isReferenceAvailable(String letterName);
}

// UI Components
class ReferenceAudioButton extends StatelessWidget {
  final String letterName;
  final VoidCallback? onPlay;
}
```

**Backend Components Needed**:
```python
# Serve reference audio files
@app.route('/api/reference-audio/<letter>')
def get_reference_audio(letter):
    # Return audio file for reference pronunciation

# Generate reference audio using TTS
@app.route('/api/generate-reference/<letter>')
def generate_reference_audio(letter):
    # Use TTS to create reference pronunciation
```

**Integration Tasks**:
1. Create/collect reference audio files
2. Add audio serving endpoints
3. Implement audio player in Flutter
4. Add play button to letter cards
5. Cache audio files locally

---

### **Feature 4: Pronunciation Comparison** ❌ TO IMPLEMENT
**Frontend Components Needed**:
```dart
class PitchVisualizationWidget extends StatelessWidget {
  final List<double> userPitchData;
  final List<double> referencePitchData;
  final bool showComparison;
}

class ComparisonAnalysisService {
  Future<ComparisonResult> compareWithReference(
    String audioPath, 
    String referencePath
  );
}
```

**Backend Components Needed**:
```python
@app.route('/api/detailed-analysis', methods=['POST'])
def detailed_analysis():
    # Return pitch data arrays for visualization
    return {
        'user_pitch': [freq1, freq2, ...],
        'reference_pitch': [ref1, ref2, ...],
        'time_points': [t1, t2, ...],
        'similarities': {...}
    }
```

**Integration Tasks**:
1. Extract pitch data arrays from analysis
2. Create pitch visualization widget
3. Implement real-time comparison
4. Add detailed analysis endpoint
5. Create comparison UI screen

---

## **PHASE 3: Gamification (Weeks 5-6)**

### **Feature 5: Achievement System** ❌ TO IMPLEMENT
**Frontend Components Needed**:
```dart
class Achievement {
  String id;
  String title;
  String description;
  String iconPath;
  bool isUnlocked;
  DateTime? unlockedAt;
}

class AchievementService {
  Future<List<Achievement>> getUserAchievements();
  Future<void> checkForNewAchievements();
}
```

**Backend Components Needed**:
```python
class Achievement(db.Model):
    id = db.Column(db.String(50), primary_key=True)
    title = db.Column(db.String(100))
    description = db.Column(db.String(200))
    condition_type = db.Column(db.String(50))  # 'score', 'streak', 'attempts'
    condition_value = db.Column(db.Float)

@app.route('/api/achievements/<user_id>')
def get_achievements(user_id):
    # Return user's achievements with unlock status
```

**Integration Tasks**:
1. Define achievement criteria
2. Implement achievement checking logic
3. Create achievement UI components
4. Add achievement notifications
5. Store achievement progress

---

### **Feature 6: Voice Games Integration** ❌ TO IMPLEMENT
**Frontend Components Needed**:
```dart
class VoiceGame {
  String gameId;
  String title;
  String description;
  GameType type; // SPEED_PRACTICE, SOUND_MATCH, etc.
}

class GameSession {
  String sessionId;
  String gameId;
  List<GameRound> rounds;
  int totalScore;
  DateTime startTime;
}
```

**Backend Components Needed**:
```python
@app.route('/api/games/<game_id>/session', methods=['POST'])
def start_game_session(game_id):
    # Initialize new game session
    
@app.route('/api/games/session/<session_id>/round', methods=['POST'])
def submit_game_round(session_id):
    # Process game round with voice input
```

**Integration Tasks**:
1. Design game mechanics
2. Create game session management
3. Implement real-time scoring
4. Add game UI screens
5. Store game statistics

---

## **IMPLEMENTATION PRIORITY ORDER**

### **Next Up: Progress Tracking (Feature 2)**
**Why First?**: Essential for user engagement and learning tracking
**Complexity**: Medium
**Dependencies**: None
**Estimated Time**: 3-4 days

### **Files to Create/Modify**:
```
Backend:
- models.py (new) - Database models
- database.py (new) - Database initialization  
- progress_routes.py (new) - Progress API endpoints
- app.py (modify) - Add database integration

Frontend:
- lib/models/user_progress.dart (new)
- lib/services/progress_service.dart (new)
- lib/screens/progress_screen.dart (modify)
- lib/screens/speak_screen.dart (modify) - Add progress saving
```

## **GETTING STARTED**

Ready to implement **Progress Tracking**? Let me know and I'll:

1. ✅ Set up SQLite database with Flask-SQLAlchemy
2. ✅ Create user and progress models
3. ✅ Add progress tracking endpoints
4. ✅ Update Flutter app to save/retrieve progress
5. ✅ Enhance progress screen with real data

Which feature would you like to tackle first? 🚀