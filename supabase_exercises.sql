-- ========================================================
-- FitLog: Baza ćwiczeń w Supabase (1 ćwiczenie = 1 rekord)
-- Klucz złożony / tablica partii mięśniowych (muscles)
-- ========================================================

-- 1. Tabela ćwiczeń
-- id jest TEXT (slug wbudowanych: b_..., UUID ćwiczeń użytkownika), nie UUID —
-- plany i historia trzymają te same stringi.
CREATE TABLE IF NOT EXISTS public.exercises (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  muscle TEXT NOT NULL,
  muscles TEXT[] NOT NULL DEFAULT '{}',
  created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Istniejąca tabela mogła mieć id UUID — konwersja zachowuje dotychczasowe rekordy użytkownika.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'exercises'
      AND column_name = 'id'
      AND data_type = 'uuid'
  ) THEN
    ALTER TABLE public.exercises ALTER COLUMN id TYPE TEXT USING id::text;
  END IF;
END $$;

ALTER TABLE public.exercises ADD COLUMN IF NOT EXISTS muscles TEXT[] NOT NULL DEFAULT '{}';

-- 2. Row Level Security (RLS)
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Exercises are viewable by everyone" ON public.exercises;
CREATE POLICY "Exercises are viewable by everyone"
  ON public.exercises FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Users can insert their own exercises" ON public.exercises;
CREATE POLICY "Users can insert their own exercises"
  ON public.exercises FOR INSERT
  WITH CHECK (auth.uid() = created_by);

DROP POLICY IF EXISTS "Users can update their own exercises" ON public.exercises;
CREATE POLICY "Users can update their own exercises"
  ON public.exercises FOR UPDATE
  USING (auth.uid() = created_by);

DROP POLICY IF EXISTS "Users can delete their own exercises" ON public.exercises;
CREATE POLICY "Users can delete their own exercises"
  ON public.exercises FOR DELETE
  USING (auth.uid() = created_by);

-- 3. Rekordy ćwiczeń (jedno ćwiczenie = jeden rekord ze złożonym zestawem partii mięśniowych)
INSERT INTO public.exercises (id, name, muscle, muscles, created_by) VALUES
  ('b_wyciskanie-sztangi-na-lawce-plaskiej', 'Wyciskanie sztangi na ławce płaskiej', 'Klatka piersiowa', ARRAY['Klatka piersiowa', 'Triceps', 'Barki (przód)'], NULL),
  ('b_wyciskanie-sztangi-na-lawce-skosnej', 'Wyciskanie sztangi na ławce skośnej', 'Klatka piersiowa', ARRAY['Klatka piersiowa', 'Barki (przód)', 'Triceps'], NULL),
  ('b_wyciskanie-hantli-na-lawce-plaskiej', 'Wyciskanie hantli na ławce płaskiej', 'Klatka piersiowa', ARRAY['Klatka piersiowa', 'Triceps', 'Barki (przód)'], NULL),
  ('b_wyciskanie-hantli-na-lawce-skosnej', 'Wyciskanie hantli na ławce skośnej', 'Klatka piersiowa', ARRAY['Klatka piersiowa', 'Barki (przód)', 'Triceps'], NULL),
  ('b_rozpietki-z-hantlami', 'Rozpiętki z hantlami', 'Klatka piersiowa', ARRAY['Klatka piersiowa', 'Barki (przód)'], NULL),
  ('b_krzyzowanie-linek-wyciagu-cable-fly', 'Krzyżowanie linek wyciągu (cable fly)', 'Klatka piersiowa', ARRAY['Klatka piersiowa'], NULL),
  ('b_pompki-na-poreczach-dipy', 'Pompki na poręczach (dipy)', 'Klatka piersiowa', ARRAY['Klatka piersiowa', 'Triceps', 'Barki (przód)'], NULL),
  ('b_wyciskanie-na-maszynie-chest-press', 'Wyciskanie na maszynie (chest press)', 'Klatka piersiowa', ARRAY['Klatka piersiowa', 'Triceps'], NULL),
  ('b_pompki-klasyczne', 'Pompki klasyczne', 'Klatka piersiowa', ARRAY['Klatka piersiowa', 'Triceps', 'Barki (przód)', 'Brzuch'], NULL),
  ('b_martwy-ciag', 'Martwy ciąg', 'Plecy', ARRAY['Plecy', 'Nogi', 'Pośladki', 'Przedramiona'], NULL),
  ('b_podciaganie-na-drazku', 'Podciąganie na drążku', 'Plecy', ARRAY['Plecy', 'Biceps', 'Przedramiona'], NULL),
  ('b_wioslowanie-sztanga-w-opadzie', 'Wiosłowanie sztangą w opadzie', 'Plecy', ARRAY['Plecy', 'Biceps', 'Barki (tył)'], NULL),
  ('b_wioslowanie-hantla-jednoracz', 'Wiosłowanie hantlą jednorącz', 'Plecy', ARRAY['Plecy', 'Biceps'], NULL),
  ('b_sciaganie-drazka-wyciagu-gornego-lat-pulldown', 'Ściąganie drążka wyciągu górnego (lat pulldown)', 'Plecy', ARRAY['Plecy', 'Biceps'], NULL),
  ('b_wioslowanie-na-maszynie-siedzac', 'Wiosłowanie na maszynie (siedząc)', 'Plecy', ARRAY['Plecy', 'Biceps'], NULL),
  ('b_hiperekstensje', 'Hiperekstensje', 'Plecy', ARRAY['Plecy', 'Pośladki', 'Nogi'], NULL),
  ('b_przysiad-ze-sztanga', 'Przysiad ze sztangą', 'Nogi', ARRAY['Nogi', 'Pośladki', 'Brzuch'], NULL),
  ('b_przysiad-przedni-front-squat', 'Przysiad przedni (front squat)', 'Nogi', ARRAY['Nogi', 'Pośladki', 'Brzuch'], NULL),
  ('b_wykroki-z-hantlami', 'Wykroki z hantlami', 'Nogi', ARRAY['Nogi', 'Pośladki'], NULL),
  ('b_prostowanie-nog-na-maszynie-leg-extension', 'Prostowanie nóg na maszynie (leg extension)', 'Nogi', ARRAY['Nogi'], NULL),
  ('b_uginanie-nog-lezac-leg-curl', 'Uginanie nóg leżąc (leg curl)', 'Nogi', ARRAY['Nogi', 'Pośladki'], NULL),
  ('b_wyciskanie-nog-na-suwnicy-leg-press', 'Wyciskanie nóg na suwnicy (leg press)', 'Nogi', ARRAY['Nogi', 'Pośladki'], NULL),
  ('b_martwy-ciag-rumunski', 'Martwy ciąg rumuński', 'Nogi', ARRAY['Nogi', 'Pośladki', 'Plecy'], NULL),
  ('b_wykroki-bulgarskie', 'Wykroki bułgarskie', 'Nogi', ARRAY['Nogi', 'Pośladki'], NULL),
  ('b_wyciskanie-zolnierskie-ohp', 'Wyciskanie żołnierskie (OHP)', 'Barki (przód)', ARRAY['Barki (przód)', 'Triceps', 'Klatka piersiowa'], NULL),
  ('b_wyciskanie-hantli-nad-glowe-siedzac', 'Wyciskanie hantli nad głowę siedząc', 'Barki (przód)', ARRAY['Barki (przód)', 'Triceps'], NULL),
  ('b_unoszenie-hantli-przodem', 'Unoszenie hantli przodem', 'Barki (przód)', ARRAY['Barki (przód)'], NULL),
  ('b_unoszenie-hantli-bokiem', 'Unoszenie hantli bokiem', 'Barki (bok)', ARRAY['Barki (bok)'], NULL),
  ('b_unoszenie-linki-bokiem-cable', 'Unoszenie linki bokiem (cable)', 'Barki (bok)', ARRAY['Barki (bok)'], NULL),
  ('b_unoszenie-hantli-w-opadzie-tylny-akton', 'Unoszenie hantli w opadzie (tylny akton)', 'Barki (tył)', ARRAY['Barki (tył)', 'Plecy'], NULL),
  ('b_odwrotne-rozpietki-na-maszynie', 'Odwrotne rozpiętki na maszynie', 'Barki (tył)', ARRAY['Barki (tył)', 'Plecy'], NULL),
  ('b_face-pull', 'Face pull', 'Barki (tył)', ARRAY['Barki (tył)', 'Plecy'], NULL),
  ('b_arnold-press', 'Arnold press', 'Barki (przód)', ARRAY['Barki (przód)', 'Barki (bok)', 'Triceps'], NULL),
  ('b_uginanie-ramion-ze-sztanga', 'Uginanie ramion ze sztangą', 'Biceps', ARRAY['Biceps', 'Przedramiona'], NULL),
  ('b_uginanie-ramion-z-hantlami-mlotkowe', 'Uginanie ramion z hantlami (młotkowe)', 'Biceps', ARRAY['Biceps', 'Przedramiona'], NULL),
  ('b_uginanie-ramion-na-modlitewniku', 'Uginanie ramion na modlitewniku', 'Biceps', ARRAY['Biceps'], NULL),
  ('b_uginanie-ramion-na-wyciagu-dolnym', 'Uginanie ramion na wyciągu dolnym', 'Biceps', ARRAY['Biceps'], NULL),
  ('b_wyciskanie-francuskie', 'Wyciskanie francuskie', 'Triceps', ARRAY['Triceps'], NULL),
  ('b_prostowanie-ramion-na-wyciagu-gornym', 'Prostowanie ramion na wyciągu górnym', 'Triceps', ARRAY['Triceps'], NULL),
  ('b_pompki-na-poreczach-waskim-chwytem', 'Pompki na poręczach wąskim chwytem', 'Triceps', ARRAY['Triceps', 'Klatka piersiowa', 'Barki (przód)'], NULL),
  ('b_wyciskanie-sztangi-waskim-chwytem', 'Wyciskanie sztangi wąskim chwytem', 'Triceps', ARRAY['Triceps', 'Klatka piersiowa', 'Barki (przód)'], NULL),
  ('b_brzuszki', 'Brzuszki', 'Brzuch', ARRAY['Brzuch'], NULL),
  ('b_plank-deska', 'Plank (deska)', 'Brzuch', ARRAY['Brzuch', 'Całe ciało'], NULL),
  ('b_unoszenie-nog-w-zwisie', 'Unoszenie nóg w zwisie', 'Brzuch', ARRAY['Brzuch', 'Przedramiona'], NULL),
  ('b_skrety-tulowia-z-obciazeniem-russian-twist', 'Skręty tułowia z obciążeniem (russian twist)', 'Brzuch', ARRAY['Brzuch'], NULL),
  ('b_hip-thrust', 'Hip thrust', 'Pośladki', ARRAY['Pośladki', 'Nogi'], NULL),
  ('b_odwodzenie-nogi-w-bok-na-maszynie', 'Odwodzenie nogi w bok na maszynie', 'Pośladki', ARRAY['Pośladki'], NULL),
  ('b_wspiecia-na-palce-stojac', 'Wspięcia na palce stojąc', 'Łydki', ARRAY['Łydki'], NULL),
  ('b_wspiecia-na-palce-siedzac', 'Wspięcia na palce siedząc', 'Łydki', ARRAY['Łydki'], NULL),
  ('b_uginanie-nadgarstkow-ze-sztanga', 'Uginanie nadgarstków ze sztangą', 'Przedramiona', ARRAY['Przedramiona'], NULL),
  ('b_burpees', 'Burpees', 'Całe ciało', ARRAY['Całe ciało', 'Nogi', 'Klatka piersiowa', 'Brzuch'], NULL)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  muscle = EXCLUDED.muscle,
  muscles = EXCLUDED.muscles;
