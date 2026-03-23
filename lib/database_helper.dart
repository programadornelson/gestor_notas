import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        materia TEXT,
        actividad TEXT,
        nota TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  // INSERTAR
  Future insertNota(Map<String, dynamic> nota) async {
    final db = await instance.database;
    return await db.insert('notas', nota);
  }

  // OBTENER
  Future<List<Map<String, dynamic>>> getNotas() async {
    final db = await instance.database;
    return await db.query('notas');
  }

  // ACTUALIZAR
  Future updateNota(int id, String nota) async {
    final db = await instance.database;
    return await db.update(
      'notas',
      {'nota': nota, 'synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ELIMINAR
  Future deleteNota(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // NOTAS NO SINCRONIZADAS
  Future<List<Map<String, dynamic>>> getNotasNoSync() async {
    final db = await instance.database;
    return await db.query(
      'notas',
      where: 'synced = 0',
    );
  }

  // MARCAR COMO SINCRONIZADO
  Future marcarComoSync(int id) async {
    final db = await instance.database;
    return await db.update(
      'notas',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}