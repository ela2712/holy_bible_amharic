const fs = require('fs');
const path = require('path');

function auditO81(filePath) {
  console.log(`\n========================================`);
  console.log(`AUDITING ORTHODOX 81: ${filePath}`);
  console.log(`========================================`);
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  let issues = [];
  let totalVerses = 0;

  for (const b of data) {
    const bNum = b.book_number;
    const bName = b.book_name_am || b.title;
    for (const c of b.chapters) {
      const cNum = c.chapter;
      let verses = [];
      if (c.verses) {
        verses = c.verses;
      } else if (c.sections) {
        for (const s of c.sections) {
          if (s.verses) verses.push(...s.verses);
        }
      }
      
      verses.sort((x, y) => x.verse - y.verse);
      
      for (let i = 0; i < verses.length; i++) {
        totalVerses++;
        const v = verses[i];
        const text = (v.text || '').trim();
        const vNum = v.verse;
        
        if (!text || text === '-' || text === '.') {
          issues.push({ book: bName, bNum, ch: cNum, v: vNum, issue: 'EMPTY_OR_DASH', text });
        } else if (text.length < 18) {
          issues.push({ book: bName, bNum, ch: cNum, v: vNum, issue: `VERY_SHORT_${text.length}_CHARS`, text });
        } else if (text.endsWith('፤') || text.endsWith('፥') || text.endsWith('፣') || text.endsWith('፡')) {
          issues.push({ book: bName, bNum, ch: cNum, v: vNum, issue: `TRUNCATED_MID_SENTENCE_PUNCTUATION`, text });
        }
      }
    }
  }

  console.log(`Total verses checked: ${totalVerses}`);
  console.log(`Total suspicious/truncated verses found: ${issues.length}`);
  return issues;
}

function auditA54(filePath) {
  console.log(`\n========================================`);
  console.log(`AUDITING AMHARIC 1954: ${filePath}`);
  console.log(`========================================`);
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  const books = data.books || [];
  let issues = [];
  let totalVerses = 0;

  for (let bIdx = 0; bIdx < books.length; bIdx++) {
    const b = books[bIdx];
    const bNum = bIdx + 1;
    const bName = b.title;
    for (let cIdx = 0; cIdx < (b.chapters || []).length; cIdx++) {
      const c = b.chapters[cIdx];
      const cNum = parseInt(c.chapter, 10) || (cIdx + 1);
      const verses = c.verses || [];
      for (let vIdx = 0; vIdx < verses.length; vIdx++) {
        totalVerses++;
        const vNum = vIdx + 1;
        const text = (verses[vIdx] || '').trim();
        if (!text || text === '.') {
          issues.push({ book: bName, bNum, ch: cNum, v: vNum, issue: 'EMPTY', text });
        } else if (text === '-') {
          // merged marker
          issues.push({ book: bName, bNum, ch: cNum, v: vNum, issue: 'MERGED_DASH', text });
        } else if (text.length < 18) {
          issues.push({ book: bName, bNum, ch: cNum, v: vNum, issue: `VERY_SHORT_${text.length}_CHARS`, text });
        } else if (text.endsWith('፤') || text.endsWith('፥') || text.endsWith('፣') || text.endsWith('፡')) {
          issues.push({ book: bName, bNum, ch: cNum, v: vNum, issue: `TRUNCATED_MID_SENTENCE_PUNCTUATION`, text });
        }
      }
    }
  }

  console.log(`Total verses checked: ${totalVerses}`);
  console.log(`Total issues found: ${issues.length}`);
  return issues;
}

function auditKjv(filePath) {
  console.log(`\n========================================`);
  console.log(`AUDITING KJV: ${filePath}`);
  console.log(`========================================`);
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  let issues = [];
  let totalVerses = 0;
  for (let bIdx = 0; bIdx < data.length; bIdx++) {
    const b = data[bIdx];
    const bName = b.name || b.abbrev;
    for (let cIdx = 0; cIdx < b.chapters.length; cIdx++) {
      const ch = b.chapters[cIdx];
      for (let vIdx = 0; vIdx < ch.length; vIdx++) {
        totalVerses++;
        const text = (ch[vIdx] || '').trim();
        if (!text || text === '-') {
          issues.push({ book: bName, ch: cIdx + 1, v: vIdx + 1, issue: 'EMPTY', text });
        } else if (text.length < 8) {
          issues.push({ book: bName, ch: cIdx + 1, v: vIdx + 1, issue: `VERY_SHORT_${text.length}_CHARS`, text });
        }
      }
    }
  }
  console.log(`Total verses checked: ${totalVerses}`);
  console.log(`Total issues found: ${issues.length}`);
  return issues;
}

const o81Issues = auditO81('C:/Users/Administrator/holy_bible_amharic/assets/data/orthodox_81.json');
fs.writeFileSync('C:/Users/Administrator/holy_bible_amharic/tools/o81_audit_report.json', JSON.stringify(o81Issues, null, 2), 'utf8');

const a54Issues = auditA54('C:/Users/Administrator/holy_bible_amharic/assets/data/amharic_1954.json');
fs.writeFileSync('C:/Users/Administrator/holy_bible_amharic/tools/a54_audit_report.json', JSON.stringify(a54Issues, null, 2), 'utf8');

const kjvIssues = auditKjv('C:/Users/Administrator/holy_bible_amharic/assets/data/kjv.json');
fs.writeFileSync('C:/Users/Administrator/holy_bible_amharic/tools/kjv_audit_report.json', JSON.stringify(kjvIssues, null, 2), 'utf8');
