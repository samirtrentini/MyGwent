import '../enums/card_type.enum.dart';

class GwentCard {
  const GwentCard({
    this.id,
    required this.title,
    this.power,
    required this.type,
    this.quantity = 1,
  });

  final int? id;
  final String title;
  final int? power;
  final CardType type;
  final int quantity;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'power': power,
      'type': type.id,
    };
  }

  factory GwentCard.fromMap(Map<String, Object?> map) {
    return GwentCard(
      id: map['id'] as int?,
      title: map['title'] as String,
      power: map['power'] as int?,
      type: CardType.fromId(map['type'] as int),
      quantity: (map['quantity'] as int?) ?? 1,
    );
  }
}
