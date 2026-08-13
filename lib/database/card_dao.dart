import 'package:my_gwent/models/card.model.dart';
import 'app_database.dart';

class CardDao {
  CardDao({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<GwentCard>> getByDeckId(int deckId) async {
    final db = await _database.database;

    final maps = await db.rawQuery('''
      SELECT
        c.id,
        c.title,
        c.power,
        c.type,
        dc.quantity
      FROM cards c
      INNER JOIN deck_cards dc
        ON dc.card_id = c.id
      WHERE dc.deck_id = ?
      ORDER BY c.title COLLATE NOCASE
    ''', [deckId]);

    return maps.map(GwentCard.fromMap).toList();
  }

  Future<int> _getOrCreateCard(
      dynamic txn,
      GwentCard card,
      ) async {
    final existing = await txn.rawQuery(
      'SELECT id FROM cards WHERE title = ? COLLATE NOCASE',
      [card.title],
    );

    if (existing.isNotEmpty) {
      final existingId = existing.first['id'] as int;

      await txn.update(
        'cards',
        {
          'power': card.power,
          'type': card.type.id,
        },
        where: 'id = ?',
        whereArgs: [existingId],
      );

      return existingId;
    }

    return txn.insert('cards', card.toMap());
  }

  Future<GwentCard> insert({
    required int deckId,
    required GwentCard card,
  }) async {
    final db = await _database.database;

    return db.transaction((txn) async {
      final cardId = await _getOrCreateCard(txn, card);

      await txn.rawInsert('''
        INSERT INTO deck_cards (deck_id, card_id, quantity)
        VALUES (?, ?, ?)
        ON CONFLICT(deck_id, card_id)
        DO UPDATE SET quantity = excluded.quantity
      ''', [deckId, cardId, card.quantity]);

      return GwentCard(
        id: cardId,
        title: card.title,
        power: card.power,
        type: card.type,
        quantity: card.quantity,
      );
    });
  }

  Future<void> updateQuantity({
    required int deckId,
    required int cardId,
    required int quantity,
  }) async {
    final db = await _database.database;

    await db.update(
      'deck_cards',
      {'quantity': quantity},
      where: 'deck_id = ? AND card_id = ?',
      whereArgs: [deckId, cardId],
    );
  }

  Future<void> deleteFromDeck({
    required int deckId,
    required int cardId,
  }) async {
    final db = await _database.database;

    await db.delete(
      'deck_cards',
      where: 'deck_id = ? AND card_id = ?',
      whereArgs: [deckId, cardId],
    );
  }
}
