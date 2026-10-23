const fs = require('fs');

const o81 = JSON.parse(fs.readFileSync('C:/Users/Administrator/holy_bible_amharic/assets/data/orthodox_81.json', 'utf8'));
const a54 = JSON.parse(fs.readFileSync('C:/Users/Administrator/holy_bible_amharic/assets/data/amharic_1954.json', 'utf8'));

// Canonical codes
const eotc81ToCanonical = {
  1: 'GEN', 2: 'EXO', 3: 'LEV', 4: 'NUM', 5: 'DEU', 6: 'JOS', 7: 'JDG', 8: 'RUT',
  9: '1SA', 10: '2SA', 11: '1KI', 12: '2KI', 13: '1CH', 14: '2CH', 15: 'JUB',
  16: 'ENO', 17: 'EZR', 18: 'NEH', 19: 'EZ3', 20: 'EZ4', 21: 'TOB', 22: 'JDT',
  23: 'EST', 24: 'MQ1', 25: 'MQ2', 26: 'MQ3', 27: 'JOB', 28: 'PSA', 29: 'PRO',
  30: 'TEG', 31: 'WIS', 32: 'ECC', 33: 'SNG', 34: 'SIR', 35: 'ISA', 36: 'JER',
  37: 'BAR', 38: 'LAM', 39: 'TER', 40: 'TBR', 41: 'EZK', 42: 'DAN', 43: 'HOS',
  44: 'AMO', 45: 'MIC', 46: 'JOL', 47: 'OBA', 48: 'JON', 49: 'NAH', 50: 'HAB',
  51: 'ZEP', 52: 'HAG', 53: 'ZEC', 54: 'MAL',
  55: 'MAT', 56: 'MRK', 57: 'LUK', 58: 'JHN', 59: 'ACT', 60: 'ROM', 61: '1CO',
  62: '2CO', 63: 'GAL', 64: 'EPH', 65: 'PHP', 66: 'COL', 67: '1TH', 68: '2TH',
  69: '1TI', 70: '2TI', 71: 'TIT', 72: 'PHM', 73: 'HEB', 74: '1PE', 75: '2PE',
  76: '1JN', 77: '2JN', 78: '3JN', 79: 'JAS', 80: 'JUD', 81: 'REV'
};

const canonicalToA54BookIdx = {
  'GEN': 0, 'EXO': 1, 'LEV': 2, 'NUM': 3, 'DEU': 4, 'JOS': 5, 'JDG': 6, 'RUT': 7,
  '1SA': 8, '2SA': 9, '1KI': 10, '2KI': 11, '1CH': 12, '2CH': 13, 'EZR': 14,
  'NEH': 15, 'EST': 16, 'JOB': 17, 'PSA': 18, 'PRO': 19, 'ECC': 20, 'SNG': 21,
  'ISA': 22, 'JER': 23, 'LAM': 24, 'EZK': 25, 'DAN': 26, 'HOS': 27, 'JOL': 28,
  'AMO': 29, 'OBA': 30, 'JON': 31, 'MIC': 32, 'NAH': 33, 'HAB': 34, 'ZEP': 35,
  'HAG': 36, 'ZEC': 37, 'MAL': 38,
  'MAT': 39, 'MRK': 40, 'LUK': 41, 'JHN': 42, 'ACT': 43, 'ROM': 44, '1CO': 45,
  '2CO': 46, 'GAL': 47, 'EPH': 48, 'PHP': 49, 'COL': 50, '1TH': 51, '2TH': 52,
  '1TI': 53, '2TI': 54, 'TIT': 55, 'PHM': 56, 'HEB': 57, 'JAS': 58, '1PE': 59,
  '2PE': 60, '1JN': 61, '2JN': 62, '3JN': 63, 'JUD': 64, 'REV': 65
};

console.log('--- Deep Audit of All 81 Books ---');

let sharedBookDiscrepancies = [];
let deuteroIssues = [];

for (let bNum = 1; bNum <= 81; bNum++) {
  const oBook = o81[bNum - 1];
  const canonId = eotc81ToCanonical[bNum];
  const a54Idx = canonicalToA54BookIdx[canonId];
  
  if (a54Idx !== undefined) {
    // Shared book! Compare verse by verse
    const aBook = a54.books[a54Idx];
    
    for (let cIdx = 0; cIdx < oBook.chapters.length; cIdx++) {
      const oCh = oBook.chapters[cIdx];
      const aCh = (aBook && aBook.chapters) ? aBook.chapters[cIdx] : null;
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
        
        // Check for severe truncation
        if (aText && aText !== '-' && aText.length > 25) {
          // If oText is less than 50% of aText or missing critical parts
          if (oText.length < aText.length * 0.50) {
            sharedBookDiscrepancies.push({
              canonId,
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
  } else {
    // Deuterocanonical book (81 Only)
    for (let cIdx = 0; cIdx < oBook.chapters.length; cIdx++) {
      const oCh = oBook.chapters[cIdx];
      let oVerses = [];
      if (oCh.verses) oVerses = oCh.verses;
      else if (oCh.sections) {
        for (const s of oCh.sections) if (s.verses) oVerses.push(...s.verses);
      }
      for (const ov of oVerses) {
        const text = (ov.text || '').trim();
        if (!text || text === '-' || text.length < 15) {
          deuteroIssues.push({
            canonId,
            book: oBook.book_name_am,
            ch: oCh.chapter,
            v: ov.verse,
            text
          });
        }
      }
    }
  }
}

console.log(`Shared books severe truncations: ${sharedBookDiscrepancies.length}`);
console.log(`Deuterocanonical books issues: ${deuteroIssues.length}`);

fs.writeFileSync('C:/Users/Administrator/holy_bible_amharic/tools/shared_discrepancies.json', JSON.stringify(sharedBookDiscrepancies, null, 2), 'utf8');
fs.writeFileSync('C:/Users/Administrator/holy_bible_amharic/tools/deutero_issues.json', JSON.stringify(deuteroIssues, null, 2), 'utf8');
