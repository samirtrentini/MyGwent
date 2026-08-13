class GwentCard {
  const GwentCard({
    this.id,
    required this.title,
    this.power,
    required this.quantity,
  });

  final int? id;
  final String title;
  final int? power;
  final int quantity;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'power': power,
    };
  }

  factory GwentCard.fromMap(Map<String, Object?> map) {
    return GwentCard(
      id: map['id'] as int?,
      title: map['title'] as String,
      power: map['power'] as int?,
      quantity: map['quantity'] as int? ?? 1,
    );
  }
}
