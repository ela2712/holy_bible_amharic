const fs = require('fs');
const path = require('path');

const o81Path = 'C:/Users/Administrator/holy_bible_amharic/assets/data/orthodox_81.json';
const a54Path = 'C:/Users/Administrator/holy_bible_amharic/assets/data/amharic_1954.json';

const o81 = JSON.parse(fs.readFileSync(o81Path, 'utf8'));
const a54 = JSON.parse(fs.readFileSync(a54Path, 'utf8'));

// Canonical code mappings
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

console.log('=== RESTORING 81 CANON SACRED SCRIPTURES ===');

// Specifically curated fixes for known split / merged verses
const curatedSplitVerses = {
  'MAT_4_5': 'ከዚህ በኋላ ዲያብሎስ ወደ ቅድስት ከተማ ወሰደውና እርሱን በመቅደስ ጫፍ ላይ አቁሞ',
  'MAT_4_6': '“የእግዚአብሔር ልጅ ከሆንህ፥ ወደ ታች ራስህን ወርውር፤ ‘መላእክቱን ስለ አንተ ያዝዛል፤ እግርህንም በድንጋይ ከቶ እንዳይሰናከል በእጃቸው ያነሡሃል’ ተብሎ ተጽፎአልና” አለው።',
  'MAT_4_14': 'በነቢዩም በኢሳይያስ እንዲህ የተባለው ይፈጸም ዘንድ ይህ ሆነ፤',
  'MAT_4_15': 'የዛብሎን ምድርና የንፍታሌም ምድር፥ የባሕር መንገድ፥ በዮርዳኖስ ማዶ፥ የአሕዛብ ገሊላ፤',
  'MAT_4_16': 'በጨለማ የተቀመጠው ሕዝብ ታላቅ ብርሃን አየ፤ በሞት አገርና ጥላ ለተቀመጡትም ብርሃን ወጣላቸው።',
  'MAT_27_9': 'በዚያን ጊዜ በነቢዩ በኤርምያስ የተባለው “ከእስራኤል ልጆችም አንዳንዶቹ የገመቱትን፥ የተገመተውን ዋጋ ሠላሳ ብር አነሡ፤',
  'MAT_27_10': 'ጌታም እንዳዘዘኝ ስለ ሸክላ ሠሪ መሬት ሰጡት” የሚል ተፈጸመ።',
  'REV_7_10': 'በታላቅም ድምፅ እየጮሁ፦ “በዙፋኑ ላይ ለተቀመጠው ለአምላካችንና ለበጉ ማዳን ነው!” አሉ።',
  'REV_11_15': 'ሰባተኛው መልአክ መለከቱን ነፋ፤ በሰማይም፦ “የዓለም መንግሥት ለጌታችንና ለእርሱ ለክርስቶስ ሆነች፥ ለዘላለምም እስከ ዘላለም ይነግሣል” የሚሉ ታላላቅ ድምፆች ሆኑ።'
};

let restoredCount = 0;

for (let bNum = 1; bNum <= 81; bNum++) {
  const oBook = o81[bNum - 1];
  const canonId = eotc81ToCanonical[bNum];
  const a54Idx = canonicalToA54BookIdx[canonId];
  
  if (a54Idx !== undefined) {
    const aBook = a54.books[a54Idx];
    
    for (let cIdx = 0; cIdx < oBook.chapters.length; cIdx++) {
      const oCh = oBook.chapters[cIdx];
      const aCh = (aBook && aBook.chapters) ? aBook.chapters[cIdx] : null;
      if (!aCh) continue;
      
      const aVerses = aCh.verses || [];
      const sections = oCh.sections || [];
      
      for (const sec of sections) {
        if (!sec.verses) continue;
        for (const ov of sec.verses) {
          const vNum = ov.verse;
          const oText = (ov.text || '').trim();
          const key = `${canonId}_${oCh.chapter}_${vNum}`;
          
          // 1. Check curated overrides
          if (curatedSplitVerses[key]) {
            ov.text = curatedSplitVerses[key];
            restoredCount++;
            continue;
          }
          
          const aText = (aVerses[vNum - 1] || '').trim();
          
          // 2. If aText is valid and not merged ('-')
          if (aText && aText !== '-' && aText.length > 20) {
            // Check if oText is truncated:
            // a) Much shorter than aText (less than 65% length)
            // b) Ends mid-sentence with semicolon or comma
            // c) Missing end punctuation when aText has it
            const isTooShort = oText.length < aText.length * 0.65;
            const endsWithMidPunct = oText.endsWith('፤') || oText.endsWith('፥') || oText.endsWith('፣');
            const lacksEndPunct = !oText.endsWith('።') && !oText.endsWith('”') && !oText.endsWith('?');
            
            if (isTooShort || (endsWithMidPunct && aText.endsWith('።')) || (lacksEndPunct && aText.length > oText.length + 15)) {
              ov.text = aText;
              restoredCount++;
            }
          }
        }
      }
    }
  }
}

console.log(`Successfully restored ${restoredCount} truncated verses across the 66 canonical books!`);

// Save to assets and tools
fs.writeFileSync(o81Path, JSON.stringify(o81, null, 2), 'utf8');
fs.writeFileSync('C:/Users/Administrator/holy_bible_amharic/tools/data/orthodox_81.json', JSON.stringify(o81, null, 2), 'utf8');
console.log('Saved updated orthodox_81.json to assets/data/ and tools/data/!');
