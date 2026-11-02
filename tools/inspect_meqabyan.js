const fs = require('fs');
const geez = JSON.parse(fs.readFileSync('assets/data/geez_81.json', 'utf8'));

[24, 25, 26].forEach(bn => {
  const b = geez.find(x => x.book_number === bn);
  console.log('=== Book ' + bn + ' ' + b.name + ' ===');
  b.chapters.forEach(c => {
    c.verses.forEach((v, vIdx) => {
      const trimmed = v.trim();
      if (!trimmed.endsWith('።') && !trimmed.endsWith('፡') && !trimmed.endsWith('፤')) {
        console.log('Ch ' + c.chapter + ' V ' + (vIdx + 1) + ': ' + v);
      }
    });
  });
});
