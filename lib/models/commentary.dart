class Commentary {
  final int id;
  final int bookNumber;
  final int chapter;
  final int verse;
  final String authorName; // e.g. ቅዱስ ዮሐንስ አፈወርቅ (St. John Chrysostom)
  final String authorTitle; // e.g. የቁስጥንጥንያ ሊቀ ጳጳስ (349–407 ዓ.ም.)
  final String authorEra; // e.g. 4ኛው መቶ ክፍለ ዘመን
  final String content; // Patristic exposition
  final String sourceWork; // e.g. ድርሳነ ማቴዎስ / Homilies on Matthew
  final String tradition; // e.g. 'ኦርቶዶክሳዊ የአበው ትርጓሜ' / Patristic

  const Commentary({
    required this.id,
    required this.bookNumber,
    required this.chapter,
    required this.verse,
    required this.authorName,
    required this.authorTitle,
    required this.authorEra,
    required this.content,
    required this.sourceWork,
    this.tradition = 'የቀደምት አበው ትርጓሜ (Patristic)',
  });
}
