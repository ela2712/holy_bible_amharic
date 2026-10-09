/// Converts Arabic numbers (e.g. 1, 25, 119) to Ge'ez numerals (e.g. ፩, ፳፭, ፻፲፱)
class GeezNumbers {
  GeezNumbers._();

  static const List<String> _ones = [
    '', '፩', '፪', '፫', '፬', '፭', '፮', '፯', '፰', '፱'
  ];
  static const List<String> _tens = [
    '', '፲', '፳', '፴', '፵', '፶', '፷', '፸', '፹', '፺'
  ];
  static const String _hundred = '፻';
  static const String _tenThousand = '፼';

  static String toGeez(int number) {
    if (number <= 0) return number.toString();
    if (number > 999999) return number.toString();

    String result = '';

    if (number >= 10000) {
      int myriads = number ~/ 10000;
      number %= 10000;
      if (myriads > 1) {
        result += _convertUnder10000(myriads);
      }
      result += _tenThousand;
    }

    if (number > 0) {
      result += _convertUnder10000(number);
    }

    return result.isEmpty ? '፩' : result;
  }

  static String _convertUnder10000(int num) {
    String res = '';
    if (num >= 100) {
      int hundreds = num ~/ 100;
      num %= 100;
      if (hundreds > 1) {
        res += _convertUnder100(hundreds);
      }
      res += _hundred;
    }
    if (num > 0) {
      res += _convertUnder100(num);
    }
    return res;
  }

  static String _convertUnder100(int num) {
    int tens = num ~/ 10;
    int ones = num % 10;
    return _tens[tens] + _ones[ones];
  }
}
