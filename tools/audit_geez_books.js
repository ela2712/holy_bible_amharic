const fs = require('fs');

const geez = JSON.parse(fs.readFileSync('assets/data/geez_81.json', 'utf8'));

console.log('Total books in geez_81:', geez.length);

geez.forEach((b) => {
  let totalVerses = 0;
  let truncatedCount = 0;
  const sampleTruncated = [];

  b.chapters.forEach(c => {
    totalVerses += c.verses.length;
    c.verses.forEach((v, vIdx) => {
      const text = typeof v === 'string' ? v : (v.text || '');
      // Check for abrupt endings: doesn't end with Ethiopic full stop (።) or question/exclamation mark or quotes
      const trimmed = text.trim();
      // Ethiopic full stop is '።' (U+1362)
      if (trimmed.length > 0 && !trimmed.endsWith('።') && !trimmed.endsWith(':') && !trimmed.endsWith('፤')) {
        truncatedCount++;
        if (sampleTruncated.length < 3) {
          sampleTruncated.push(`Ch ${c.chapter} V ${vIdx + 1}: ${trimmed.substring(Math.max(0, trimmed.length - 30))}`);
        }
      }
    });
  });

  if (
    [36, 37, 38, 39, 44, 45, 46].includes(b.book_number) ||
    b.name.includes('ባሮክ') ||
    b.name.includes('ኤርምያስ') ||
    b.name.includes('መቃብያን') ||
    truncatedCount > 0
  ) {
    console.log(`[${b.book_number}] ${b.name} (${b.name_en}): ${b.chapters.length} ch, ${totalVerses} vs, truncated: ${truncatedCount}`);
    if (sampleTruncated.length > 0) {
      console.log('   Samples ending without Ethiopic punctuation:', sampleTruncated);
    }
  }
});
