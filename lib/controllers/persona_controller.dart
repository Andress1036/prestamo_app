import 'package:flutter/material.dart';
import '../data/persona.dart';
import '../repository/persona_repository.dart';

class PersonaController extends ChangeNotifier {
  final PersonaRepository _repo = PersonaRepository();

  List<Persona> personas = [];
  bool loading = false;

  Future<void> loadPersonas() async {
    loading = true;
    notifyListeners();
    personas = await _repo.findAll();
    loading = false;
    notifyListeners();
  }

  Future<void> addPersona(String nombre) async {
    if (nombre.trim().isEmpty) return;
    await _repo.insertPersona(Persona(nombre: nombre.trim()));
    await loadPersonas();
  }

  Future<void> deletePersona(int id) async {
    await _repo.deletePersona(id);
    await loadPersonas();
  }
}
