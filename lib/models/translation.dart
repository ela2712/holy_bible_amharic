class Translation {
  final int id;
  final String code;
  final String name;
  final String shortName;
  final String language;
  final String canon;
  final bool isDefault;

  const Translation({
    required this.id,
    required this.code,
    required this.name,
    required this.shortName,
    required this.language,
    required this.canon,
    required this.isDefault,
  });

  factory Translation.fromMap(Map<String, dynamic> map) {
    return Translation(
      id: map['id'] as int,
      code: map['code'] as String,
      name: map['name'] as String,
      shortName: map['short_name'] as String,
      language: map['language'] as String,
      canon: map['canon'] as String,
      isDefault: (map['is_default'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'short_name': shortName,
      'language': language,
      'canon': canon,
      'is_default': isDefault ? 1 : 0,
    };
  }
}
