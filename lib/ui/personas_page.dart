
import 'package:flutter/material.dart';
import 'movimientos_page.dart';

class PersonasPage extends StatelessWidget {
  final List<Map<String, dynamic>> personas = [
    {"id": 1, "nombre": "Juan"},
    {"id": 2, "nombre": "Maria"},
    {"id": 3, "nombre": "Carlos"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Personas")),
      body: ListView.builder(
        itemCount: personas.length,
        itemBuilder: (_, i) {
          final p = personas[i];

          return ListTile(
            title: Text(p["nombre"]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovimientosPage(
                    personaId: p["id"],
                    personaName: p["nombre"],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
