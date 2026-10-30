class CrossReferenceItem {
  final int fromBookNumber;
  final int fromChapter;
  final int fromVerse;
  final int targetBookNumber;
  final String targetBookName;
  final int targetChapter;
  final int targetVerse;
  final int? targetVerseEnd;
  final String connectionType; // e.g., 'ትንቢትና ፍጻሜ (Prophecy & Fulfillment)'
  final String sourceCitation; // Detailed scholarly/canonical source
  final String explanation; // Detailed explanation of the link
  final String targetPreviewText;

  const CrossReferenceItem({
    required this.fromBookNumber,
    required this.fromChapter,
    required this.fromVerse,
    required this.targetBookNumber,
    required this.targetBookName,
    required this.targetChapter,
    required this.targetVerse,
    this.targetVerseEnd,
    required this.connectionType,
    required this.sourceCitation,
    required this.explanation,
    required this.targetPreviewText,
  });

  String get targetReference {
    if (targetVerseEnd != null && targetVerseEnd! > targetVerse) {
      return '$targetBookName $targetChapter:$targetVerse-$targetVerseEnd';
    }
    return '$targetBookName $targetChapter:$targetVerse';
  }
}
