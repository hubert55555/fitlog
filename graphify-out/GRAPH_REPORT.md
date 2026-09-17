# Graph Report - claude  (2026-09-17)

## Corpus Check
- Corpus is ~3,704 words - fits in a single context window. You may not need a graph.

## Summary
- 113 nodes · 57 edges · 60 communities (3 shown, 57 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 2 edges (avg confidence: 0.8)
- Token cost: 0 input · 126,087 output

## Community Hubs (Navigation)
- Workout Session Lifecycle
- App Shell & Rendering
- Plan & Routine Management
- Supabase Persistence Layer
- Set Editing
- Exercise Block Editing
- Exercise Picker
- Routine Editor
- Settings Sheet
- Confirm Dialog
- Custom Exercise Form
- Service Worker Cache
- App Icon Asset
- Built-in Exercises Data
- Current User State
- App Init
- Muscle Groups Data
- Raw Exercise Catalogue
- Storage Availability Check
- Routine Templates Data

## God Nodes (most connected - your core abstractions)
1. `render()` - 9 edges
2. `WorkoutEditor()` - 8 edges
3. `PlanyTab()` - 6 edges
4. `syncTable()` - 4 edges
5. `SetRow()` - 4 edges
6. `ExercisePickerSheet()` - 4 edges
7. `RoutineEditor()` - 4 edges
8. `CwiczeniaTab()` - 4 edges
9. `SettingsSheet()` - 4 edges
10. `ExerciseBlock()` - 3 edges

## Surprising Connections (you probably didn't know these)
- `ExercisePickerSheet()` --calls--> `render()`  [EXTRACTED]
  index.html → index.html  _Bridges community 1 → community 6_
- `PlanyTab()` --calls--> `render()`  [EXTRACTED]
  index.html → index.html  _Bridges community 1 → community 2_
- `RoutineEditor()` --calls--> `render()`  [EXTRACTED]
  index.html → index.html  _Bridges community 1 → community 7_
- `SettingsSheet()` --calls--> `render()`  [EXTRACTED]
  index.html → index.html  _Bridges community 1 → community 8_

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Supabase persistence sync flow** — index_dbwrite, index_synctable, index_savecustomexercises, index_saveroutines, index_savehistory, index_saveactive, index_setunit, index_settrackrir, index_loadalldata [INFERRED 0.85]
- **In-memory CACHE data layer accessors** — index_cache, index_customexercises, index_allexercises, index_routines, index_history, index_getactive, index_getunit, index_gettrackrir [INFERRED 0.85]
- **Tab-based render pipeline** — index_render, index_app, index_tabcontent, index_treningtab, index_planytab, index_statystykitab, index_cwiczeniatab [INFERRED 0.80]

## Communities (60 total, 57 thin omitted)

### Community 0 - "Workout Session Lifecycle"
Cohesion: 0.20
Nodes (3): CACHE (in-memory data store), state (global UI state object), WorkoutEditor()

### Community 1 - "App Shell & Rendering"
Cohesion: 0.20
Nodes (3): CwiczeniaTab(), LoadFailedScreen(), render()

### Community 2 - "Plan & Routine Management"
Cohesion: 0.25
Nodes (3): PlanyTab(), startWorkout(), TreningTab()

## Knowledge Gaps
- **10 isolated node(s):** `SHELL`, `RAW_EXERCISES (exercise catalogue data)`, `BUILT_IN (built-in exercises list)`, `MUSCLES (muscle group list)`, `TEMPLATES (routine templates)` (+5 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 96 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **57 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `render()` connect `App Shell & Rendering` to `Settings Sheet`, `Plan & Routine Management`, `Exercise Picker`, `Routine Editor`?**
  _High betweenness centrality (0.057) - this node is a cross-community bridge._
- **Why does `PlanyTab()` connect `Plan & Routine Management` to `App Shell & Rendering`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **Why does `ExercisePickerSheet()` connect `Exercise Picker` to `App Shell & Rendering`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **What connects `SHELL`, `RAW_EXERCISES (exercise catalogue data)`, `BUILT_IN (built-in exercises list)` to the rest of the system?**
  _10 weakly-connected nodes found - possible documentation gaps or missing edges._