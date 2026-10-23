const fs = require('fs');

const kjv = JSON.parse(fs.readFileSync('C:/Users/Administrator/holy_bible_amharic/assets/data/kjv.json', 'utf8'));

let kjvIssues = [];
let totalVerses = 0;

for (const b of kjv) {
  for (let cIdx = 0; cIdx < b.chapters.length; cIdx++) {
    const ch = b.chapters[cIdx];
    for (let vIdx = 0; vIdx < ch.length; vIdx++) {
      totalVerses++;
      const text = (ch[vIdx] || '').trim();
      const vNum = vIdx + 1;
      if (!text || text === '-') {
        kjvIssues.push({ book: b.name, ch: cIdx + 1, v: vNum, issue: 'EMPTY', text });
      } else if (text.length < 8) {
        kjvIssues.push({ book: b.name, ch: cIdx + 1, v: vNum, issue: 'VERY_SHORT', text });
      }
    }
  }
}

console.log(`KJV total verses: ${totalVerses}`);
console.log(`KJV total issues: ${kjvIssues.length}`);
if (kjvIssues.length > 0) {
  console.log('Sample KJV issues:', JSON.stringify(kjvIssues.slice(0, 10), null, 2));
}

// Check Matt 4:6 in KJV
console.log('KJV Matt 4:6:', kjv.find(b => b.name === 'Matthew').chapters[3][5]);
