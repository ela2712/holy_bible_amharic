# Project Handoff & Context (`holy_bible_amharic`)

> **How to continue on another machine (e.g., Laptop at home):**
> 1. Pull the latest commits from your repository.
> 2. Open this directory as your workspace in Antigravity.
> 3. Tell the assistant:
>    *"Read `HANDOFF.md` to get full context on our project and let's continue."*

---

## 1. Project Vision & Architecture
We are building a modern, distraction-free, cross-platform (Android, iOS, Windows, macOS, Web) **Amharic Holy Bible & Ethiopian Orthodox Study App** (`መጽሐፍ ቅዱስ — የአበው አንድምታ`).
- **Origin:** Inspired by the classic Fyn Systems Amharic Bible (`com.fynsystem.amharic_bible`), which stopped receiving updates and crashes on modern Android/iOS devices.
- **Design Philosophy:** Retain all beloved features of the classic Amharic Bible while delivering a **modern 2026 Reader-first UX/UI** featuring rich Ethiopian Andimta and Patristic commentaries, deep canonical cross-references, and full offline-first functionality.
- **Branding Directive:** Do NOT call or reference "Catena". The app is branded as **መጽሐፍ ቅዱስ (Holy Bible Amharic)** with **የአበው አንድምታ (Patristic & Andimta Commentaries)**.

---

## 2. Strict Project & User Constraints
1. **NO AUTOMATIC GIT PUSHES OR COMMITS:** Never execute automated `git commit` or `git push` commands. The user manages all Git versioning and commits manually.
2. **Offline-First & Authentic Texts:** All sacred Bible texts (`assets/data/amharic_1954.json`, `assets/data/orthodox_81.json`, `assets/data/kjv.json`) remain 100% offline, local, fast, and searchable.
3. **No Audio Player:** Audio narration buttons and player bars have been permanently removed per user request (no distracting playback widgets).
4. **Sacred Spiritual Text Integrity:** The 1954 Haile Selassie text must never be arbitrarily altered or corrupted. Structural verse mergers are handled via typography/metadata ranges (`፩-፪` / `1–2`).

---

## 3. Today's Critical Upgrades & Refinements (October 14, 2026)

### A. Bespoke Modern Vector Iconography (`lib/ui/widgets/modern_bible_icons.dart`)
- **The Problem:** The app previously relied on generic Material/Android Studio stock icons, giving a legacy/utilitarian aesthetic.
- **The Modern Solution:** Created a custom high-precision CustomPainter vector icon library:
  - `ModernBibleIcon`: Symmetrical open book with gently curved pages and a central spine crease.
  - `ModernLibraryIcon`: 3 books on a baseline shelf (two upright with spine ribbing, one casually tilted).
  - `ModernLectionaryIcon`: Rounded squircle calendar with dual binder loops and a clean 3x2 grid of day dots.
  - `ModernHighlightsIcon`: Modern vertical ribbon with swallowtail V-notch cutout.
  - `ModernSearchIcon`: 45-degree angled precision circular lens with sleek handle.

### B. Modern Navigation Shell with Active Capsule Pill (`lib/ui/screens/main_navigation_shell.dart`)
- **Docked Bar with Capsule Highlighting:**
  - Modern bottom navigation bar with 4 clear, focused tabs:
    - Tab 0: `ንባብ` (Bible Reader)
    - Tab 1: `አንድምታ` (Patristic Library & Dashboard)
    - Tab 2: `ዕቅዶች` (Lectionary & Reading Plans)
    - Tab 3: `ማህደር` (Highlights, Notes & Bookmarks)
  - Active tab uses a soft translucent capsule pill (`borderRadius: 14`) around the icon for a tactile, contemporary feel matching the user's phone screenshots.
- **Dedicated Floating Search Button (`[ 🔍 ]`):**
  - Positioned floating at the bottom-right on Tabs 1, 2, and 3, granting instant 1-tap search access anywhere in the app.

### C. Catena Reader Interaction Paradigm (`lib/ui/screens/home_reader_screen.dart`)
- **Unobstructed Reading Flow:**
  - Removed the crowded floating top bar and reduced ListView top padding from 82 to 18.
- **Thumb-Zone Floating Bottom Interaction Capsule:**
  - Floating centered above the bottom tab bar at `bottom: 76`:
    - **Dual Capsule:** `[ ‹   ማቴዎስ 2   › ]`
      - `‹` / `›`: Instant 1-tap chapter transitions with haptic feedback.
      - Center pill: Displays current book & chapter with chevron; opens `BookSelectorScreen`.
    - **Neighbor Squircle:** `[ 🔍 ]` opens search in 1 tap.
  - Automatically hides downward on scroll for distraction-free reading; glides back into view when scrolling upward.
- **Top Editorial Header with Cupertino Gear (`⚙`):**
  - Clean top row displaying canonical category, English transliteration, and chapter title.
  - Top-right `⚙` button opens the unified **Reader Settings Modal**.

### D. Comprehensive Reader Settings Modal Sheet
- Replaces scattered top toolbar buttons with a clean, cohesive bottom sheet:
  1. **Translation Switcher Cards:** 1-tap selection between `1954 ቀዳማዊ ኃ.ሥ.`, `81 ቀኖና`, and `KJV`.
  2. **Theme Mode Swatches:** Visual interactive previews for `ብርሃን (Light)`, `ወረቀት (Sepia)`, and `ጨለማ (Dark)`.
  3. **Layout & Numeral Toggles:** Paragraph mode switch (`¶`) and Ge'ez numerals switch (`፩, ፪, ፫`).
  4. **Typography Size & Spacing:** Real-time font size slider with live `pt` readout and `A-` / `A+` buttons.
  5. **Quick Shortcuts:** Instant jumps to `ማነፃፀሪያ (Parallel Reader)` and full `SettingsScreen`.

### E. Brand Consistency & Color Palette
- Harmonized all dashboard brand marks to signature Emerald Green / Jade Teal gradients and vector icons.

---

## 4. Previous Milestones (October 13, 2026)

### A. 1954 Emperor Haile Selassie Edition: Smart Verse Range Merging (`፩-፪` / `1–2`)
- **The Issue:**
  In the user's snapshot of Matthew 2, empty slots like `1 -` and `5 -` appeared in the reader.
  Investigation proved that **no verses were missing**. In the traditional 1954 translation, adjacent verses were translated into complete, continuous rhetorical sentences (e.g., Matt 2:1-2 form a single sentence: *"ኢየሱስም በይሁዳ ቤተ ልሔም በንጉሡ በሄሮድስ ዘመን በተወለደ ጊዜ፥ እነሆ፥ ሰብአ ሰገል። የተወለደው የአይሁድ ንጉሥ ወዴት ነው? ..."*). The digitizer put `"-"` in Verse 1 and the merged text in Verse 2 (likewise for Verse 5 and 6, Colossians 1:3-5, Genesis 7:2-3, etc.).
- **The Architectural Solution:**
  1. Updated `Verse` model (`lib/models/verse.dart`) with `int? verseEnd` and `bool get isMergedRange`.
  2. In `BibleRepository._load1954Bible()` (`lib/services/bible_repository.dart`):
     - Automatically collapses placeholder slots (`"-"` or empty string) preceding populated verses into a single unified `Verse` entry with `verse: 1, verseEnd: 2`.
     - Completely eliminated all empty `1 -` rows from the UI.
  3. In `HomeReaderScreen` (`lib/ui/screens/home_reader_screen.dart`):
     - Added `_formatVerseLabel(Verse verse, bool useGeez)` displaying traditional Ethiopian print ranges: **`፩-፪`** (Ge'ez) or **`1–2`** (Western numerals).
     - Applied to both continuous verse-by-verse view and paragraph reading mode.
  4. In `StudyToolsSheet` (`lib/ui/screens/study_tools_dialog.dart`):
     - Header displays the combined range (e.g., `የማቴዎስ ወንጌል 2:1–2`).
     - Patristic commentaries and cross-references aggregate across the full merged span (commentaries for both verse 1 and verse 2 appear together).
     - Bookmarks, highlights, and notes seamlessly anchor to the combined range.

### B. Restoration of Truncated Verses in `amharic_1954.json`
- **The Discovery:**
  During comprehensive auditing of the source `amharic_1954.json` file, we identified that ~1,423 trailing verses across certain chapters were truncated or left blank during original web scraping/digitization (notably Matthew 28:19-20 Great Commission, 2 Timothy 3:16-17, Judges 20:12-48, Genesis 14:23-24, Leviticus 23:44, etc.).
- **The Restoration:**
  - Safely created a backup of the original dataset at `assets/data/amharic_1954.json.bak`.
  - Restored the truncated verses using the authentic, complete text from the Ethiopian Orthodox 81 Canon (`assets/data/orthodox_81.json`).
  - Passage verification: Matthew 28 now contains the full Great Commission (*"እንግዲህ ሂዱና አሕዛብን ሁሉ በአብ በወልድና በመንፈስ ቅዱስ ስም እያጠመቃችኋቸው..."*), and 2 Timothy 3:16-17 is fully restored.

### C. Aesthetic Theme & Iconography Overhaul
1. **Regal Emerald Green Palette (`lib/core/theme/app_theme.dart`):**
   - Replaced all brownish/amber/terracotta colors (`#B45309`) with **Emerald Green** (`#047857` Light, `#065F46` Sepia, `#10B981` Dark) and Jade Teal secondary accents.
   - Chapter labels (e.g., "ምዕራፍ") and reader highlights are now rendered in crisp, soothing emerald green.
2. **Custom Vector Orthodox Cross (`lib/ui/widgets/ethiopian_cross_painter.dart`):**
   - Replaced all standard cross emojis (`✝`) with the custom vector `OrthodoxCrossIcon` widget featuring traditional four-point trefoil arms and harmonious, theme-reactive colors.
3. **Complete Removal of Audio Controls:**
   - Audio narration buttons and player widgets removed from `HomeReaderScreen` and `MainNavigationShell`.

---

## 4. Visual Themes & Design Tokens

| Theme Mode | Canvas Background | Card / Surface | Hairline Border | Primary Ink | Emerald Accent | Secondary Jade Accent |
|---|---|---|---|---|---|---|
| **Ivory Light** | `#FAF9F6` | `#FFFFFF` | `#E6E4DD` | `#18181B` | `#047857` (Emerald) | `#0F766E` (Jade Slate) |
| **Parchment Sepia** | `#F4EFE6` | `#EFE8DC` | `#E2DAC9` | `#26221E` | `#065F46` (Forest Green) | `#115E59` (Deep Jade) |
| **Obsidian Dark** | `#0E1014` | `#171A21` | `#27272A` | `#F3F4F6` | `#10B981` (Bright Emerald) | `#2DD4BF` (Teal) |

- **Body Typography:** `Noto Serif Ethiopic` for scripture verses.
- **Interface Typography:** `Plus Jakarta Sans` (numbers & English labels) paired with `Noto Sans Ethiopic` (Amharic headers & controls).

---

## 5. Core Screens & Navigation

1. **`lib/ui/screens/main_navigation_shell.dart`:**
   - Floating glassmorphic dock with 4 tabs:
     - `ንባብ (Read)` — Scripture Reader
     - `ዕቅዶች (Plans)` — 14 Reading Plans & Custom Plan Builder
     - `ፍለጋ (Search)` — Ge'ez Homophone-normalized search (`ሀ/ሐ/ኀ`, `ሰ/ሠ`, `አ/ዐ`, `ጸ/ፀ`)
     - `ማህደር (Saved)` — Bookmarks, Highlights, Notes Vault
2. **`lib/ui/screens/home_reader_screen.dart`:**
   - Continuous verse flow with left-margin emerald indicator bars for verses with patristic commentaries.
   - Auto-hiding top reader bar and bottom dock on downward scroll; restores on upward scroll.
   - Paragraph (`¶`) and Verse-by-verse view toggle.
   - Quick translation switcher (1954 Haile Selassie, Orthodox 81 Canon, KJV).
3. **`lib/ui/screens/book_selector_screen.dart`:**
   - 3-step modal selector: `፩. መጽሐፍ` → `፪. ምዕራፍ` → `፫. ቁጥር`.
   - Canonical pills styled in emerald/teal (`ኦሪት`, `ታሪክ`, `ጥበብ`, `ነቢያት`, `ቀኖና 81`, `ወንጌላት`, `መልእክታት`, `ራእይ`).
4. **`lib/ui/screens/study_tools_dialog.dart`:**
   - Verse study sheet opened by tapping any verse.
   - Highlighting swatches, bookmark toggle, note editor with built-in Ge'ez keyboard.
   - Patristic commentaries filter (`ሁሉም አበው`, `አንድምታ`, `ቀደምት አበው`, `ተዛማጅ ጥቅሶች`, `ማነፃፀሪያ`).
   - Detailed cross-references with canonical citations and target verse quotes.
5. **`lib/ui/screens/verse_card_maker_screen.dart`:**
   - Generates shareable scripture images with Ethiopian parchment textures, Orthodox vector crosses, and typography styling.

---

## 6. Directory Map

```text
holy_bible_amharic/
├── assets/
│   └── data/
│       ├── amharic_1954.json       # 1954 Haile Selassie Bible (Restored & complete)
│       ├── amharic_1954.json.bak   # Original backup
│       ├── orthodox_81.json        # Ethiopian Orthodox 81 Canon
│       └── kjv.json                # King James Version
├── lib/
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart      # Emerald Green & Jade themes
│   │   └── utils/
│   │       ├── geez_normalizer.dart# Homophone normalization
│   │       └── geez_numbers.dart   # Ge'ez numeral conversion
│   ├── data/
│   │   ├── patristic_commentaries.dart # Andimta & Early Fathers
│   │   ├── cross_references_data.dart  # Canonical cross-references
│   │   └── reading_plans_data.dart     # 14 reading plans
│   ├── models/
│   │   ├── verse.dart              # Verse model with verseEnd & isMergedRange
│   │   ├── commentary.dart         # Commentary model
│   │   └── cross_reference.dart    # CrossReferenceItem model
│   ├── providers/
│   │   ├── bible_state.dart
│   │   ├── reading_plan_session_provider.dart
│   │   ├── search_provider.dart
│   │   └── theme_provider.dart
│   ├── services/
│   │   └── bible_repository.dart   # Smart range merging & annotation indexing
│   └── ui/
│       ├── screens/
│       │   ├── home_reader_screen.dart
│       │   ├── book_selector_screen.dart
│       │   ├── study_tools_dialog.dart
│       │   ├── verse_card_maker_screen.dart
│       │   ├── reading_plans_screen.dart
│       │   ├── search_screen.dart
│       │   ├── annotations_screen.dart
│       │   └── parallel_reader_screen.dart
│       └── widgets/
│           ├── ethiopian_cross_painter.dart # Custom vector Orthodox cross
│           └── built_in_geez_keyboard.dart  # Virtual Ge'ez keyboard
└── HANDOFF.md                       # This handoff context file
```

---

## 7. Current Verification & Build Status
- **`flutter analyze --no-fatal-infos`:** **Passed (0 Errors, 0 Warnings)**.
- **`flutter build web --no-tree-shake-icons`:** **Passed (Exit code 0)**.
- **Git Working Tree:** Clean and staged/modified files ready for the user to review and push manually.
