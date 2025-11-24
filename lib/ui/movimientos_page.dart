
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/movimiento_controller.dart';
import '../data/movimiento.dart';

class MovimientosPage extends StatefulWidget {
  final int personaId;
  final String personaName;

  const MovimientosPage({
    super.key,
    required this.personaId,
    required this.personaName,
  });

  @override
  State<MovimientosPage> createState() => _MovimientosPageState();
}

class _MovimientosPageState extends State<MovimientosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovimientoController>(context, listen: false)
          .cargarMovimientos(widget.personaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Provider.of<MovimientoController>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Movimientos de ${widget.personaName}")),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "prestamo",
            onPressed: () => _agregarMovimiento(context, tipo: "prestamo"),
            label: Text("Préstamo"),
            icon: Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "abono",
            onPressed: () => _agregarMovimiento(context, tipo: "abono"),
            label: Text("Abono"),
            icon: Icon(Icons.remove),
          ),
        ],
      ),
      body: c.loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  color: Colors.black12,
                  child: Text(
                    "Total actual: \$${c.total.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: c.movimientos.length,
                    itemBuilder: (_, i) {
                      final m = c.movimientos[i];

                      return ListTile(
                        title: Text(
                          "${m.tipo == 'prestamo' ? '+' : '-'} \$${m.monto}",
                          style: TextStyle(
                            color: m.tipo == 'prestamo'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(m.descripcion),
                        trailing: Text(
                          "${m.fecha.day}/${m.fecha.month}/${m.fecha.year}",
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _agregarMovimiento(BuildContext context, {required String tipo}) {
    final montoCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(tipo == "prestamo" ? "Nuevo préstamo" : "Nuevo abono"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: montoCtrl,
                decoration: InputDecoration(labelText: "Monto"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descCtrl,
                decoration: InputDecoration(labelText: "Descripción"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
            ElevatedButton(
              child: Text("Guardar"),
              onPressed: () async {
                final monto = double.tryParse(montoCtrl.text);
                if (monto == null) return;

                final c = Provider.of<MovimientoController>(context, listen: false);

                if (tipo == "prestamo") {
                  await c.agregarPrestamo(widget.personaId, monto, descCtrl.text);
                } else {
                  await c.agregarAbono(widget.personaId, monto, descCtrl.text);
                }

                if (!mounted) return;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
