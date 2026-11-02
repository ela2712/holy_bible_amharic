const fs = require('fs');
const path = require('path');

const numToCanon = {
  1: 'GEN', 2: 'EXO', 3: 'LEV', 4: 'NUM', 5: 'DEU', 6: 'JOS', 7: 'JDG', 8: 'RUT',
  9: '1SA', 10: '2SA', 11: '1KI', 12: '2KI', 13: '1CH', 14: '2CH', 15: 'EZR', 16: 'NEH',
  17: 'EST', 18: 'JOB', 19: 'PSA', 20: 'PRO', 21: 'ECC', 22: 'SNG', 23: 'ISA', 24: 'JER',
  25: 'LAM', 26: 'EZK', 27: 'DAN', 28: 'HOS', 29: 'JOL', 30: 'AMO', 31: 'OBA', 32: 'JON',
  33: 'MIC', 34: 'NAM', 35: 'HAB', 36: 'ZEP', 37: 'HAG', 38: 'ZEC', 39: 'MAL',
  59: 'MAT', 60: 'MRK', 61: 'LUK', 62: 'JHN', 63: 'ACT', 64: 'ROM', 65: '1CO', 66: '2CO',
  67: 'GAL', 68: 'EPH', 69: 'PHP', 70: 'COL', 71: '1TH', 72: '2TH', 73: '1TI', 74: '2TI',
  75: 'TIT', 76: 'PHM', 77: 'HEB', 78: 'JAS', 79: '1PE', 80: '2PE', 81: '1JN', 82: '2JN',
  83: '3JN', 84: 'JUD', 85: 'REV'
};

const inputPath = path.join(__dirname, '../assets/data/cross_references.json');
const raw = JSON.parse(fs.readFileSync(inputPath, 'utf8'));
const canonicalIndex = {};

let totalRefs = 0;
let skippedRefs = 0;

for (const key of Object.keys(raw)) {
  const [bStr, cStr, vStr] = key.split('-');
  const bNum = parseInt(bStr, 10);
  const canonBook = numToCanon[bNum];
  if (!canonBook) {
    skippedRefs++;
    continue;
  }
  const newKey = `${canonBook}-${cStr}-${vStr}`;
  const targets = [];
  for (const item of raw[key]) {
    const targetCanon = numToCanon[item.b];
    if (!targetCanon) {
      skippedRefs++;
      continue;
    }
    const tObj = { b: targetCanon, c: item.c, v: item.v };
    if (item.to) tObj.to = item.to;
    if (item.w) tObj.w = item.w;
    targets.push(tObj);
    totalRefs++;
  }
  if (targets.length > 0) {
    canonicalIndex[newKey] = targets;
  }
}

console.log(`Successfully converted ${Object.keys(canonicalIndex).length} canonical verse keys with ${totalRefs} cross references (skipped: ${skippedRefs}).`);

// Save updated JSON
fs.writeFileSync(inputPath, JSON.stringify(canonicalIndex), 'utf8');
console.log(`Saved canonical cross references to ${inputPath} (size: ${(fs.statSync(inputPath).size / 1024 / 1024).toFixed(2)} MB).`);
