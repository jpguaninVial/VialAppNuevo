import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/sync_service.dart';
import '../helper/connection_helper.dart';

class ImprovedConnectionController extends GetxController {
  static ImprovedConnectionController get to => Get.find();

  final isOffline = true.obs; // Iniciar como offline por seguridad
  final connectionStable = false.obs;
  final lastConnectionCheck = DateTime.now().obs;
  final isCheckingConnection =
      true.obs; // Nueva variable para saber si está verificando

  Timer? _connectionTimer;
  int _consecutiveSuccesses = 0;
  int _consecutiveFailures = 0;

  static const int REQUIRED_STABLE_CONNECTIONS = 2; // Reducido de 3 a 2
  static const int CONNECTION_CHECK_INTERVAL =
      10; // Reducido de 15 a 10 segundos

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
    // Verificación inicial inmediata
    checkConnection();

    // Segunda verificación rápida después de 2 segundos
    Future.delayed(Duration(seconds: 2), () {
      if (!isClosed) checkConnection();
    });

    // Verificaciones periódicas
    _connectionTimer = Timer.periodic(
        Duration(seconds: CONNECTION_CHECK_INTERVAL), (_) => checkConnection());
  }

  Future<void> checkConnection() async {
    try {
      isCheckingConnection.value = true;
      lastConnectionCheck.value = DateTime.now();

      // Timeout optimizado para respuesta más rápida
      final connected =
          await isConnectedToServer().timeout(Duration(seconds: 5));

      if (connected) {
        _consecutiveSuccesses++;
        _consecutiveFailures = 0;

        // Requerir múltiples conexiones exitosas para considerar estable
        if (_consecutiveSuccesses >= REQUIRED_STABLE_CONNECTIONS) {
          if (isOffline.value) {
            // Cambio de offline a online
            isOffline.value = false;
            connectionStable.value = true;

            Fluttertoast.showToast(
              msg: 'Conexión Restaurada - Sincronizando...',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
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

            Fluttertoast.showToast(
              msg: 'Conexión Perdida - Modo offline',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.orange,
              textColor: Colors.white,
              fontSize: 16.0,
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
    } finally {
      isCheckingConnection.value = false;
    }
  }

  /// Forzar verificación manual de conexión
  Future<bool> forceConnectionCheck() async {
    try {
      final connected =
          await isConnectedToServer().timeout(Duration(seconds: 15));

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
