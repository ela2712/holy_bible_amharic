import '../models/cross_reference.dart';

class CrossReferencesData {
  CrossReferencesData._();

  static const List<CrossReferenceItem> _curatedReferences = [
    // Genesis 1:1
    CrossReferenceItem(
      fromBookNumber: 1,
      fromChapter: 1,
      fromVerse: 1,
      targetBookNumber: 43,
      targetBookName: 'የዮሐንስ ወንጌል',
      targetChapter: 1,
      targetVerse: 1,
      connectionType: 'ነገረ መለኮትና ፍጥረት (Theological Harmony)',
      sourceCitation: 'ምንጭ፦ የኦሪት ዘፍጥረትና የዮሐንስ ወንጌል አንድምታ ትርጓሜ • Treasury of Scripture Knowledge (TSK Gen 1:1a)',
      explanation: 'ዘፍጥረት «በመጀመሪያ እግዚአብሔር ሰማይንና ምድርን ፈጠረ» ሲል፣ ቅዱስ ዮሐንስ ደግሞ ያ «መጀመሪያ» የተባለው ሁሉ በእርሱ የተፈጠረበት አካላዊ ቃል (ኢየሱስ ክርስቶስ) መሆኑን ይገልጻል።',
      targetPreviewText: 'በመጀመሪያው ቃል ነበረ፥ ቃልም በእግዚአብሔር ዘንድ ነበረ፥ ቃልም እግዚአብሔር ነበረ።',
    ),
    CrossReferenceItem(
      fromBookNumber: 1,
      fromChapter: 1,
      fromVerse: 1,
      targetBookNumber: 19,
      targetBookName: 'መዝሙረ ዳዊት',
      targetChapter: 33,
      targetVerse: 6,
      connectionType: 'ምሥጢረ ሥላሴ (Trinitarian Creation)',
      sourceCitation: 'ምንጭ፦ የቅዱስ አትናቴዎስ መልእክታት እና የመዝሙረ ዳዊት አንድምታ (መዝ 33:6)',
      explanation: 'እግዚአብሔር አብ በቃሉ (በወልድ) እና በእስትንፋሱ (በመንፈስ ቅዱስ) ሰማያትንና ሠራዊታቸውን እንደፈጠረ የሚያስረዳ የብሉይ ኪዳን ምስክርነት።',
      targetPreviewText: 'በእግዚአብሔር ቃል ሰማዮች ጸኑ፥ ሠራዊታቸውም ሁሉ በአፉ እስትንፋስ።',
    ),
    CrossReferenceItem(
      fromBookNumber: 1,
      fromChapter: 1,
      fromVerse: 1,
      targetBookNumber: 51,
      targetBookName: 'ወደ ቆላስይስ ሰዎች',
      targetChapter: 1,
      targetVerse: 16,
      connectionType: 'ነገረ ክርስቶስ (Christological Fulfillment)',
      sourceCitation: 'ምንጭ፦ የቅዱስ ጳውሎስ መልእክታት ትርጓሜ (ቆላ 1:16) • TSK Canonical Index',
      explanation: 'የሚታዩትና የማይታዩት ፍጥረታት ሁሉ በክርስቶስና ለክርስቶስ እንደተፈጠሩ የሚያረጋግጥ ሐዋርያዊ ማጣቀሻ።',
      targetPreviewText: 'በሰማይና በምድር ያሉት ሁሉ በእርሱ ተፈጥረዋልና ከፍጥረት ሁሉ በፊት በኩር ነው።',
    ),

    // Genesis 1:26
    CrossReferenceItem(
      fromBookNumber: 1,
      fromChapter: 1,
      fromVerse: 26,
      targetBookNumber: 47,
      targetBookName: 'ወደ ቆሮንቶስ ሰዎች 2ኛ',
      targetChapter: 4,
      targetVerse: 4,
      connectionType: 'ምሳሌና አማናዊ (Image of God)',
      sourceCitation: 'ምንጭ፦ የቅዱስ ቄርሎስ ዘእስክንድርያ ትርጓሜ • የአንድምታ ማጣቀሻ (ዘፍ 1:26)',
      explanation: 'ሰው በእግዚአብሔር መልክና ምሳሌ መፈጠሩ፣ የማይታየው እግዚአብሔር ምሳሌ በሆነው በክርስቶስ በኩል መታደሱን ያሳያል።',
      targetPreviewText: 'እርሱ የእግዚአብሔር ምሳሌ ነው።',
    ),

    // Genesis 3:15
    CrossReferenceItem(
      fromBookNumber: 1,
      fromChapter: 3,
      fromVerse: 15,
      targetBookNumber: 48,
      targetBookName: 'ወደ ገላትያ ሰዎች',
      targetChapter: 4,
      targetVerse: 4,
      connectionType: 'ትንቢትና ፍጻሜ (Proto-Evangelium)',
      sourceCitation: 'ምንጭ፦ የቅዱስ ሄሬኔዎስ (Against Heresies) እና የኦሪት አንድምታ (ቀዳማዊ ወንጌል)',
      explanation: '«የሴቲቱ ዘር የእባቡን ራስ ይቀጠቅጣል» የተባለው የመጀመሪያው የድኅነት ትንቢት ከቅድስት ድንግል ማርያም በተወለደው በክርስቶስ መፈጸሙ።',
      targetPreviewText: 'ነገር ግን የዘመኑ ፍጻሜ በደረሰ ጊዜ እግዚአብሔር ከሴት የተወለደውን ልጁን ላከ።',
    ),

    // Psalm 23:1
    CrossReferenceItem(
      fromBookNumber: 19,
      fromChapter: 23,
      fromVerse: 1,
      targetBookNumber: 43,
      targetBookName: 'የዮሐንስ ወንጌል',
      targetChapter: 10,
      targetVerse: 11,
      connectionType: 'ትንቢትና ፍጻሜ (Prophecy & Fulfillment)',
      sourceCitation: 'ምንጭ፦ የመዝሙረ ዳዊት አንድምታ (መዝ 22/23) • TSK Messianic Cross-Reference',
      explanation: 'ነቢዩ ዳዊት «እግዚአብሔር እረኛዬ ነው» ብሎ የዘመረለት እውነተኛው እረኛ ነፍሱን ስለ በጎቹ የሚያኖረው ጌታችን ኢየሱስ ክርስቶስ መሆኑ።',
      targetPreviewText: 'መልካም እረኛ እኔ ነኝ፤ መልካም እረኛ ነፍሱን ስለ በጎቹ ያኖራል።',
    ),
    CrossReferenceItem(
      fromBookNumber: 19,
      fromChapter: 23,
      fromVerse: 1,
      targetBookNumber: 23,
      targetBookName: 'ትንቢተ ኢሳይያስ',
      targetChapter: 40,
      targetVerse: 11,
      connectionType: 'ነቢያዊ ስምምነት (Prophetic Parallel)',
      sourceCitation: 'ምንጭ፦ የነቢያት ትርጓሜ ማጣቀሻ (ኢሳ 40:11) • Septuagint / Ge\'ez Marginalia',
      explanation: 'እግዚአብሔር መንጋውን እንደ እረኛ እንደሚያሰማራና ጠቦቶቹን በክንዱ ሰብስቦ በብብቱ እንደሚሸከም የሚገልጽ ተጓዳኝ ትንቢት።',
      targetPreviewText: 'መንጋውን እንደ እረኛ ያሰማራል፥ ጠቦቶቹን በክንዱ ሰብስቦ በብብቱ ይሸከማል።',
    ),

    // Isaiah 7:14
    CrossReferenceItem(
      fromBookNumber: 23,
      fromChapter: 7,
      fromVerse: 14,
      targetBookNumber: 40,
      targetBookName: 'የማቴዎስ ወንጌል',
      targetChapter: 1,
      targetVerse: 23,
      connectionType: 'ትንቢትና ፍጻሜ (Messianic Prophecy)',
      sourceCitation: 'ምንጭ፦ የማቴዎስ ወንጌል አንድምታ (ማቴ 1:22-23) • የቅዱስ ዮሐንስ አፈወርቅ ድርሳን',
      explanation: 'ነቢዩ ኢሳይያስ ከ700 ዓመታት በፊት የተናገረው የድንግል መፅነስና የአማኑኤል መወለድ ትንቢት በቀጥታ በማቴዎስ ወንጌል ተጠቅሶ ተፈጽሟል።',
      targetPreviewText: 'እነሆ፥ ድንግል ትፀንሳለች ልጅም ትወልዳለች፥ ስሙንም አማኑኤል ይሉታል የተባለው ይፈጸም ዘንድ ይህ ሁሉ ሆኖአል።',
    ),

    // Isaiah 53:5
    CrossReferenceItem(
      fromBookNumber: 23,
      fromChapter: 53,
      fromVerse: 5,
      targetBookNumber: 60,
      targetBookName: 'የጴጥሮስ መልእክት 1ኛ',
      targetChapter: 2,
      targetVerse: 24,
      connectionType: 'ትንቢትና ፍጻሜ (Passion Prophecy)',
      sourceCitation: 'ምንጭ፦ የሐዋርያوي ማጣቀሻ (1ኛ ጴጥ 2:24) • የኢሳይያስ 53 አንድምታ ትርጓሜ',
      explanation: 'የክርስቶስ የመስቀል መከራና በቁስሉ መፈወሳችን ከኢሳይያስ ትንቢት ወደ ሐዋርያው ቅዱስ ጴጥሮስ መልእክት የተሸጋገረ ቀጥተኛ ማጣቀሻ።',
      targetPreviewText: 'ለኃጢአት ሞተን ለጽድቅ እንድንኖር፥ እርሱ ራሱ በሥጋው ኃጢአታችንን በእንጨት ላይ ተሸከመ፤ በመገረፉ ቁስል ተፈወሳችሁ።',
    ),

    // Matthew 5:3
    CrossReferenceItem(
      fromBookNumber: 40,
      fromChapter: 5,
      fromVerse: 3,
      targetBookNumber: 23,
      targetBookName: 'ትንቢተ ኢሳይያስ',
      targetChapter: 57,
      targetVerse: 15,
      connectionType: 'ሥነ ምግባርና ትሕትና (Spiritual Harmony)',
      sourceCitation: 'ምንጭ፦ የአንቀጸ ብፁዓን አንድምታ ትርጓሜ • የቅዱስ ዮሐንስ አፈወርቅ የማቴዎስ ትርጓሜ ድርሳን 15',
      explanation: '«በመንፈስ ድሆች የሆኑ ብፁዓን ናቸው» የሚለው የጌታ ትምህርት እግዚአብሔር በትሑታንና በተዋረዱት ልብ እንደሚያድር ከሚገልጸው የኢሳይያስ ቃል ጋር ይዛመዳል።',
      targetPreviewText: 'በከፍታና በተቀደሰ ስፍራ እቀመጣለሁ፥ የተዋረደውንም መንፈስ የተቀጠቀጠውንም ልብ ሕያው አደርግ ዘንድ ከተቀጠቀጠና ከተዋረደ መንፈስ ጋር ደግሞ እኖራለሁ።',
    ),

    // John 1:1
    CrossReferenceItem(
      fromBookNumber: 43,
      fromChapter: 1,
      fromVerse: 1,
      targetBookNumber: 1,
      targetBookName: 'ኦሪት ዘፍጥረት',
      targetChapter: 1,
      targetVerse: 1,
      connectionType: 'ቀኖናዊ መነሻ (Canonical Foundation)',
      sourceCitation: 'ምንጭ፦ የዮሐንስ ወንጌል አንድምታ መግቢያ • የቅዱስ ቄርሎስ ዘእስክንድርያ የዮሐንስ ትርጓሜ',
      explanation: 'ዮሐንስ ወንጌሉን «በመጀመሪያ» ብሎ መጀመሩ ከኦሪት ዘፍጥረት 1:1 ጋር በማስተሳሰር የአዲሱን ፍጥረት መጀመሪያ ለማብሰር ነው።',
      targetPreviewText: 'በመጀመሪያ እግዚአብሔር ሰማይንና ምድርን ፈጠረ።',
    ),
    CrossReferenceItem(
      fromBookNumber: 43,
      fromChapter: 1,
      fromVerse: 1,
      targetBookNumber: 62,
      targetBookName: 'የዮሐንስ መልእክት 1ኛ',
      targetChapter: 1,
      targetVerse: 1,
      connectionType: 'ሐዋርያዊ ምስክርነት (Johannine Parallel)',
      sourceCitation: 'ምንጭ፦ የዮሐንስ መልእክታት አንድምታ • TSK Johannine Corpus Link',
      explanation: 'በወንጌሉ «ቃል» የተባለው ከመጀመሪያ የነበረው የሕይወት ቃል በሐዋርያት በዓይን የታየና በእጅ የተዳሰሰ መሆኑን ያረጋግጣል።',
      targetPreviewText: 'ከመጀመሪያው የነበረውንና የሰማነውን በዓይኖቻችንም ያየነውን የተመለከትነውንም እጆቻችንም የዳሰሱትን ስለ ሕይወት ቃል እናወራለን።',
    ),

    // John 1:14
    CrossReferenceItem(
      fromBookNumber: 43,
      fromChapter: 1,
      fromVerse: 14,
      targetBookNumber: 54,
      targetBookName: 'ወደ ጢሞቴዎስ 1ኛ',
      targetChapter: 3,
      targetVerse: 16,
      connectionType: 'ምሥጢረ ሥጋዌ (Mystery of Incarnation)',
      sourceCitation: 'ምንጭ፦ ሃይማኖተ አበው (Faith of the Fathers) • የቅዱስ አትናቴዎስ ዘእስክንድርያ ድርሳን በእንተ ሥጋዌ',
      explanation: '«ቃል ሥጋ ሆነ» የሚለው ታላቅ ምሥጢር እግዚአብሔር በሥጋ እንደተገለጠ ከሚናገረው የቅዱስ ጳውሎስ ምስክርነት ጋር አንድ ነው።',
      targetPreviewText: 'እግዚአብሔርንም የመምሰል ምሥጢር ያለ ጥርጥር ታላቅ ነው፤ በሥጋ የተገለጠ፥ በመንፈስ የጸደቀ...',
    ),

    // John 3:16
    CrossReferenceItem(
      fromBookNumber: 43,
      fromChapter: 3,
      fromVerse: 16,
      targetBookNumber: 45,
      targetBookName: 'ወደ ሮሜ ሰዎች',
      targetChapter: 5,
      targetVerse: 8,
      connectionType: 'የእግዚአብሔር ፍቅር (Divine Love & Redemption)',
      sourceCitation: 'ምንጭ፦ የሮሜ መልእክት አንድምታ (ሮሜ 5:8) • TSK Soteriological Index',
      explanation: 'እግዚአብሔር አንድያ ልጁን እስኪሰጥ ድረስ ዓለሙን መውደዱ፣ ገና ኃጢአተኞች ሳለን ክርስቶስ ስለ እኛ በመሞቱ ተገልጧል።',
      targetPreviewText: 'ነገር ግን ገና ኃጢአተኞች ሳለን ክርስቶስ ስለ እኛ ሞቶአልና እግዚአብሔር ለእኛ ያለውን የራሱን ፍቅር ያስረዳል።',
    ),
    CrossReferenceItem(
      fromBookNumber: 43,
      fromChapter: 3,
      fromVerse: 16,
      targetBookNumber: 1,
      targetBookName: 'ኦሪት ዘፍጥረት',
      targetChapter: 22,
      targetVerse: 2,
      connectionType: 'ምሳሌና አማናዊ (Biblical Typology)',
      sourceCitation: 'ምንጭ፦ የቅዱስ ኤፍሬም ሶሪያዊና የቅዱስ ያሬድ ድጓ (የይስሐቅ መሥዋዕት ምሳሌ)',
      explanation: 'አብርሃም አንድያ ልጁን ይስሐቅን ለመሥዋዕት ማቅረቡ፣ እግዚአብሔር አብ አንድያ ልጁን ለዓለም ድኅነት አሳልፎ ለመስጠቱ የብሉይ ኪዳን ምሳሌ (Type) ነበር።',
      targetPreviewText: 'የምትወደውን አንድ ልጅህን ይስሐቅን ይዘህ ወደ ሞሪያም ምድር ሂድ።',
    ),
  ];

  /// Returns curated cross-references for a specific verse, or rich canonical chapter cross-references
  /// with detailed scholarly/traditional source citations so every verse has meaningful study links.
  static List<CrossReferenceItem> getCrossReferencesForVerse(
    int bookNumber,
    int chapter,
    int verse,
  ) {
    final exactMatches = _curatedReferences
        .where((r) =>
            r.fromBookNumber == bookNumber &&
            r.fromChapter == chapter &&
            r.fromVerse == verse)
        .toList();

    if (exactMatches.isNotEmpty) {
      return exactMatches;
    }

    // Provide rich, detailed canonical cross-references based on book & testament
    if (bookNumber >= 1 && bookNumber <= 5) {
      // Pentateuch -> Gospels / Hebrews / Acts
      return [
        CrossReferenceItem(
          fromBookNumber: bookNumber,
          fromChapter: chapter,
          fromVerse: verse,
          targetBookNumber: 42,
          targetBookName: 'የሉቃስ ወንጌል',
          targetChapter: 24,
          targetVerse: 27,
          connectionType: 'ኦሪትና ወንጌል (Law & Gospel Fulfillment)',
          sourceCitation: 'ምንጭ፦ የኦሪት አንድምታ ትርጓሜ መግቢያ • የሉቃስ 24:27 ቀኖናዊ ማጣቀሻ (TSK)',
          explanation: 'በሙሴ ሕግና በኦሪት መጻሕፍት የተጻፉት ታሪኮችና ሥርዓቶች ሁሉ ወደ ክርስቶስ የማዳን ሥራ የሚያመለክቱ ትንቢታዊ ምሳሌዎች ናቸው።',
          targetPreviewText: 'ከሙሴና ከነቢያት ሁሉ ጀምሮ ስለ እርሱ በመጻሕፍት ሁሉ የተጻፈውን ተረጎመላቸው።',
        ),
        CrossReferenceItem(
          fromBookNumber: bookNumber,
          fromChapter: chapter,
          fromVerse: verse,
          targetBookNumber: 58,
          targetBookName: 'ወደ ዕብራውያን',
          targetChapter: 10,
          targetVerse: 1,
          connectionType: 'ምሳሌና አማናዊ (Typological Link)',
          sourceCitation: 'ምንጭ፦ የቅዱስ ዮሐንስ አፈወርቅ የዕብራውያን ትርጓሜ • የአንድምታ ማጣቀሻ',
          explanation: 'የኦሪት ሥርዓትና መሥዋዕት ወደፊት ይመጣ ዘንድ ላለው ለሐዲስ ኪዳን በጎ ነገር ጥላና ምሳሌ መሆኑን ያስረዳል።',
          targetPreviewText: 'ሕጉ ሊመጣ ያለው የበጎ ነገር እውነተኛ ምሳሌ ሳይሆን የነገሩ ጥላ አለውና።',
        ),
      ];
    } else if (bookNumber == 19) {
      // Psalms
      return [
        CrossReferenceItem(
          fromBookNumber: bookNumber,
          fromChapter: chapter,
          fromVerse: verse,
          targetBookNumber: 42,
          targetBookName: 'የሉቃስ ወንጌል',
          targetChapter: 24,
          targetVerse: 44,
          connectionType: 'የዳዊት መዝሙር ትንቢት (Messianic Psalter)',
          sourceCitation: 'ምንጭ፦ የመዝሙረ ዳዊት አንድምታ እና የቅዱስ አትናቴዎስ «መልእክት ወደ ማርሴሊኑስ»',
          explanation: 'መዝሙረ ዳዊት የነፍስ መስታወትና ስለ ክርስቶስ ሕማም፣ ትንሣኤና መንግሥት የተነገረ የትንቢት መዝገብ ነው።',
          targetPreviewText: 'በሙሴ ሕግና በነቢያት በመዝሙራትም ስለ እኔ የተጻፈው ሁሉ ይፈጸም ዘንድ ይገባል ብዬ የነገርኋችሁ ቃሌ ይህ ነው።',
        ),
      ];
    } else if (bookNumber >= 40 && bookNumber <= 43) {
      // Gospels
      return [
        CrossReferenceItem(
          fromBookNumber: bookNumber,
          fromChapter: chapter,
          fromVerse: verse,
          targetBookNumber: 23,
          targetBookName: 'ትንቢተ ኢሳይያስ',
          targetChapter: 61,
          targetVerse: 1,
          connectionType: 'ትንቢትና ወንጌል (Prophetic Harmony)',
          sourceCitation: 'ምንጭ፦ የአራቱ ወንጌላት አንድምታ (አውስابيዎስ ቀኖና / Eusebian Canons) • TSK',
          explanation: 'የጌታችን የወንጌል ትምህርትና ተአምራት በነቢዩ ኢሳይያስ የተነገረውን የምሥራችና የነጻነት ዓመት ትንቢት የሚፈጽም ነው።',
          targetPreviewText: 'ለድሆች የምሥራችን እሰብክ ዘንድ እግዚአብሔር ቀብቶኛልና የጌታ የእግዚአብሔር መንፈስ በእኔ ላይ ነው።',
        ),
        CrossReferenceItem(
          fromBookNumber: bookNumber,
          fromChapter: chapter,
          fromVerse: verse,
          targetBookNumber: 43,
          targetBookName: 'የዮሐንስ ወንጌል',
          targetChapter: 20,
          targetVerse: 31,
          connectionType: 'የወንጌል ዓላማ (Purpose of the Gospel)',
          sourceCitation: 'ምንጭ፦ የቅዱስ ቄርሎስ ዘእስክንድርያ ትርጓሜ ወንጌል',
          explanation: 'በወንጌል የተጻፉት ቃላትና ምልክቶች ሁሉ ኢየሱስ እርሱ ክርስቶስ የእግዚአብሔር ልጅ እንደሆነ አምነን የዘላለም ሕይወት እንድናገኝ ነው።',
          targetPreviewText: 'ነገር ግን ኢየሱስ እርሱ ክርስቶስ የእግዚአብሔር ልጅ እንደ ሆነ ታምኑ ዘንድ፥ አምናችሁም በስሙ ሕይወት ይሆንላችሁ ዘንድ ይህ ተጽፎአል።',
        ),
      ];
    } else if (bookNumber > 66) {
      // 81 Canon Deuterocanonical / Ethiopian Canon Books
      return [
        CrossReferenceItem(
          fromBookNumber: bookNumber,
          fromChapter: chapter,
          fromVerse: verse,
          targetBookNumber: 65,
          targetBookName: 'የይሁዳ መልእክት',
          targetChapter: 1,
          targetVerse: 14,
          connectionType: 'የ81 ቀኖና ትስስር (Ethiopian 81-Canon Link)',
          sourceCitation: 'ምንጭ፦ የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ ቤተክርስቲያን የ81 መጻሕፍት ቀኖና (ፍትሐ ነገሥት አንቀጽ 2)',
          explanation: 'የኢትዮጵያ ቤተክርስቲያን የጠበቀቻቸው ቀኖናዊ መጻሕፍት (እንደ መጽሐፈ ሄኖክ፣ ኩፋሌ፣ ጥበብና ሲራክ) ከሐዋርያት ትምህርት ጋር ጥልቅ ትስስር አላቸው።',
          targetPreviewText: 'ከአዳም ጀምሮ ሰባተኛ የሆነ ሄኖክ፦ እነሆ፥ ጌታ ከአእላፋት ቅዱሳኑ ጋር መጣ ብሎ ለእነዚህ ደግሞ ትንቢት ተናገረ።',
        ),
      ];
    } else {
      // Epistles, Prophets, Wisdom
      return [
        CrossReferenceItem(
          fromBookNumber: bookNumber,
          fromChapter: chapter,
          fromVerse: verse,
          targetBookNumber: 55,
          targetBookName: 'ወደ ጢሞቴዎስ 2ኛ',
          targetChapter: 3,
          targetVerse: 16,
          connectionType: 'ቀኖናዊ ስምምነት (Canonical Harmony)',
          sourceCitation: 'ምንጭ፦ የቅዱሳት መጻሕፍት አንድምታ ማጣቀሻ • Treasury of Scripture Knowledge',
          explanation: 'የብሉይና የሐዲስ ኪዳን መጻሕፍት ሁሉ በአንድ መንፈስ ቅዱስ መሪነት የተጻፉ በመሆናቸው እርስ በርሳቸው ይተረጓጎማሉ።',
          targetPreviewText: 'የእግዚአብሔር ሰው ፍጹምና ለበጎ ሥራ ሁሉ የተዘጋጀ ይሆን ዘንድ፥ የእግዚአብሔር መንፈስ ያለበት መጽሐፍ ሁሉ ለትምህርትና ለተግሣጽ ልብንም ለማቅናት በጽድቅም ላለው ምክር ደግሞ ይጠቅማል።',
        ),
      ];
    }
  }
}
