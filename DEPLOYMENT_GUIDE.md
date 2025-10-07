# Voice Shiksha Backend Deployment Guide

## Option 1: Railway (Recommended - Free & Easy)

1. **Prepare for deployment:**
   - All files are ready (requirements.txt, Procfile, runtime.txt)
   - Your Flask app is configured for cloud deployment

2. **Deploy to Railway:**
   - Go to https://railway.app/
   - Sign up with GitHub
   - Click "New Project" → "Deploy from GitHub repo"
   - Connect your GitHub account and select this repository
   - Railway will automatically detect it's a Python Flask app
   - It will build and deploy automatically

3. **Get your deployment URL:**
   - After deployment, Railway will give you a URL like: `https://your-app-name.railway.app`
   - This will be your backend URL

4. **Update Flutter app:**
   - Replace the IP address in Flutter with your Railway URL
   - Example: `https://voice-shiksha-backend.railway.app`

## Option 2: Heroku (Alternative)

1. **Install Heroku CLI:**
   ```bash
   # Download from https://devcenter.heroku.com/articles/heroku-cli
   ```

2. **Deploy to Heroku:**
   ```bash
   heroku login
   heroku create voice-shiksha-backend
   git add .
   git commit -m "Deploy to Heroku"
   git push heroku main
   ```

3. **Your app will be available at:**
   `https://voice-shiksha-backend.herokuapp.com`

## Option 3: Render (Alternative)

1. Go to https://render.com/
2. Sign up and connect GitHub
3. Create new "Web Service"
4. Select this repository
5. Use these settings:
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `gunicorn app:app`
   - Your app will be deployed automatically

## After Deployment:

1. Test your backend by visiting: `https://your-deployment-url.com/`
2. You should see: `{"message": "Voice Shiksha API is running!"}`
3. Update the Flutter app with the new URL
4. Test the complete flow: Listen → Record → Analyze

## Benefits of Cloud Deployment:

✅ No network configuration issues
✅ Always accessible from any device
✅ Professional deployment
✅ Automatic scaling
✅ HTTPS security
✅ No firewall issues