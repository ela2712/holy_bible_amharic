const fs = require('fs');

const geez = JSON.parse(fs.readFileSync('assets/data/geez_81.json', 'utf8'));

let healedCount = 0;

[24, 25, 26].forEach(bn => {
  const b = geez.find(x => x.book_number === bn);
  b.chapters.forEach(c => {
    const newVerses = [];
    for (let i = 0; i < c.verses.length; i++) {
      const v = c.verses[i];
      const trimmed = v.trim();
      
      // If broken fragment (< 25 chars and not ending with '።')
      if (trimmed.length < 25 && !trimmed.endsWith('።') && i + 1 < c.verses.length) {
        const nextV = c.verses[i + 1];
        c.verses[i + 1] = trimmed + ' ' + nextV;
        healedCount++;
        console.log(`[Book ${bn} Ch ${c.chapter} V ${i + 1}] Merged fragment: "${trimmed}"`);
        continue;
      }
      newVerses.push(trimmed);
    }
    c.verses = newVerses;
  });
});

console.log(`Total fragments merged in Meqabyan: ${healedCount}`);
