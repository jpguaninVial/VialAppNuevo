import 'dart:async';
import 'package:asistencia_vial_app/src/provider/turno_provider.dart';
import 'package:get/get.dart';

import '../provider/movimiento_provider.dart';
import '../controllers/improved_connection_controller.dart';
import 'connection_helper.dart';

class ConnectionController extends GetxController {
  // Proxy del ImprovedConnectionController
  var isOffline = false.obs;
  Timer? _timer;
  MovimientoProvider movimientoProvider=MovimientoProvider();
  TurnoProvider turnoProvider=TurnoProvider();

  @override
  void onInit() {
    super.onInit();
    
    // Sincronizar con el ImprovedConnectionController
    _syncWithImprovedController();
    
    // Mantener sincronización cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncWithImprovedController();
    });
  }

  void _syncWithImprovedController() {
    try {
      // Obtener el estado del ImprovedConnectionController
      final improved = ImprovedConnectionController.to;
      isOffline.value = improved.isOffline.value;
    } catch (e) {
      // Si no está disponible, usar verificación directa
      checkConnection();
    }
  }

  Future<void> checkConnection() async {
    try {
      final connected = await isConnectedToServer();
      isOffline.value = !connected;
    } catch (e) {
      isOffline.value = true;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
