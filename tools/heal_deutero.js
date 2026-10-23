const fs = require('fs');

const o81Path = 'C:/Users/Administrator/holy_bible_amharic/assets/data/orthodox_81.json';
const o81 = JSON.parse(fs.readFileSync(o81Path, 'utf8'));

const deuteroBookNums = [15, 16, 19, 20, 21, 22, 24, 25, 26, 30, 31, 34, 37, 39, 40];

let healedCount = 0;

for (const bNum of deuteroBookNums) {
  const b = o81[bNum - 1];
  for (const c of b.chapters) {
    const sections = c.sections || [];
    for (const sec of sections) {
      if (!sec.verses || sec.verses.length === 0) continue;
      
      const newVerses = [];
      for (let i = 0; i < sec.verses.length; i++) {
        const v = sec.verses[i];
        const text = (v.text || '').trim();
        
        // If this verse is an incomplete fragment (< 20 chars, doesn't end with sentence terminator '።' or '?')
        // and there is a next verse in the section
        if (text.length < 20 && !text.endsWith('።') && !text.endsWith('?') && i + 1 < sec.verses.length) {
          const nextV = sec.verses[i + 1];
          // Merge text forward or backward
          nextV.text = `${text} ${nextV.text}`.trim();
          healedCount++;
          // Skip adding this broken fragment as separate verse
          continue;
        }
        
        newVerses.push(v);
      }
      
      // Re-number verses in section sequentially
      for (let j = 0; j < newVerses.length; j++) {
        newVerses[j].verse = j + 1;
      }
      sec.verses = newVerses;
    }
  }
}

console.log(`Healed ${healedCount} broken line fragments in Deuterocanonical books!`);

fs.writeFileSync(o81Path, JSON.stringify(o81, null, 2), 'utf8');
fs.writeFileSync('C:/Users/Administrator/holy_bible_amharic/tools/data/orthodox_81.json', JSON.stringify(o81, null, 2), 'utf8');
console.log('Saved healed orthodox_81.json!');
