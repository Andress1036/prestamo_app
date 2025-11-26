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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // COLORES ADAPTADOS A MODO OSCURO
    final totalBg = isDark ? Colors.grey.shade800 : Colors.black12;
    final textLight = isDark ? Colors.white : Colors.black;
    final fechaColor = isDark ? Colors.grey[300] : Colors.grey.shade700;

    return Scaffold(
      appBar: AppBar(title: Text('Movimientos de ${widget.personaName}')),

      // ------------------------------
      // BOTTOM BAR REDONDEADO
      // ------------------------------
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          height: 70,
          color: isDark
              ? Colors.grey.shade900
              : const Color.fromARGB(255, 238, 223, 223),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _openAddDialog(context, tipo: 'prestamo'),
                icon: const Icon(Icons.add),
                label: const Text('Préstamo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openAddDialog(context, tipo: 'abono'),
                icon: const Icon(Icons.remove),
                label: const Text('Abono'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ------------------------------
      // LISTA + TOTAL
      // ------------------------------
      body: c.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // TOTAL
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: totalBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total actual: \$${formatter.format(c.total)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textLight,
                    ),
                  ),
                ),

                // LISTA
                Expanded(
                  child: c.movimientos.isEmpty
                      ? const Center(child: Text('No hay movimientos'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: c.movimientos.length,
                          itemBuilder: (_, i) {
                            final Movimiento m = c.movimientos[i];
                            final isPrestamo = m.tipo == "prestamo";

                            // Colores según tipo, ajustados a tema oscuro
                            final bgColor = isDark
                                ? (isPrestamo
                                    ? Colors.red.withOpacity(0.15)
                                    : Colors.green.withOpacity(0.15))
                                : (isPrestamo
                                    ? const Color.fromARGB(255, 255, 241, 241)
                                    : const Color.fromARGB(255, 243, 254, 242));

                            return Card(
                              elevation: isDark ? 0 : 2,
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
                                      color:
                                          isPrestamo ? Colors.red : Colors.green,
                                      size: 24,
                                    ),

                                    const SizedBox(width: 10),

                                    // TEXTO
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
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
                                                  color: fechaColor,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 3),

                                          Text(
                                            m.descripcion,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textLight,
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
                                          icon: Icon(
                                            Icons.delete,
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black54,
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

  // ------------------------------
  // DIALOGS
  // ------------------------------

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
