-- ====================================================================
-- CODE TO UNLOCK: Supabase PostgreSQL Schema & Security Infrastructure
-- Digital Wellbeing & Gamified Coding Application
-- ====================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Users Table
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL DEFAULT 'Developer',
    email TEXT UNIQUE NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. User Preferences
CREATE TABLE IF NOT EXISTS public.user_preferences (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    preferred_language TEXT NOT NULL DEFAULT 'Python',
    daily_coding_goal INT NOT NULL DEFAULT 2,
    reset_hour INT NOT NULL DEFAULT 0,
    reset_minute INT NOT NULL DEFAULT 0,
    timezone TEXT NOT NULL DEFAULT 'UTC',
    theme TEXT NOT NULL DEFAULT 'dark',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Managed Applications
CREATE TABLE IF NOT EXISTS public.managed_apps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    package_name TEXT NOT NULL,
    app_name TEXT NOT NULL,
    daily_limit_seconds INT NOT NULL DEFAULT 3600,
    protection_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    category TEXT NOT NULL DEFAULT 'Social',
    icon_identifier TEXT NOT NULL DEFAULT 'app',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, package_name)
);

-- 4. Daily Usage
CREATE TABLE IF NOT EXISTS public.daily_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    package_name TEXT NOT NULL,
    usage_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_used_seconds INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, package_name, usage_date)
);

-- 5. Coding Questions Bank (1,000+ Level System)
CREATE TABLE IF NOT EXISTS public.coding_questions (
    id TEXT PRIMARY KEY,
    canonical_problem_id TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    difficulty_rating INT NOT NULL CHECK (difficulty_rating BETWEEN 1 AND 10),
    difficulty_band TEXT NOT NULL,
    topic TEXT NOT NULL,
    input_description TEXT,
    output_description TEXT,
    constraints JSONB NOT NULL DEFAULT '[]'::jsonb,
    examples JSONB NOT NULL DEFAULT '[]'::jsonb,
    sample_test_cases JSONB NOT NULL DEFAULT '[]'::jsonb,
    hidden_test_cases JSONB NOT NULL DEFAULT '[]'::jsonb,
    starter_code JSONB NOT NULL DEFAULT '{}'::jsonb,
    reference_solutions JSONB NOT NULL DEFAULT '{}'::jsonb,
    hints JSONB NOT NULL DEFAULT '[]'::jsonb,
    time_limit_ms INT NOT NULL DEFAULT 2000,
    memory_limit_mb INT NOT NULL DEFAULT 128,
    source_metadata TEXT NOT NULL DEFAULT 'Curated',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. User Question History (Enforces Strict Uniqueness)
CREATE TABLE IF NOT EXISTS public.user_question_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    question_id TEXT NOT NULL REFERENCES public.coding_questions(id),
    canonical_problem_id TEXT NOT NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    attempted_at TIMESTAMPTZ,
    solved_at TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'assigned' CHECK (status IN ('assigned', 'attempted', 'solved', 'failed')),
    language_used TEXT,
    UNIQUE(user_id, canonical_problem_id)
);

-- 7. Coding Submissions
CREATE TABLE IF NOT EXISTS public.coding_submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    question_id TEXT NOT NULL REFERENCES public.coding_questions(id),
    language TEXT NOT NULL,
    code TEXT NOT NULL,
    submission_status TEXT NOT NULL CHECK (submission_status IN ('accepted', 'wrong_answer', 'time_limit_exceeded', 'compilation_error', 'runtime_error')),
    execution_time_ms INT NOT NULL DEFAULT 0,
    tests_passed INT NOT NULL DEFAULT 0,
    total_tests INT NOT NULL DEFAULT 0,
    manual_typing_ratio NUMERIC(5,2) NOT NULL DEFAULT 1.0,
    keystrokes_count INT NOT NULL DEFAULT 0,
    paste_attempts_count INT NOT NULL DEFAULT 0,
    is_flagged_for_cheating BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. User Progress
CREATE TABLE IF NOT EXISTS public.user_progress (
    user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    current_level INT NOT NULL DEFAULT 1 CHECK (current_level >= 1),
    xp INT NOT NULL DEFAULT 0 CHECK (xp >= 0),
    total_solved INT NOT NULL DEFAULT 0,
    total_attempts INT NOT NULL DEFAULT 0,
    current_streak INT NOT NULL DEFAULT 0,
    longest_streak INT NOT NULL DEFAULT 0,
    last_active_date DATE,
    topics_mastered JSONB NOT NULL DEFAULT '[]'::jsonb,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9. Unlock Sessions
CREATE TABLE IF NOT EXISTS public.unlock_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    package_name TEXT NOT NULL,
    unlock_sequence INT NOT NULL DEFAULT 1,
    required_question_count INT NOT NULL DEFAULT 1,
    status TEXT NOT NULL DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'abandoned')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- 10. Unlock Challenges
CREATE TABLE IF NOT EXISTS public.unlock_challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    unlock_session_id UUID NOT NULL REFERENCES public.unlock_sessions(id) ON DELETE CASCADE,
    question_id TEXT NOT NULL REFERENCES public.coding_questions(id),
    solved_at TIMESTAMPTZ,
    validation_status TEXT NOT NULL DEFAULT 'pending' CHECK (validation_status IN ('pending', 'accepted', 'rejected')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 11. Reward Transactions Ledger (20 min increments)
CREATE TABLE IF NOT EXISTS public.reward_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    package_name TEXT NOT NULL,
    unlock_session_id UUID NOT NULL REFERENCES public.unlock_sessions(id),
    challenge_ids JSONB NOT NULL DEFAULT '[]'::jsonb,
    duration_seconds INT NOT NULL DEFAULT 1200, -- 20 minutes
    granted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'revoked')),
    idempotency_key TEXT UNIQUE NOT NULL
);

-- 12. Achievements Catalog
CREATE TABLE IF NOT EXISTS public.achievements (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon TEXT NOT NULL,
    xp_reward INT NOT NULL DEFAULT 50,
    criteria JSONB NOT NULL DEFAULT '{}'::jsonb
);

-- 13. User Achievements
CREATE TABLE IF NOT EXISTS public.user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    achievement_id TEXT NOT NULL REFERENCES public.achievements(id),
    earned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- ====================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.managed_apps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coding_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_question_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coding_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.unlock_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.unlock_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

-- Questions & Achievements are publicly readable
CREATE POLICY "Public questions read" ON public.coding_questions FOR SELECT USING (true);
CREATE POLICY "Public achievements read" ON public.achievements FOR SELECT USING (true);

-- User-scoped policies
CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can access own preferences" ON public.user_preferences FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own apps" ON public.managed_apps FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own usage" ON public.daily_usage FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view own question history" ON public.user_question_history FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view and create submissions" ON public.coding_submissions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view and update progress" ON public.user_progress FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view own unlock sessions" ON public.unlock_sessions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view own unlock challenges" ON public.unlock_challenges FOR ALL USING (
    EXISTS (SELECT 1 FROM public.unlock_sessions s WHERE s.id = unlock_session_id AND s.user_id = auth.uid())
);
CREATE POLICY "Users can view own rewards" ON public.reward_transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can view own achievements" ON public.user_achievements FOR ALL USING (auth.uid() = user_id);

-- ====================================================================
-- IDEMPOTENT SERVER-SIDE REWARD GRANT FUNCTION
-- ====================================================================

CREATE OR REPLACE FUNCTION public.grant_unlock_reward(
    p_package_name TEXT,
    p_unlock_session_id UUID,
    p_challenge_ids JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_session RECORD;
    v_reward RECORD;
    v_expires_at TIMESTAMPTZ;
    v_idempotency_key TEXT;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Verify session ownership and validity
    SELECT * INTO v_session FROM public.unlock_sessions
    WHERE id = p_unlock_session_id AND user_id = v_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unlock session not found or unauthorized';
    END IF;

    IF v_session.status = 'completed' THEN
        -- Idempotently return existing reward
        SELECT * INTO v_reward FROM public.reward_transactions
        WHERE unlock_session_id = p_unlock_session_id;
        RETURN jsonb_build_object('success', true, 'reward_id', v_reward.id, 'expires_at', v_reward.expires_at);
    END IF;

    v_expires_at := NOW() + INTERVAL '20 minutes';
    v_idempotency_key := v_user_id || '_' || p_unlock_session_id;

    INSERT INTO public.reward_transactions (
        user_id, package_name, unlock_session_id, challenge_ids, duration_seconds, granted_at, expires_at, status, idempotency_key
    ) VALUES (
        v_user_id, p_package_name, p_unlock_session_id, p_challenge_ids, 1200, NOW(), v_expires_at, 'active', v_idempotency_key
    ) RETURNING * INTO v_reward;

    UPDATE public.unlock_sessions
    SET status = 'completed', completed_at = NOW()
    WHERE id = p_unlock_session_id;

    RETURN jsonb_build_object('success', true, 'reward_id', v_reward.id, 'expires_at', v_reward.expires_at);
END;
$$;
