-- ============================================================
-- NGOMeet — Supabase PostgreSQL Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- ── MEETINGS TABLE ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.meetings (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title       TEXT        NOT NULL,
    date        DATE        NOT NULL DEFAULT CURRENT_DATE,
    audio_url   TEXT,
    transcript  TEXT,
    summary     TEXT,
    mom_json    JSONB,
    status      TEXT        NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending','processing','completed','error')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── TASKS TABLE ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.tasks (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    meeting_id  UUID        NOT NULL REFERENCES public.meetings(id) ON DELETE CASCADE,
    user_id     UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    description TEXT        NOT NULL,
    assignee    TEXT        DEFAULT 'Unassigned',
    status      TEXT        NOT NULL DEFAULT 'Pending'
                    CHECK (status IN ('Pending','In Progress','Completed')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── ROW LEVEL SECURITY ───────────────────────────────────────
ALTER TABLE public.meetings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks    ENABLE ROW LEVEL SECURITY;

CREATE POLICY "meetings_select_own" ON public.meetings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "meetings_insert_own" ON public.meetings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "meetings_update_own" ON public.meetings FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "meetings_delete_own" ON public.meetings FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "tasks_select_own" ON public.tasks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "tasks_insert_own" ON public.tasks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "tasks_update_own" ON public.tasks FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "tasks_delete_own" ON public.tasks FOR DELETE USING (auth.uid() = user_id);

-- ── INDEXES ──────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_meetings_user_id  ON public.meetings(user_id);
CREATE INDEX IF NOT EXISTS idx_meetings_created  ON public.meetings(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_meetings_date     ON public.meetings(date DESC);
CREATE INDEX IF NOT EXISTS idx_tasks_meeting_id  ON public.tasks(meeting_id);
CREATE INDEX IF NOT EXISTS idx_tasks_user_id     ON public.tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status      ON public.tasks(status);

-- Full-text search on title + summary
CREATE INDEX IF NOT EXISTS idx_meetings_fts ON public.meetings
    USING GIN (to_tsvector('english',
        coalesce(title, '') || ' ' || coalesce(summary, '')
    ));
