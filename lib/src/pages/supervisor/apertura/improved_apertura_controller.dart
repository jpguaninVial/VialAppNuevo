import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../models/movimiento.dart';
import '../../../models/turno.dart';
import '../../../models/usuario.dart';
import '../../../provider/movimiento_provider.dart';
import '../../../provider/turno_provider.dart';
import '../../../controllers/loading_controller.dart';
import '../../../controllers/improved_connection_controller.dart';

class ImprovedAperturaController extends GetxController {
  static const String LOADING_KEY = 'apertura';

  final MovimientoProvider _movimientoProvider = MovimientoProvider();
  final TurnoProvider _turnoProvider = TurnoProvider();
  final Usuario usuarioSession =
      Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Usuario? usuario;
  final asignacion = 'null'.obs;
  String via1 = '';

  // Controllers para los campos
  TextEditingController billetes10Controller = TextEditingController();
  TextEditingController billetes5Controller = TextEditingController();
  TextEditingController billetes1Controller = TextEditingController();
  TextEditingController Moneda50Controller = TextEditingController();
  TextEditingController Moneda25Controller = TextEditingController();
  TextEditingController Moneda10Controller = TextEditingController();
  TextEditingController Moneda5Controller = TextEditingController();
  TextEditingController Moneda1Controller = TextEditingController();

  final totalCalculado = 0.0.obs;

  ImprovedAperturaController(Usuario usuario) {
    this.usuario = usuario;
  }

  @override
  void onInit() {
    super.onInit();
    final controllers = [
      billetes10Controller,
      billetes5Controller,
      billetes1Controller,
      Moneda50Controller,
      Moneda25Controller,
      Moneda10Controller,
      Moneda5Controller,
      Moneda1Controller,
    ];
    for (var controller in controllers) {
      controller.addListener(_recalculateTotal);
    }
  }

  void _recalculateTotal() {
    double getValue(TextEditingController controller) {
      if (controller.text.isEmpty) return 0;
      return double.tryParse(controller.text) ?? 0;
    }

    totalCalculado.value = (getValue(billetes10Controller) * 10) +
        (getValue(billetes5Controller) * 5) +
        (getValue(billetes1Controller) * 1) +
        (getValue(Moneda50Controller) * 0.5) +
        (getValue(Moneda25Controller) * 0.25) +
        (getValue(Moneda10Controller) * 0.1) +
        (getValue(Moneda5Controller) * 0.05) +
        (getValue(Moneda1Controller) * 0.01);
  }

  Future<void> updateVia(String via, String idTurno) async {
    try {
      LoadingController.to.setLoading(LOADING_KEY, message: 'Asignando vía...');

      var response = await _turnoProvider.updateVia(via, idTurno);
      if (response.isOk) {
        asignacion.value = via;
        List<Turno> turno = await _turnoProvider.getAll(idTurno);
        via1 = turno.first.via!;
        Get.snackbar('Asignado', 'La vía ha sido asignada correctamente');
        update();
      } else {
        Get.snackbar('Error', 'No se pudo asignar la vía: $via');
      }
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un problema al asignar la vía: $e');
    } finally {
      LoadingController.to.clearLoading(LOADING_KEY);
    }
  }

  /// Registro de apertura con validación de conexión obligatoria
  Future<void> registrarApertura(BuildContext context, Usuario usuario) async {
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
    LoadingController.to
        .setLoading(LOADING_KEY, message: 'Procesando apertura...');

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
            Text('No se puede procesar la apertura sin conexión al servidor.'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[800], size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Importante:',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.red[800]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Las aperturas requieren conexión inmediata para inicializar correctamente el turno.',
                    style: TextStyle(fontSize: 13, color: Colors.red[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
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
                registrarApertura(Get.context!, usuario!);
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
    // Verificar que al menos un campo tenga valor
    final hasValues = [
      billetes10Controller.text,
      billetes5Controller.text,
      billetes1Controller.text,
      Moneda50Controller.text,
      Moneda25Controller.text,
      Moneda10Controller.text,
      Moneda5Controller.text,
      Moneda1Controller.text,
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
        billetes10Controller.text,
        billetes5Controller.text,
        billetes1Controller.text,
        Moneda50Controller.text,
        Moneda25Controller.text,
        Moneda10Controller.text,
        Moneda5Controller.text,
        Moneda1Controller.text,
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
    String via = usuario.idRol == '4' ? '0' : via1;

    return Movimiento(
        turno: usuario.turno,
        idSupervisor: usuarioSession.id,
        idCajero: usuario.id,
        idTipoMovimiento: '1',
        idPeaje: usuarioSession.idPeaje,
        via: via,
        idturno: usuario.idTurno,
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
        entrega1C:
            Moneda1Controller.text.isEmpty ? '0' : Moneda1Controller.text,
        entrega5C:
            Moneda5Controller.text.isEmpty ? '0' : Moneda5Controller.text,
        entrega10C:
            Moneda10Controller.text.isEmpty ? '0' : Moneda10Controller.text,
        entrega25C:
            Moneda25Controller.text.isEmpty ? '0' : Moneda25Controller.text,
        entrega50C:
            Moneda50Controller.text.isEmpty ? '0' : Moneda50Controller.text,
        entrega1D:
            billetes1Controller.text.isEmpty ? '0' : billetes1Controller.text,
        entrega1DB: '0',
        entrega5D:
            billetes5Controller.text.isEmpty ? '0' : billetes5Controller.text,
        entrega10D:
            billetes10Controller.text.isEmpty ? '0' : billetes10Controller.text,
        entrega20D: '0');
  }

  Future<TransactionResult> _submitTransactionWithRetries(
      Movimiento movimiento) async {
    int maxRetries = 3;
    int currentRetry = 0;

    while (currentRetry < maxRetries) {
      try {
        LoadingController.to.setLoading(LOADING_KEY,
            message: currentRetry == 0
                ? 'Enviando apertura...'
                : 'Reintentando... (${currentRetry + 1}/$maxRetries)');

        final response = await _movimientoProvider
            .createOnlineOnly(movimiento)
            .timeout(Duration(seconds: 45));

        if (response.statusCode == 201) {
          return TransactionResult(success: true, statusCode: 201);
        } else if ((response.statusCode ?? 0) >= 400 &&
            (response.statusCode ?? 0) < 500) {
          return TransactionResult(
            success: false,
            statusCode: response.statusCode ?? 0,
            error: 'Error de datos o autorización',
          );
        } else {
          currentRetry++;
          if (currentRetry < maxRetries) {
            await Future.delayed(Duration(seconds: 2 * currentRetry));
          } else {
            return TransactionResult(
              success: false,
              statusCode: response.statusCode ?? 0,
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
            error:
                'Error de conexión después de $maxRetries intentos: ${e.toString()}',
          );
        }

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
      Get.snackbar(
        'Apertura Exitosa',
        'La apertura ha sido registrada correctamente',
        icon: Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _clearFields();
      Get.offNamedUntil('/home', (route) => false, arguments: {'index': 2});
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
            Text('Error en Apertura'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No se pudo procesar la apertura:'),
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
              registrarApertura(Get.context!, usuario!);
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
      'Ocurrió un error al procesar la apertura',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _clearFields() {
    billetes10Controller.clear();
    billetes5Controller.clear();
    billetes1Controller.clear();
    Moneda50Controller.clear();
    Moneda25Controller.clear();
    Moneda10Controller.clear();
    Moneda5Controller.clear();
    Moneda1Controller.clear();
  }

  @override
  void onClose() {
    billetes10Controller.dispose();
    billetes5Controller.dispose();
    billetes1Controller.dispose();
    Moneda50Controller.dispose();
    Moneda25Controller.dispose();
    Moneda10Controller.dispose();
    Moneda5Controller.dispose();
    Moneda1Controller.dispose();
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
