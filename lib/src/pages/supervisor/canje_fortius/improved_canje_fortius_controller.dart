import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../models/movimiento.dart';
import '../../../models/usuario.dart';
import '../../../provider/movimiento_provider.dart';
import '../../../controllers/loading_controller.dart';
import '../../../controllers/improved_connection_controller.dart';

class ImprovedCanjeFortiusController extends GetxController {
  static const String LOADING_KEY = 'canje_fortius';

  final MovimientoProvider _movimientoProvider = MovimientoProvider();
  final Usuario usuarioSession =
      Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Usuario? usuario;

  // Controllers para los campos
  TextEditingController billetes5RecibeController = TextEditingController();
  TextEditingController billetes1RecibeController = TextEditingController();
  TextEditingController billetes10RecibeController = TextEditingController();
  TextEditingController billetes10EntregaController = TextEditingController();
  TextEditingController billetes20EntregaController = TextEditingController();

  ImprovedCanjeFortiusController(Usuario usuario) {
    this.usuario = usuario;
  }

  void _log(String message) {
    // Usa print para que se vea en el logcat/console
    print('📄 [CANJE_FORTIUS] $message');
  }

  /// Registro de canje fortius con validación de conexión obligatoria
  Future<void> registrarCanjeeFortius(
      BuildContext context, Usuario usuario) async {
    _log('Inicio registrarCanjeeFortius para usuario ${usuario.id}');
    // Validar que no haya una operación en curso
    if (LoadingController.to.isLoading(LOADING_KEY)) {
      _log('Se bloquea por operación en curso');
      Get.snackbar('Operación en Curso', 'Por favor espere...');
      return;
    }

    // Validación de campos
    if (!_validateFields()) {
      _log('Validación de campos fallida');
      return;
    }

    // Verificar conexión OBLIGATORIA
    final hasConnection = await _verifyConnection();
    _log('Resultado verificación conexión: $hasConnection');
    if (!hasConnection) {
      _log('Sin conexión, mostrando diálogo');
      _showNoConnectionDialog();
      return;
    }

    // Mostrar indicador de carga
    LoadingController.to
        .setLoading(LOADING_KEY, message: 'Procesando canje fortius...');

    try {
      // Crear el movimiento
      final movimiento = _buildMovimiento(usuario);
      _log('Movimiento construido: ${movimiento.toJson()}');

      // Enviar la petición con múltiples reintentos
      final result = await _submitTransactionWithRetries(movimiento);
      _log(
          'Resultado transacción: success=${result.success}, status=${result.statusCode}, error=${result.error}');

      // Manejar respuesta
      await _handleTransactionResult(result);
    } catch (e) {
      _log('Excepción no controlada: $e');
      _handleError(e);
    } finally {
      _log('Limpiando loading');
      LoadingController.to.clearLoading(LOADING_KEY);
    }
  }

  Future<bool> _verifyConnection() async {
    LoadingController.to
        .setLoading(LOADING_KEY, message: 'Verificando conexión...');

    try {
      final connected =
          await ImprovedConnectionController.to.forceConnectionCheck();
      return connected;
    } catch (e) {
      return false;
    } finally {
      LoadingController.to.clearLoading(LOADING_KEY);
    }
  }

  void _showNoConnectionDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Sin Conexión'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'No se puede procesar el canje fortius sin conexión al servidor.'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue[800], size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Recomendaciones:',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[800]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('• Verifique su conexión a internet',
                      style: TextStyle(fontSize: 13)),
                  Text('• Acérquese a un punto con mejor señal',
                      style: TextStyle(fontSize: 13)),
                  Text('• Contacte al administrador de red',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Entendido'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final hasConnection = await _verifyConnection();
              if (hasConnection) {
                registrarCanjeeFortius(Get.context!, usuario!);
              } else {
                Get.snackbar(
                  'Sin Conexión',
                  'Aún no hay conexión disponible',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  bool _validateFields() {
    // Verificar que tenga valores para recibir y entregar
    final hasRecibeValues = [
      billetes1RecibeController.text,
      billetes5RecibeController.text,
      billetes10RecibeController.text,
    ].any((text) => text.isNotEmpty && text != '0');

    final hasEntregaValues = [
      billetes10EntregaController.text,
      billetes20EntregaController.text,
    ].any((text) => text.isNotEmpty && text != '0');

    if (!hasRecibeValues && !hasEntregaValues) {
      Get.snackbar(
        'Campos Requeridos',
        'Debe ingresar al menos una denominación',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    // Validar formato numérico
    try {
      [
        billetes1RecibeController.text,
        billetes5RecibeController.text,
        billetes10RecibeController.text,
        billetes10EntregaController.text,
        billetes20EntregaController.text,
      ].forEach((text) {
        if (text.isNotEmpty) double.parse(text);
      });
    } catch (e) {
      Get.snackbar(
        'Formato Inválido',
        'Los valores deben ser números válidos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Movimiento _buildMovimiento(Usuario usuario) {
    return Movimiento(
        turno: '2',
        idturno: '2',
        idSupervisor: usuarioSession.id,
        idCajero: usuarioSession.id,
        idTipoMovimiento: '5', // Tipo de movimiento para canje fortius
        idPeaje: usuarioSession.idPeaje,
        via: usuario.via,
        recibe1C: '0',
        recibe5C: '0',
        recibe10C: '0',
        recibe25C: '0',
        recibe50C: '0',
        recibe2D: '0',
        recibe1D: billetes1RecibeController.text.isEmpty
            ? '0'
            : billetes1RecibeController.text,
        recibe1DB: '0',
        recibe5D: billetes5RecibeController.text.isEmpty
            ? '0'
            : billetes5RecibeController.text,
        recibe10D: billetes10RecibeController.text.isEmpty
            ? '0'
            : billetes10RecibeController.text,
        recibe20D: '0',
        entrega1C: '0',
        entrega5C: '0',
        entrega10C: '0',
        entrega25C: '0',
        entrega50C: '0',
        entrega1D: '0',
        entrega1DB: '0',
        entrega5D: '0',
        entrega10D: billetes10EntregaController.text.isEmpty
            ? '0'
            : billetes10EntregaController.text,
        entrega20D: billetes20EntregaController.text.isEmpty
            ? '0'
            : billetes20EntregaController.text);
  }

  Future<TransactionResult> _submitTransactionWithRetries(
      Movimiento movimiento) async {
    int maxRetries = 3;
    int currentRetry = 0;

    while (currentRetry < maxRetries) {
      try {
        LoadingController.to.setLoading(LOADING_KEY,
            message: currentRetry == 0
                ? 'Enviando transacción...'
                : 'Reintentando... (${currentRetry + 1}/$maxRetries)');
        _log('Intento ${currentRetry + 1} de $maxRetries');

        final response = await _movimientoProvider
            .createOnlineOnly(movimiento)
            .timeout(Duration(seconds: 45));

        final status = response.statusCode ?? 0;
        _log('Respuesta status=$status body=${response.body}');

        if (status == 201) {
          return TransactionResult(success: true, statusCode: status);
        } else if (status >= 400 && status < 500) {
          return TransactionResult(
            success: false,
            statusCode: status,
            error:
                _extractError(response.body) ?? 'Error de datos o autorización',
          );
        } else if (status >= 500 && status < 600) {
          final serverMsg = _extractError(response.body);
          if (serverMsg != null && serverMsg.isNotEmpty) {
            return TransactionResult(
              success: false,
              statusCode: status,
              error: serverMsg,
            );
          }
        } else {
          currentRetry++;
          if (currentRetry < maxRetries) {
            _log('Reintentando por respuesta inesperada (status=$status)');
            await Future.delayed(Duration(seconds: 2 * currentRetry));
          } else {
            return TransactionResult(
              success: false,
              statusCode: status,
              error: _extractError(response.body) ??
                  'Error del servidor después de $maxRetries intentos',
            );
          }
        }
      } on TimeoutException {
        currentRetry++;
        if (currentRetry >= maxRetries) {
          return TransactionResult(
            success: false,
            statusCode: 0,
            error: 'Tiempo de espera agotado después de $maxRetries intentos',
          );
        }
        _log('Timeout, reintento ${currentRetry + 1}');
        await Future.delayed(Duration(seconds: 2 * currentRetry));
      } catch (e) {
        currentRetry++;
        if (currentRetry >= maxRetries) {
          return TransactionResult(
            success: false,
            statusCode: 0,
            error:
                'Error de conexión después de $maxRetries intentos: ${e.toString()}',
          );
        }

        _log('Excepción $e, reintento ${currentRetry + 1}');
        await Future.delayed(Duration(seconds: 2 * currentRetry));
      }
    }

    return TransactionResult(
      success: false,
      statusCode: 0,
      error: 'Máximo de reintentos alcanzado',
    );
  }

  Future<void> _handleTransactionResult(TransactionResult result) async {
    if (result.success) {
      _log('Transacción exitosa, navegando a home');
      Get.snackbar(
        'Transacción Exitosa',
        'El canje fortius ha sido registrado correctamente',
        icon: Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _clearFields();
      Get.offNamedUntil('/home', (route) => false, arguments: {'index': 0});
    } else {
      _log('Transacción fallida, mostrando diálogo de error');
      await _showErrorDialog(result);
    }
  }

  Future<void> _showErrorDialog(TransactionResult result) async {
    await Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error en Transacción'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No se pudo procesar el canje fortius:'),
            SizedBox(height: 8),
            Text(
              result.error ?? 'Error desconocido',
              style: TextStyle(color: Colors.red[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              registrarCanjeeFortius(Get.context!, usuario!);
            },
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _handleError(dynamic error) {
    _log('Error inesperado: $error');
    Get.snackbar(
      'Error Inesperado',
      'Ocurrió un error al procesar el canje fortius',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _clearFields() {
    billetes1RecibeController.clear();
    billetes5RecibeController.clear();
    billetes10RecibeController.clear();
    billetes10EntregaController.clear();
    billetes20EntregaController.clear();
  }

  @override
  void onClose() {
    LoadingController.to.clearLoading(LOADING_KEY);
    super.onClose();
  }
}

class TransactionResult {
  final bool success;
  final int statusCode;
  final String? error;

  TransactionResult({
    required this.success,
    required this.statusCode,
    this.error,
  });
}

String? _extractError(dynamic body) {
  if (body == null) return null;
  if (body is Map<String, dynamic>) {
    if (body['error'] != null && body['error'].toString().isNotEmpty) {
      return body['error'].toString();
    }
    if (body['message'] != null && body['message'].toString().isNotEmpty) {
      return body['message'].toString();
    }
  }
  if (body is String && body.isNotEmpty) {
    try {
      final decoded = json.decode(body);
      final nested = _extractError(decoded);
      if (nested != null) return nested;
    } catch (_) {
      // no-op, fallback al string plano
    }
    return body;
  }
  return null;
}
