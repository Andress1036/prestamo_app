class Movimiento {
  int? id;
  int personaId;
  String tipo; // "prestamo" o "abono"
  double monto;
  String descripcion;
  DateTime fecha;

  Movimiento({
    this.id,
    required this.personaId,
    required this.tipo,
    required this.monto,
    required this.descripcion,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personaId': personaId,
      'tipo': tipo,
      'monto': monto,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id'],
      personaId: map['personaId'],
      tipo: map['tipo'],
      monto: map['monto'],
      descripcion: map['descripcion'],
      fecha: DateTime.parse(map['fecha']),
    );
  }
}
