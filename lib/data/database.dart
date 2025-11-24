import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  Database? _db;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), "prestamos_simple.db");

    return await openDatabase(
      path,
      version: 3, // súbelo a 3 para forzar migración
      onCreate: (db, version) async {
        await db.execute('''
      CREATE TABLE personas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

        await db.execute('''
      CREATE TABLE movimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        personaId INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        monto REAL NOT NULL,
        descripcion TEXT,
        fecha TEXT NOT NULL,
        FOREIGN KEY (personaId) REFERENCES personas(id) ON DELETE CASCADE
      )
    ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        // ⚠️ SOLO PARA DESARROLLO: limpia todo
        await db.execute('DROP TABLE IF EXISTS movimientos');
        await db.execute('DROP TABLE IF EXISTS personas');

        // recrea
        await db.execute('''
      CREATE TABLE personas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

        await db.execute('''
      CREATE TABLE movimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        personaId INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        monto REAL NOT NULL,
        descripcion TEXT,
        fecha TEXT NOT NULL,
        FOREIGN KEY (personaId) REFERENCES personas(id) ON DELETE CASCADE
      )
    ''');
      },
    );
  }
}
