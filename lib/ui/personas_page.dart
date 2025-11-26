import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/persona_controller.dart';
import '../controllers/movimiento_controller.dart';
import 'movimientos_page.dart';

class PersonasPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const PersonasPage({super.key, required this.onToggleTheme});

  @override
  State<PersonasPage> createState() => _PersonasPageState();
}

class _PersonasPageState extends State<PersonasPage> {
  final nombreCtrl = TextEditingController();
  final formatter = NumberFormat('#,##0.00', 'es_CO');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PersonaController>(context, listen: false).loadPersonas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final personaCtrl = Provider.of<PersonaController>(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Préstamos a:'),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),

      // -------------------------
      // BOTTOM BAR REDONDEADO
      // -------------------------
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomAppBar(
          height: 65,
          color: isDark
              ? Colors.grey.shade900
              : const Color.fromARGB(255, 244, 235, 235),
          child: Center(
            child: ElevatedButton.icon(
              onPressed: () => _showAddPersonaDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Agregar Persona'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),

      // -------------------------
      // LISTA DE PERSONAS
      // -------------------------
      body: personaCtrl.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: personaCtrl.personas.length,
              itemBuilder: (_, i) {
                final p = personaCtrl.personas[i];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    title: Text(
                      p.nombre,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                          isDark ? Colors.blueGrey : Colors.blue.shade200,
                      child: Text(
                        p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiProvider(
                            providers: [
                              ChangeNotifierProvider(
                                  create: (_) => MovimientoController()),
                            ],
                            child: MovimientosPage(
                                personaId: p.id!, personaName: p.nombre),
                          ),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.red, size: 26),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Eliminar persona'),
                            content: Text(
                                '¿Eliminar a ${p.nombre}? Se eliminarán sus movimientos.'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await Provider.of<PersonaController>(context,
                                  listen: false)
                              .deletePersona(p.id!);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ---------------------------------------
  // DIALOG PARA AGREGAR PERSONA
  // ---------------------------------------
  void _showAddPersonaDialog(BuildContext context) {
    nombreCtrl.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva persona'),
        content: TextField(
          controller: nombreCtrl,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final name = nombreCtrl.text.trim();
              if (name.isEmpty) return;
              await Provider.of<PersonaController>(context, listen: false)
                  .addPersona(name[0].toUpperCase() + name.substring(1));
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
