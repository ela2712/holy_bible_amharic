class CrossReferenceItem {
  final int fromBookNumber;
  final int fromChapter;
  final int fromVerse;
  final int targetBookNumber;
  final String targetBookName;
  final int targetChapter;
  final int targetVerse;
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
    required this.connectionType,
    required this.sourceCitation,
    required this.explanation,
    required this.targetPreviewText,
  });

  String get targetReference => '$targetBookName $targetChapter:$targetVerse';
}
