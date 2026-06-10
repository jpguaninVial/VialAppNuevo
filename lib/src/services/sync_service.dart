import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/movimiento.dart';
import '../provider/movimiento_provider.dart';
import '../provider/turno_provider.dart';
import '../helper/connection_helper.dart';

class SyncService extends GetxController {
  static SyncService get to => Get.find();

  final MovimientoProvider _movimientoProvider = MovimientoProvider();
  final TurnoProvider _turnoProvider = TurnoProvider();

  // Estados observables
  final isSyncing = false.obs;
  final lastSyncTime = DateTime.now().obs;
  final pendingTransactions = 0.obs;
  final failedTransactions = 0.obs;

  Timer? _syncTimer;

  // Control de reintentos
  static const int MAX_RETRIES = 3;
  static const int SYNC_INTERVAL_SECONDS = 30; // Aumentado de 10 a 30 segundos
  static const int CONNECTION_TIMEOUT_SECONDS =
      10; // Aumentado de 3 a 10 segundos

  @override
  void onInit() {
    super.onInit();
    _startPeriodicSync();
    _updatePendingCount();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(Duration(seconds: SYNC_INTERVAL_SECONDS),
        (_) => _performSyncIfConnected());
  }

  Future<void> _performSyncIfConnected() async {
    if (isSyncing.value) {
      log('Sincronización ya en curso, saltando...');
      return;
    }

    final isConnected = await _checkConnectivity();
    if (isConnected) {
      await performFullSync();
    }
  }

  Future<bool> _checkConnectivity() async {
    try {
      return await isConnectedToServer()
          .timeout(Duration(seconds: CONNECTION_TIMEOUT_SECONDS));
    } catch (e) {
      log('Error verificando conectividad: $e');
      return false;
    }
  }

  /// Sincronización completa con control de estado
  Future<SyncResult> performFullSync() async {
    if (isSyncing.value) {
      return SyncResult.alreadyInProgress();
    }

    isSyncing.value = true;

    try {
      final results = await Future.wait([
        _syncTransactions(),
        _syncUpdates(),
        _syncLiquidations(),
        _syncTurns(),
      ]);

      final totalSuccess =
          results.fold(0, (sum, result) => sum + result.successCount);
      final totalFailed =
          results.fold(0, (sum, result) => sum + result.failedCount);

      lastSyncTime.value = DateTime.now();
      failedTransactions.value = totalFailed;

      _updatePendingCount();

      return SyncResult.completed(totalSuccess, totalFailed);
    } catch (e) {
      log('Error durante sincronización completa: $e');
      return SyncResult.error(e.toString());
    } finally {
      isSyncing.value = false;
    }
  }

  Future<SyncResult> _syncTransactions() async {
    return _syncBox(
        'transacciones',
        (movimiento) => _movimientoProvider.create(movimiento),
        'Transacciones');
  }

  Future<SyncResult> _syncUpdates() async {
    return _syncBox(
        'updateTransacciones',
        (movimiento) => _movimientoProvider.update(movimiento),
        'Actualizaciones');
  }

  Future<SyncResult> _syncLiquidations() async {
    return _syncBox(
        'liquidacionTransacciones',
        (movimiento) =>
            _movimientoProvider.updateLiquidacionCompleta(movimiento),
        'Liquidaciones');
  }

  Future<SyncResult> _syncTurns() async {
    try {
      await _turnoProvider.sincronizarTurnosPendientes();
      return SyncResult.completed(1, 0);
    } catch (e) {
      log('Error sincronizando turnos: $e');
      return SyncResult.completed(0, 1);
    }
  }

  Future<SyncResult> _syncBox(
      String boxName,
      Future<Response> Function(Movimiento) syncFunction,
      String operationType) async {
    try {
      final box = await Hive.openBox<Movimiento>(boxName);
      final keys = box.keys.toList();

      if (keys.isEmpty) {
        return SyncResult.completed(0, 0);
      }

      int successCount = 0;
      int failedCount = 0;

      for (var key in keys) {
        final movimiento = box.get(key);
        if (movimiento == null) continue;

        final success = await _retryOperation(() async {
          final response =
              await syncFunction(movimiento).timeout(Duration(seconds: 30));
          return response.statusCode == 201;
        });

        if (success) {
          await box.delete(key);
          successCount++;
          log('$operationType sincronizada exitosamente: $key');
        } else {
          failedCount++;
          log('Error al sincronizar $operationType $key tras $MAX_RETRIES intentos');
        }

        await Future.delayed(Duration(milliseconds: 500));
      }

      return SyncResult.completed(successCount, failedCount);
    } catch (e) {
      log('Error general sincronizando $operationType: $e');
      return SyncResult.error(e.toString());
    }
  }

  /// Executes [operation] up to [MAX_RETRIES] times with exponential backoff.
  /// Returns true on first success, false if all attempts fail.
  Future<bool> _retryOperation(Future<bool> Function() operation) async {
    for (int attempt = 1; attempt <= MAX_RETRIES; attempt++) {
      try {
        final success = await operation();
        if (success) return true;
      } catch (e) {
        log('Intento $attempt/$MAX_RETRIES falló: $e');
      }
      if (attempt < MAX_RETRIES) {
        // Backoff: 500ms, 1000ms, 2000ms
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
    return false;
  }

  Future<void> _updatePendingCount() async {
    try {
      final boxes = [
        'transacciones',
        'updateTransacciones',
        'liquidacionTransacciones'
      ];

      int total = 0;
      for (String boxName in boxes) {
        final box = await Hive.openBox<Movimiento>(boxName);
        total += box.length;
      }

      pendingTransactions.value = total;
    } catch (e) {
      log('Error actualizando contador de pendientes: $e');
    }
  }

  /// Forzar sincronización manual
  Future<SyncResult> forceManuaSync() async {
    if (!await _checkConnectivity()) {
      return SyncResult.noConnection();
    }

    return await performFullSync();
  }

  /// Limpiar todas las transacciones offline (usar con cuidado)
  Future<void> clearAllOfflineData() async {
    try {
      final boxes = [
        'transacciones',
        'updateTransacciones',
        'liquidacionTransacciones'
      ];

      for (String boxName in boxes) {
        final box = await Hive.openBox<Movimiento>(boxName);
        await box.clear();
      }

      _updatePendingCount();
      Fluttertoast.showToast(
        msg:
            'Datos Limpiados - Todas las transacciones offline han sido eliminadas',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      log('Error limpiando datos offline: $e');
      Fluttertoast.showToast(
        msg: 'Error - No se pudieron limpiar los datos offline',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}

class SyncResult {
  final bool success;
  final int successCount;
  final int failedCount;
  final String? error;
  final SyncStatus status;

  SyncResult._(this.success, this.successCount, this.failedCount, this.error,
      this.status);

  factory SyncResult.completed(int success, int failed) =>
      SyncResult._(failed == 0, success, failed, null, SyncStatus.completed);

  factory SyncResult.error(String error) =>
      SyncResult._(false, 0, 0, error, SyncStatus.error);

  factory SyncResult.noConnection() =>
      SyncResult._(false, 0, 0, 'Sin conexión', SyncStatus.noConnection);

  factory SyncResult.alreadyInProgress() => SyncResult._(
      false, 0, 0, 'Sincronización en curso', SyncStatus.inProgress);
}

enum SyncStatus { completed, error, noConnection, inProgress }
