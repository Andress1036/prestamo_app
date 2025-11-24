import 'package:sqflite/sqflite.dart';
import '../data/database.dart';
import '../data/persona.dart';

class PersonaRepository {
  Future<int> insertPersona(Persona p) async {
    final db = await AppDatabase.instance.database;
    return await db.insert('personas', p.toMap());
  }

  Future<List<Persona>> findAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('personas', orderBy: 'nombre ASC');
    return rows.map((r) => Persona.fromMap(r)).toList();
  }

  Future<void> deletePersona(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('personas', where: 'id = ?', whereArgs: [id]);
  }
}
