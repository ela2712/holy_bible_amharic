# Project Handoff & Context (`holy_bible_amharic`)

> **How to continue on another machine (e.g., Laptop at home):**
> 1. Pull the latest commits from your repository (`git pull`).
> 2. Open this directory as your workspace in Antigravity.
> 3. Tell the assistant:
>    *"Read `HANDOFF.md` to get full context on our project and let's continue."*

---

## 1. Project Vision & Architecture
We are building a modern, distraction-free, cross-platform (Android, iOS, Windows, macOS, Web) **Amharic Holy Bible & Ethiopian Orthodox Study App** (`መጽሐፍ ቅዱስ — የአበው አንድምታ`).
- **Origin:** Inspired by the classic Fyn Systems Amharic Bible (`com.fynsystem.amharic_bible`), which stopped receiving updates and crashes on modern devices.
- **Design Philosophy:** Retain all beloved features of the classic Amharic Bible while delivering a **modern 2026 Reader-first UX/UI** featuring rich Ethiopian Andimta and Patristic commentaries, deep canonical cross-references, and full offline-first functionality.
- **Branding Directive:** Do NOT call or reference "Catena". The app is branded as **መጽሐፍ ቅዱስ (Holy Bible Amharic)** with **የአበው አንድምታ (Patristic & Andimta Commentaries)**.

---

## 2. Strict Project & User Constraints
1. **NO AUTOMATIC GIT PUSHES OR COMMITS:** Never execute automated `git commit` or `git push` commands. The user manages all Git versioning and commits manually.
2. **Orthodox 81 Canon (`eotc_81`) is Primary Default:** The 81 Orthodox Canon is the main, primary translation throughout the entire app. 1954 and KJV are available secondary translations.
3. **No "Protestant" Labels:** Never refer to KJV or 66-book editions as "protestant". KJV is labeled as "Authorized King James Version (Classic English)" with canon identifier `'standard_kjv'`.
4. **Cross-Translation Location Persistence:** Switching translations lands on the exact same book and chapter (e.g., Matthew 1 in 81 lands on Matthew 1 in 1954/KJV). 81-exclusive books fall back gracefully.
5. **Offline-First & Authentic Texts:** All sacred Bible texts (`assets/data/orthodox_81.json`, `assets/data/amharic_1954.json`, `assets/data/kjv.json`) remain 100% offline, local, fast, and searchable.
6. **No Audio Player:** Audio narration buttons and player widgets have been permanently removed per user directive.
7. **Sacred Spiritual Text Integrity:** Structural verse mergers in 1954 (e.g., Matthew 2:1–2) are handled via typography/metadata ranges (`፩-፪` / `1–2`).

---

## 3. Milestones & Today's Updates (October 15, 2026)

### A. Orthodox 81 Canon (`eotc_81`) Set as Primary Default
- **`BibleRepository` (`lib/services/bible_repository.dart`):**
  - Set `id: 2` (`eotc_81`) as the first translation in `_translations` with `isDefault: true`.
  - Changed KJV canon identifier from `'protestant_66'` to `'standard_kjv'`.
  - Replaced raw Portuguese book titles in `_loadKjvBible()` with standard English KJV titles (`Genesis`, `Matthew`, `John`, etc.) via `CanonicalBookMap.kjvEnglishNames`.
  - Added explicit `'testament'` tag to all indexed verses so search testament filtering accurately distinguishes between OT and NT across both 54-OT and 39-OT canons.
- **`BibleStateNotifier` (`lib/providers/bible_state.dart`):**
  - Updated default active translation ID to `2` (81 Canon).
  - Search provider and home dashboard default to `id: 2`.

### B. Canonical Cross-Translation Navigation (`lib/core/utils/canonical_book_map.dart`)
- **The Divergence:**
  - In the Ethiopian Orthodox 81 Canon, the Old Testament has 54 books. Consequently, `የማቴዎስ ወንጌል` (Matthew) is **book #55**.
  - In 1954 and KJV, the Old Testament has 39 books. Consequently, `የማቴዎስ ወንጌል` is **book #40**.
  - Navigating purely by `bookNumber` caused Matthew in 81 to switch to 2 Timothy in 1954/KJV.
- **The Solution:**
  - Built `CanonicalBookMap` mapping all 81 Ethiopian Orthodox books (54 OT + 27 NT) and 66 traditional books to standard canonical IDs (`GEN`, `MAT`, `ROM`, etc.).
  - `selectTranslation(Translation)` in `bible_state.dart` translates the active book number to its canonical ID and resolves the corresponding book number in the target translation.
  - If a book is exclusive to the 81 Canon (e.g. Enoch, Jubilees, Meqabyan), it gracefully lands on the first book in the same testament.
  - Unit tests in `test/translation_cross_navigation_test.dart` verify 100% precision.

### C. Comprehensive Whole-App Scan & Quality Audit Fixes
1. **Dashboard Tab Navigation Repaired (`lib/ui/screens/home_dashboard_screen.dart`):**
   - Corrected all tab navigation indices:
     - "Resume Reading", "ምዕራፉን አንብብ" (Daily Verse), Canon Quick-Strip, Patristic Spotlight, and Thematic Selections now navigate to **Tab 0** (`HomeReaderScreen`).
     - "Reading Plans Hub" and "View all plans" now navigate to **Tab 2** (`ReadingPlansScreen`).
2. **Merged Verse Range Selection & Highlighting (`lib/ui/screens/home_reader_screen.dart`):**
   - Fixed `_selectedVerseNumber` matching in both paragraph and list view so tapping or jumping to any verse within a merged range (e.g., verse 2 in 1–2) properly selects and highlights the merged verse.
3. **Book Selector Verse Grid (`lib/ui/screens/book_selector_screen.dart`):**
   - Updated `_verseCountForChapter` calculation to compute `max(verseEnd ?? verse)` so all verses in merged chapters are fully accessible in Step 3.
4. **Parallel Verses Canonical Matching (`lib/services/bible_repository.dart` & `lib/ui/screens/study_tools_dialog.dart`):**
   - Enhanced `getParallelVerseTexts` with `sourceTranslationId` and `CanonicalBookMap` lookup so comparing 81 Canon verses with 1954 and KJV matches the identical book rather than offset book numbers.
6. **Canonical Resolution across Reading Plans & Dashboard (`CanonicalBookMap.resolveBook`):**
   - Added `CanonicalBookMap.resolveBook(...)` to seamlessly map traditional 66-book numbers (`40` Matthew, `19` Psalms, `20` Proverbs, `46` 1 Corinthians) to their corresponding 81 Canon book positions (`55`, `28`, `29`, `61`).
   - Integrated into `ReadingPlansScreen` passage launcher, Canon Quick-Strip, Patristic Spotlight, and Thematic Guides so all links open the correct biblical book regardless of active translation.
7. **Direct Verse Navigation & Highlight (`targetVerse`):**
   - Added `targetVerse` state to `BibleViewState` with reactive listener in `HomeReaderScreen`.
   - Tapping search results, bookmarks, highlights, notes, or cross-references now automatically scrolls directly to the verse and highlights it with an emerald glow.
8. **In-Text Search Keyword Highlighting:**
   - Search results in `SearchScreen` now render rich text with the query term highlighted in soft emerald/jade ink and bold weight.
9. **Cross-Platform Verse Card Export:**
   - Migrated `VerseCardMakerScreen` from `dart:io` `File` to `XFile.fromData`, enabling 100% crash-free card export on Web, Desktop, and Mobile.

---

## 4. Visual Themes & Design Tokens

| Theme Mode | Canvas Background | Card / Surface | Hairline Border | Primary Ink | Emerald Accent | Secondary Jade Accent |
|---|---|---|---|---|---|---|
| **Ivory Light** | `#FAF9F6` | `#FFFFFF` | `#E6E4DD` | `#18181B` | `#047857` (Emerald) | `#0F766E` (Jade Slate) |
| **Parchment Sepia** | `#F4EFE6` | `#EFE8DC` | `#E2DAC9` | `#26221E` | `#065F46` (Forest Green) | `#115E59` (Deep Jade) |
| **Obsidian Dark** | `#0E1014` | `#171A21` | `#27272A` | `#F3F4F6` | `#10B981` (Bright Emerald) | `#2DD4BF` (Teal) |

- **Body Typography:** `Noto Serif Ethiopic` for scripture verses.
- **Interface Typography:** `Plus Jakarta Sans` paired with `Noto Sans Ethiopic`.
- **Vector Icons:** Bespoke `ModernBibleIcons` and `EthiopianCrossPainter`.

---

## 5. Navigation Shell Structure

- **Tab 0: `ንባብ` (Bible Reader)** — Auto-hiding floating interaction capsule, paragraph/verse modes, patristic commentary indicators, quick translation switcher.
- **Tab 1: `አንድምታ` (Library & Dashboard)** — Daily verse hero, reading progress, canon quick-access strip, patristic spotlight carousel, thematic collections.
- **Tab 2: `ዕቅዶች` (Lectionary & Reading Plans)** — 14 liturgical & devotional reading plans, Bahire Hasab movable feasts/fasts auto-calculation, custom plan generator.
- **Tab 3: `ማህደር` (Annotations Vault)** — Saved bookmarks, highlights by color, and personal notes with virtual Ge'ez keyboard.
- **Floating `[ 🔍 ]` Search Button:** Floating on Tabs 1, 2, and 3 for instant search access.

---

## 6. Verification Status

- **`flutter test`:** **All passed (smoke tests & canonical cross-navigation tests)**.
- **`flutter analyze --no-fatal-infos`:** **0 Errors, 0 Warnings**.
- **Working Tree:** All modifications verified and ready for manual user commit & push.
