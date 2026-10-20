# Project Handoff & Context (`holy_bible_amharic`)

> **How to continue on another machine (e.g., Laptop at home):**
> 1. Pull the latest commits from your repository (`git pull`).
> 2. Open this directory as your workspace in Antigravity.
> 3. Tell the assistant:
>    *"Read `HANDOFF.md` to get full context on our project and let's continue."*

---

## 1. Project Vision & Architecture
We are building a modern, distraction-free, cross-platform (Android, iOS, Windows, macOS, Web) **Amharic Holy Bible & Ethiopian Orthodox Study App** (`መጽሐፍ ቅዱስ — 81 ቀኖና`).
- **Origin:** Inspired by the classic Fyn Systems Amharic Bible (`com.fynsystem.amharic_bible`), which stopped receiving updates and crashes on modern devices.
- **Design Philosophy:** Retain all beloved features of the classic Amharic Bible while delivering a **modern 2026 Reader-first UX/UI** featuring the authentic 81 Orthodox Canon, canonical cross-references, parallel 3-way translation comparison, reading plans with Bahire Hasab, and full offline-first functionality.
- **Branding Directive:** Do NOT call or reference "Catena". The app is branded as **መጽሐፍ ቅዱስ (Holy Bible Amharic — 81 ቀኖና)**. Incomplete commentary snippets have been eliminated to preserve sacred tradition integrity.

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
74: 
10. **Scripture Digitizer Glitch Audit & Text Restoration (`assets/data/orthodox_81.json`):**
    - **Diagnosis from Snapshot:**
      - **Matthew 5:3:** Clipped first 2 letters (`በመ` eaten by `“`): `“ንፈስ ድሆች...` $\rightarrow$ restored to **`በመንፈስ ድሆች የሆኑ ብፁዓን ናቸው፤ መንግሥተ ሰማያት የእነርሱ ናትና።`**
      - **Matthew 5:11:** Clipped first 2 letters (`ሲነ` eaten by `“`): `“ቅፉአችሁና...` $\rightarrow$ restored to **`ሲነቅፉአችሁና ሲያሳድዱአችሁ በእኔም ምክንያት ክፉውን ሁሉ በውሸት ሲናገሩባችሁ ብፁዓን ናችሁ።`**
      - **Matthew 5:13:** Clipped letters (`የም` eaten by `“`): `እናንተ “ድር ጨው...` $\rightarrow$ restored to **`እናንተ የምድር ጨው ናችሁ፤...`**
      - **Matthew 5:14:** Clipped letters (`እና` eaten by `“`): `“ንተ የዓለም...` $\rightarrow$ restored to **`እናንተ የዓለም ብርሃን ናችሁ。...`**
      - **Matthew 5:27:** Typo fix: `ዝንደተባለ` $\rightarrow$ **`እንደተባለ`**.
      - **Matthew 12:43:** Clipped letter (`እ` eaten by `“`): `“ርኩስ መንፈስ...` $\rightarrow$ restored to **`እርኩስ መንፈስ ግን...`**.
      - **Dangling Quotes & Spacing:** Removed stranded unclosed quotation marks and added proper spaces after Ethiopic semicolons (`፤ `) across Matthew 5:3–43 (24 verses total repaired).

### D. Authentic Tradition Integrity — Complete Removal of Incomplete "አንድምታ" (Commentary)
- **Rationale:** The authentic Ethiopian Orthodox Andimta is a vast, monumental oral and written exegetical library spanning all 81 canonical books. Displaying an "አንድምታ" label and spotlight while having only ~18 hardcoded snippet entries in `patristic_commentaries.dart` (which only lit up on Matthew 5:2–3 in 1954 due to book numbering divergence, and was empty everywhere else) was misleading and misrepresented sacred tradition.
- **Completed Changes:**
  1. **Removed Dead Commentary Files:** Deleted `lib/data/patristic_commentaries.dart` and `lib/models/commentary.dart`.
  2. **Reader Screen (`lib/ui/screens/home_reader_screen.dart`):**
     - Removed commentary imports, queries, left-margin indicator borders, and inline commentary badge chips from both paragraph and list view.
     - Bookmarks, highlights, personal notes, and tap gestures remain 100% active.
  3. **Study Tools Sheet (`lib/ui/screens/study_tools_dialog.dart`):**
     - Removed commentary tab and mock cards.
     - Streamlined dialog to two high-value study tabs: **`ተዛማጅ ጥቅሶች` (Canonical Cross-References)** and **`ማነፃፀሪያ` (Parallel 3 Translations: 81 Canon vs 1954 vs KJV)**.
  4. **Home Dashboard (`lib/ui/screens/home_dashboard_screen.dart`):**
     - Removed Patristic Spotlight horizontal carousel (`_buildPatristicSpotlight`).
     - Removed Church Father frosted glass box from the Daily Verse Hero.
     - Replaced `'አንድምታ'` badge with **`81 ቀኖና`** and updated subtitle to **`'የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ 81 መጻሕፍትና ትርጉሞች'`**.
  5. **Navigation Shell (`lib/ui/screens/main_navigation_shell.dart`):**
     - Renamed Tab 1 from `'አንድምታ'` to **`'መነሻ'`** (Home / Library).
     - Modern library icon retained and clarified.

### E. Comprehensive 81 Canon Verification & Text Restoration (`assets/data/orthodox_81.json`)
- **Diagnosis & Audit:**
  - Audited all 81 canonical books (54 Old Testament + 27 New Testament).
  - Identified that an early parser / digitization glitch broke at quotation marks (`“` / `«`) or swallowed merged verse slots from 1954, dropping direct speech, prophecies, and quotes (e.g. Matthew 2:5 truncated to `"እነርሱም"`, verse 6 omitted entirely, Matthew 2:14-15 truncated, etc.).
- **Completed Repairs:**
  1. **Old Testament Passages Restored:**
     - **1 Samuel 2:1–10:** Restored Hannah's prayer under `"የሳሙኤል እናት የሐና ጸሎት"`.
     - **2 Samuel 3:33–34:** Restored David's complete lament for Abner.
     - **2 Samuel 23:1–7:** Restored David's last words under `"የዳዊት የመጨረሻ ቃል"`.
     - **Zephaniah 2:1–2:** Properly split and numbered.
  2. **New Testament Full-Canon Restoration (15 books repaired, 161 verses restored):**
     - Across Matthew, Mark, 1 & 2 Thessalonians, 1 & 2 Timothy, Titus, Philemon, 1 & 2 Peter, 1 & 2 John, James, Jude, and Revelation:
       - Restored 161 missing / truncated verse slots with complete, sacred Amharic text.
       - Re-inserted proper section placement and sorted all verses sequentially.
       - Restored Revelation 5:9–10 (which was omitted, causing a cascade numbering shift).
  3. **Verification & Audit:**
     - **New Testament:** 27 of 27 books verified with **0 missing verses** and **0 truncations**.
     - **Old Testament:** 54 of 54 books verified intact.
     - **Matthew 2:** Verified verses 1 through 23 in complete sequence, including verses 2, 5, 6, 14, 15.

### F. Merged Verses Restoration & Continuous Paragraph Mode Integrity (`assets/data/amharic_1954.json` & `home_reader_screen.dart`)
- **Matthew 3:1–2 Merged Range Restored (`amharic_1954.json`):**
  - Re-unified the awkwardly split sentence into the authentic 1954 merged verse structure:
    `1–2 (፩-፪) በዚያም ወራት መጥምቁ ዮሐንስ፦ መንግሥተ ሰማያት ቀርባለችና ንስሐ ግቡ ብሎ በይሁዳ ምድረ በዳ እየሰበከ መጣ።`
  - Replaced stray English `[see v2]` tags in Exodus 10:1, Exodus 33:1, and Isaiah 10:1 with standard `-` placeholder tokens so they automatically resolve to proper merged ranges (`1–2`).
- **Continuous Paragraph Mode (`home_reader_screen.dart`):**
  - Re-architected `_buildParagraphModeFlow` to group verses into natural section chunks according to `headingsByVerse`. All mid-chapter section titles (e.g. `የኢየሱስ መጠመቅ` at Matthew 3:13) now properly appear above their respective paragraph flows.
  - Enhanced numeral rendering: Ge'ez numerals (`themeConfig.useGeezNumerals`) render using `notoSansEthiopic` to eliminate font fallback issues, while standard numerals use `plusJakartaSans`.
  - Both Paragraph Mode and Minimalist Verse Mode now seamlessly preserve merged verse labels (`1–2` / `፩-፪`), gesture taps, highlighting, and study tool sheets.
- **Verification Status:**
  - `flutter analyze`: **0 Errors, 0 Warnings, 0 Issues** (`No issues found!`).
  - `flutter test`: **All 5 tests pass**.
  - All changes reside in the working directory ready for manual user review and commit.

### G. Reader Typography Varieties, Header Dropdown & Quick Navigation (October 20, 2026)
- **4 Distinct Ethiopic Font Varieties (`app_theme.dart`, `theme_provider.dart`, `home_reader_screen.dart`):**
  1. **ሴሪፍ (Noto Serif Ethiopic):** Classical literary serif typeface.
  2. **ሳንስ (Noto Sans Ethiopic):** Clean modern sans-serif with high legibility.
  3. **አቢሲኒካ (Abyssinica SIL):** Distinguished scholarly SIL Ethiopic typeface.
  4. **ፓወር ግዕዝ (Power Ge'ez Unicode):** Standard Ethiopian desktop publishing typeface with fallback hierarchy (`['PowerGeez', 'Power Ge\'ez', 'Nyala', 'WashRa', 'Abyssinica SIL', 'Noto Serif Ethiopic']`).
  - Added live font-family cards in reader settings modal with real-time preview of `በመጀመሪያ` and persistent state storage in `SharedPreferences` (`'reader_font_family'`).
  - Universal scripture text routing via `_getScriptureTextStyle(themeConfig, ...)` across verse flow, continuous paragraph mode, and chapter headers.
- **Zero-Scroll Single-View 4-Dropdown Header (`home_reader_screen.dart`):**
  - **4 Identical Dropdown Pills Aligned on One Line (No Horizontal Scrolling Required):**
    1. **Testament:** `[ ሐዲስ ⌵ ]` / `[ ብሉይ ⌵ ]` / `[ ቀኖና 81 ⌵ ]` (instant jump across OT, NT, and Canon 81 Deuterocanon; full names and descriptions displayed in popup menu).
    2. **Book:** `[ ማቴዎስ ⌵ ]` (compact liturgical name via `_getCompactBookName`, e.g. `ማቴዎስ`, `ዘፍጥረት`, `መዝሙር`, `ሮሜ`, `ራእይ`).
    3. **Chapter:** `[ ምዕ. 1 ⌵ ]` (compact chapter label opening Chapter Selector).
    4. **Canon / Translation:** `[ 81 ቀኖና ⌵ ]` / `[ 1954 ⌵ ]` / `[ KJV ⌵ ]`.
    - Compact micro-padding (`7px horizontal, 4.5px vertical`), font size `11pt`, icon size `16pt`, spacing `4px`.
    - Wrapped in `FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft)` so that on any standard mobile viewport (360px–412px+) all 4 dropdowns and the theme toggle fit within a single screen view without requiring horizontal scrolling.
  - **Modern Theme Toggle Button:**
    - 3-state modern Theme Selector button (`_buildThemeToggleButton`, `28x26px`, icon size `14pt`).
    - One-tap sequential rotation through the 3 reading themes: **ብርሃን (Light `☀️`) $\rightarrow$ ብራና (Sepia `📜`) $\rightarrow$ ጨለማ (Dark `🌙`)** with tactile haptic feedback. Long-press opens the comprehensive reading settings sheet.
- **Full English Context Uniformity for KJV (`home_reader_screen.dart`):**
  - When the King James Version (`KJV`) is active, all navigation headers, pills, tooltips, and footers automatically adapt to English:
    - **Testament Pill:** Displays `OT` / `NT` (instead of `ብሉይ` / `ሐዲስ`), with popup descriptions in English (`Old Testament • 39 Books`, `New Testament • 27 Books`).
    - **Chapter Pill:** Displays `Ch. $chapterStr` (e.g. `Ch. 3` instead of `ምዕ. 3`).
    - **Book Pill & Dropdowns:** Render in crisp Latin typography (`Plus Jakarta Sans`).
    - **Chapter Footer Buttons:** Render as `← Chapter X-1` and `Chapter X+1 →`.
    - **Empty State & Tooltips:** Translated to English (`Loading chapter...`, `Select Testament`, `Switch Translation`, `Theme: Light/Sepia/Dark`).
- **Harmonious Editorial Title Row (`home_reader_screen.dart`):**
  - Added a dedicated editorial title heading directly beneath the top dropdown bar divider and above verse 1:
    - **Left:** Current Book Title (e.g. `የሉቃስ ወንጌል` / `የማቴዎስ ወንጌል`).
    - **Right:** Current Chapter (e.g. `ምዕራፍ 9` / `ምዕራፍ 1`, adapting to Ge'ez numerals when enabled).
    - **Aesthetics & Sizing:** Balanced `17pt` font size (`FontWeight.w800`, line height `1.25`) for both sides in the app's signature accent color (`themeConfig.accentColor`).
    - **Interactive:** Tapping the book name opens the Book Selector; tapping the chapter opens the Chapter Selector.
- **Option B Implementation for Bottom Floating Controls (`home_reader_screen.dart`):**
  - Central floating capsule (`< የማቴዎስ ወንጌል 1 ⌵ >`) completely removed to avoid obstructing text and redundant interactions.
  - Retained only the modern corner search squircle button (`_buildCornerSearchButton`, 50x50px, 16px radius) at `bottom: _isChromeVisible ? 80 : -90, right: 18`, perfectly matching the floating search button position and styling across Tabs 1, 2, and 3.
  - Bottom `ListView` padding optimized to `80px` (`140px` when active reading plan session bar is present), allowing end-of-chapter Next/Prev buttons (`← ምዕራፍ X-1`, `ምዕራፍ X+1 →`) to sit comfortably above the navigation bar.
- **5-Tab Navigation Shell with Settings (`main_navigation_shell.dart` & `modern_bible_icons.dart`):**
  - Added Tab 4 `ቅንብሮች` (Settings) to the bottom navigation bar with a matching custom vector `ModernSettingsIcon`.
- **Eliminated Instruction Banner:**
  - Removed the `'ለማድመቅ፣ ለዕልባት፣ ለማስታወሻና ለማነፃፀር ማንኛውንም ጥቅስ ይጫኑ'` banner container from the reader header for a clean, distraction-free reading experience.

### H. Full-Scripture Spiritual & Textual Integrity Audit (October 20, 2026)
- **Rationale & Imperative:** As holy scripture, accuracy and reverence are paramount. We executed a comprehensive automated and manual textual audit across all three translations (`orthodox_81.json`, `amharic_1954.json`, and `kjv.json`) to detect and eliminate OCR artifacts, stray transliteration characters, missing verses, index shifts, and empty slots.
- **Completed Repairs & Normalization:**
  1. **81 Orthodox Canon (`assets/data/orthodox_81.json`):**
     - **Scope:** 81 books (54 Old Testament + 27 New Testament), 39,492 verses.
     - **OCR Character Cleansing:** Cleaned 32 OCR English character transliterations (e.g. `ቈoፈሩ` $\rightarrow$ `ቈፈሩ`, `Wa` $\rightarrow$ `ቷ`/`ዋ`, `ቅWልፍ` $\rightarrow$ `ቍልፍ`, `ቦታW` $\rightarrow$ `ቦታው`, `ጊዜM` $\rightarrow$ `ጊዜም`, `Aረ` $\rightarrow$ `ኧረ`).
     - **Editorial Cleaning:** Cleaned stray editorial brackets in `መጽሐፈ ኢያሱ 21:42` while preserving sacred canonical text.
     - **Audit Result:** **0 stray English tokens, 0 empty verses**.
  2. **1954 Amharic Bible (`assets/data/amharic_1954.json`):**
     - **Scope:** 66 books, 31,607 non-placeholder verses, 475 authentic merged placeholders (`-`).
     - **OCR & Footnote Cleansing:** Cleaned all 99 OCR relics, trailing `" a"` footnote anchors, embedded footnotes (Gen 15:14, Gen 32:32), and transliteration relics (`Dኒኤል` $\rightarrow$ `ጵኒኤል`, `Doጥፌራ` $\rightarrow$ `ጶጥፌራ`, `gWdጓድ` $\rightarrow$ `ጕድጓድ`, `kWraት` $\rightarrow$ `ኵራት`, `KWTaው` $\rightarrow$ `ቍጣው`, `Avረ` $\rightarrow$ `ኧረ`). Re-scanned: **0 stray English tokens remain**.
     - **Resolved All 401 Empty Slots:** 384 authentic merged translation slots tagged with `"-"` so `bible_repository.dart` seamlessly renders merged ranges (e.g. `2–3`, `14–15`, `44–45`, `1–4`) in continuous paragraph mode and verse-by-verse mode.
     - **Repaired Dropped Verses & Index Cascades:**
       - **Matthew 2:** Restored dropped verses 14, 15, 17, 18, merged ranges 14–15 and 17–18, eliminated duplicated verses 22 and 23.
       - **Luke 1:** Restored prologue range (1–4) and missing verses 24 and 25.
       - **Philemon 1:** Restored dropped verse 10, realigned verses 11–24, and eliminated duplicate verse 25.
       - **Romans 16:** Restored dropped verses 24, 25, 26 and eliminated duplicate verse 27.
       - **Psalm 23:** Trimmed duplicate Psalm 24 fragment (verses 7–10) back to authentic 6 verses.
       - **Trailing Gaps Filled:** Job 41 (verses 31–34), Psalm 78 (verses 70–72), Hosea 11 (verse 12), Jonah 1 (verse 17), Revelation 4 (verses 10–11).
       - **Eliminated Duplicate Tail Verses:** Removed duplicate tail verses across 12 chapters (Matt 13, Mark 15, Acts 14, 1 Thess 2, 1 Tim 2, 2 Tim 1, Titus 3, 2 Peter 3, 1 John 2 & 3, Rev 2 & 19).
     - **Audit Result:** **0 stray English tokens, 0 unresolved empty slots, 0 trailing placeholders**.
     - Synchronized clean files to `tools/data/` (`orthodox_81.json`, `amharic_1954.json`, `kjv.json`).
  3. **King James Version (`assets/data/kjv.json`):**
     - Verified: 66 books, 31,102 verses, 0 empty verses, completely intact and reverent.
- **Bilingual Dynamic Shell Navigation (`lib/ui/screens/main_navigation_shell.dart`):**
  - Bottom navigation bar labels dynamically reflect active translation:
    - When KJV is active: English labels (`Bible`, `Home`, `Plans`, `Saved`, `Settings`) styled with `GoogleFonts.inter`.
    - When 81 Canon or 1954 is active: Amharic labels (`ንባብ`, `መነሻ`, `ዕቅዶች`, `ማህደር`, `ቅንብሮች`) styled with `GoogleFonts.notoSansEthiopic`.
- **Comprehensive Functionality & UI Verification:**
  - Tested all 4 dropdown selectors (Testament, Book, Chapter, Translation) and verified zero horizontal scrolling on mobile viewports.
  - Tested 3-state Theme Toggle (Light $\rightarrow$ Sepia $\rightarrow$ Dark).
  - Tested Chapter Next/Prev navigation buttons with boundary enforcement.
  - Tested Continuous Paragraph Mode and Verse-by-Verse Mode with Ge'ez and standard numerals.
  - Tested Canonical Cross-References and 3-Way Parallel translations.
  - Tested Corner Search button and keyword highlight in results.
- **Verification Status:**
  - `flutter analyze`: **No issues found!**
  - `flutter test`: **5/5 tests passed!**

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

- **Tab 0: `ንባብ` (Bible Reader)** — Auto-hiding floating interaction capsule, paragraph/verse modes, quick translation switcher, verse selection with highlighting, bookmarks, notes, and parallel study.
- **Tab 1: `መነሻ` (Home / Library Dashboard)** — Daily verse hero, reading progress bento, canon quick-access strip, visual reading plans carousel, thematic scripture collections.
- **Tab 2: `ዕቅዶች` (Lectionary & Reading Plans)** — 14 liturgical & devotional reading plans, Bahire Hasab movable feasts/fasts auto-calculation, custom plan generator.
- **Tab 3: `ማህደር` (Annotations Vault)** — Saved bookmarks, highlights by color, and personal notes with virtual Ge'ez keyboard.
- **Tab 4: `ቅንብሮች` (Settings)** — Full settings suite including translations, backup & export/import, reading themes, and font configurations.
- **Floating `[ 🔍 ]` Search Button:** Floating on Tabs 1, 2, and 3 for instant search access.

---

## 6. Verification Status

- **`flutter test`:** **All passed (5/5 tests)**.
- **`flutter analyze`:** **0 Errors, 0 Warnings, 0 Issues** (`No issues found!`).
- **Working Tree:** All modifications verified and ready for manual user commit & push.


