# መጽሐፍ ቅዱስ - Holy Bible (Multiplatform Native)

A high-performance, modern native multiplatform Bible application built with Flutter, designed to deliver the ultimate reading and study experience for Ethiopian Christians and worldwide readers.

Built to replace and dramatically improve upon legacy Bible applications with zero crashes on modern operating systems, smooth 120Hz scrolling, dynamic typography, authentic traditional translations, and offline capability.

---

## 📖 Translations & Canons Included

1. **የቀዳማዊ ኃይለ ሥላሴ 1954/1962 ዓ.ም. ትርጉም (1954 Haile Selassie Version)**
   - The authentic, deeply revered 66-book traditional Amharic Bible translation.
2. **ሰማንያ ወአሐዱ (Ethiopian Orthodox 81-Book Canon)**
   - The complete 81-book canon of the Ethiopian Orthodox Tewahedo Church (including Enoch/ሄኖክ, Jubilees/ኩፋሌ, Meqabyan/መቃብያን, etc.) with traditional section headings (*የፍጥረት ታሪክ*, etc.).
3. **King James Version (KJV)**
   - Classical English companion for comparative study, Strong's concordance alignment, and cross-referencing.

---

## ✨ Features & Enhancements

* **Zero-Crash Modern Architecture:** Built on null-safe Flutter 3.47+, compatible with Android 15/16, iOS 18/19, macOS, Windows, Linux, and Web.
* **Flawless Typography & Zoom:** Dynamic type scaling with Noto Sans Ethiopic. Eliminates text-clipping bugs entirely at any font size (14sp to 34sp).
* **Smart Ge'ez Homophone Search:** Matches search queries regardless of spelling variations (`ሀ/ሐ/ኀ`, `ሰ/ሠ`, `አ/ዐ`, `ጸ/ፀ`).
* **Persistent Search Memory:** Search queries and results are never lost on exit; full text selection and copying supported.
* **Hybrid Ge'ez Typing:** Type using your phone's native keyboard (Gboard, SwiftKey, iOS Amharic) or toggle the optional built-in 7-order phonetic keyboard.
* **Three Dedicated Reading Themes:**
  * **ቀን (Day):** Crisp warm paper white with high contrast.
  * **ብራና (Sepia):** Warm parchment designed to reduce eye strain.
  * **ሌሊት (True Dark):** AMOLED true black for night reading with soft gold accents.
* **Parallel / Comparative Reader:** Side-by-side or stacked multi-translation reader to compare verses in real-time.
* **Audio Bible Streaming & Caching:** Listen to any chapter on demand with background playback and audio speed controls (0.75x to 1.5x).
* **Verse Card Maker:** Create shareable graphic cards and wallpapers with Ethiopian parchment and royal velvet gradients for WhatsApp, Telegram, and Instagram.
* **Annotations & Study Tools:** Highlight with 5 soft colors, save bookmarks, write private study notes, and copy/share with a single tap.
* **365-Day Reading Plans:** Track your progress through the Bible in one year.
* **Data Safety & Backup:** Offline-first SQLite database with one-tap JSON export/import for bookmarks, highlights, and notes.

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (installed at `C:\src\flutter\bin`)
* Git & Node.js

### Running the App
To launch the application on any connected device or desktop:

```bash
# Run on connected device or emulator
flutter run

# Run specifically on Windows Desktop
flutter run -d windows

# Run on Chrome/Web
flutter run -d chrome
```

### Rebuilding the SQLite Database
The unified SQLite database (`assets/database/bible.db`) is compiled directly from the raw datasets:

```bash
cd tools
node build_database.js
```

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── database/
│   │   └── database_helper.dart      # Multiplatform SQLite manager
│   ├── theme/
│   │   └── app_theme.dart            # Day, Sepia, and OLED Dark themes
│   └── utils/
│       ├── geez_normalizer.dart      # Ethiopic homophone phonetic search normalizer
│       └── geez_numbers.dart         # Arabic to Ge'ez numeral converter (፩, ፪, ፫...)
├── models/
│   ├── annotation.dart               # Bookmarks, Highlights, Notes
│   ├── book.dart                     # OT & NT book structure
│   ├── translation.dart              # Multi-canon definitions
│   └── verse.dart                    # Verse text and section headings
├── providers/
│   ├── bible_state.dart              # Active translation, book, and chapter
│   ├── search_provider.dart          # Search state & persistent history
│   └── theme_provider.dart           # Persistent typography & theme state
├── services/
│   ├── audio_player_service.dart     # Streaming and playback controller
│   └── bible_repository.dart         # Database queries & annotation persistence
└── ui/
    ├── screens/
    │   ├── home_reader_screen.dart   # Main Bible reader interface
    │   ├── book_selector_screen.dart # OT/NT book & chapter selector
    │   ├── search_screen.dart        # Search with history & copy
    │   ├── parallel_reader_screen.dart # Comparative translation reader
    │   ├── reading_plans_screen.dart # 365-day reading plan schedule
    │   ├── annotations_screen.dart   # My bookmarks, highlights, and notes
    │   ├── verse_card_maker_screen.dart # Graphic card generator
    │   ├── settings_screen.dart      # Settings & JSON backup export
    │   └── study_tools_dialog.dart   # Verse tap bottom sheet
    └── widgets/
        ├── audio_player_bar.dart     # Mini audio player bottom sheet
        └── built_in_geez_keyboard.dart # In-app 7-order phonetic Ge'ez keyboard
```
