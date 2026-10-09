import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bible_v1.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dbDirectory.path, fileName);

    // Check if the database exists in the app data folder
    final exists = await databaseExists(dbPath);

    if (!exists) {
      if (kDebugMode) {
        print('Database does not exist at $dbPath. Copying bundled assets/database/bible.db...');
      }

      // Ensure directory exists
      try {
        await Directory(p.dirname(dbPath)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      final ByteData data = await rootBundle.load('assets/database/bible.db');
      final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes, flush: true);

      if (kDebugMode) {
        print('Database successfully deployed to $dbPath (${bytes.length} bytes)');
      }
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onOpen: (db) async {
        // Ensure user tables exist
        await db.execute('''
          CREATE TABLE IF NOT EXISTS bookmarks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id INTEGER,
            chapter INTEGER,
            verse INTEGER,
            translation_code TEXT,
            created_at TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS highlights (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id INTEGER,
            chapter INTEGER,
            verse INTEGER,
            color_hex TEXT,
            created_at TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id INTEGER,
            chapter INTEGER,
            verse INTEGER,
            note_text TEXT,
            updated_at TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS reading_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id INTEGER,
            chapter INTEGER,
            verse INTEGER,
            read_at TEXT
          );
        ''');
      },
    );
  }
}
