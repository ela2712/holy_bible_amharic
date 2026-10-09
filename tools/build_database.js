const fs = require('fs');
const path = require('path');
const initSqlJs = require('sql.js');

function normalizeEthiopic(text) {
  if (!text) return '';
  return text
    .replace(/[ሐኀ]/g, 'ሀ')
    .replace(/[ሑኁ]/g, 'ሁ')
    .replace(/[ሒኂ]/g, 'ሂ')
    .replace(/[ሓኃ]/g, 'ሃ')
    .replace(/[ሔኄ]/g, 'ሄ')
    .replace(/[ሕኅ]/g, 'ህ')
    .replace(/[ሖኆ]/g, 'ሆ')
    .replace(/ሠ/g, 'ሰ')
    .replace(/ሡ/g, 'ሱ')
    .replace(/ሢ/g, 'ሲ')
    .replace(/ሣ/g, 'ሳ')
    .replace(/ሤ/g, 'ሴ')
    .replace(/ሥ/g, 'ስ')
    .replace(/ሦ/g, 'ሶ')
    .replace(/ዐ/g, 'አ')
    .replace(/ዑ/g, 'ኡ')
    .replace(/ዒ/g, 'ኢ')
    .replace(/ዓ/g, 'ኣ')
    .replace(/ዔ/g, 'ኤ')
    .replace(/ዕ/g, 'እ')
    .replace(/ዖ/g, 'ኦ')
    .replace(/ፀ/g, 'ጸ')
    .replace(/ፁ/g, 'ጹ')
    .replace(/ፂ/g, 'ጺ')
    .replace(/ፃ/g, 'ጻ')
    .replace(/ፄ/g, 'ጼ')
    .replace(/ፅ/g, 'ጽ')
    .replace(/ፆ/g, 'ጾ')
    .replace(/[፡።፣፤፥፦\.,;:!?]/g, ' ')
    .toLowerCase()
    .trim();
}

async function build() {
  console.log('--- Initializing SQLite WebAssembly Engine ---');
  const SQL = await initSqlJs();
  const db = new SQL.Database();

  console.log('--- Creating Unified Bible Schema ---');
  db.run(`
    CREATE TABLE translations (
      id INTEGER PRIMARY KEY,
      code TEXT UNIQUE,
      name TEXT,
      short_name TEXT,
      language TEXT,
      canon TEXT,
      is_default INTEGER DEFAULT 0
    );

    CREATE TABLE books (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      translation_id INTEGER,
      book_number INTEGER,
      name TEXT,
      short_name TEXT,
      name_en TEXT,
      testament TEXT,
      order_index INTEGER,
      total_chapters INTEGER,
      FOREIGN KEY (translation_id) REFERENCES translations(id)
    );

    CREATE TABLE sections (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id INTEGER,
      chapter INTEGER,
      verse INTEGER,
      title TEXT,
      FOREIGN KEY (book_id) REFERENCES books(id)
    );

    CREATE TABLE verses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id INTEGER,
      chapter INTEGER,
      verse INTEGER,
      text TEXT,
      text_normalized TEXT,
      FOREIGN KEY (book_id) REFERENCES books(id)
    );

    CREATE TABLE bookmarks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id INTEGER,
      chapter INTEGER,
      verse INTEGER,
      translation_code TEXT,
      created_at TEXT
    );

    CREATE TABLE highlights (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id INTEGER,
      chapter INTEGER,
      verse INTEGER,
      color_hex TEXT,
      created_at TEXT
    );

    CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id INTEGER,
      chapter INTEGER,
      verse INTEGER,
      note_text TEXT,
      updated_at TEXT
    );

    CREATE TABLE reading_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id INTEGER,
      chapter INTEGER,
      verse INTEGER,
      read_at TEXT
    );

    CREATE TABLE reading_plans (
      id TEXT PRIMARY KEY,
      plan_name TEXT,
      day INTEGER,
      completed INTEGER DEFAULT 0,
      completed_at TEXT
    );
  `);

  console.log('--- Seeding Translations ---');
  const insertTrans = db.prepare(`INSERT INTO translations VALUES (?, ?, ?, ?, ?, ?, ?)`);
  insertTrans.run([1, 'amh_1954', 'የቀዳማዊ ኃይለ ሥላሴ 1954/1962 ትርጉም', '1954', 'am', 'traditional_66', 1]);
  insertTrans.run([2, 'eotc_81', 'ሰማንያ ወአሐዱ (81 Books Orthodox Canon)', '81', 'am', 'orthodox_81', 0]);
  insertTrans.run([3, 'en_kjv', 'King James Version', 'KJV', 'en', 'protestant_66', 0]);
  insertTrans.free();

  const dataDir = path.join(__dirname, 'data');
  const insertBook = db.prepare(`
    INSERT INTO books (translation_id, book_number, name, short_name, name_en, testament, order_index, total_chapters)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `);
  const insertVerse = db.prepare(`
    INSERT INTO verses (book_id, chapter, verse, text, text_normalized)
    VALUES (?, ?, ?, ?, ?)
  `);
  const insertSection = db.prepare(`
    INSERT INTO sections (book_id, chapter, verse, title)
    VALUES (?, ?, ?, ?)
  `);

  // 1. Process amharic_1954.json
  console.log('--- Processing Haile Selassie 1954/1962 Amharic Bible ---');
  const amh1954Path = path.join(dataDir, 'amharic_1954.json');
  if (fs.existsSync(amh1954Path)) {
    const raw = fs.readFileSync(amh1954Path, 'utf8');
    const data = JSON.parse(raw);
    const books = data.books || [];
    let bookIdCounter = 1;

    for (let i = 0; i < books.length; i++) {
      const b = books[i];
      const bookNum = i + 1;
      const testament = bookNum <= 39 ? 'OT' : 'NT';
      const totalCh = b.chapters ? b.chapters.length : 0;

      insertBook.run([1, bookNum, b.title || '', b.abbv || '', '', testament, bookNum, totalCh]);
      const currentBookId = bookIdCounter++;

      if (b.chapters) {
        for (let cIdx = 0; cIdx < b.chapters.length; cIdx++) {
          const chObj = b.chapters[cIdx];
          const chNum = parseInt(chObj.chapter, 10) || (cIdx + 1);
          const verses = chObj.verses || [];
          for (let vIdx = 0; vIdx < verses.length; vIdx++) {
            const vText = verses[vIdx];
            if (vText && vText.trim().length > 0) {
              const vNum = vIdx + 1;
              insertVerse.run([currentBookId, chNum, vNum, vText.trim(), normalizeEthiopic(vText)]);
            }
          }
        }
      }
    }
    console.log(`Loaded ${books.length} books for 1954 Haile Selassie Bible.`);
  }

  // 2. Process orthodox_81.json
  console.log('--- Processing Ethiopian Orthodox 81-Book Canon ---');
  const eotcPath = path.join(dataDir, 'orthodox_81.json');
  if (fs.existsSync(eotcPath)) {
    const raw = fs.readFileSync(eotcPath, 'utf8');
    const books = JSON.parse(raw);
    const startBookId = 100; // Offset for translation 2 books
    let bId = startBookId;

    for (let i = 0; i < books.length; i++) {
      const b = books[i];
      const bookNum = b.book_number || (i + 1);
      const testament = (b.testament && b.testament.toLowerCase() === 'new') ? 'NT' : 'OT';
      const totalCh = b.chapters ? b.chapters.length : 0;

      insertBook.run([
        2,
        bookNum,
        b.book_name_am || '',
        b.book_short_name_am || '',
        b.book_name_en || '',
        testament,
        bookNum,
        totalCh
      ]);
      const currentBookId = bId++;

      if (b.chapters) {
        for (const chObj of b.chapters) {
          const chNum = chObj.chapter;
          if (chObj.sections) {
            for (const sec of chObj.sections) {
              if (sec.title && sec.verses && sec.verses.length > 0) {
                insertSection.run([currentBookId, chNum, sec.verses[0].verse, sec.title]);
              }
              if (sec.verses) {
                for (const vObj of sec.verses) {
                  const vNum = vObj.verse;
                  const vText = vObj.text || '';
                  if (vText.trim().length > 0) {
                    insertVerse.run([currentBookId, chNum, vNum, vText.trim(), normalizeEthiopic(vText)]);
                  }
                }
              }
            }
          }
        }
      }
    }
    console.log(`Loaded ${books.length} books for Ethiopian Orthodox 81 Canon.`);
  }

  // 3. Process kjv.json
  console.log('--- Processing King James Version (KJV) ---');
  const kjvPath = path.join(dataDir, 'kjv.json');
  if (fs.existsSync(kjvPath)) {
    const raw = fs.readFileSync(kjvPath, 'utf8');
    const books = JSON.parse(raw);
    const startBookId = 300;
    let bId = startBookId;

    for (let i = 0; i < books.length; i++) {
      const b = books[i];
      const bookNum = i + 1;
      const testament = bookNum <= 39 ? 'OT' : 'NT';
      const totalCh = b.chapters ? b.chapters.length : 0;

      insertBook.run([
        3,
        bookNum,
        b.name || '',
        b.abbrev || '',
        b.name || '',
        testament,
        bookNum,
        totalCh
      ]);
      const currentBookId = bId++;

      if (b.chapters) {
        for (let cIdx = 0; cIdx < b.chapters.length; cIdx++) {
          const chNum = cIdx + 1;
          const verses = b.chapters[cIdx] || [];
          for (let vIdx = 0; vIdx < verses.length; vIdx++) {
            const vText = verses[vIdx] || '';
            if (vText.trim().length > 0) {
              const vNum = vIdx + 1;
              insertVerse.run([currentBookId, chNum, vNum, vText.trim(), vText.toLowerCase()]);
            }
          }
        }
      }
    }
    console.log(`Loaded ${books.length} books for King James Version.`);
  }

  insertBook.free();
  insertVerse.free();
  insertSection.free();

  console.log('--- Building Query & Search Indexes ---');
  db.run(`
    CREATE INDEX idx_verses_lookup ON verses(book_id, chapter, verse);
    CREATE INDEX idx_verses_norm ON verses(text_normalized);
    CREATE INDEX idx_books_trans ON books(translation_id, book_number);
    CREATE INDEX idx_sections ON sections(book_id, chapter, verse);
    CREATE INDEX idx_bookmarks ON bookmarks(book_id, chapter);
    CREATE INDEX idx_highlights ON highlights(book_id, chapter);
    CREATE INDEX idx_notes ON notes(book_id, chapter);
  `);

  console.log('--- Exporting Database File ---');
  const binaryArray = db.export();
  const buffer = Buffer.from(binaryArray);
  const outDir = path.join(__dirname, '..', 'assets', 'database');
  if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }
  const outPath = path.join(outDir, 'bible.db');
  fs.writeFileSync(outPath, buffer);

  console.log(`SUCCESS! SQLite database written to ${outPath}`);
  console.log(`Total database size: ${(buffer.length / 1024 / 1024).toFixed(2)} MB`);
}

build().catch(err => {
  console.error('Fatal error during build:', err);
  process.exit(1);
});
