import 'package:flutter/material.dart';
import '../data/movimiento.dart';
import '../repository/movimiento_repository.dart';

class MovimientoController extends ChangeNotifier {
  final MovimientoRepository _repo = MovimientoRepository();

  List<Movimiento> movimientos = [];
  double total = 0.0;
  bool loading = false;

  Future<void> cargarMovimientos(int personaId) async {
    loading = true;
    notifyListeners();

    movimientos = await _repo.findByPersona(personaId);
    total = await _repo.calcularTotal(personaId);

    loading = false;
    notifyListeners();
  }

  Future<void> agregarPrestamo(int personaId, double monto, String descripcion) async {
    final movimiento = Movimiento(
      personaId: personaId,
      tipo: 'prestamo',
      monto: monto,
      descripcion: descripcion,
      fecha: DateTime.now(),
    );
    await _repo.insertMovimiento(movimiento);
    await cargarMovimientos(personaId);
  }

  Future<void> agregarAbono(int personaId, double monto, String descripcion) async {
    final movimiento = Movimiento(
      personaId: personaId,
      tipo: 'abono',
      monto: monto,
      descripcion: descripcion,
      fecha: DateTime.now(),
    );
    await _repo.insertMovimiento(movimiento);
    await cargarMovimientos(personaId);
  }

  Future<void> editarMonto(int id, double nuevoMonto, int personaId) async {
    await _repo.updateMonto(id, nuevoMonto);
    await cargarMovimientos(personaId);
  }

  Future<void> borrarMovimiento(int id, int personaId) async {
    await _repo.deleteMovimiento(id);
    await cargarMovimientos(personaId);
  }
}
