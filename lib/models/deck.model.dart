import 'package:my_gwent/enums/faction.enum.dart';

class Deck {
  const Deck({
    this.id,
    required this.name,
    required this.faction,
    this.description,
  });

  final int? id;
  final String name;
  final Faction faction;
  final String? description;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'faction': faction.id,
      'description': description,
    };
  }

  factory Deck.fromMap(Map<String, Object?> map) {
    return Deck(
      id: map['id'] as int?,
      name: map['name'] as String,
      faction: Faction.fromId(map['faction'] as int),
      description: map['description'] as String?,
    );
  }
}
