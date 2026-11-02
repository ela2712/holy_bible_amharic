const fs = require('fs');
const geez = JSON.parse(fs.readFileSync('assets/data/geez_81.json', 'utf8'));
const o81 = JSON.parse(fs.readFileSync('assets/data/orthodox_81.json', 'utf8'));

console.log('Book # | Name (O81) | O81 Ch | Geez Ch | O81 Vs | Geez Vs | Diff Note');
for (let i = 1; i <= 81; i++) {
  const ob = o81.find(b => b.book_number === i);
  const gb = geez.find(b => b.book_number === i);
  let ovCount = 0;
  if (ob) {
    ob.chapters.forEach(c => {
      (c.sections || []).forEach(s => ovCount += (s.verses ? s.verses.length : 0));
      if (c.verses) ovCount += c.verses.length;
    });
  }
  let gvCount = 0;
  if (gb) {
    gb.chapters.forEach(c => gvCount += (c.verses ? c.verses.length : 0));
  }
  const och = ob ? ob.chapters.length : 0;
  const gch = gb ? gb.chapters.length : 0;
  if (och !== gch || Math.abs(ovCount - gvCount) > 10) {
    let note = '';
    if (och !== gch) note += `Chapter count mismatch (${och} vs ${gch})! `;
    if (Math.abs(ovCount - gvCount) > 10) note += `Verse count diff: ${ovCount - gvCount}`;
    console.log(
      String(i).padStart(6) + ' | ' +
      (ob ? ob.book_name_am : 'N/A').padEnd(20) + ' | ' +
      String(och).padStart(6) + ' | ' +
      String(gch).padStart(7) + ' | ' +
      String(ovCount).padStart(6) + ' | ' +
      String(gvCount).padStart(7) + ' | ' +
      note
    );
  }
}
