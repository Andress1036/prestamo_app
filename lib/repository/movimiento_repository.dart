import 'package:sqflite/sqflite.dart';
import '../data/database.dart';
import '../data/movimiento.dart';

class MovimientoRepository {
  Future<void> insertMovimiento(Movimiento movimiento) async {
    final db = await AppDatabase.instance.database;
    await db.insert('movimientos', movimiento.toMap());
  }

  Future<List<Movimiento>> findByPersona(int personaId) async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      'movimientos',
      where: 'personaId = ?',
      whereArgs: [personaId],
      orderBy: 'fecha DESC',
    );

    return result.map((m) => Movimiento.fromMap(m)).toList();
  }

  Future<double> calcularTotal(int personaId) async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN tipo = 'prestamo' THEN monto ELSE 0 END) -
        SUM(CASE WHEN tipo = 'abono' THEN monto ELSE 0 END)
      AS total
      FROM movimientos
      WHERE personaId = ?
    ''', [personaId]);

    final totalValue = result.first['total'] as num?;
    return (totalValue ?? 0).toDouble();
  }

  Future<void> updateMonto(int id, double nuevoMonto) async {
    final db = await AppDatabase.instance.database;
    await db.update('movimientos', {'monto': nuevoMonto},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteMovimiento(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('movimientos', where: 'id = ?', whereArgs: [id]);
  }
}
