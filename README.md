# NGOMeet — Meeting Summarization & Task Tracking Platform

A production-ready web application that transcribes NGO meeting audio, generates structured Minutes of Meeting (MoM), and tracks action items through a Kanban-style interface.

---

## 📌 Project Introduction

**NGOMeet** is a production-ready web application that automates the transformation of raw meeting audio into structured Minutes of Meeting (MoM) and actionable task boards. Built specifically for NGOs and organizations with limited administrative resources, it eliminates manual note-taking and ensures no action item falls through the cracks.

---

## ❓ Problem Statement

NGOs and non-profit organizations face several critical challenges in meeting management:

| Problem | Impact |
|---------|--------|
| **Manual note-taking** consumes 20-30% of meeting time | Reduced productivity and engagement |
| **Inconsistent documentation** across different note-takers | Loss of critical context and decisions |
| **Action items get lost** in email threads or forgotten | Missed deadlines, unaccountable tasks |
| **No centralized task tracking** for meeting outcomes | Duplicate efforts, unclear ownership |
| **Language barriers** in multilingual teams | Misinterpretation of assignments |
| **Audio recordings sit unused** after meetings | Valuable information never documented |

Traditional solutions like manual transcription services are expensive ($2-5 per minute) and slow (24-48 hour turnaround), making them impractical for resource-constrained NGOs.

---

## 💡 Solution Approach

NGOMeet addresses these challenges through an end-to-end automation pipeline:

### Core Capabilities

1. **Automated Transcription** — Converts meeting audio to text using state-of-the-art Whisper ASR
2. **Intelligent Summarization** — Generates structured MoM with key decisions, discussions, and action items
3. **Task Extraction & Assignment** — Automatically identifies action items, assigns owners, and sets deadlines
4. **Visual Task Management** — Kanban board for tracking task status (To Do → In Progress → Done)
5. **Searchable Archive** — Historical meeting lookup by date, keyword, or participant

### Key Differentiators

- **Zero manual effort** — Upload audio, get complete MoM + tasks
- **Real-time processing** — 10-minute audio processed in under 2 minutes
- **Cost-effective** — ~$0.10 per meeting vs $50-100 for manual services
- **Privacy-first** — Audio stored in private Supabase buckets with signed URLs
- **NGO-friendly pricing** — Free tier supports up to 50 meetings/month

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Backend** | Python 3.11+ / Flask | Lightweight API server, route handling |
| **Authentication** | Supabase Auth (Email) | User management, session handling |
| **Database** | Supabase PostgreSQL | Store meetings, transcripts, tasks, users |
| **Storage** | Supabase Storage (Private) | Secure audio file hosting with signed URLs |
| **Transcription** | Groq API (`whisper-large-v3`) | High-speed, accurate speech-to-text |
| **LLM Intelligence** | Google Gemini (`gemini-1.5-flash`) | MoM generation, task extraction, summarization |
| **Audio Processing** | pydub + ffmpeg | Chunk splitting, format conversion |
| **Frontend** | HTML5 + Tailwind CSS (CDN) + Vanilla JS | Responsive UI, Kanban board, no build step |
| **Deployment** | Render.com (optional) | Free-tier hosting with ffmpeg support |

### Why This Stack?

- **Supabase** — Replaces Firebase/AWS with generous free tier (500 MB DB, 1 GB storage)
- **Groq** — 10x faster than OpenAI Whisper API, optimized for real-time use
- **Gemini 1.5 Flash** — 1M token context window, cheaper than GPT-4
- **Vanilla JS + Tailwind** — No React/Vue complexity, faster development

---

## 🔄 Workflow
┌─────────────────────────────────────────────────────────────────────────────┐
│                           USER JOURNEY                                       │
└─────────────────────────────────────────────────────────────────────────────┘

Step 1: Authentication
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Sign Up    │ ──► │   Login      │ ──► │  Dashboard   │
│ (Email/Pass) │     │ (Session)    │     │  (Landing)   │
└──────────────┘     └──────────────┘     └──────────────┘

Step 2: Audio Upload & Processing
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Upload MP3/ │ ──► │  Split into  │ ──► │  Transcribe  │
│  WAV/M4A     │     │  10-min      │     │  via Groq    │
│  (max 100MB) │     │  chunks      │     │  Whisper     │
└──────────────┘     └──────────────┘     └──────────────┘
                                                  │
                                                  ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Store in    │ ◄── │  Generate    │ ◄── │  Combine     │
│  Supabase    │     │  Structured  │     │  Chunks      │
│  PostgreSQL  │     │  MoM + Tasks │     │  Transcript  │
└──────────────┘     └──────────────┘     └──────────────┘
                           │
                           ▼
Step 3: View Results
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Meeting     │ ──► │  Minutes of  │ ──► │  Action      │
│  Detail Page │     │  Meeting     │     │  Items List  │
│              │     │  (Formatted) │     │  (Extracted) │
└──────────────┘     └──────────────┘     └──────────────┘

Step 4: Task Management
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Global      │ ──► │  Kanban      │ ──► │  Update      │
│  Tasks Page  │     │  Board       │     │  Status      │
│              │     │  (To Do /     │     │  (Drag &     │
│              │     │   In Progress/│     │   Drop)      │
│              │     │   Done)       │     │              │
└──────────────┘     └──────────────┘     └──────────────┘

Step 5: Archive & Search
┌──────────────┐     ┌──────────────┐
│  Archive     │ ──► │  Search by   │
│  Page        │     │  Date/Title  │
│  (All past   │     │  /Participant│
│   meetings)  │     │              │
└──────────────┘     └──────────────┘

## Dataflow 
[User] ──audio──► [Flask App] ──chunks──► [Groq API] ──transcript──► [Gemini API]
                    │                                              │
                    │                                              ▼
                    │                                         [MoM + Tasks]
                    │                                              │
                    ▼                                              ▼
              [Supabase] ◄────────────────────────────────────────┘
              (Storage + DB)
                    │
                    ▼
              [Frontend UI] ◄──fetch── [User Browser]


---

## 📋 Procedure (Step-by-Step Setup & Run)

### Phase 1: System Prerequisites

#### 1.1 Install ffmpeg (Required for audio processing)

| OS | Command |
|----|---------|
| **Ubuntu/Debian** | `sudo apt update && sudo apt install -y ffmpeg` |
| **macOS** | `brew install ffmpeg` |
| **Windows** | Download from [ffmpeg.org](https://ffmpeg.org/download.html) and add `bin/` to PATH |

**Verify:** `ffmpeg -version`

---

### Phase 2: Python Environment Setup

```bash
# Create project directory
mkdir ngomeet && cd ngomeet

# Create virtual environment
python3 -m venv venv

# Activate environment
source venv/bin/activate          # Linux/macOS
venv\Scripts\activate             # Windows

# Install dependencies
pip install -r requirements.txt

Phase 3: Supabase Setup
3.1 Create Supabase Project
Go to supabase.com → Sign up (free)

Click New project → Name: ngomeet → Set database password

Wait for provisioning (~2 minutes)

3.2 Configure Authentication
Authentication → Providers → Enable Email provider

Authentication → Settings → Disable "Confirm email" (for local testing)

3.3 Create Storage Bucket
Storage → New bucket → Name: meeting-audio

Set Public bucket → OFF (private access via signed URLs)

3.4 Run Database Schema
run file schema.sql

3.5 Get Credentials
Project Settings → API → Copy:

SUPABASE_URL (Project URL)
SUPABASE_ANON_KEY (anon public key)
SUPABASE_SERVICE_KEY (service_role key — keep secret!)


Phase 4: API Keys Setup
4.1 Groq API Key
Go to console.groq.com → Sign up
API Keys → Create API Key → Copy gsk_...

4.2 Google Gemini API Key
Go to aistudio.google.com/app/apikey
Create API Key → Copy AIza...

Phase 5: Environment Configuration
Create .env in project root:
# Flask
FLASK_SECRET_KEY=your-32-byte-hex-secret-key
FLASK_DEBUG=True

# Supabase
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_KEY=eyJ...

# Groq
GROQ_API_KEY=gsk_...

# Gemini
GEMINI_API_KEY=AIza...

# Audio Processing
MAX_CHUNK_DURATION_MS=600000
TEMP_AUDIO_DIR=/tmp/ngomeet_audio

Phase 6: Run Application
# Ensure virtual environment is active
source venv/bin/activate

# Start Flask server
python app.py

Phase 7: Production Deployment (Optional)
Deploy on Render.com (Free Tier)
Push code to GitHub (ensure .env is in .gitignore)

Create render.yaml in project root:


On Render:
New Web Service → Connect GitHub repo
Build command: apt-get install -y ffmpeg && pip install -r requirements.txt
Start command: gunicorn app:app
Add all environment variables manually