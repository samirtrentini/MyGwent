import 'package:sqflite/sqflite.dart';

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

  Future<Deck> insert(Deck deck) async {
    final db = await _database.database;

    final id = await db.insert(
      'decks',
      deck.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return Deck(
      id: id,
      name: deck.name,
      faction: deck.faction,
      description: deck.description,
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
      conflictAlgorithm: ConflictAlgorithm.abort,
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
