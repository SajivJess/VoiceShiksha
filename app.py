from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from pitch import EnhancedPitchAnalyzer
import os
from pydub import AudioSegment
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes to allow Flutter web access

analyzer = EnhancedPitchAnalyzer("hindi_pitch_dataset.csv")

@app.route('/')
def home():
    return jsonify({
        "message": "Voice Shiksha API is running!",
        "status": "healthy",
        "endpoints": {
            "practice": "/practice",
            "analyze": "/analyze_pronunciation"
        }
    })

@app.route('/practice')
def practice():
    return jsonify({
        "message": "Voice practice endpoint - use Flutter app for UI",
        "status": "available",
        "instructions": "This is an API endpoint. Use the Flutter mobile app for the user interface."
    })

@app.route('/audio/<letter>')
def get_reference_audio(letter):
    """Serve reference audio files for the Listen button functionality"""
    try:
        # Map Hindi characters to English equivalents for file lookup
        hindi_to_english = {
            'अ': 'A',
            'आ': 'Aaa', 
            'इ': 'e',
            'ई': 'eee',
            'उ': 'u',
            'ऊ': 'Uuu',
            'ए': 'Ea',
            'ऐ': 'Eaa',
            'ओ': 'O',
            'औ': 'Oo',
            'अं': 'angg',
            'री': 'rii',
            'हहा': 'hahaa'
        }
        
        # Get the English equivalent for file lookup
        english_letter = hindi_to_english.get(letter, letter)
        audio_file_path = f"data/{english_letter}.mpeg"
        
        if os.path.exists(audio_file_path):
            logger.info(f"🔊 Serving reference audio: {audio_file_path} for letter: {letter}")
            return send_file(audio_file_path, mimetype='audio/mpeg')
        else:
            logger.warning(f"❌ Reference audio not found: {audio_file_path}")
            return jsonify({
                "success": False,
                "message": f"Reference audio not available for '{letter}'"
            }), 404
            
    except Exception as e:
        logger.error(f"❌ Error serving reference audio: {str(e)}")
        return jsonify({
            "success": False,
            "message": f"Error loading audio: {str(e)}"
        }), 500

@app.route('/analyze_pronunciation', methods=['POST', 'OPTIONS'])
def analyze():
    # Handle CORS preflight requests
    if request.method == 'OPTIONS':
        response = jsonify({'status': 'ok'})
        response.headers.add('Access-Control-Allow-Origin', '*')
        response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
        response.headers.add('Access-Control-Allow-Methods', 'POST')
        return response
    
    try:
        logger.info("📥 Received pronunciation analysis request")
        
        # Validate request
        if "audio" not in request.files or "target" not in request.form:
            logger.error("❌ Missing audio file or target parameter")
            return jsonify({
                "success": False, 
                "message": "Missing audio file or target parameter"
            }), 400

        file = request.files["audio"]
        target = request.form["target"]
        
        logger.info(f"🎯 Target letter: {target}")
        logger.info(f"📁 Audio file: {file.filename}")

        # Create uploads directory
        os.makedirs("uploads", exist_ok=True)

        # Save uploaded file
        webm_path = f"uploads/{target}.webm"
        file.save(webm_path)
        
        # Get actual file size after saving
        actual_file_size = os.path.getsize(webm_path)
        logger.info(f"💾 Saved audio file to: {webm_path}, Actual size: {actual_file_size} bytes")

        # Convert webm → wav
        try:
            audio = AudioSegment.from_file(webm_path)
            wav_path = f"uploads/{target}.wav"
            audio.export(wav_path, format="wav")
            logger.info(f"🔄 Converted audio to: {wav_path}")
        except Exception as e:
            logger.error(f"❌ Audio conversion failed: {e}")
            return jsonify({
                "success": False, 
                "message": f"Audio conversion failed: {str(e)}"
            }), 500

        # Analyze pronunciation
        logger.info("🔍 Starting pronunciation analysis...")
        results = analyzer.analyze_pronunciation(target, audio_path=wav_path)

        if results:
            logger.info("✅ Analysis completed successfully")
            return jsonify({
                "success": True,
                "feedback": results['feedback']['overall'],
                "score": results['feedback']['composite_score'],
                "level": results['feedback']['level'],
                "detailed_feedback": {
                    "pitch_level": results['feedback'].get('pitch_level', ''),
                    "stability": results['feedback'].get('stability', ''),
                    "similarities": results['similarities'],
                    "voice_characteristics": results.get('voice_characteristics', {})
                }
            })
        else:
            logger.error("❌ Analysis returned no results")
            return jsonify({
                "success": False, 
                "message": "Analysis failed - no results returned"
            }), 500

    except Exception as e:
        logger.error(f"❌ Unexpected error during analysis: {str(e)}")
        return jsonify({
            "success": False, 
            "message": f"Server error: {str(e)}"
        }), 500

if __name__ == '__main__':
    import os
    port = int(os.environ.get('PORT', 5000))
    logger.info("🚀 Starting Voice Shiksha Flask server...")
    logger.info(f"📍 Server will be available at: http://0.0.0.0:{port}")
    logger.info("🔗 Flutter app should connect to this URL")
    app.run(debug=False, host='0.0.0.0', port=port)
