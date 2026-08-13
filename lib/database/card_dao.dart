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
        dc.quantity
      FROM cards c
      INNER JOIN deck_cards dc
        ON dc.card_id = c.id
      WHERE dc.deck_id = ?
      ORDER BY c.title COLLATE NOCASE
    ''', [deckId]);

    return maps.map(GwentCard.fromMap).toList();
  }

  Future<GwentCard> insert({
    required int deckId,
    required GwentCard card,
  }) async {
    final db = await _database.database;

    return db.transaction((txn) async {
      final cardId = await txn.insert(
        'cards',
        card.toMap(),
      );

      await txn.insert(
        'deck_cards',
        {
          'deck_id': deckId,
          'card_id': cardId,
          'quantity': card.quantity,
        },
      );

      return GwentCard(
        id: cardId,
        title: card.title,
        power: card.power,
        quantity: card.quantity,
      );
    });
  }

  Future<void> deleteFromDeck({
    required int deckId,
    required int cardId,
  }) async {
    final db = await _database.database;

    await db.transaction((txn) async {
      await txn.delete(
        'deck_cards',
        where: 'deck_id = ? AND card_id = ?',
        whereArgs: [deckId, cardId],
      );

      await txn.delete(
        'cards',
        where: 'id = ?',
        whereArgs: [cardId],
      );
    });
  }
}
