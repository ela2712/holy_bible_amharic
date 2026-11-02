const fs = require('fs');
const path = require('path');

const geezPath = path.join(__dirname, '../assets/data/geez_81.json');
const o81Path = path.join(__dirname, '../assets/data/orthodox_81.json');

const geez = JSON.parse(fs.readFileSync(geezPath, 'utf8'));
const o81 = JSON.parse(fs.readFileSync(o81Path, 'utf8'));

console.log('=== Starting Ge\'ez 81 Canon Deep Repair & Harmonization ===');

// Helper to convert Amharic sectioned chapter to array of Ge'ez-styled strings
function o81ChapterToVerses(o81Ch) {
  const verses = [];
  if (o81Ch.sections) {
    o81Ch.sections.forEach(s => {
      (s.verses || []).forEach(v => {
        // Format text with Ge'ez style word separators if needed
        const txt = (v.text || '').trim();
        verses.push(txt);
      });
    });
  } else if (o81Ch.verses) {
    o81Ch.verses.forEach(v => {
      verses.push((v.text || v || '').trim());
    });
  }
  return verses;
}

// 1. Repair Book 37 (Baruch) - replace 52-chapter duplicate Jeremiah with genuine 5 chapters
const baruchO81 = o81.find(b => b.book_number === 37);
const baruchGeez = geez.find(b => b.book_number === 37);
if (baruchGeez && baruchO81) {
  console.log(`Re-structuring Book 37 (መጽሐፈ ባሮክ): from ${baruchGeez.chapters.length} duplicate ch to ${baruchO81.chapters.length} genuine ch`);
  baruchGeez.name = 'መጽሐፈ ባሮክ';
  baruchGeez.name_en = 'Baruch';
  baruchGeez.chapters = baruchO81.chapters.map((ch, idx) => ({
    chapter: idx + 1,
    verses: o81ChapterToVerses(ch)
  }));
}

// 2. Repair Book 39 (Teref Ermias / Epistle of Jeremiah) - replace 52-chapter duplicate Jeremiah with genuine 1 chapter (73 verses)
const terO81 = o81.find(b => b.book_number === 39);
const terGeez = geez.find(b => b.book_number === 39);
if (terGeez && terO81) {
  console.log(`Re-structuring Book 39 (ተረፈ ኤርምያስ): from ${terGeez.chapters.length} duplicate ch to ${terO81.chapters.length} genuine ch`);
  terGeez.name = 'ተረፈ ኤርምያስ';
  terGeez.name_en = 'Rest of Jeremiah';
  terGeez.chapters = terO81.chapters.map((ch, idx) => ({
    chapter: idx + 1,
    verses: o81ChapterToVerses(ch)
  }));
}

// 3. Repair Book 30 (Tegsas / Book of Admonition) - replace 26-chapter duplicate Proverbs with genuine 6 chapters
const tegO81 = o81.find(b => b.book_number === 30);
const tegGeez = geez.find(b => b.book_number === 30);
if (tegGeez && tegO81) {
  console.log(`Re-structuring Book 30 (መጽሐፈ ተግሣጽ): from ${tegGeez.chapters.length} duplicate ch to ${tegO81.chapters.length} genuine ch`);
  tegGeez.name = 'መጽሐፈ ተግሣጽ';
  tegGeez.name_en = 'Book of Admonition';
  tegGeez.chapters = tegO81.chapters.map((ch, idx) => ({
    chapter: idx + 1,
    verses: o81ChapterToVerses(ch)
  }));
}

// 4. Specific Truncation Fixes
// Tobit (Book 21) Ch 14 V 15
const tobit = geez.find(b => b.book_number === 21);
if (tobit && tobit.chapters[13]) {
  const lastVIdx = tobit.chapters[13].verses.length - 1;
  const lastV = tobit.chapters[13].verses[lastVIdx];
  if (lastV.includes('ወሞተ፡ ጦብያ፡ በ፻ወ፳ወ')) {
    tobit.chapters[13].verses[lastVIdx] = 'ወሞተ፡ ጦብያ፡ በ፻ወ፳ወሰብዑ፡ ዓመት፡ ወተቀብረ፡ በክብር፡ ውስተ፡ ባጥና።';
    console.log('Repaired Tobit 14:15 ending.');
  }
}

// Judith (Book 22) Ch 16 V 28
const judith = geez.find(b => b.book_number === 22);
if (judith && judith.chapters[15]) {
  const lastVIdx = judith.chapters[15].verses.length - 1;
  const lastV = judith.chapters[15].verses[lastVIdx];
  if (lastV.includes('ወረስዓት፡ በቤተ፡ ምናሴ፡ ምታ፡ ፻ወ')) {
    judith.chapters[15].verses[lastVIdx] = 'ወረስዓት፡ በቤተ፡ ምናሴ፡ ምታ፡ ፻ወ፭፡ ዓመተ፡ ወሞተት፡ በክብር፡ ወተቀብረት፡ ውስተ፡ በዓተ፡ ምታ።';
    console.log('Repaired Judith 16:28 ending.');
  }
}

// Daniel (Book 42) Ch 3 V 47
const daniel = geez.find(b => b.book_number === 42);
if (daniel && daniel.chapters[2]) {
  const v47 = daniel.chapters[2].verses[46];
  if (v47 && v47.includes('ወተለዓለ፡ ነበልባል፡ እምዕቶን፡ ፵፡ ወ')) {
    daniel.chapters[2].verses[46] = 'ወተለዓለ፡ ነበልባል፡ እምዕቶን፡ ፵ወ፱፡ እመት።';
    console.log('Repaired Daniel 3:47 furnace flame height.');
  }
}

// Amos (Book 44) Ch 5 V 3-7 consolidation
const amos = geez.find(b => b.book_number === 44);
if (amos && amos.chapters[4]) {
  const ch5 = amos.chapters[4];
  if (ch5.verses[3] === 'ይተርፉ' || ch5.verses[3] === 'ይተርፉ።') {
    console.log('Consolidating fragmented Amos 5:3-7...');
    const mergedV3 = `${ch5.verses[2]} ይተርፉ፤ ${ch5.verses[4]} ይተርፋ ${ch5.verses[6]}`.replace(/\s+/g, ' ').trim();
    // Reconstruct chapter 5
    const newVerses = [
      ch5.verses[0],
      ch5.verses[1],
      mergedV3,
      ...ch5.verses.slice(7)
    ];
    ch5.verses = newVerses;
    console.log('Amos 5 verses consolidated successfully. Now has ' + ch5.verses.length + ' verses.');
  }
}

// Micah (Book 45) Ch 5 V 5-7 consolidation
const micah = geez.find(b => b.book_number === 45);
if (micah && micah.chapters[4]) {
  const ch5 = micah.chapters[4];
  if (ch5.verses[5] && ch5.verses[5].startsWith('ኖሉት')) {
    console.log('Consolidating fragmented Micah 5:5-6...');
    const mergedV5 = `${ch5.verses[4]} ኖሉት፡ ላዕሌሁ።`.replace(/\s+/g, ' ').trim();
    const newVerses = [
      ch5.verses[0],
      ch5.verses[1],
      ch5.verses[2],
      ch5.verses[3],
      mergedV5,
      ...ch5.verses.slice(6)
    ];
    ch5.verses = newVerses;
    console.log('Micah 5 verses consolidated successfully. Now has ' + ch5.verses.length + ' verses.');
  }
}

// Zechariah (Book 53) Ch 11 V 13-14
const zec = geez.find(b => b.book_number === 53);
if (zec && zec.chapters[10]) {
  const ch11 = zec.chapters[10];
  if (ch11.verses[12] && ch11.verses[12].endsWith('ወነሳእኩ፡ ዝሎ')) {
    ch11.verses[12] = ch11.verses[12].replace('ወነሳእኩ፡ ዝሎ', '').trim();
    if (!ch11.verses[12].endsWith('።')) ch11.verses[12] += '።';
    ch11.verses[13] = 'ወነሣእኩ፡ ሠላሳ፡ ብሩረ፡ ' + ch11.verses[13];
    console.log('Repaired Zechariah 11:13-14 word splitting.');
  }
}

// 5. Heal Meqabyan 1, 2, 3 (Books 24, 25, 26)
let meqHealed = 0;
[24, 25, 26].forEach(bn => {
  const b = geez.find(x => x.book_number === bn);
  b.chapters.forEach(c => {
    const newVerses = [];
    for (let i = 0; i < c.verses.length; i++) {
      const v = c.verses[i].trim();
      
      // Known isolated word fragments
      if (
        (v.length < 25 && !v.endsWith('።') && !v.endsWith('?') && i + 1 < c.verses.length) ||
        v === 'ወቦቱ' ||
        v === 'ወመጽኡ' ||
        v === 'ወእሙንቱሰ' ||
        v === 'ወሶበ፡ አስተርአይዎሙ'
      ) {
        c.verses[i + 1] = v + ' ' + c.verses[i + 1].trim();
        meqHealed++;
        continue;
      }
      
      // If ends without punctuation and next line completes it
      if (
        (v.endsWith('ለ') || v.endsWith('መጠነ') || v.endsWith('እም') || v.endsWith('ወ')) &&
        i + 1 < c.verses.length
      ) {
        c.verses[i + 1] = v + ' ' + c.verses[i + 1].trim();
        meqHealed++;
        continue;
      }

      newVerses.push(v);
    }
    c.verses = newVerses;
  });
});
console.log(`Healed ${meqHealed} fragments in Meqabyan 1, 2, 3.`);

// Save back to geez_81.json
fs.writeFileSync(geezPath, JSON.stringify(geez, null, 2), 'utf8');
console.log('Successfully written repaired geez_81.json!');
