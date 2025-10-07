#!/usr/bin/env python3
"""
Test script for Voice Shiksha Backend
Usage: python test_deployment.py <base_url>
Example: python test_deployment.py https://your-app.railway.app
"""

import requests
import sys

def test_backend(base_url):
    """Test the deployed backend"""
    print(f"🧪 Testing Voice Shiksha Backend at: {base_url}")
    
    try:
        # Test 1: Health check
        print("\n1️⃣ Testing health endpoint...")
        response = requests.get(f"{base_url}/")
        if response.status_code == 200:
            print("✅ Health check passed!")
            print(f"   Response: {response.json()}")
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
        
        # Test 2: Audio endpoint
        print("\n2️⃣ Testing audio endpoint...")
        response = requests.get(f"{base_url}/audio/अ")
        if response.status_code == 200:
            print("✅ Audio endpoint working!")
        elif response.status_code == 404:
            print("⚠️ Audio endpoint accessible but file not found (expected)")
        else:
            print(f"❌ Audio endpoint failed: {response.status_code}")
        
        print("\n🎉 Backend deployment test completed!")
        print(f"🔗 Your backend is ready at: {base_url}")
        print("\n📱 Next steps:")
        print(f"   1. Update Flutter app to use: {base_url}")
        print("   2. Test the complete flow in your mobile app")
        
        return True
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Connection failed: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python test_deployment.py <base_url>")
        print("Example: python test_deployment.py https://your-app.railway.app")
        sys.exit(1)
    
    base_url = sys.argv[1].rstrip('/')
    test_backend(base_url)