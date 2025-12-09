import 'package:asistencia_vial_app/src/models/boveda.dart';
import 'package:hive/hive.dart';

class BovedaProviderOffline {
  final Box<Boveda> _box=Hive.box<Boveda>('boveda');

  Future<void> clearBoveda()async{
    final box = await Hive.openBox('boveda');
    await box.clear();
  }

  Future<Boveda?> getAll(String idPeaje) async {
    try {
      // Buscar la bóveda con el idPeaje especificado
      return _box.values.firstWhere(
        (b) => b.idpeaje == idPeaje,
        orElse: () => throw StateError('No boveda found'), // Esto permitirá que el catch maneje el error
      );
    } catch (e) {
      // Si no encuentra la bóveda, retornar null
      print('No se encontró bóveda para el peaje: $idPeaje');
      return null;
    }
  }

  Future<void> saveBoveda(Boveda boveda) async{
    await _box.put(boveda.id, boveda);
  }

}