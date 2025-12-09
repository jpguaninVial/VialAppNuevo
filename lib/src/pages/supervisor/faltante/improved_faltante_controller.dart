import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../models/movimiento.dart';
import '../../../models/usuario.dart';
import '../../../provider/movimiento_provider.dart';
import '../../../controllers/loading_controller.dart';
import '../../../controllers/improved_connection_controller.dart';

class ImprovedFaltanteController extends GetxController {
  static const String LOADING_KEY = 'faltante';

  final MovimientoProvider _movimientoProvider = MovimientoProvider();
  final Usuario usuarioSession =
      Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Usuario? usuario;
  List<Movimiento>? movimientos;
  int? bandera;
  String? pdt;

  // Controllers para los campos
  //ENTRGA
  TextEditingController billetes20ControllerE = TextEditingController();
  TextEditingController billetes10ControllerE = TextEditingController();
  TextEditingController billetes5ControllerE = TextEditingController();
  TextEditingController billetes1ControllerE = TextEditingController();
  TextEditingController Moneda50ControllerE = TextEditingController();
  TextEditingController Moneda25ControllerE = TextEditingController();
  TextEditingController Moneda10ControllerE = TextEditingController();
  TextEditingController Moneda5ControllerE = TextEditingController();

  //RECIBE
  TextEditingController billetes20ControllerR = TextEditingController();
  TextEditingController billetes10ControllerR = TextEditingController();
  TextEditingController billetes5ControllerR = TextEditingController();
  TextEditingController billetes1ControllerR = TextEditingController();
  TextEditingController Moneda50ControllerR = TextEditingController();
  TextEditingController Moneda25ControllerR = TextEditingController();
  TextEditingController Moneda10ControllerR = TextEditingController();
  TextEditingController Moneda5ControllerR = TextEditingController();
  TextEditingController simulacionesCantidadController =
      TextEditingController();
  TextEditingController simulacionesValorController = TextEditingController();
  TextEditingController anulacionesCantidadController = TextEditingController();
  TextEditingController anulacionesValorController = TextEditingController();
  TextEditingController sobrantesController = TextEditingController();
  final TextEditingController parteTrabajoController = TextEditingController();

  ImprovedFaltanteController(
      Usuario usuario, List<Movimiento> movimientos, int bandera, String pdt) {
    this.usuario = usuario;
    this.movimientos = movimientos;
    this.bandera = bandera;
    this.pdt = pdt;
  }

  /// Registro de faltante con validación de conexión obligatoria
  Future<void> actualizarLiquidacion(
      BuildContext context, List<Movimiento> movimientos) async {
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
        .setLoading(LOADING_KEY, message: 'Procesando faltante...');

    try {
      // Crear el movimiento
      final movimiento = _buildMovimiento(usuario!, movimientos);

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
            Text('No se puede procesar el faltante sin conexión al servidor.'),
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
                  Text(
                    '• Verifique su conexión a internet',
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    '• Acérquese a un punto con mejor señal',
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    '• Contacte al administrador de red',
                    style: TextStyle(fontSize: 13),
                  ),
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
                actualizarLiquidacion(Get.context!, movimientos!);
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
    // Verificar que al menos un campo tenga valor o que el parte de trabajo esté completo
    List<String> fieldsToCheck = [
      billetes20ControllerE.text,
      billetes10ControllerE.text,
      billetes5ControllerE.text,
      billetes1ControllerE.text,
      Moneda50ControllerE.text,
      Moneda25ControllerE.text,
      Moneda10ControllerE.text,
      Moneda5ControllerE.text,
      billetes20ControllerR.text,
      billetes10ControllerR.text,
      billetes5ControllerR.text,
      billetes1ControllerR.text,
      Moneda50ControllerR.text,
      Moneda25ControllerR.text,
      Moneda10ControllerR.text,
      Moneda5ControllerR.text,
    ];

    if (bandera == 1) {
      fieldsToCheck.addAll([
        simulacionesCantidadController.text,
        simulacionesValorController.text,
        anulacionesCantidadController.text,
        anulacionesValorController.text,
        sobrantesController.text,
      ]);
    }
    final hasValues =
        fieldsToCheck.any((text) => text.isNotEmpty && text != '0');
    final hasParteTrabajoValue = parteTrabajoController.text.isNotEmpty;

    if (!hasValues && !hasParteTrabajoValue) {
      Get.snackbar(
        'Campos Requeridos',
        'Debe ingresar al menos un valor o completar el parte de trabajo',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    // Validar formato numérico para campos numéricos
    try {
      List<String> numericFields = [];
      if (bandera == 1) {
        numericFields.addAll([
          simulacionesCantidadController.text,
          simulacionesValorController.text,
          anulacionesCantidadController.text,
          anulacionesValorController.text,
          sobrantesController.text,
        ]);
      }
      numericFields.forEach((text) {
        if (text.isNotEmpty) int.parse(text);
      });
    } catch (e) {
      Get.snackbar(
        'Formato Inválido',
        'Los valores numéricos deben ser válidos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Movimiento _buildMovimiento(Usuario usuario, List<Movimiento> movimientos) {
    return Movimiento(
        turno: usuario.turno,
        idturno: usuario.idTurno,
        idSupervisor: usuarioSession.id,
        idCajero: usuario.id,
        idTipoMovimiento: '7', // Tipo de movimiento para faltante
        idPeaje: usuarioSession.idPeaje,
        via: usuario.via,
        recibe20D: billetes20ControllerR.text.isEmpty
            ? '0'
            : billetes20ControllerR.text,
        recibe10D: billetes10ControllerR.text.isEmpty
            ? '0'
            : billetes10ControllerR.text,
        recibe5D:
            billetes5ControllerR.text.isEmpty ? '0' : billetes5ControllerR.text,
        recibe1D:
            billetes1ControllerR.text.isEmpty ? '0' : billetes1ControllerR.text,
        recibe50C:
            Moneda50ControllerR.text.isEmpty ? '0' : Moneda50ControllerR.text,
        recibe25C:
            Moneda25ControllerR.text.isEmpty ? '0' : Moneda25ControllerR.text,
        recibe10C:
            Moneda10ControllerR.text.isEmpty ? '0' : Moneda10ControllerR.text,
        recibe5C:
            Moneda5ControllerR.text.isEmpty ? '0' : Moneda5ControllerR.text,
        entrega1D:
            billetes1ControllerE.text.isEmpty ? '0' : billetes1ControllerE.text,
        entrega5D:
            billetes5ControllerE.text.isEmpty ? '0' : billetes5ControllerE.text,
        entrega10D: billetes10ControllerE.text.isEmpty
            ? '0'
            : billetes10ControllerE.text,
        entrega20D: billetes20ControllerE.text.isEmpty
            ? '0'
            : billetes20ControllerE.text,
        entrega50C:
            Moneda50ControllerE.text.isEmpty ? '0' : Moneda50ControllerE.text,
        entrega25C:
            Moneda25ControllerE.text.isEmpty ? '0' : Moneda25ControllerE.text,
        entrega10C:
            Moneda10ControllerE.text.isEmpty ? '0' : Moneda10ControllerE.text,
        sobrante:
            sobrantesController.text.isEmpty ? '0' : sobrantesController.text,
        partetrabajo: parteTrabajoController.text.isEmpty
            ? pdt
            : parteTrabajoController.text,
        simulaciones:
            (bandera == 1 && simulacionesCantidadController.text.isNotEmpty)
                ? simulacionesCantidadController.text
                : '0',
        valorsimulaciones:
            (bandera == 1 && simulacionesValorController.text.isNotEmpty)
                ? simulacionesValorController.text
                : '0',
        anulaciones:
            (bandera == 1 && anulacionesCantidadController.text.isNotEmpty)
                ? anulacionesCantidadController.text
                : '0',
        valoranulaciones:
            (bandera == 1 && anulacionesValorController.text.isNotEmpty)
                ? anulacionesValorController.text
                : '0');
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
        'Transacción Exitosa',
        'El faltante ha sido registrado correctamente',
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
            Text('Error en Transacción'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No se pudo procesar el faltante:'),
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
              actualizarLiquidacion(Get.context!, movimientos!);
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
      'Ocurrió un error al procesar el faltante',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _clearFields() {
    if (bandera == 1) {
      simulacionesCantidadController.clear();
      simulacionesValorController.clear();
      anulacionesCantidadController.clear();
      anulacionesValorController.clear();
      sobrantesController.clear();
    }
    parteTrabajoController.clear();
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
