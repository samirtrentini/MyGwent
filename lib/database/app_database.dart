import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _databaseName = 'gwent_decks.db';
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();

    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();

    final path = join(
      databasesPath,
      _databaseName,
    );

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE decks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
          CHECK(length(name) BETWEEN 1 AND 50),
        faction INTEGER NOT NULL,
        description TEXT
          CHECK(description IS NULL OR length(description) <= 500)
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL
          CHECK(length(title) BETWEEN 1 AND 100)
          UNIQUE,
        power INTEGER,
        type INTEGER NOT NULL DEFAULT 0
          CHECK(type IN (0, 1, 2))
      )
    ''');

    await db.execute('''
      CREATE TABLE deck_cards (
        deck_id INTEGER NOT NULL,
        card_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1
          CHECK(quantity > 0),

        PRIMARY KEY (deck_id, card_id),

        FOREIGN KEY (deck_id)
          REFERENCES decks(id)
          ON DELETE CASCADE,

        FOREIGN KEY (card_id)
          REFERENCES cards(id)
          ON DELETE CASCADE
      )
    ''');
  }

  /// Use temporariamente durante o desenvolvimento quando o schema mudar.
  /// Isso apaga o banco local.
  Future<void> resetDatabase() async {
    final databasesPath = await getDatabasesPath();

    final path = join(
      databasesPath,
      _databaseName,
    );

    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    await deleteDatabase(path);
  }
}
