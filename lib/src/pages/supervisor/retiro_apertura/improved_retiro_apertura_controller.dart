import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../models/movimiento.dart';
import '../../../models/usuario.dart';
import '../../../provider/movimiento_provider.dart';
import '../../../controllers/loading_controller.dart';
import '../../../controllers/improved_connection_controller.dart';

class ImprovedRetiroAperturaController extends GetxController {
  static const String LOADING_KEY = 'retiro_apertura';

  final MovimientoProvider _movimientoProvider = MovimientoProvider();
  final Usuario usuarioSession =
      Usuario.fromJson(GetStorage().read('usuario') ?? {});
  late String idmovimiento;
  late String via;
  Usuario? usuario;
  Movimiento? movimiento;
  RxBool enProgresoApertura = false.obs;
  RxBool aperturaCompleta = false.obs;
  RxDouble Entregado = 0.0.obs;
  RxDouble Recibido = 0.0.obs;

  // Controllers para los campos
  TextEditingController billetes20Controller = TextEditingController();
  TextEditingController billetes10RecibeController = TextEditingController();
  TextEditingController billetes5RecibeController = TextEditingController();
  TextEditingController Moneda50RecibeController = TextEditingController();
  TextEditingController Moneda25RecibeController = TextEditingController();
  TextEditingController Moneda10RecibeController = TextEditingController();
  TextEditingController Moneda5RecibeController = TextEditingController();
  TextEditingController Moneda1RecibeController = TextEditingController();
  TextEditingController billetes1RecibeController = TextEditingController();
  TextEditingController billetes10EntregaController = TextEditingController();
  TextEditingController billetes5EntregaController = TextEditingController();
  TextEditingController billetes1EntregaController = TextEditingController();
  TextEditingController Moneda50EntregaController = TextEditingController();
  TextEditingController Moneda25EntregaController = TextEditingController();
  TextEditingController Moneda10EntregaController = TextEditingController();
  TextEditingController Moneda5EntregaController = TextEditingController();
  TextEditingController Moneda1EntregaController = TextEditingController();

  ImprovedRetiroAperturaController(Usuario usuario, Movimiento movimiento) {
    this.usuario = usuario;
    this.movimiento = movimiento;

    billetes10EntregaController.text = movimiento.entrega10D?.toString() ?? '0';
    billetes5EntregaController.text = movimiento.entrega5D?.toString() ?? '0';
    billetes1EntregaController.text = movimiento.entrega1D?.toString() ?? '0';
    Moneda50EntregaController.text = movimiento.entrega50C?.toString() ?? '0';
    Moneda25EntregaController.text = movimiento.entrega25C?.toString() ?? '0';
    Moneda5EntregaController.text = movimiento.entrega10C?.toString() ?? '0';
    Moneda10EntregaController.text = movimiento.entrega5C?.toString() ?? '0';
    Moneda1EntregaController.text = movimiento.entrega1C?.toString() ?? '0';
    movimiento.recibe20D == '0'
        ? movimiento.recibe20D = ''
        : billetes20Controller.text = movimiento.recibe20D ?? '';
    movimiento.recibe10D == '0'
        ? movimiento.recibe10D = ''
        : billetes10RecibeController.text = movimiento.recibe10D ?? '';
    movimiento.recibe5D == '0'
        ? movimiento.recibe5D = ''
        : billetes5RecibeController.text = movimiento.recibe5D ?? '';
    movimiento.recibe1D == '0'
        ? movimiento.recibe1D = ''
        : billetes1RecibeController.text = movimiento.recibe1D ?? '';
    movimiento.recibe50C == '0'
        ? movimiento.recibe50C = ''
        : Moneda50RecibeController.text = movimiento.recibe50C ?? '';
    movimiento.recibe25C == '0'
        ? movimiento.recibe25C = ''
        : Moneda25RecibeController.text = movimiento.recibe25C ?? '';
    movimiento.recibe10C == '0'
        ? movimiento.recibe10C = ''
        : Moneda10RecibeController.text = movimiento.recibe10C ?? '';
    movimiento.recibe5C == '0'
        ? movimiento.recibe5C = ''
        : Moneda5RecibeController.text = movimiento.recibe5C ?? '';
    movimiento.recibe1C == '0'
        ? movimiento.recibe1C = ''
        : Moneda1RecibeController.text = movimiento.recibe1C ?? '';
    idmovimiento = movimiento.id?.toString() ?? '0';
    via = movimiento.via?.toString() ?? '0';
  }

  /// Registro de retiro de apertura con validación de conexión obligatoria
  Future<void> registrarRetiroApertura(
      BuildContext context, Usuario usuario) async {
    // Validar que no haya una operación en curso
    if (LoadingController.to.isLoading(LOADING_KEY)) {
      Get.snackbar('Operación en Curso', 'Por favor espere...');
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
        .setLoading(LOADING_KEY, message: 'Procesando retiro de apertura...');

    try {
      String entrega10D = billetes10EntregaController.text.isEmpty
          ? '0'
          : billetes10EntregaController.text;
      String entrega5D = billetes5EntregaController.text.isEmpty
          ? '0'
          : billetes5EntregaController.text;
      String entrega1D = billetes1EntregaController.text.isEmpty
          ? '0'
          : billetes1EntregaController.text;
      String entrega50C = Moneda50EntregaController.text.isEmpty
          ? '0'
          : Moneda50EntregaController.text;
      String entrega25C = Moneda25EntregaController.text.isEmpty
          ? '0'
          : Moneda25EntregaController.text;
      String entrega10C = Moneda10EntregaController.text.isEmpty
          ? '0'
          : Moneda10EntregaController.text;
      String entrega5C = Moneda5EntregaController.text.isEmpty
          ? '0'
          : Moneda5EntregaController.text;
      String entrega1C = Moneda1EntregaController.text.isEmpty
          ? '0'
          : Moneda1EntregaController.text;

      String recibe1D = billetes1RecibeController.text.isEmpty
          ? '0'
          : billetes1RecibeController.text;
      String recibe5D = billetes5RecibeController.text.isEmpty
          ? '0'
          : billetes5RecibeController.text;
      String recibe10D = billetes10RecibeController.text.isEmpty
          ? '0'
          : billetes10RecibeController.text;
      String recibe20D =
          billetes20Controller.text.isEmpty ? '0' : billetes20Controller.text;
      String recibe50C = Moneda50RecibeController.text.isEmpty
          ? '0'
          : Moneda50RecibeController.text;
      String recibe25C = Moneda25RecibeController.text.isEmpty
          ? '0'
          : Moneda25RecibeController.text;
      String recibe10C = Moneda10RecibeController.text.isEmpty
          ? '0'
          : Moneda10RecibeController.text;
      String recibe5C = Moneda5RecibeController.text.isEmpty
          ? '0'
          : Moneda5RecibeController.text;
      String recibe1C = Moneda1RecibeController.text.isEmpty
          ? '0'
          : Moneda1RecibeController.text;

      // Crear el objeto Movimiento
      Movimiento movimiento = Movimiento(
          id: idmovimiento,
          via: via,
          idSupervisor: usuarioSession.id,
          entrega20D: '0',
          entrega10D: entrega10D,
          entrega5D: entrega5D,
          entrega1D: entrega1D,
          entrega50C: entrega50C,
          entrega25C: entrega25C,
          entrega10C: entrega10C,
          entrega5C: entrega5C,
          entrega1C: entrega1C,
          recibe1C: recibe1C,
          recibe5C: recibe5C,
          recibe10C: recibe10C,
          recibe25C: recibe25C,
          recibe50C: recibe50C,
          recibe1D: recibe1D,
          recibe5D: recibe5D,
          recibe10D: recibe10D,
          recibe20D: recibe20D);

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
            Text(
                'No se puede procesar el retiro de apertura sin conexión al servidor.'),
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
                registrarRetiroApertura(Get.context!, usuario!);
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
            .update(movimiento)
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
        'El retiro de apertura ha sido registrado correctamente',
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
            Text('No se pudo procesar el retiro de apertura:'),
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
              registrarRetiroApertura(Get.context!, usuario!);
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
      'Ocurrió un error al procesar el retiro de apertura',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _clearFields() {
    billetes20Controller.clear();
    billetes10RecibeController.clear();
    billetes5RecibeController.clear();
    billetes1RecibeController.clear();
    Moneda50RecibeController.clear();
    Moneda25RecibeController.clear();
    Moneda10RecibeController.clear();
    Moneda5RecibeController.clear();
    Moneda1RecibeController.clear();
    billetes10EntregaController.clear();
    billetes5EntregaController.clear();
    billetes1EntregaController.clear();
    Moneda50EntregaController.clear();
    Moneda25EntregaController.clear();
    Moneda10EntregaController.clear();
    Moneda5EntregaController.clear();
    Moneda1EntregaController.clear();
  }

  void verificarApertura() {
    enProgresoApertura.value = true;

    final totalEntregado = (int.tryParse(billetes10EntregaController.text) ??
                0) *
            10 +
        (int.tryParse(billetes5EntregaController.text) ?? 0) * 5 +
        (int.tryParse(billetes1EntregaController.text) ?? 0) * 1 +
        ((int.tryParse(Moneda50EntregaController.text) ?? 0) * 0.5).toDouble() +
        ((int.tryParse(Moneda25EntregaController.text) ?? 0) * 0.25)
            .toDouble() +
        ((int.tryParse(Moneda10EntregaController.text) ?? 0) * 0.5).toDouble() +
        ((int.tryParse(Moneda5EntregaController.text) ?? 0) * 0.05).toDouble() +
        ((int.tryParse(Moneda5EntregaController.text) ?? 0) * 0.01).toDouble();

    final totalRecibido = (int.tryParse(billetes20Controller.text) ?? 0) * 20 +
        (int.tryParse(billetes10RecibeController.text) ?? 0) * 10 +
        (int.tryParse(billetes5RecibeController.text) ?? 0) * 5 +
        (int.tryParse(billetes1RecibeController.text) ?? 0) * 1 +
        ((int.tryParse(Moneda50RecibeController.text) ?? 0) * 0.5).toDouble() +
        ((int.tryParse(Moneda25RecibeController.text) ?? 0) * 0.25).toDouble() +
        ((int.tryParse(Moneda10RecibeController.text) ?? 0) * 0.5).toDouble() +
        ((int.tryParse(Moneda5RecibeController.text) ?? 0) * 0.05).toDouble() +
        ((int.tryParse(Moneda5RecibeController.text) ?? 0) * 0.01).toDouble();

    aperturaCompleta.value = (totalEntregado - totalRecibido) == 0;
    Entregado.value = totalEntregado;
    Recibido.value = totalRecibido;

    // Si apertura está completa, deshabilitar los campos y ocultar el botón
    if (aperturaCompleta.value) {
      enProgresoApertura.value = false;
    }
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
