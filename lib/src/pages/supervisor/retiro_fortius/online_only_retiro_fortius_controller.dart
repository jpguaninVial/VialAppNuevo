import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../models/movimiento.dart';
import '../../../models/usuario.dart';
import '../../../provider/movimiento_provider.dart';
import '../../../controllers/loading_controller.dart';
import '../../../controllers/improved_connection_controller.dart';

class OnlineOnlyRetiroFortiusController extends GetxController {
  static const String LOADING_KEY = 'retiro_fortius_online';
  
  final MovimientoProvider _movimientoProvider = MovimientoProvider();
  final Usuario usuarioSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});
  
  Usuario? usuario;
  final selectedTurno = 0.obs;

  // Controllers para los campos
  TextEditingController billetes20Controller = TextEditingController();
  TextEditingController billetes10EntregaController = TextEditingController();
  TextEditingController billetes5EntregaController = TextEditingController();
  TextEditingController billetes1EntregaController = TextEditingController();
  TextEditingController Moneda50EntregaController = TextEditingController();
  TextEditingController Moneda25EntregaController = TextEditingController();
  TextEditingController Moneda10EntregaController = TextEditingController();
  TextEditingController Moneda5EntregaController = TextEditingController();
  TextEditingController Moneda1EntregaController = TextEditingController();

  OnlineOnlyRetiroFortiusController(Usuario usuario) {
    this.usuario = usuario;
  }

  /// Registro de retiro con validación de conexión obligatoria
  Future<void> registrarRetiroParcial(BuildContext context, Usuario usuario) async {
    // Validar que no haya una operación en curso
    if (LoadingController.to.isLoading(LOADING_KEY)) {
      Get.snackbar('Operación en Curso', 'Por favor espere...');
      return;
    }

    // Validación de campos
    if (!_validateFields()) {
      return;
    }

    // Verificar conexión OBLIGATORIA
    final hasConnection = await _verifyConnection();
    if (!hasConnection) {
      _showNoConnectionDialog();
      return;
    }

    // Mostrar indicador de carga
    LoadingController.to.setLoading(
      LOADING_KEY,
      message: 'Procesando retiro de Fortius...'
    );

    try {
      // Crear el movimiento
      final movimiento = _buildMovimiento(usuario);

      // Enviar la petición con múltiples reintentos
      final result = await _submitTransactionWithRetries(movimiento);

      // Manejar respuesta
      await _handleTransactionResult(result);

    } catch (e) {
      _handleError(e);
    } finally {
      LoadingController.to.clearLoading(LOADING_KEY);
    }
  }

  Future<bool> _verifyConnection() async {
    LoadingController.to.setLoading(LOADING_KEY, message: 'Verificando conexión...');
    
    try {
      // Verificar con timeout generoso
      final connected = await ImprovedConnectionController.to.forceConnectionCheck();
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
            Text('No se puede procesar la transacción sin conexión al servidor.'),
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
                      Icon(Icons.info_outline, color: Colors.blue[800], size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Recomendaciones:',
                        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue[800]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('• Verifique su conexión a internet', style: TextStyle(fontSize: 13)),
                  Text('• Acérquese a un punto con mejor señal', style: TextStyle(fontSize: 13)),
                  Text('• Contacte al administrador de red', style: TextStyle(fontSize: 13)),
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
              // Reintentar verificación
              final hasConnection = await _verifyConnection();
              if (hasConnection) {
                registrarRetiroParcial(context, usuario);
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

  Future<TransactionResult> _submitTransactionWithRetries(Movimiento movimiento) async {
    int maxRetries = 3;
    int currentRetry = 0;
    
    while (currentRetry < maxRetries) {
      try {
        LoadingController.to.setLoading(
          LOADING_KEY,
          message: currentRetry == 0 
              ? 'Enviando transacción...'
              : 'Reintentando... (${currentRetry + 1}/$maxRetries)'
        );

        final response = await _movimientoProvider.createOnlineOnly(movimiento)
            .timeout(Duration(seconds: 45)); // Timeout más generoso

        if (response.statusCode == 201) {
          return TransactionResult(success: true, statusCode: 201);
        } else if (response.statusCode >= 400 && response.statusCode < 500) {
          // Error del cliente, no reintentar
          return TransactionResult(
            success: false,
            statusCode: response.statusCode,
            error: 'Error de datos o autorización',
          );
        } else {
          // Error del servidor, reintentar
          currentRetry++;
          if (currentRetry < maxRetries) {
            await Future.delayed(Duration(seconds: 2 * currentRetry)); // Backoff exponencial
          } else {
            return TransactionResult(
              success: false,
              statusCode: response.statusCode,
              error: 'Error del servidor después de $maxRetries intentos',
            );
          }
        }
      } catch (e) {
        currentRetry++;
        if (currentRetry >= maxRetries) {
          return TransactionResult(
            success: false,
            statusCode: 0,
            error: 'Error de conexión después de $maxRetries intentos: ${e.toString()}',
          );
        }
        
        // Esperar antes del siguiente intento
        await Future.delayed(Duration(seconds: 2 * currentRetry));
      }
    }
    
    return TransactionResult(
      success: false,
      statusCode: 0,
      error: 'Máximo de reintentos alcanzado',
    );
  }

  bool _validateFields() {
    // Mismo código de validación que antes
    final hasValues = [
      billetes20Controller.text,
      billetes10EntregaController.text,
      billetes5EntregaController.text,
      billetes1EntregaController.text,
      Moneda50EntregaController.text,
      Moneda25EntregaController.text,
      Moneda10EntregaController.text,
      Moneda5EntregaController.text,
      Moneda1EntregaController.text,
    ].any((text) => text.isNotEmpty && text != '0');

    if (!hasValues) {
      Get.snackbar(
        'Campos Requeridos',
        'Debe ingresar al menos una denominación',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      [
        billetes20Controller.text,
        billetes10EntregaController.text,
        billetes5EntregaController.text,
        billetes1EntregaController.text,
        Moneda50EntregaController.text,
        Moneda25EntregaController.text,
        Moneda10EntregaController.text,
        Moneda5EntregaController.text,
        Moneda1EntregaController.text,
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
    // Mismo código que antes
    return Movimiento(
      turno: selectedTurno.value.toString(),
      idturno: '2',
      idSupervisor: usuarioSession.id,
      idCajero: usuarioSession.id,
      idTipoMovimiento: '5',
      idPeaje: usuario.idPeaje,
      via: '0',
      recibe1C: '0',
      recibe5C: '0',
      recibe10C: '0',
      recibe25C: '0',
      recibe50C: '0',
      recibe2D: '0',
      recibe1D: '0',
      recibe1DB: '0',
      recibe5D: '0',
      recibe10D: '0',
      recibe20D: '0',
      entrega1C: Moneda1EntregaController.text.isEmpty ? '0' : Moneda1EntregaController.text,
      entrega5C: Moneda5EntregaController.text.isEmpty ? '0' : Moneda5EntregaController.text,
      entrega10C: Moneda10EntregaController.text.isEmpty ? '0' : Moneda10EntregaController.text,
      entrega25C: Moneda25EntregaController.text.isEmpty ? '0' : Moneda25EntregaController.text,
      entrega50C: Moneda50EntregaController.text.isEmpty ? '0' : Moneda50EntregaController.text,
      entrega1D: billetes1EntregaController.text.isEmpty ? '0' : billetes1EntregaController.text,
      entrega1DB: '0',
      entrega5D: billetes5EntregaController.text.isEmpty ? '0' : billetes5EntregaController.text,
      entrega10D: billetes10EntregaController.text.isEmpty ? '0' : billetes10EntregaController.text,
      entrega20D: billetes20Controller.text.isEmpty ? '0' : billetes20Controller.text,
    );
  }

  Future<void> _handleTransactionResult(TransactionResult result) async {
    if (result.success) {
      Get.snackbar(
        'Retiro Fortius Exitoso',
        'El retiro ha sido registrado correctamente',
        icon: Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      _clearFields();
      Get.offNamedUntil('/home', (route) => false, arguments: {'index': 0});
      
    } else {
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
            Text('No se pudo procesar la transacción:'),
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
              registrarRetiroParcial(Get.context!, usuario!);
            },
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _handleError(dynamic error) {
    Get.snackbar(
      'Error Inesperado',
      'Ocurrió un error al procesar la transacción',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _clearFields() {
    billetes20Controller.clear();
    billetes10EntregaController.clear();
    billetes5EntregaController.clear();
    billetes1EntregaController.clear();
    Moneda50EntregaController.clear();
    Moneda25EntregaController.clear();
    Moneda10EntregaController.clear();
    Moneda5EntregaController.clear();
    Moneda1EntregaController.clear();
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
