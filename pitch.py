import librosa
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from fastdtw import fastdtw
from scipy import signal, stats
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_squared_error
import os
import warnings
import json
warnings.filterwarnings('ignore')

class EnhancedPitchAnalyzer:
    def __init__(self, reference_csv_path="hindi_pitch_dataset.csv"):
        """
        Enhanced pitch analyzer with multiple improvements:
        - Adaptive thresholds
        - Multiple similarity metrics
        - Noise filtering
        - Statistical analysis
        """
        self.reference_table = pd.read_csv(reference_csv_path)
        self.sr = 16000
        self.hop_length = 160 
        
        # Hindi to English character mapping for dataset lookup
        self.hindi_to_english = {
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
        
    def load_and_preprocess_audio(self, audio_path):
        """Enhanced audio preprocessing with noise reduction"""
        try:
            
            audio, _ = librosa.load(audio_path, sr=self.sr, mono=True)
            
           
            audio = signal.lfilter([1, -0.97], [1], audio)
            
          
            audio = librosa.util.normalize(audio)
            
           
            nyquist = self.sr // 2
            cutoff = min(4000, nyquist - 100) 
            sos = signal.butter(5, cutoff / nyquist, btype='low', output='sos')
            audio = signal.sosfilt(sos, audio)
            
            return audio
        except Exception as e:
            print(f"❌ Error loading audio: {e}")
            return None
    
    def extract_pitch_features(self, audio):
        """Enhanced pitch extraction using librosa instead of CREPE"""
        try:
            # Use librosa's piptrack for pitch extraction
            pitches, magnitudes = librosa.piptrack(y=audio, sr=self.sr, threshold=0.1, fmin=80, fmax=1000)
            
            # Extract the most prominent pitch at each time step
            times = librosa.frames_to_time(np.arange(pitches.shape[1]), sr=self.sr, hop_length=512)
            frequency = []
            confidence = []
            
            for t in range(pitches.shape[1]):
                index = magnitudes[:, t].argmax()
                pitch = pitches[index, t]
                
                if pitch > 0:
                    frequency.append(pitch)
                    confidence.append(magnitudes[index, t])
                else:
                    # Use harmonic analysis as fallback
                    f0 = librosa.yin(audio, fmin=80, fmax=1000, sr=self.sr, frame_length=2048, hop_length=512)
                    if t < len(f0) and f0[t] > 0:
                        frequency.append(f0[t])
                        confidence.append(0.8)  # Default confidence for YIN
                    else:
                        frequency.append(0)
                        confidence.append(0)
            
            # Create DataFrame
            df = pd.DataFrame({
                "Time (s)": times[:len(frequency)],
                "Pitch (Hz)": frequency,
                "Confidence": confidence
            })
            
            # Filter by confidence
            conf_threshold = max(0.5, np.percentile(df["Confidence"], 50))  # Lowered for librosa
            df = df[df["Confidence"] > conf_threshold]
            
            # Remove zero pitches
            df = df[df["Pitch (Hz)"] > 0]
            
            # Outlier removal
            if not df.empty:
                pitch_median = df["Pitch (Hz)"].median()
                pitch_std = df["Pitch (Hz)"].std()
                
                min_pitch = max(80, pitch_median - 3 * pitch_std)
                max_pitch = min(1000, pitch_median + 3 * pitch_std)
                
                df = df[(df["Pitch (Hz)"] >= min_pitch) & (df["Pitch (Hz)"] <= max_pitch)]
            
            if df.empty:
                return None, None
            
            # IQR-based outlier removal
            Q1 = df["Pitch (Hz)"].quantile(0.25)
            Q3 = df["Pitch (Hz)"].quantile(0.75)
            IQR = Q3 - Q1
            lower_bound = Q1 - 1.5 * IQR
            upper_bound = Q3 + 1.5 * IQR
            df = df[(df["Pitch (Hz)"] >= lower_bound) & (df["Pitch (Hz)"] <= upper_bound)]
            
            # Apply median filter for smoothing
            df["Pitch (Hz)"] = signal.medfilt(df["Pitch (Hz)"], kernel_size=5)
            
            return df, self._extract_advanced_features(df)
            
        except Exception as e:
            print(f"❌ Error in pitch extraction: {e}")
            return None, None
    
    def _extract_advanced_features(self, df):
        """Extract comprehensive pitch features"""
        pitch_values = df["Pitch (Hz)"].values
        
        features = {
            'mean_pitch': float(np.mean(pitch_values)),
            'median_pitch': float(np.median(pitch_values)),
            'std_pitch': float(np.std(pitch_values)),
            'pitch_range': float(np.ptp(pitch_values)),  # peak-to-peak
            'pitch_variance': float(np.var(pitch_values)),
            'pitch_skewness': float(stats.skew(pitch_values)),
            'pitch_kurtosis': float(stats.kurtosis(pitch_values)),
            'pitch_slope': float(self._calculate_pitch_slope(df)),
            'jitter': float(self._calculate_jitter(pitch_values)),
            'shimmer': float(self._calculate_shimmer(pitch_values)),
            'voiced_frames_ratio': float(len(df) / max(len(df), 1))
        }
        
        return features
    
    def _calculate_pitch_slope(self, df):
        """Calculate overall pitch trend"""
        if len(df) < 2:
            return 0
        x = np.arange(len(df))
        slope, _, _, _, _ = stats.linregress(x, df["Pitch (Hz)"])
        return slope
    
    def _calculate_jitter(self, pitch_values):
        """Calculate pitch jitter (period-to-period variation)"""
        if len(pitch_values) < 2:
            return 0
        periods = 1.0 / pitch_values  # Convert Hz to periods
        period_diffs = np.abs(np.diff(periods))
        return np.mean(period_diffs) / np.mean(periods) * 100  # Percentage
    
    def _calculate_shimmer(self, pitch_values):
        """Calculate amplitude shimmer approximation using pitch variation"""
        if len(pitch_values) < 2:
            return 0
        pitch_diffs = np.abs(np.diff(pitch_values))
        return np.mean(pitch_diffs) / np.mean(pitch_values) * 100  # Percentage
    
    def advanced_similarity_analysis(self, child_features, ref_features, child_pitch, ref_pitch_contour):
        """Multiple similarity metrics for comprehensive analysis"""
        similarities = {}
        
        # DTW analysis
        dtw_distance, _ = fastdtw(child_pitch.tolist(), ref_pitch_contour.tolist(), 
                                 dist=lambda x, y: abs(x - y))
        similarities['dtw_distance'] = float(dtw_distance)
        similarities['dtw_similarity'] = float(max(0, 100 - (dtw_distance / 10)))
        
        # Feature-based similarity
        feature_keys = ['mean_pitch', 'std_pitch', 'pitch_range', 'jitter', 'shimmer']
        feature_distances = []
        
        for key in feature_keys:
            if key in child_features and key in ref_features:
                child_val = child_features[key]
                ref_val = ref_features[key]
                if ref_val != 0:
                    normalized_diff = abs(child_val - ref_val) / abs(ref_val)
                    feature_distances.append(normalized_diff)
        
        similarities['feature_similarity'] = float(max(0, 100 - np.mean(feature_distances) * 100))
        
        # Correlation analysis
        if len(child_pitch) == len(ref_pitch_contour):
            correlation = np.corrcoef(child_pitch, ref_pitch_contour)[0, 1]
            similarities['correlation'] = float(correlation if not np.isnan(correlation) else 0)
        else:
            # Resample to same length
            from scipy.interpolate import interp1d
            target_length = min(len(child_pitch), len(ref_pitch_contour))
            
            child_interp = interp1d(np.linspace(0, 1, len(child_pitch)), child_pitch)
            ref_interp = interp1d(np.linspace(0, 1, len(ref_pitch_contour)), ref_pitch_contour)
            
            child_resampled = child_interp(np.linspace(0, 1, target_length))
            ref_resampled = ref_interp(np.linspace(0, 1, target_length))
            
            correlation = np.corrcoef(child_resampled, ref_resampled)[0, 1]
            similarities['correlation'] = float(correlation if not np.isnan(correlation) else 0)
        
        # RMSE analysis
        rmse = np.sqrt(mean_squared_error(child_pitch, ref_pitch_contour[:len(child_pitch)]))
        similarities['rmse'] = float(rmse)
        similarities['rmse_similarity'] = float(max(0, 100 - rmse / 5))  # Scale RMSE to 0-100
        
        return similarities
    
    def get_comprehensive_feedback(self, similarities, child_features, ref_features):
        """Generate detailed feedback based on multiple metrics"""
        # Weights for different similarity metrics
        weights = {
            'dtw_similarity': 0.3,
            'feature_similarity': 0.25,
            'correlation': 0.25,
            'rmse_similarity': 0.2
        }
        
        composite_score = sum(similarities[key] * weights[key] 
                            for key in weights.keys() if key in similarities)
        
        # Handle correlation properly
        if 'correlation' in similarities:
            correlation_score = (similarities['correlation'] + 1) * 50
            composite_score = (composite_score - similarities['correlation'] * weights['correlation'] + 
                             correlation_score * weights['correlation'])
        
        # Ensure score is within bounds
        composite_score = max(0, min(100, composite_score))
        
        feedback = {
            'composite_score': float(composite_score),
            'detailed_analysis': {}
        }
        
        # Overall feedback
        if composite_score >= 85:
            feedback['overall'] = "✅ Excellent pronunciation! Pitch pattern matches very well."
            feedback['level'] = "Excellent"
        elif composite_score >= 70:
            feedback['overall'] = "✅ Good pronunciation with minor deviations."
            feedback['level'] = "Good"
        elif composite_score >= 50:
            feedback['overall'] = "⚠️ Moderate pronunciation accuracy. Some improvement needed."
            feedback['level'] = "Moderate"
        else:
            feedback['overall'] = "❌ Significant pitch deviation. Needs practice."
            feedback['level'] = "Needs Improvement"
        
        # Specific pitch level feedback
        pitch_diff = abs(child_features['mean_pitch'] - ref_features['mean_pitch'])
        if pitch_diff > 50:
            if child_features['mean_pitch'] > ref_features['mean_pitch']:
                feedback['pitch_level'] = "🔊 Your pitch is too high. Try speaking lower."
            else:
                feedback['pitch_level'] = "🔉 Your pitch is too low. Try speaking higher."
        else:
            feedback['pitch_level'] = "✅ Pitch level is appropriate."
        
        # Stability feedback
        if child_features['jitter'] > ref_features.get('jitter', 2) * 1.5:
            feedback['stability'] = "📈 Work on pitch stability - reduce voice tremor."
        else:
            feedback['stability'] = "✅ Good pitch stability."
        
        return feedback
    
    def analyze_pronunciation(self, target_alphabet, audio_path=None):
        """Main analysis function with comprehensive evaluation"""
        print(f"🎯 Analyzing pronunciation for: '{target_alphabet}'")
        
        try:
            # Map Hindi character to English equivalent for dataset lookup
            lookup_alphabet = self.hindi_to_english.get(target_alphabet, target_alphabet)
            print(f"📋 Looking up reference data for: '{lookup_alphabet}'")
            
            # Find reference data
            ref_row = self.reference_table[self.reference_table["Alphabet"] == lookup_alphabet]
            if ref_row.empty:
                print(f"❌ No reference data found for '{lookup_alphabet}' (original: '{target_alphabet}')")
                return {
                    'success': False,
                    'error': f"No reference data found for '{target_alphabet}' (mapped to '{lookup_alphabet}')",
                    'similarities': {},
                    'feedback': {
                        'overall': f"No reference data available for '{target_alphabet}'",
                        'composite_score': 0,
                        'level': 'Error'
                    }
                }
            
            ref_avg_pitch = ref_row["Avg_Pitch_Hz"].values[0]
            ref_duration = ref_row["Duration_s"].values[0]
            
            # Create reference features
            ref_features = {
                'mean_pitch': float(ref_avg_pitch),
                'std_pitch': float(ref_avg_pitch * 0.1),  
                'pitch_range': float(ref_avg_pitch * 0.3),
                'jitter': 1.0,  # Default jitter value
                'shimmer': 2.0  # Default shimmer value
            }
            
            print(f"📊 Reference: {ref_avg_pitch:.1f} Hz, Duration: {ref_duration:.2f}s")
            
            # Validate audio path
            if not audio_path or not os.path.exists(audio_path):
                # Try multiple fallback paths
                fallback_paths = [
                    f"uploads/{target_alphabet}.wav",
                    f"uploads/{lookup_alphabet}.wav", 
                    f"data/{target_alphabet}.wav",
                    f"data/{lookup_alphabet}.wav"
                ]
                
                audio_path = None
                for path in fallback_paths:
                    if os.path.exists(path):
                        audio_path = path
                        print(f"📁 Found audio file: {audio_path}")
                        break
                
                if not audio_path:
                    print(f"❌ Audio file not found in any of: {fallback_paths}")
                    return {
                        'success': False,
                        'error': f"Audio file not found for '{target_alphabet}'",
                        'similarities': {},
                        'feedback': {
                            'overall': 'Audio file not found',
                            'composite_score': 0,
                            'level': 'Error'
                        }
                    }

            audio = self.load_and_preprocess_audio(audio_path)
            if audio is None:
                print("❌ Failed to load audio")
                return {
                    'success': False,
                    'error': 'Failed to load audio file',
                    'similarities': {},
                    'feedback': {
                        'overall': 'Failed to process audio file',
                        'composite_score': 0,
                        'level': 'Error'
                    }
                }

            df, child_features = self.extract_pitch_features(audio)
            if df is None or child_features is None:
                print("❌ Could not extract reliable pitch features")
                return {
                    'success': False,
                    'error': 'Could not extract pitch features from audio',
                    'similarities': {},
                    'feedback': {
                        'overall': 'Could not analyze audio - please try speaking louder and clearer',
                        'composite_score': 0,
                        'level': 'Analysis Failed'
                    }
                }
            
            # Perform analysis
            child_pitch = df["Pitch (Hz)"].values
            ref_pitch_contour = np.full_like(child_pitch, ref_avg_pitch)
            
            similarities = self.advanced_similarity_analysis(
                child_features, ref_features, child_pitch, ref_pitch_contour
            )
            
            feedback = self.get_comprehensive_feedback(similarities, child_features, ref_features)
            
            # Display results for debugging (optional)
            if os.getenv('DEBUG', 'false').lower() == 'true':
                self._display_results(similarities, feedback, child_features, ref_features)
            
            # Return JSON-compatible result
            return {
                'success': True,
                'similarities': similarities,
                'feedback': feedback,
                'features': child_features,
                'reference_features': ref_features,
                'audio_duration': float(df["Time (s)"].max()),
                'pitch_points': len(df)
            }
            
        except Exception as e:
            print(f"❌ Error during analysis: {str(e)}")
            return {
                'success': False,
                'error': str(e),
                'similarities': {},
                'feedback': {
                    'overall': f'Analysis failed: {str(e)}',
                    'composite_score': 0,
                    'level': 'Error'
                }
            }
    
    def _display_results(self, similarities, feedback, child_features, ref_features):
        """Display comprehensive analysis results"""
        print(f"\n{'='*50}")
        print("📈 COMPREHENSIVE PITCH ANALYSIS")
        print(f"{'='*50}")
        
        print(f"\n🎯 Overall Score: {feedback['composite_score']:.1f}/100 ({feedback['level']})")
        print(f"📝 {feedback['overall']}")
        
        print(f"\n📊 Detailed Metrics:")
        print(f"   • DTW Similarity: {similarities.get('dtw_similarity', 0):.1f}/100")
        print(f"   • Feature Similarity: {similarities.get('feature_similarity', 0):.1f}/100")
        print(f"   • Correlation: {similarities.get('correlation', 0):.3f}")
        print(f"   • RMSE Similarity: {similarities.get('rmse_similarity', 0):.1f}/100")
        
        print(f"\n🎵 Voice Characteristics:")
        print(f"   • Mean Pitch: {child_features['mean_pitch']:.1f} Hz")
        print(f"   • Pitch Range: {child_features['pitch_range']:.1f} Hz")
        print(f"   • Jitter: {child_features['jitter']:.2f}%")
        print(f"   • Shimmer: {child_features['shimmer']:.2f}%")
        
        print(f"\n💡 Specific Feedback:")
        print(f"   • {feedback.get('pitch_level', 'N/A')}")
        print(f"   • {feedback.get('stability', 'N/A')}")
    
    def _plot_enhanced_analysis(self, df, ref_avg_pitch, target_alphabet, similarities):
        """Create enhanced visualization with multiple subplots"""
        fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(15, 10))
        
        time_series = df["Time (s)"]
        child_pitch = df["Pitch (Hz)"]
        
     
        ax1.plot(time_series, child_pitch, label="Your Pitch", color='blue', linewidth=2)
        ax1.axhline(y=ref_avg_pitch, label=f"Reference ({ref_avg_pitch:.1f} Hz)", 
                   color='orange', linestyle='--', linewidth=2)
        ax1.fill_between(time_series, child_pitch, ref_avg_pitch, alpha=0.3)
        ax1.set_title(f"Pitch Comparison: '{target_alphabet}'")
        ax1.set_xlabel("Time (s)")
        ax1.set_ylabel("Pitch (Hz)")
        ax1.legend()
        ax1.grid(True, alpha=0.3)
        
     
        ax2.plot(time_series, df["Confidence"], color='green', linewidth=2)
        ax2.set_title("Pitch Detection Confidence")
        ax2.set_xlabel("Time (s)")
        ax2.set_ylabel("Confidence")
        ax2.grid(True, alpha=0.3)
        
       
        ax3.hist(child_pitch, bins=30, alpha=0.7, color='skyblue', edgecolor='black')
        ax3.axvline(ref_avg_pitch, color='orange', linestyle='--', linewidth=2, 
                   label=f'Reference: {ref_avg_pitch:.1f} Hz')
        ax3.axvline(np.mean(child_pitch), color='red', linestyle='-', linewidth=2,
                   label=f'Your Average: {np.mean(child_pitch):.1f} Hz')
        ax3.set_title("Pitch Distribution")
        ax3.set_xlabel("Pitch (Hz)")
        ax3.set_ylabel("Frequency")
        ax3.legend()
        ax3.grid(True, alpha=0.3)
        
      
        metrics = ['DTW', 'Feature', 'Correlation', 'RMSE']
        values = [
            similarities.get('dtw_similarity', 0),
            similarities.get('feature_similarity', 0),
            (similarities.get('correlation', 0) + 1) * 50, 
            similarities.get('rmse_similarity', 0)
        ]
        
        bars = ax4.bar(metrics, values, color=['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4'])
        ax4.set_title("Similarity Metrics")
        ax4.set_ylabel("Score (0-100)")
        ax4.set_ylim(0, 100)
        
     
        for bar, value in zip(bars, values):
            ax4.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 1,
                    f'{value:.1f}', ha='center', va='bottom')
        
        plt.tight_layout()
        plt.show()


    def analyze_pronunciation_json(self, target_alphabet, audio_path=None):
        """
        Wrapper method that returns JSON string for easy integration
        """
        result = self.analyze_pronunciation(target_alphabet, audio_path)
        return json.dumps(result, indent=2, ensure_ascii=False)

def main():
    
    analyzer = EnhancedPitchAnalyzer("hindi_pitch_dataset.csv")
    
   
    target_alphabet = input("Enter the alphabet/word (e.g., Aaa): ").strip()
    

    results = analyzer.analyze_pronunciation(target_alphabet)
    
    if results:
        print(f"\n✅ Analysis complete! Check the visualization above.")
    else:
        print("❌ Analysis failed. Please check your inputs and try again.")

if __name__ == "__main__":
    main()

