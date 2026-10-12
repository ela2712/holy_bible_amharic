# Project Handoff & Context (`holy_bible_amharic`)

> **How to use this file on another machine:**
> Open this repository as your workspace in Antigravity and tell the assistant:
> *"Read `HANDOFF.md` to get full context on our project and let's continue."*

---

## 1. Project Vision & Goal
We are building a modern, cross-platform (Android, iOS, Windows, macOS, Web) **Amharic & Ethiopian Orthodox Study Bible** (`ቅዱስ መጽሐፍ — Catena Edition`).
- **Origin:** Inspired by the classic Fyn Systems Amharic Bible (`com.fynsystem.amharic_bible`), which stopped receiving updates and crashes on modern devices.
- **Design Philosophy:** Retain all the beloved features of the classic Amharic Bible while delivering a **modern 2026 Reader-first UX/UI** inspired by **Catena**—without looking like a clone of Fyn Systems OR a literal 1:1 clone of Catena.

---

## 2. Strict User Constraints
1. **NO AUTOMATIC GIT PUSHES OR COMMITS:** Never run `git push` or automatic `git commit` commands. The user manages all Git commits and pushes manually.
2. **Offline-First & Authentic Texts:** Keep all offline Bible texts (`assets/data/amharic_1954.json`, `assets/data/orthodox_81.json`, `assets/data/kjv.json`) fast, intact, and searchable offline.

---

## 3. Core UX/UI & Product Decisions (from `/grill-me` Design Alignment)

### A. Reader-First Entry & Auto-Hiding Chrome
- **Direct-to-Reader Launch (`lib/ui/screens/main_navigation_shell.dart`):**
  - The app opens directly into the distraction-free **Scripture Reader** (`Tab 0: ንባብ / Read`).
  - Minimalist 4-tab floating glassmorphic pill dock:
    1. `ንባብ (Read)` — Main Scripture Reader
    2. `ዕቅዶች (Plans)` — Reading Plans & Custom Plan Builder
    3. `ፍለጋ (Search)` — Homophone-normalized Ge'ez Search & Topic Explorer
    4. `ማህደር (Saved)` — Bookmarks, Highlights & Personal Study Notes Vault
- **Auto-Hiding Bars (`lib/ui/screens/home_reader_screen.dart`):**
  - Scrolling down inside the Reader smoothly slides/fades away both the top floating reader bar and the bottom navigation dock for a 100% full-screen reading canvas. Scrolling up restores them immediately.

### B. Distinct Visual Palette (`lib/core/theme/app_theme.dart`)
- **Minimalist Monochrome & Warm Terracotta-Gold / Teal-Slate:**
  - **Ivory Light (Default):** `#FAF9F6` canvas, `#FFFFFF` cards, `#E6E4DD` hairline borders, `#18181B` charcoal ink, `#B45309` warm terracotta-gold primary accent, `#0F766E` deep teal-slate secondary accent.
  - **Archival Parchment (Sepia):** `#F4EFE6` canvas, `#EFE8DC` surface, `#26221E` espresso ink, `#9A4E12` burnished bronze accent.
  - **Obsidian Charcoal (Dark):** `#0E1014` canvas, `#171A21` surface, `#F3F4F6` warm-white ink, `#E09F5A` luminous coral-gold accent, `#2DD4BF` teal accent.
- **Typography:** Pairs **Noto Serif Ethiopic** for scripture body text with **Plus Jakarta Sans** + **Noto Sans Ethiopic** for clean editorial UI controls.

### C. Scripture Reader Layout (`lib/ui/screens/home_reader_screen.dart`)
- **Continuous Verse Flow with Left-Margin Accent Bars:**
  - Verses flow cleanly down the page. Verses with direct commentaries display a **warm terracotta-gold left-margin vertical bar** (`3.2px`) and a subtle `✝ N የአበው ትርጓሜ • M ማጣቀሻ` badge.
- **Paragraph vs. Verse-Flow Toggle (`¶`):**
  - Users can toggle between continuous paragraph reading and verse-by-verse study blocks right from the floating top bar.
- **1-Tap Theme Cycle & Translation Switcher:**
  - Switch between **1954 Haile Selassie (66 Books)**, **Ethiopian Orthodox 81 Canon (`ሰማንያ አሐዱ`)**, and **King James Version (KJV)**, or cycle Light → Sepia → Dark in one tap.

### D. 3-Step Book → Chapter → Verse Modal Selector (`lib/ui/screens/book_selector_screen.dart`)
- Tapping the Book/Chapter pill opens a 90%-height modal sheet with a **3-Step Breadcrumb Bar (`፩. መጽሐፍ` → `፪. ምዕራፍ` → `፫. ቁጥር`)**.
- Color-coded canonical categories (`ኦሪት`, `ታሪክ`, `ጥበብና መዝሙር`, `ነቢያት`, `ቀኖና 81`, `ወንጌላት`, `መልእክታት`, `ራእይ`).
- Toggle between a compact **Abbreviation Grid** (`ዘፍ`, `ዘጸ`, `መዝ`, `ሄኖ`, `ማቴ`, `ዮሐ`) and **Detailed List**, plus instant search and OT/NT filters.
- Selecting a verse scrolls the Reader directly to that verse and highlights it.

### E. Interactive Verse Study Bottom Sheet (`lib/ui/screens/study_tools_dialog.dart`)
- Tapping any verse highlights it and opens `StudyToolsSheet`:
  - **Top Quick-Action Strip:** 1-tap highlight color swatches (`#FDE68A`, `#A7F3D0`, `#BAE6FD`, `#FECDD3`, `#DDD6FE`, + Clear), Bookmark toggle, collapsible Personal Note editor (with built-in Ge'ez keyboard), Copy, Share, and Verse Card Maker (`VerseCardMakerScreen`).
  - **Tradition & Study Filter Pills:**
    - `ሁሉም አበው (All Fathers)`
    - `አንድምታ (Ethiopian Andimta Tradition — St. Yared, Abba Giyorgis of Gascha, Andimta Scholars)`
    - `ቀደምት አበው (Early Church Fathers — St. John Chrysostom, St. Cyril of Alexandria, St. Athanasius, St. Ephrem, St. Augustine)`
    - `ተዛማጅ ጥቅሶች (Detailed Cross-References)`
    - `ማነፃፀሪያ (Parallel 1954 / 81 Canon / KJV)`
- **Detailed Cross-References (`lib/data/cross_references_data.dart` & `lib/models/cross_reference.dart`):**
  - Every cross-reference includes:
    1. Target reference badge (`የዮሐንስ ወንጌል 1:1`, etc.)
    2. Connection category (`ትንቢትና ፍጻሜ`, `ምሳሌና አማናዊ`, `ነገረ መለኮት`, `የ81 ቀኖና ትስስር`)
    3. **Detailed source citation** (`sourceCitation`, e.g., *ምንጭ፦ የመጽሐፍ ቅዱስ ቀኖናዊ ማጣቀሻ (Treasury of Scripture Knowledge) እና የአንድምታ ትርጓሜ*)
    4. Target verse quote preview + exegetical explanation of how the verses connect
    5. 1-tap **"ወደ ጥቅሱ ሂድ (Jump to Verse)"** button.

### F. In-Reader Reading Plans & Custom Plan Builder (`lib/ui/screens/reading_plans_screen.dart`)
- **14 Pre-Built Plans (`lib/data/reading_plans_data.dart`):**
  - Every single day across all 14 plans (including *Canonical 365*, *Chronological 365*, *M'Cheyne 180*, *New Testament 90*, *4 Gospels 30*, *Holy Passion Week 8*, *Great Lent 55*, *Fast of the Prophets 43*, *Filseta 16*, *Proverbs 31*, *Psalms 60*, *Miracles & Parables 21*, *Faith & Courage 30*, *Messianic Prophecies 40*) maps to **real, accurate Bible book numbers and chapters**.
- **Custom Plan Builder (`+ ዕቅድ ፍጠር`):**
  - Users can create custom plans by naming their plan, selecting a canonical scope (4 Gospels, New Testament, Psalms & Wisdom, Pentateuch, Old Testament, or Full Bible), and picking a duration (`7`, `14`, `21`, `30`, `60`, `90`, `180`, `365` days).
- **In-Reader Active Plan Bar (`lib/providers/reading_plan_session_provider.dart`):**
  - Launching any plan day opens the exact chapter in the Reader with a floating bar showing the current plan/day and a **`✓ ቀኑን አጠናቅቅ (Mark Day Complete & Next)`** button.

---

## 4. Key Directory & File Structure
- `lib/main.dart` — App entry point and Riverpod `ProviderScope`
- `lib/core/theme/app_theme.dart` — Minimalist Monochrome & Terracotta-Gold / Teal-Slate theme system
- `lib/core/utils/geez_numbers.dart` & `geez_normalizer.dart` — Ge'ez numeral conversion & homophone-normalized search (`ሀ/ሐ/ኀ`, `ሰ/ሠ`, `አ/ዐ`, `ጸ/ፀ`)
- `lib/data/patristic_commentaries.dart` — Early Church Fathers & Ethiopian Andimta commentaries + contextual fallback engine
- `lib/data/cross_references_data.dart` — Curated & canonical cross-references with detailed sources and explanations
- `lib/data/reading_plans_data.dart` — 14 accurate reading plans + dynamic Custom Plan Builder generator
- `lib/providers/bible_state.dart` — Active translation, book, chapter, verses, headings state
- `lib/providers/reading_plan_session_provider.dart` — Active in-reader plan session, completion persistence, and custom plans state
- `lib/providers/search_provider.dart` — Normalized Ge'ez search state & recent searches
- `lib/providers/theme_provider.dart` — Reader theme, font size, line spacing, Ge'ez numerals, and paragraph mode persistence
- `lib/services/bible_repository.dart` — Loads and caches `amharic_1954.json`, `orthodox_81.json`, and `kjv.json`, plus bookmarks/highlights/notes
- `lib/services/audio_player_service.dart` — Streaming chapter audio player (`just_audio`)
- `lib/ui/screens/main_navigation_shell.dart` — Reader-first 4-tab shell with auto-hiding floating dock
- `lib/ui/screens/home_reader_screen.dart` — Main Scripture Reader with auto-hiding top bar, left-margin commentary bars, paragraph mode, and active plan bar
- `lib/ui/screens/book_selector_screen.dart` — 3-step (`Book → Chapter → Verse`) modal selector
- `lib/ui/screens/study_tools_dialog.dart` — Interactive verse study bottom sheet with tradition filter pills & detailed cross-references
- `lib/ui/screens/reading_plans_screen.dart` — Reading plans hub & Custom Plan Builder modal
- `lib/ui/screens/search_screen.dart` — Homophone-aware Ge'ez search & spiritual topic chips
- `lib/ui/screens/annotations_screen.dart` — Study Vault (Bookmarks, Highlights, Notes)
- `lib/ui/screens/parallel_reader_screen.dart` — Side-by-side translation comparison
- `lib/ui/screens/verse_card_maker_screen.dart` — Shareable verse image card designer
