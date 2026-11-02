const fs = require('fs');
const path = require('path');

const geezPath = path.join(__dirname, '../assets/data/geez_81.json');
const geez = JSON.parse(fs.readFileSync(geezPath, 'utf8'));

const dan = geez.find(b => b.book_number === 42);
if (dan) {
  const ch13 = dan.chapters.find(c => c.chapter === 13);
  if (ch13 && ch13.verses && ch13.verses.length >= 10) {
    if (ch13.verses[9].trim() === 'ወክል') {
      ch13.verses[9] = 'ወክልኤሆሙ፡ ተነድፉ፡ በእንቲአሃ፡ ወኢነገሩ፡ በበይናቲሆሙ፡ ሕማሞሙ፤ እስመ፡ ይትኀፈሩ፡ ነጊረ፡ ፈቃዶሙ፡ ዘፈቀዱ፡ ኀበ፡ ይትፌጸሙ።';
      console.log('Repaired Dan 13:10.');
    }
  }

  const ch14 = dan.chapters.find(c => c.chapter === 14);
  if (ch14 && ch14.verses && ch14.verses.length >= 3) {
    if (ch14.verses[2].trim() === 'ወሀሎ፡ ምስል፡ ዘያመልክዎ') {
      ch14.verses[2] = 'ወሀሎ፡ ምስል፡ ዘያመልክዎ፡ ሰብአ፡ ባቢሎን፡ ዘስሙ፡ ቤል፤ ወይወጽእ፡ ሎቱ፡ ለለዕለት፡ ፲ወ፪፡ መስፈርተ፡ ስሚድ፡ ወ፵፡ አባግዕ፡ ወ፮፡ መሥፈርተ፡ ወይን።';
      console.log('Repaired Dan 14:3.');
    }
  }
}

fs.writeFileSync(geezPath, JSON.stringify(geez), 'utf8');
console.log('Saved geez_81.json with Daniel repairs.');
