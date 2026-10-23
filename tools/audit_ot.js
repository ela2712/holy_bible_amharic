const fs = require('fs');

const o81 = JSON.parse(fs.readFileSync('C:/Users/Administrator/holy_bible_amharic/assets/data/orthodox_81.json', 'utf8'));
const a54 = JSON.parse(fs.readFileSync('C:/Users/Administrator/holy_bible_amharic/assets/data/amharic_1954.json', 'utf8'));

// Compare first 39 OT books
let otDiscrepancies = [];

for (let i = 0; i < 39; i++) {
  const oBook = o81[i]; // In o81, are the first 39 traditional or are deuterocanonical mixed in?
  console.log(`OT Book ${i+1}: ${oBook.book_name_am} (testament: ${oBook.testament})`);
}
