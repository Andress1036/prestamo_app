import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
  final formatter = NumberFormat('#,##0.00', 'es_CO');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovimientoController>(
        context,
        listen: false,
      ).cargarMovimientos(widget.personaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Provider.of<MovimientoController>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Movimientos de ${widget.personaName}')),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'prestamo',
            onPressed: () => _openAddDialog(context, tipo: 'prestamo'),
            label: const Text('Préstamo'),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'abono',
            onPressed: () => _openAddDialog(context, tipo: 'abono'),
            label: const Text('Abono'),
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
      body: c.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.black12,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Total actual: \$${formatter.format(c.total)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: c.movimientos.isEmpty
                      ? const Center(child: Text('No hay movimientos'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: c.movimientos.length,
                          itemBuilder: (_, i) {
                            final Movimiento m = c.movimientos[i];

                            final isPrestamo = m.tipo == "prestamo";
                            final bgColor = isPrestamo
                                ? Colors.red.shade100
                                : Colors.green.shade100;

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: bgColor,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isPrestamo
                                          ? Icons.call_made
                                          : Icons.call_received,
                                      color: isPrestamo
                                          ? Colors.red
                                          : Colors.green,
                                      size: 24,
                                    ),

                                    const SizedBox(width: 10),

                                    // TEXTO PRINCIPAL (monto + descripción)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // MONTO + FECHA EN LA MISMA LÍNEA
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${isPrestamo ? "+" : "-"} \$${formatter.format(m.monto)}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: isPrestamo
                                                      ? Colors.red
                                                      : Colors.green,
                                                ),
                                              ),
                                              Text(
                                                '${m.fecha.day}/${m.fecha.month}/${m.fecha.year}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 3),

                                          Text(
                                            m.descripcion,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // BOTONES
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          iconSize: 20,
                                          onPressed: () =>
                                              _openEditDialog(context, m),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.black54,
                                          ),
                                          iconSize: 20,
                                          onPressed: () =>
                                              _confirmDelete(context, m),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void _openAddDialog(BuildContext context, {required String tipo}) {
    final montoCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(tipo == 'prestamo' ? 'Nuevo préstamo' : 'Nuevo abono'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: montoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final monto = double.tryParse(montoCtrl.text.trim());
                if (monto == null || monto <= 0) return;

                final controller = Provider.of<MovimientoController>(
                  context,
                  listen: false,
                );

                if (tipo == 'prestamo') {
                  await controller.agregarPrestamo(
                    widget.personaId,
                    monto,
                    descCtrl.text,
                  );
                } else {
                  await controller.agregarAbono(
                    widget.personaId,
                    monto,
                    descCtrl.text,
                  );
                }

                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _openEditDialog(BuildContext context, Movimiento m) {
    final montoCtrl = TextEditingController(text: m.monto.toString());
    final descCtrl = TextEditingController(text: m.descripcion);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Editar ${m.tipo}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: montoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto'),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nuevoMonto = double.tryParse(montoCtrl.text.trim());
                if (nuevoMonto == null || nuevoMonto <= 0) return;

                final controller = Provider.of<MovimientoController>(
                  context,
                  listen: false,
                );
                await controller.editarMonto(
                  m.id!,
                  nuevoMonto,
                  widget.personaId,
                );

                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Movimiento m) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: const Text('¿Eliminar este movimiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final controller = Provider.of<MovimientoController>(
        context,
        listen: false,
      );
      await controller.borrarMovimiento(m.id!, widget.personaId);
    }
  }
}
