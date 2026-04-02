# NGOMeet — Meeting Summarization & Task Tracking Platform

A production-ready web application that transcribes NGO meeting audio, generates structured Minutes of Meeting (MoM), and tracks action items through a Kanban-style interface.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Python 3.11+ / Flask |
| Auth + DB + Storage | Supabase (free tier) |
| Transcription | Groq API (`whisper-large-v3`) |
| Intelligence | Google Gemini API (`gemini-1.5-flash`) |
| Audio Processing | pydub + ffmpeg |
| Frontend | HTML5, Tailwind CSS (CDN), Vanilla JS |

---

## Project Structure

```
ngomeet/
├── app.py                          # Flask app entry point & all routes
├── requirements.txt
├── .env                            # Environment variables (never commit!)
├── .env.example
├── utils/
│   ├── __init__.py
│   ├── audio_processor.py          # pydub chunking + Groq transcription
│   ├── gemini_processor.py         # Gemini MoM + task extraction
│   └── supabase_client.py          # Supabase singleton client
└── templates/
    ├── base.html                   # Shared layout
    ├── auth/
    │   ├── login.html
    │   └── signup.html
    ├── dashboard.html              # Upload + meeting list
    ├── meeting_detail.html         # MoM viewer + task panel
    ├── tasks.html                  # Global Kanban task board
    └── archive.html                # Searchable meeting archive
```

---

## Step 1 — System Prerequisites

### Install ffmpeg (required by pydub)

**Ubuntu / Debian:**
```bash
sudo apt update && sudo apt install -y ffmpeg
```

**macOS (Homebrew):**
```bash
brew install ffmpeg
```

**Windows:**
Download from https://ffmpeg.org/download.html and add the `bin/` folder to your system PATH.

Verify: `ffmpeg -version`

---

## Step 2 — Python Environment

```bash
# Clone or create project directory
mkdir ngomeet && cd ngomeet

# Create virtual environment
python3 -m venv venv

# Activate
source venv/bin/activate          # Linux/macOS
venv\Scripts\activate             # Windows

# Install dependencies
pip install -r requirements.txt
```

---

## Step 3 — Supabase Setup

### 3a. Create a Supabase Project
1. Go to https://supabase.com and sign up (free).
2. Click **New project**, give it a name (e.g., `ngomeet`), set a strong DB password, choose your region.
3. Wait ~2 minutes for the project to provision.

### 3b. Configure Authentication
1. In your Supabase dashboard, go to **Authentication → Providers**.
2. Ensure **Email** provider is **Enabled**.
3. (Optional) Under **Authentication → Settings**, disable "Confirm email" for faster local testing.

### 3c. Create Storage Bucket
1. Go to **Storage** in the sidebar.
2. Click **New bucket**.
3. Name it: `meeting-audio`
4. Set **Public bucket** to **OFF** (private — access via signed URLs).
5. Click **Save**.

### 3d. Run SQL Schema
Go to **SQL Editor** in the sidebar and run the following:
schema.sql

### 3e. Get Supabase Credentials
1. Go to **Project Settings → API**.
2. Copy:
   - **Project URL** → `SUPABASE_URL`
   - **anon public** key → `SUPABASE_ANON_KEY`
   - **service_role** key → `SUPABASE_SERVICE_KEY` (keep secret!)

---

## Step 4 — API Keys

### Groq API Key
1. Go to https://console.groq.com and sign up (free tier available).
2. Go to **API Keys → Create API Key**.
3. Copy the key → `GROQ_API_KEY`

### Google Gemini API Key
1. Go to https://aistudio.google.com/app/apikey
2. Click **Create API Key**.
3. Copy the key → `GEMINI_API_KEY`

---

## Step 5 — Environment Variables

Create a `.env` file in the project root:

```env
# Flask
FLASK_SECRET_KEY=your-very-long-random-secret-key-here
FLASK_DEBUG=False

# Supabase
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_KEY=eyJ...

# Groq
GROQ_API_KEY=gsk_...

# Gemini
GEMINI_API_KEY=AIza...

# Audio Processing
MAX_CHUNK_DURATION_MS=600000   # 10 minutes per chunk in milliseconds
TEMP_AUDIO_DIR=/tmp/ngomeet_audio
```

Generate a strong Flask secret key:
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

---

## Step 6 — Run the Application

```bash
# Make sure venv is active
source venv/bin/activate

# Start Flask development server
python app.py
```

Open http://localhost:5000 in your browser.

---

## Step 7 — Production Deployment (Optional)

For deployment on **Render.com** (free tier):
1. Push code to GitHub (ensure `.env` is in `.gitignore`).
2. Create a new **Web Service** on Render, connect your repo.
3. Build command: `pip install -r requirements.txt`
4. Start command: `gunicorn app:app`
5. Add all `.env` variables under **Environment** in the Render dashboard.
6. Install ffmpeg via a `render.yaml`:

```yaml
services:
  - type: web
    name: ngomeet
    env: python
    buildCommand: "apt-get install -y ffmpeg && pip install -r requirements.txt"
    startCommand: "gunicorn app:app"
```

---

## Troubleshooting

| Issue | Fix |
|---|---|
| `FileNotFoundError: ffmpeg` | Install ffmpeg and ensure it's on PATH |
| `Groq 413 Payload Too Large` | Reduce `MAX_CHUNK_DURATION_MS` in `.env` |
| `Supabase 401 Unauthorized` | Check that you're using `SUPABASE_SERVICE_KEY` for backend ops |
| Audio upload fails | Verify `meeting-audio` bucket exists in Supabase Storage |
| Gemini returns empty tasks | Ensure transcript isn't empty; check Gemini API quota |
