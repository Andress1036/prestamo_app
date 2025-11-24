class Movimiento {
  int? id;
  int personaId;
  String tipo; // "prestamo" or "abono"
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
      id: map['id'] as int?,
      personaId: map['personaId'] as int,
      tipo: map['tipo'] as String,
      monto: (map['monto'] as num).toDouble(),
      descripcion: map['descripcion'] as String? ?? '',
      fecha: DateTime.parse(map['fecha'] as String),
    );
  }
}
