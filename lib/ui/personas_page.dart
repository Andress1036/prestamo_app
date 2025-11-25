import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/persona_controller.dart';
import '../controllers/movimiento_controller.dart';
import 'movimientos_page.dart';

class PersonasPage extends StatefulWidget {
  const PersonasPage({super.key});

  @override
  State<PersonasPage> createState() => _PersonasPageState();
}

class _PersonasPageState extends State<PersonasPage> {
  final nombreCtrl = TextEditingController();
  final formatter = NumberFormat('#,##0.00', 'es_CO');

  @override
  void initState() {
    super.initState();
    // cargar personas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PersonaController>(context, listen: false).loadPersonas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final personaCtrl = Provider.of<PersonaController>(context);
    // movimiento controller será usado para calcular total al presionar la persona
    return Scaffold(
      appBar: AppBar(title: const Text('Prestamos a:')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPersonaDialog(context),
        child: const Icon(Icons.add),
      ),
      body: personaCtrl.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: personaCtrl.personas.length,
              itemBuilder: (_, i) {
                final p = personaCtrl.personas[i];
                return ListTile(
                  title: Text(p.nombre),
                  leading: CircleAvatar(child: Text(p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?')),
                  onTap: () async {
                    // cuando se abre la página de movimientos, esta cargará sus datos
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider(create: (_) => MovimientoController()),
                          ],
                          child: MovimientosPage(personaId: p.id!, personaName: p.nombre),
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Eliminar persona'),
                          content: Text('¿Eliminar a ${p.nombre}? Se eliminarán sus movimientos.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await Provider.of<PersonaController>(context, listen: false).deletePersona(p.id!);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final name = nombreCtrl.text.trim();
              if (name.isEmpty) return;
              await Provider.of<PersonaController>(context, listen: false).addPersona(name[0].toUpperCase() + name.substring(1));
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
