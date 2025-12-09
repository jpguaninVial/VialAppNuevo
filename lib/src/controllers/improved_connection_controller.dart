import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import '../helper/connection_helper.dart';

class ImprovedConnectionController extends GetxController {
  static ImprovedConnectionController get to => Get.find();
  
  final isOffline = true.obs; // Iniciar como offline por seguridad
  final connectionStable = false.obs;
  final lastConnectionCheck = DateTime.now().obs;
  
  Timer? _connectionTimer;
  int _consecutiveSuccesses = 0;
  int _consecutiveFailures = 0;
  
  static const int REQUIRED_STABLE_CONNECTIONS = 3;
  static const int CONNECTION_CHECK_INTERVAL = 15; // segundos
  
  @override
  void onInit() {
    super.onInit();
    _startConnectionMonitoring();
  }
  
  @override
  void onClose() {
    _connectionTimer?.cancel();
    super.onClose();
  }
  
  void _startConnectionMonitoring() {
    // Verificación inicial
    checkConnection();
    
    // Verificaciones periódicas
    _connectionTimer = Timer.periodic(
      Duration(seconds: CONNECTION_CHECK_INTERVAL),
      (_) => checkConnection()
    );
  }
  
  Future<void> checkConnection() async {
    try {
      lastConnectionCheck.value = DateTime.now();
      
      // Timeout más generoso para conexiones lentas
      final connected = await isConnectedToServer()
          .timeout(Duration(seconds: 10));
      
      if (connected) {
        _consecutiveSuccesses++;
        _consecutiveFailures = 0;
        
        // Requerir múltiples conexiones exitosas para considerar estable
        if (_consecutiveSuccesses >= REQUIRED_STABLE_CONNECTIONS) {
          if (isOffline.value) {
            // Cambio de offline a online
            isOffline.value = false;
            connectionStable.value = true;
            
            Get.snackbar(
              'Conexión Restaurada',
              'Sincronizando transacciones pendientes...',
              icon: Icon(Icons.wifi, color: Colors.white),
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
            );
            
            // Trigger sincronización después de un breve delay
            Future.delayed(Duration(seconds: 1), () {
              SyncService.to.performFullSync();
            });
          }
        }
      } else {
        _consecutiveFailures++;
        _consecutiveSuccesses = 0;
        
        if (_consecutiveFailures >= 2) {
          if (!isOffline.value) {
            // Cambio de online a offline
            isOffline.value = true;
            connectionStable.value = false;
            
            Get.snackbar(
              'Conexión Perdida',
              'Trabajando en modo offline',
              icon: Icon(Icons.wifi_off, color: Colors.white),
              backgroundColor: Colors.orange[800],
              colorText: Colors.white,
              duration: Duration(seconds: 3),
            );
          }
        }
      }
      
    } catch (e) {
      _consecutiveFailures++;
      _consecutiveSuccesses = 0;
      
      if (!isOffline.value && _consecutiveFailures >= 2) {
        isOffline.value = true;
        connectionStable.value = false;
      }
    }
  }
  
  /// Forzar verificación manual de conexión
  Future<bool> forceConnectionCheck() async {
    try {
      final connected = await isConnectedToServer()
          .timeout(Duration(seconds: 15));
      
      if (connected != !isOffline.value) {
        // Estado cambió
        if (connected) {
          _consecutiveSuccesses = REQUIRED_STABLE_CONNECTIONS;
          _consecutiveFailures = 0;
          isOffline.value = false;
          connectionStable.value = true;
        } else {
          _consecutiveFailures = 2;
          _consecutiveSuccesses = 0;
          isOffline.value = true;
          connectionStable.value = false;
        }
      }
      
      return connected;
    } catch (e) {
      return false;
    }
  }
}
