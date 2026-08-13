enum Faction {
  northernRealms(0),
  nilfgaard(1),
  scoiatael(2),
  monsters(3),
  skellige(4);

  const Faction(this.id);

  final int id;

  static Faction fromId(int id) {
    return Faction.values.firstWhere(
          (faction) => faction.id == id,
    );
  }

  String get label {
    switch (this) {
      case Faction.northernRealms:
        return 'Northern Realms';

      case Faction.nilfgaard:
        return 'Nilfgaard';

      case Faction.scoiatael:
        return "Scoia'tael";

      case Faction.monsters:
        return 'Monsters';

      case Faction.skellige:
        return 'Skellige';
    }
  }
}
