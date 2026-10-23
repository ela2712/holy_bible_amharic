const fs = require('fs');

const o81 = JSON.parse(fs.readFileSync('C:/Users/Administrator/holy_bible_amharic/assets/data/orthodox_81.json', 'utf8'));

const deuteroBookNums = [15, 16, 19, 20, 21, 22, 24, 25, 26, 30, 31, 34, 37, 39, 40];

console.log('=== AUDITING 15 DEUTEROCANONICAL BOOKS IN O81 ===');

let totalDeuteroVerses = 0;
let shortVerses = [];
let punctuationIssues = [];

for (const bNum of deuteroBookNums) {
  const b = o81[bNum - 1];
  let bookVerses = 0;
  for (const c of b.chapters) {
    let verses = [];
    if (c.verses) verses = c.verses;
    else if (c.sections) {
      for (const s of c.sections) if (s.verses) verses.push(...s.verses);
    }
    for (const v of verses) {
      bookVerses++;
      totalDeuteroVerses++;
      const text = (v.text || '').trim();
      if (!text || text === '-' || text.length < 20) {
        shortVerses.push({ book: b.book_name_am, ch: c.chapter, v: v.verse, text });
      } else if (text.endsWith('፤') || text.endsWith('፥')) {
        punctuationIssues.push({ book: b.book_name_am, ch: c.chapter, v: v.verse, text });
      }
    }
  }
  console.log(`Book ${bNum}: ${b.book_name_am} (${b.book_name_en}) -> ${b.chapters.length} chapters, ${bookVerses} verses.`);
}

console.log(`Total Deuterocanonical verses: ${totalDeuteroVerses}`);
console.log(`Short verses (<20 chars): ${shortVerses.length}`);
console.log(`Ending with mid-sentence punctuation: ${punctuationIssues.length}`);

console.log('\nSample short verses:');
console.log(JSON.stringify(shortVerses.slice(0, 15), null, 2));
