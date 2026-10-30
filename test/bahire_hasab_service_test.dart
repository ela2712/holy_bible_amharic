import 'package:flutter_test/flutter_test.dart';
import 'package:holy_bible_amharic/services/bahire_hasab_service.dart';

void main() {
  group('Authentic EOTC Bahire Hasab Tests', () {
    test('Evangelist cycles match four-year cycle', () {
      // 2015 = Luke, 2016 = John, 2017 = Matthew, 2018 = Mark
      expect(BahireHasabService.getEvangelist(2015), 'ዘመነ ሉቃስ');
      expect(BahireHasabService.getEvangelist(2016), 'ዘመነ ዮሐንስ');
      expect(BahireHasabService.getEvangelist(2017), 'ዘመነ ማቴዎስ');
      expect(BahireHasabService.getEvangelist(2018), 'ዘመነ ማርቆስ');
    });

    test('Leap year detection is true for Year of Luke (ዘመነ ሉቃስ)', () {
      expect(BahireHasabService.isLeapYear(2015), isTrue); // 2015 was Luke (leap)
      expect(BahireHasabService.isLeapYear(2016), isFalse);
      expect(BahireHasabService.isLeapYear(2017), isFalse);
      expect(BahireHasabService.isLeapYear(2018), isFalse);
      expect(BahireHasabService.isLeapYear(2019), isTrue); // 2019 is Luke (leap)
    });

    test('Fast of Nineveh (ጾመ ነነዌ) matches official Ethiopian Patriarchate calendar', () {
      // 2015 E.C.: Tir 29
      final n2015 = BahireHasabService.getNinevehDate(2015);
      expect(n2015.month, 5); // Tir
      expect(n2015.day, 29);
      expect(n2015.dayOfWeek, 1); // Monday

      // 2016 E.C.: Yekatit 18
      final n2016 = BahireHasabService.getNinevehDate(2016);
      expect(n2016.month, 6); // Yekatit
      expect(n2016.day, 18);
      expect(n2016.dayOfWeek, 1); // Monday

      // 2017 E.C.: Yekatit 3
      final n2017 = BahireHasabService.getNinevehDate(2017);
      expect(n2017.month, 6); // Yekatit
      expect(n2017.day, 3);
      expect(n2017.dayOfWeek, 1); // Monday
    });

    test('Great Lent (ዐቢይ ጾም) starts exactly 14 days after Nineveh on a Monday', () {
      final events2017 = BahireHasabService.getMovableEvents(2017);
      final lent = events2017.firstWhere((e) => e.title.contains('ዐቢይ ጾም'));
      // Nineveh 2017 was Yekatit 3 -> Lent is Yekatit 17 (always Monday)
      expect(lent.date.month, 6); // Yekatit
      expect(lent.date.day, 17);
      expect(lent.date.dayOfWeek, 1);
    });

    test('Gregorian to Ethiopian date conversion is accurate', () {
      // Sept 11, 2024 -> Meskerem 1, 2017 E.C.
      final eth1 = BahireHasabService.fromGregorian(DateTime(2024, 9, 11));
      expect(eth1.year, 2017);
      expect(eth1.month, 1);
      expect(eth1.day, 1);

      // Oct 29, 2026 -> Tikimt 19, 2019 E.C.
      final eth2 = BahireHasabService.fromGregorian(DateTime(2026, 10, 29));
      expect(eth2.year, 2019);
      expect(eth2.month, 2);
      expect(eth2.day, 19);
      expect(eth2.toGeezString().contains('ጥቅምት ፲፱'), isTrue);
    });

    test('Fasting rule detects Wednesday and Friday fasting', () {
      // Test on a known Wednesday outside Easter 50 days
      final wednesday = DateTime(2024, 10, 16); // Tikimt 6, 2017 (Wednesday)
      final status = BahireHasabService.getCurrentLiturgicalStatus(wednesday);
      expect(status['isFastDay'], isTrue);
      expect((status['fastLabel'] as String).contains('ረቡዕ'), isTrue);
    });
  });
}
