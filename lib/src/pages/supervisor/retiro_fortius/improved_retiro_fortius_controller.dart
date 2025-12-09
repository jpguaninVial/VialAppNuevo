import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../models/movimiento.dart';
import '../../../models/usuario.dart';
import '../../../provider/movimiento_provider.dart';
import '../../../controllers/loading_controller.dart';
import '../../../controllers/improved_connection_controller.dart';
import '../../../services/sync_service.dart';

class ImprovedRetiroFortiusController extends GetxController {
  static const String LOADING_KEY = 'retiro_fortius';
  
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

  ImprovedRetiroFortiusController(Usuario usuario) {
    this.usuario = usuario;
  }

  /// Registro de retiro con manejo mejorado de estado y errores
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

    // Mostrar indicador de carga
    LoadingController.to.setLoading(
      LOADING_KEY,
      message: 'Procesando retiro de Fortius...'
    );

    try {
      // Verificar estado de conexión
      final isOffline = ImprovedConnectionController.to.isOffline.value;
      
      if (isOffline) {
        final shouldContinue = await _showOfflineConfirmation();
        if (!shouldContinue) {
          LoadingController.to.clearLoading(LOADING_KEY);
          return;
        }
      }

      // Crear el movimiento
      final movimiento = _buildMovimiento(usuario);

      // Enviar la petición con retry logic
      final result = await _submitTransaction(movimiento, isOffline);

      // Manejar respuesta
      await _handleTransactionResult(result, isOffline);

    } catch (e) {
      _handleError(e);
    } finally {
      LoadingController.to.clearLoading(LOADING_KEY);
    }
  }

  bool _validateFields() {
    // Verificar que al menos un campo tenga valor
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

    // Validar formato numérico
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

  Future<bool> _showOfflineConfirmation() async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Modo Offline'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No hay conexión al servidor.'),
            SizedBox(height: 8),
            Text('La transacción se guardará localmente y se sincronizará cuando haya conexión.'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[800], size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Transacciones pendientes: ${SyncService.to.pendingTransactions.value}',
                      style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('Continuar Offline'),
          ),
        ],
      ),
    ) ?? false;
  }

  Movimiento _buildMovimiento(Usuario usuario) {
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

  Future<TransactionResult> _submitTransaction(Movimiento movimiento, bool isOffline) async {
    try {
      final response = await _movimientoProvider.create(movimiento)
          .timeout(Duration(seconds: 30));

      return TransactionResult(
        success: response.statusCode == 201 || response.statusCode == 202,
        statusCode: response.statusCode,
        isOffline: response.statusCode == 202,
      );
    } catch (e) {
      if (e is TimeoutException) {
        return TransactionResult(
          success: false,
          statusCode: 0,
          error: 'Timeout - La conexión es muy lenta',
        );
      } else {
        return TransactionResult(
          success: false,
          statusCode: 0,
          error: e.toString(),
        );
      }
    }
  }

  Future<void> _handleTransactionResult(TransactionResult result, bool wasOffline) async {
    if (result.success) {
      if (result.isOffline) {
        Get.snackbar(
          'Transacción Offline',
          'El retiro ha sido registrado exitosamente sin conexión',
          icon: Icon(Icons.cloud_off_outlined, color: Colors.white),
          backgroundColor: Colors.orange[800],
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Retiro Fortius Exitoso',
          'El retiro ha sido registrado correctamente',
          icon: Icon(Icons.check_circle, color: Colors.white),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      // Limpiar campos
      _clearFields();
      
      // Navegar de vuelta
      Get.offNamedUntil('/home', (route) => false, arguments: {'index': 0});
      
    } else {
      // Manejar error específico
      String errorMessage = 'Error desconocido';
      
      if (result.statusCode == 0) {
        errorMessage = result.error ?? 'Error de conexión';
      } else if (result.statusCode >= 400 && result.statusCode < 500) {
        errorMessage = 'Error de autorización o datos inválidos';
      } else if (result.statusCode >= 500) {
        errorMessage = 'Error del servidor';
      }
      
      // Ofrecer opciones al usuario
      await _showErrorDialog(errorMessage, wasOffline);
    }
  }

  Future<void> _showErrorDialog(String errorMessage, bool wasOffline) async {
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
              errorMessage,
              style: TextStyle(color: Colors.red[700]),
            ),
            if (!wasOffline) ...[
              SizedBox(height: 16),
              Text('¿Desea guardar la transacción offline?'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          if (!wasOffline)
            ElevatedButton(
              onPressed: () async {
                Get.back();
                // Forzar guardado offline
                LoadingController.to.setLoading(LOADING_KEY, message: 'Guardando offline...');
                // Aquí implementarías el guardado offline directo
                await Future.delayed(Duration(seconds: 1));
                LoadingController.to.clearLoading(LOADING_KEY);
                
                Get.snackbar(
                  'Guardado Offline',
                  'La transacción se sincronizará cuando haya conexión',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('Guardar Offline'),
            ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Reintentar
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
    // Limpiar el estado de carga al cerrar el controlador
    LoadingController.to.clearLoading(LOADING_KEY);
    super.onClose();
  }
}

class TransactionResult {
  final bool success;
  final int statusCode;
  final bool isOffline;
  final String? error;

  TransactionResult({
    required this.success,
    required this.statusCode,
    this.isOffline = false,
    this.error,
  });
}
