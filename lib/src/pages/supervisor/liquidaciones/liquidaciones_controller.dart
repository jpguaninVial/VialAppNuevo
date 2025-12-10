import 'package:asistencia_vial_app/src/environment/environment.dart';
import 'package:asistencia_vial_app/src/models/response_api.dart';
import 'package:asistencia_vial_app/src/provider/turno_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../../../models/movimiento.dart';
import '../../../models/usuario.dart';
import '../../../provider/movimiento_provider.dart';
import '../../editar_transaccion/editar_transaccion.dart';
import '../retiros_parciales/retiro_parcial.dart';
import '../../../controllers/loading_controller.dart';
import '../../../controllers/improved_connection_controller.dart';

class LiquidacionesController extends GetxController {
  static const String LOADING_KEY = 'liquidaciones';

  Socket socket = io('${Environment.API_URL}', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false
  });

  TextEditingController billetes20Controller = TextEditingController();
  TextEditingController billetes10Controller = TextEditingController();
  TextEditingController billetes5Controller = TextEditingController();
  TextEditingController billetes2Controller = TextEditingController();
  TextEditingController billetes1Controller = TextEditingController();
  TextEditingController moneda1dController = TextEditingController();
  TextEditingController Moneda50Controller = TextEditingController();
  TextEditingController Moneda25Controller = TextEditingController();
  TextEditingController Moneda10Controller = TextEditingController();
  TextEditingController Moneda5Controller = TextEditingController();
  TextEditingController Moneda1Controller = TextEditingController();

  MovimientoProvider movimientoProvider = MovimientoProvider();
  TurnoProvider turnoProvider = TurnoProvider();

  Usuario usuarioSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Usuario? usuario;
  List<Movimiento>? movimientos;

  LiquidacionesController(Usuario usuario, List<Movimiento> movimientos) {
    this.usuario = usuario;
    this.movimientos = movimientos;
    connectAndListen();
  }

  void connectAndListen() {
    socket.connect();
    socket.onConnect((data) => {print('Este dispositivo se conecto a SOCKET')});
  }

  void goToEditTransaccion(Movimiento movimiento) {
    Get.off(
      () => EditarTransaccionPage(
          movimiento: movimiento), // Página a la que navegas
    );
  }

  void goToRetiroParcial(Usuario usuario) {
    Get.to(
      () => RetiroParcialPage(usuario: usuario), // Página a la que navegas
      arguments: usuario, // Envía el objeto Usuario como argumento
    );
  }

  void registrarLiquidacion(BuildContext context, Usuario usuario,
      List<Movimiento> movimientos) async {
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
        .setLoading(LOADING_KEY, message: 'Procesando liquidacion...');

    try {
      //final liquidacion = movimientos.firstWhere((m) => m.idTipoMovimiento == '4', orElse: () => Movimiento());
      final liquidacion = movimientos.firstWhere(
          (m) => m.idTipoMovimiento == '4',
          orElse: () =>
              Movimiento(partetrabajo: '0') // Asignar '0' si no hay liquidación
          );

      // Validar valores: si están vacíos, asignar '0'
      String recibe1C =
          Moneda1Controller.text.isEmpty ? '0' : Moneda1Controller.text;
      String recibe5C =
          Moneda5Controller.text.isEmpty ? '0' : Moneda5Controller.text;
      String recibe10C =
          Moneda10Controller.text.isEmpty ? '0' : Moneda10Controller.text;
      String recibe25C =
          Moneda25Controller.text.isEmpty ? '0' : Moneda25Controller.text;
      String recibe50C =
          Moneda50Controller.text.isEmpty ? '0' : Moneda50Controller.text;
      String recibe1D =
          moneda1dController.text.isEmpty ? '0' : moneda1dController.text;
      String recibe1DB =
          billetes1Controller.text.isEmpty ? '0' : billetes1Controller.text;
      String recibe2D =
          billetes2Controller.text.isEmpty ? '0' : billetes2Controller.text;
      String recibe5D =
          billetes5Controller.text.isEmpty ? '0' : billetes5Controller.text;
      String recibe10D =
          billetes10Controller.text.isEmpty ? '0' : billetes10Controller.text;
      String recibe20D =
          billetes20Controller.text.isEmpty ? '0' : billetes20Controller.text;

      // Crear el objeto Movimiento
      Movimiento movimiento = Movimiento(
          id: liquidacion.id,
          turno: usuario.turno,
          idturno: usuario.idTurno,
          idSupervisor: usuarioSession.id,
          idCajero: usuario.id,
          idTipoMovimiento: '4',
          idPeaje: usuarioSession.idPeaje,
          via: usuario.via,
          partetrabajo: liquidacion.partetrabajo,
          recibe1C: recibe1C,
          recibe5C: recibe5C,
          recibe10C: recibe10C,
          recibe25C: recibe25C,
          recibe50C: recibe50C,
          recibe2D: recibe2D,
          recibe1D: recibe1D,
          recibe1DB: recibe1DB,
          recibe5D: recibe5D,
          recibe10D: recibe10D,
          recibe20D: recibe20D,
          entrega1C: '0',
          entrega5C: '0',
          entrega10C: '0',
          entrega25C: '0',
          entrega50C: '0',
          entrega1D: '0',
          entrega1DB: '0',
          entrega5D: '0',
          entrega10D: '0',
          entrega20D: '0',
          anulaciones: '0',
          valoranulaciones: '0',
          simulaciones: '0',
          valorsimulaciones: '0',
          sobrante: '0');

      // Verificar si ya existe una liquidación (tiene id válido)
      final bool liquidacionExiste = liquidacion.id != null &&
          liquidacion.id!.isNotEmpty &&
          liquidacion.id != '0';

      if (!liquidacionExiste) {
        // No existe liquidación, crear nueva
        final result = await _submitTransactionWithRetries(movimiento, true);
        // Manejar respuesta
        await _handleTransactionResult(result);
      } else {
        // Ya existe liquidación, actualizar (agregar faltantes/sobrantes)
        final result = await _submitTransactionWithRetries(movimiento, false);
        // Manejar respuesta
        await _handleTransactionResult(result);
      }
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un error inesperado ${e}');
    } finally {}
  }

  Future<TransactionResult> _submitTransactionWithRetries(
      Movimiento movimiento, bool isNew) async {
    int maxRetries = 3;
    int currentRetry = 0;

    while (currentRetry < maxRetries) {
      try {
        LoadingController.to.setLoading(LOADING_KEY,
            message: currentRetry == 0
                ? 'Enviando transacción...'
                : 'Reintentando... (${currentRetry + 1}/$maxRetries)');
        final response = isNew
            ? await movimientoProvider
                .createOnlineOnly(movimiento)
                .timeout(Duration(seconds: 45))
            : await movimientoProvider
                .updateLiquidacionCompletaOnlineOnly(movimiento)
                .timeout(Duration(seconds: 45));
        final response2 =
            await turnoProvider.updateEstado(usuario?.idTurno ?? '');

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
        'La liquidación ha sido registrada correctamente',
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
            Text('No se pudo procesar la liquidacion:'),
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
              registrarLiquidacion(Get.context!, usuario!, movimientos!);
            },
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
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
                'No se puede procesar la transaccion sin conexión al servidor.'),
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
                registrarLiquidacion(Get.context!, usuario!, movimientos!);
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

  void _handleError(dynamic error) {
    Get.snackbar(
      'Error Inesperado',
      'Ocurrió un error al procesar la liquidacion',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _clearFields() {
    billetes20Controller.clear();
    billetes10Controller.clear();
    billetes5Controller.clear();
    moneda1dController.clear();
    Moneda50Controller.clear();
    Moneda25Controller.clear();
    Moneda10Controller.clear();
    Moneda5Controller.clear();
  }

  @override
  void onClose() {
    LoadingController.to.clearLoading(LOADING_KEY);
    super.onClose();
    socket.disconnect();
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
