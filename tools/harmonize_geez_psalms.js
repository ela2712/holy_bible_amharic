const fs = require('fs');
const path = require('path');

const geezPath = path.join(__dirname, '../assets/data/geez_81.json');
const geez = JSON.parse(fs.readFileSync(geezPath, 'utf8'));

const ps = geez.find(b => b.book_number === 28);
console.log('Harmonizing Ge\'ez Psalms in geez_81.json...');

const oldCh = {};
ps.chapters.forEach(c => {
  oldCh[c.chapter] = c.verses;
});

const newChapters = [];

// Ch 1 to 8: identical
for (let i = 1; i <= 8; i++) {
  newChapters.push({ chapter: i, verses: oldCh[i] });
}

// Ch 9 & 10: split old Ch 9 (42 verses)
// v1-21 = Psalm 9 (21 verses), v22-42 = Psalm 10 (21 verses)
const old9 = oldCh[9];
newChapters.push({ chapter: 9, verses: old9.slice(0, 21) });
newChapters.push({ chapter: 10, verses: old9.slice(21) });

// Ch 11 to 113: map to old Ch 10 to 112 (offset -1)
for (let c = 11; c <= 113; c++) {
  newChapters.push({ chapter: c, verses: oldCh[c - 1] });
}

// Ch 114 & 115: split old Ch 113 (27 verses)
// Old Ch 113: v1-9 is Psalm 114, v10-27 is Psalm 115
const old113 = oldCh[113];
newChapters.push({ chapter: 114, verses: old113.slice(0, 9) });
newChapters.push({ chapter: 115, verses: old113.slice(9) });

// Ch 116: combine old Ch 114 (9 verses) and Ch 115 (8 verses) = 17 verses
newChapters.push({ chapter: 116, verses: [...oldCh[114], ...oldCh[115]] });

// Ch 117: old Ch 116 (2 verses)
newChapters.push({ chapter: 117, verses: oldCh[116] });

// Ch 118: old Ch 117 (29 verses)
newChapters.push({ chapter: 118, verses: oldCh[117] });

// Ch 119: old Ch 118 (176 verses)
newChapters.push({ chapter: 119, verses: oldCh[118] });

// Ch 120 to 146: map to old Ch 119 to 145 (offset -1)
// Note: Ch 132 gets old Ch 131 ("ተዘከሮ እግዚኦ ለዳዊት", 19 verses)!
// Ch 133 gets old Ch 132 ("ናሁ ሠናይ", 4 verses)!
// Ch 134 gets old Ch 133 ("ናሁ ይባርክዎ", 4 verses)!
for (let c = 120; c <= 146; c++) {
  newChapters.push({ chapter: c, verses: oldCh[c - 1] });
}

// Ch 147: combine old Ch 146 (12 verses) and Ch 147 (9 verses) = 21 verses
newChapters.push({ chapter: 147, verses: [...oldCh[146], ...oldCh[147]] });

// Ch 148 to 151: old Ch 148 to 151
for (let c = 148; c <= 151; c++) {
  newChapters.push({ chapter: c, verses: oldCh[c] });
}

// Replace chapters
ps.chapters = newChapters;

// Save updated geez_81.json
fs.writeFileSync(geezPath, JSON.stringify(geez), 'utf8');
console.log('Successfully saved harmonized geez_81.json! Verified Ch 132 has ' + ps.chapters[131].verses.length + ' verses.');
