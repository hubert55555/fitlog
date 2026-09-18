-- ========================================================
-- FitLog: Admin accounts + shared workout templates
-- ========================================================
-- Assumes RLS is already ON for public.profiles and public.routines (it is —
-- both tables are already scoped per-user in the app). This migration only
-- ADDS columns/policies/grants, it never touches existing ones, so it's safe
-- to run even without knowing their exact current definitions.

-- 1. Admin flag on profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT false;

-- Column-level privileges: a user's own profile row is otherwise fully
-- self-editable (upsert), which would let anyone grant themselves is_admin
-- with a raw REST call bypassing the app UI entirely. Restrict INSERT/UPDATE
-- from PostgREST roles to the columns the app actually needs to write —
-- is_admin can then only be changed with the service role / SQL editor.
REVOKE INSERT, UPDATE ON public.profiles FROM authenticated;
GRANT INSERT (id, unit, track_rir) ON public.profiles TO authenticated;
GRANT UPDATE (unit, track_rir) ON public.profiles TO authenticated;

-- 2. Template flag on routines — a routine with is_template = true is a
-- shared, ready-made workout visible to every user (in "Gotowe szablony"),
-- not just its owner.
ALTER TABLE public.routines ADD COLUMN IF NOT EXISTS is_template BOOLEAN NOT NULL DEFAULT false;

DROP POLICY IF EXISTS "Templates are viewable by everyone" ON public.routines;
CREATE POLICY "Templates are viewable by everyone"
  ON public.routines FOR SELECT
  USING (is_template = true);

-- Server-side enforcement that only admins can publish a template — the app
-- only shows the checkbox to admins, but RLS/grants don't restrict which
-- *values* a user writes to a column they own, so this closes that gap.
-- SECURITY DEFINER is safe here: Postgres only allows calling a trigger
-- function via its trigger, never as a plain RPC, so it can't be invoked
-- directly to do anything else.
CREATE OR REPLACE FUNCTION public.enforce_template_admin_only()
RETURNS trigger AS $$
BEGIN
  IF NEW.is_template AND NOT COALESCE(
    (SELECT is_admin FROM public.profiles WHERE id = auth.uid()), false
  ) THEN
    RAISE EXCEPTION 'Only admin accounts can publish a routine as a shared template';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trg_enforce_template_admin_only ON public.routines;
CREATE TRIGGER trg_enforce_template_admin_only
  BEFORE INSERT OR UPDATE ON public.routines
  FOR EACH ROW EXECUTE FUNCTION public.enforce_template_admin_only();

-- 3. Grant admin to the first account. Upsert so it works whether or not
-- this account has a profiles row yet (created lazily on first settings change).
INSERT INTO public.profiles (id, unit, track_rir, is_admin)
SELECT id, 'kg', true, true FROM auth.users WHERE email = 'hubo8p@gmail.com'
ON CONFLICT (id) DO UPDATE SET is_admin = true;
