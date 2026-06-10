import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/sync_service.dart';
import '../helper/connection_helper.dart';

class ImprovedConnectionController extends GetxController {
  static ImprovedConnectionController get to => Get.find();

  final isOffline = true.obs;
  final connectionStable = false.obs;
  final lastConnectionCheck = DateTime.now().obs;
  final isCheckingConnection = true.obs;
  final lastConnectionStatus = ConnectionStatus.noInternet.obs;

  Timer? _connectionTimer;
  StreamSubscription? _connectivitySubscription;
  int _consecutiveSuccesses = 0;
  int _consecutiveFailures = 0;

  static const int REQUIRED_STABLE_CONNECTIONS = 2;
  static const int CONNECTION_CHECK_INTERVAL = 10;

  @override
  void onInit() {
    super.onInit();
    _startConnectionMonitoring();
    _listenToConnectivityChanges();
  }

  @override
  void onClose() {
    _connectionTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  /// React instantly when the OS reports a network change.
  void _listenToConnectivityChanges() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (results.every((r) => r == ConnectivityResult.none)) {
        // No network interface at all — go offline immediately.
        _consecutiveFailures = 2;
        _consecutiveSuccesses = 0;
        if (!isOffline.value) {
          isOffline.value = true;
          connectionStable.value = false;
          lastConnectionStatus.value = ConnectionStatus.noInternet;
          _showToast('Sin Internet - Modo offline', Colors.orange);
        }
      } else {
        // Network came back — verify server reachability right away.
        checkConnection();
      }
    });
  }

  void _startConnectionMonitoring() {
    checkConnection();

    Future.delayed(Duration(seconds: 2), () {
      if (!isClosed) checkConnection();
    });

    _connectionTimer = Timer.periodic(
        Duration(seconds: CONNECTION_CHECK_INTERVAL), (_) => checkConnection());
  }

  Future<void> checkConnection() async {
    try {
      isCheckingConnection.value = true;
      lastConnectionCheck.value = DateTime.now();

      final status = await checkConnectionStatus();
      lastConnectionStatus.value = status;

      if (status == ConnectionStatus.ok) {
        _consecutiveSuccesses++;
        _consecutiveFailures = 0;

        if (_consecutiveSuccesses >= REQUIRED_STABLE_CONNECTIONS) {
          if (isOffline.value) {
            isOffline.value = false;
            connectionStable.value = true;
            _showToast('Conexión Restaurada - Sincronizando...', Colors.green);
            Future.delayed(Duration(seconds: 1), () {
              SyncService.to.performFullSync();
            });
          }
        }
      } else {
        _consecutiveFailures++;
        _consecutiveSuccesses = 0;

        if (_consecutiveFailures >= 2 && !isOffline.value) {
          isOffline.value = true;
          connectionStable.value = false;
          _showOfflineToast(status);
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

  void _showOfflineToast(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.noInternet:
        _showToast('Sin Internet - Modo offline', Colors.orange);
        break;
      case ConnectionStatus.timeout:
        _showToast(
            'Servidor no responde (timeout) - Modo offline', Colors.deepOrange);
        break;
      case ConnectionStatus.serverDown:
        _showToast('Servidor caído - Modo offline', Colors.red);
        break;
      case ConnectionStatus.ok:
        break;
    }
  }

  void _showToast(String msg, Color color) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Forzar verificación manual de conexión.
  Future<bool> forceConnectionCheck() async {
    final status = await checkConnectionStatus();
    lastConnectionStatus.value = status;
    final connected = status == ConnectionStatus.ok;

    if (connected != !isOffline.value) {
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
  }
}
