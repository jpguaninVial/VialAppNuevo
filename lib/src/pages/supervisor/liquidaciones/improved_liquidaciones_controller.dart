import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../../../environment/environment.dart';
import '../../../models/movimiento.dart';
import '../../../models/usuario.dart';
import '../../../provider/movimiento_provider.dart';
import '../../../provider/turno_provider.dart';
import '../../../controllers/loading_controller.dart';
import '../../../controllers/improved_connection_controller.dart';
import '../../editar_transaccion/editar_transaccion.dart';
import '../retiros_parciales/retiro_parcial.dart';

class ImprovedLiquidacionesController extends GetxController {
  static const String LOADING_KEY = 'liquidacion';

  final MovimientoProvider _movimientoProvider = MovimientoProvider();
  final TurnoProvider _turnoProvider = TurnoProvider();
  final Usuario usuarioSession =
      Usuario.fromJson(GetStorage().read('usuario') ?? {});

  Socket socket = io('${Environment.API_URL}', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false
  });

  Usuario? usuario;
  List<Movimiento>? movimientos;

  // Controllers para los campos
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

  ImprovedLiquidacionesController(
      Usuario usuario, List<Movimiento> movimientos) {
    this.usuario = usuario;
    this.movimientos = movimientos;
    connectAndListen();
  }

  void connectAndListen() {
    socket.connect();
    socket.onConnect((data) => {print('Este dispositivo se conectó a SOCKET')});
  }

  /// Registro de liquidación con validación de conexión obligatoria
  Future<void> registrarLiquidacion(BuildContext context, Usuario usuario,
      List<Movimiento> movimientos) async {
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
        .setLoading(LOADING_KEY, message: 'Procesando liquidación...');

    try {
      // Crear el movimiento
      final movimiento = _buildMovimiento(usuario, movimientos);

      // Enviar la petición con múltiples reintentos
      final result = await _submitTransactionWithRetries(movimiento, usuario);

      // Manejar respuesta
      await _handleTransactionResult(result, usuario);
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
                'No se puede procesar la liquidación sin conexión al servidor.'),
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
                    'Las liquidaciones requieren conexión inmediata para actualizar el estado del turno y la bóveda.',
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

  bool _validateFields() {
    // Verificar que al menos un campo tenga valor
    final hasValues = [
      billetes20Controller.text,
      billetes10Controller.text,
      billetes5Controller.text,
      billetes2Controller.text,
      billetes1Controller.text,
      moneda1dController.text,
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
        billetes20Controller.text,
        billetes10Controller.text,
        billetes5Controller.text,
        billetes2Controller.text,
        billetes1Controller.text,
        moneda1dController.text,
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

  Movimiento _buildMovimiento(Usuario usuario, List<Movimiento> movimientos) {
    final liquidacion = movimientos.firstWhere((m) => m.idTipoMovimiento == '4',
        orElse: () => Movimiento(partetrabajo: '0'));

    return Movimiento(
        id: liquidacion.id,
        turno: usuario.turno,
        idturno: usuario.idTurno,
        idSupervisor: usuarioSession.id,
        idCajero: usuario.id,
        idTipoMovimiento: '4',
        idPeaje: usuarioSession.idPeaje,
        via: usuario.via,
        partetrabajo: liquidacion.partetrabajo,
        recibe1C: Moneda1Controller.text.isEmpty ? '0' : Moneda1Controller.text,
        recibe5C: Moneda5Controller.text.isEmpty ? '0' : Moneda5Controller.text,
        recibe10C:
            Moneda10Controller.text.isEmpty ? '0' : Moneda10Controller.text,
        recibe25C:
            Moneda25Controller.text.isEmpty ? '0' : Moneda25Controller.text,
        recibe50C:
            Moneda50Controller.text.isEmpty ? '0' : Moneda50Controller.text,
        recibe2D:
            billetes2Controller.text.isEmpty ? '0' : billetes2Controller.text,
        recibe1D:
            moneda1dController.text.isEmpty ? '0' : moneda1dController.text,
        recibe1DB:
            billetes1Controller.text.isEmpty ? '0' : billetes1Controller.text,
        recibe5D:
            billetes5Controller.text.isEmpty ? '0' : billetes5Controller.text,
        recibe10D:
            billetes10Controller.text.isEmpty ? '0' : billetes10Controller.text,
        recibe20D:
            billetes20Controller.text.isEmpty ? '0' : billetes20Controller.text,
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
  }

  Future<TransactionResult> _submitTransactionWithRetries(
      Movimiento movimiento, Usuario usuario) async {
    int maxRetries = 3;
    int currentRetry = 0;

    while (currentRetry < maxRetries) {
      try {
        LoadingController.to.setLoading(LOADING_KEY,
            message: currentRetry == 0
                ? 'Enviando liquidación...'
                : 'Reintentando... (${currentRetry + 1}/$maxRetries)');

        Response response;
        Response response2;

        // Verificar si ya existe una liquidación (tiene id válido)
        final bool liquidacionExiste = movimiento.id != null &&
            movimiento.id!.isNotEmpty &&
            movimiento.id != '0';

        if (!liquidacionExiste) {
          // No existe liquidación, crear nueva
          response = await _movimientoProvider
              .createOnlineOnly(movimiento)
              .timeout(Duration(seconds: 45));

          if (response.statusCode == 201) {
            response2 = await _turnoProvider
                .updateEstado(usuario.idTurno ?? '')
                .timeout(Duration(seconds: 30));
          } else {
            return TransactionResult(
              success: false,
              statusCode: response.statusCode ?? 0,
              error: 'Error al crear la liquidación',
            );
          }
        } else {
          // Ya existe liquidación, actualizar (agregar faltantes/sobrantes)
          response = await _movimientoProvider
              .updateLiquidacionCompletaOnlineOnly(movimiento)
              .timeout(Duration(seconds: 45));

          if (response.statusCode == 201) {
            response2 = await _turnoProvider
                .updateEstado(usuario.idTurno ?? '')
                .timeout(Duration(seconds: 30));
          } else {
            return TransactionResult(
              success: false,
              statusCode: response.statusCode ?? 0,
              error: 'Error al actualizar la liquidación',
            );
          }
        }

        if ((response.statusCode ?? 0) == 201 &&
            (response2.statusCode ?? 0) == 200) {
          // Emitir evento del socket
          socket.emit('actualizar_turno', {'id_turno': usuario.idTurno});

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

  Future<void> _handleTransactionResult(
      TransactionResult result, Usuario usuario) async {
    if (result.success) {
      Get.snackbar(
        'Liquidación Exitosa',
        'La liquidación ha sido procesada correctamente',
        icon: Icon(Icons.check_circle, color: Colors.white),
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _clearFields();
      Get.offNamedUntil('/home', (route) => false, arguments: {'index': 2});
    } else {
      await _showErrorDialog(result, usuario);
    }
  }

  Future<void> _showErrorDialog(
      TransactionResult result, Usuario usuario) async {
    await Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error en Liquidación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No se pudo procesar la liquidación:'),
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
              registrarLiquidacion(Get.context!, usuario, movimientos!);
            },
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void goToEditTransaccion(Movimiento movimiento) {
    Get.off(() => EditarTransaccionPage(movimiento: movimiento));
  }

  void goToRetiroParcial(Usuario usuario) {
    Get.to(() => RetiroParcialPage(usuario: usuario), arguments: usuario);
  }

  void _handleError(dynamic error) {
    Get.snackbar(
      'Error Inesperado',
      'Ocurrió un error al procesar la liquidación',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _clearFields() {
    billetes20Controller.clear();
    billetes10Controller.clear();
    billetes5Controller.clear();
    billetes2Controller.clear();
    billetes1Controller.clear();
    moneda1dController.clear();
    Moneda50Controller.clear();
    Moneda25Controller.clear();
    Moneda10Controller.clear();
    Moneda5Controller.clear();
    Moneda1Controller.clear();
  }

  @override
  void onClose() {
    LoadingController.to.clearLoading(LOADING_KEY);
    socket.disconnect();
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
