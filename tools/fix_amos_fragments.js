const fs = require('fs');
const geez = JSON.parse(fs.readFileSync('assets/data/geez_81.json', 'utf8'));
const amos = geez.find(b => b.book_number === 44);

// Amos 6: verses 8, 9, 10
const ch6 = amos.chapters[5];
const mergedV9 = (ch6.verses[8] + ' ' + ch6.verses[9] + ' ' + ch6.verses[10]).replace(/\s+/g, ' ').trim();
const newCh6Verses = [
  ...ch6.verses.slice(0, 8),
  mergedV9,
  ...ch6.verses.slice(11)
];
ch6.verses = newCh6Verses;

// Amos 7: verse 0
const ch7 = amos.chapters[6];
ch7.verses[0] = ch7.verses[0].replace(/፡ ወ$/, '።');

fs.writeFileSync('assets/data/geez_81.json', JSON.stringify(geez, null, 2), 'utf8');
console.log('Fixed Amos 6 and 7 successfully!');
