enum CardType {
  normal(0),
  hero(1),
  commander(2);

  const CardType(this.id);

  final int id;

  static CardType fromId(int id) {
    return CardType.values.firstWhere(
          (type) => type.id == id,
      orElse: () => CardType.normal,
    );
  }

  String get label {
    switch (this) {
      case CardType.normal:
        return 'Normal';

      case CardType.hero:
        return 'Hero';

      case CardType.commander:
        return 'Commander';
    }
  }
}
