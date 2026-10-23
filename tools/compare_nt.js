const fs = require('fs');

const o81 = JSON.parse(fs.readFileSync('C:/Users/Administrator/holy_bible_amharic/assets/data/orthodox_81.json', 'utf8'));
const a54 = JSON.parse(fs.readFileSync('C:/Users/Administrator/holy_bible_amharic/assets/data/amharic_1954.json', 'utf8'));

let severeDiscrepancies = [];

for (let i = 0; i < 27; i++) {
  const oBook = o81[54 + i];
  const aBook = a54.books[39 + i];
  
  for (let cIdx = 0; cIdx < oBook.chapters.length; cIdx++) {
    const oCh = oBook.chapters[cIdx];
    const aCh = aBook.chapters[cIdx];
    if (!aCh) continue;
    
    let oVerses = [];
    if (oCh.verses) oVerses = oCh.verses;
    else if (oCh.sections) {
      for (const s of oCh.sections) if (s.verses) oVerses.push(...s.verses);
    }
    
    const aVerses = aCh.verses || [];
    
    for (const ov of oVerses) {
      const vNum = ov.verse;
      const oText = (ov.text || '').trim();
      const aText = (aVerses[vNum - 1] || '').trim();
      
      // If oText is significantly shorter than aText (e.g. oText has less than 45% length of aText)
      if (aText && aText !== '-' && oText.length > 0 && oText.length < aText.length * 0.45 && aText.length > 30) {
        severeDiscrepancies.push({
          book: oBook.book_name_am,
          ch: oCh.chapter,
          v: vNum,
          oLen: oText.length,
          aLen: aText.length,
          oText,
          aText
        });
      }
    }
  }
}

console.log('Total severe truncations in O81 New Testament:', severeDiscrepancies.length);
fs.writeFileSync('C:/Users/Administrator/holy_bible_amharic/tools/nt_discrepancies.json', JSON.stringify(severeDiscrepancies, null, 2), 'utf8');

console.log('Top 10 truncations:');
console.log(JSON.stringify(severeDiscrepancies.slice(0, 10), null, 2));
