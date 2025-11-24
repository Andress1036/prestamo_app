import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/persona_controller.dart';
import 'controllers/movimiento_controller.dart';
import 'ui/personas_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PersonaController()),
        // MovimientoController se crea cuando se abre la página de movimientos (para aislar estado)
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prestamo Simple',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const PersonasPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
