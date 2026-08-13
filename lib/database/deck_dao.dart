import 'package:sqflite/sqflite.dart';
import '../data/initial_decks.dart';
import '../models/deck.model.dart';
import 'app_database.dart';

class DeckDao {
  DeckDao({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Deck>> getAll() async {
    final db = await _database.database;

    final maps = await db.query(
      'decks',
      orderBy: 'id DESC',
    );

    return maps.map(Deck.fromMap).toList();
  }

  Future<Deck> create(Deck deck) async {
    final db = await _database.database;

    return db.transaction((txn) async {
      final deckId = await txn.insert(
        'decks',
        deck.toMap(),
      );

      final initialCards = initialDeckCards[deck.faction] ?? [];

      for (final initialCard in initialCards) {
        final cardId = await _getOrCreateCard(
          txn,
          initialCard,
        );

        await txn.insert(
          'deck_cards',
          {
            'deck_id': deckId,
            'card_id': cardId,
            'quantity': initialCard.quantity,
          },
        );
      }

      return Deck(
        id: deckId,
        name: deck.name,
        faction: deck.faction,
        description: deck.description,
      );
    });
  }

  Future<int> _getOrCreateCard(
      Transaction txn,
      InitialDeckCard initialCard,
      ) async {
    final existing = await txn.query(
      'cards',
      columns: ['id'],
      where: 'title = ?',
      whereArgs: [initialCard.title],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }

    return txn.insert(
      'cards',
      {
        'title': initialCard.title,
        'power': initialCard.power,
        'type': initialCard.type.index,
      },
    );
  }

  Future<void> update(Deck deck) async {
    if (deck.id == null) {
      throw ArgumentError(
        'Deck must have an id to be updated.',
      );
    }

    final db = await _database.database;

    await db.update(
      'decks',
      deck.toMap(),
      where: 'id = ?',
      whereArgs: [deck.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _database.database;

    await db.delete(
      'decks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Deck?> getById(int id) async {
    final db = await _database.database;

    final maps = await db.query(
      'decks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Deck.fromMap(maps.first);
  }
}
