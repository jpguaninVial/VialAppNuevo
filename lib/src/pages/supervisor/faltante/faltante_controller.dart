import 'package:asistencia_vial_app/src/pages/reportes/liquidacion_cajero/reporte_liquidacion.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../../../models/movimiento.dart';
import '../../../models/response_api.dart';
import '../../../models/usuario.dart';
import '../../../provider/movimiento_provider.dart';
import '../../../provider/turno_provider.dart';

class FaltanteController extends GetxController {
  // Constants
  static const String _TIPO_APERTURA = '1';
  static const String _TIPO_LIQUIDACION = '4';
  static const String _TIPO_FALTANTE = '6';

  // Dependencies
  final MovimientoProvider _movimientoProvider = MovimientoProvider();
  final TurnoProvider _turnoProvider = TurnoProvider();
  final Usuario _usuarioSession =
      Usuario.fromJson(GetStorage().read('usuario') ?? {});

  // Properties
  late final Usuario usuario;
  late final List<Movimiento> movimientos;
  late final int bandera;
  late final String parteTrabajo;
  late final String idMovimientoFaltante;

  // Form Controllers - Liquidación
  final simulacionesCantidadController = TextEditingController();
  final simulacionesValorController = TextEditingController();
  final anulacionesCantidadController = TextEditingController();
  final anulacionesValorController = TextEditingController();
  final sobrantesController = TextEditingController();
  final parteTrabajoController = TextEditingController();

  // Form Controllers - Entrega
  final billetes20ControllerE = TextEditingController();
  final billetes10ControllerE = TextEditingController();
  final billetes5ControllerE = TextEditingController();
  final billetes1ControllerE = TextEditingController();
  final moneda50ControllerE = TextEditingController();
  final moneda25ControllerE = TextEditingController();
  final moneda10ControllerE = TextEditingController();
  final moneda5ControllerE = TextEditingController();

  // Form Controllers - Recibe
  final billetes20ControllerR = TextEditingController();
  final billetes10ControllerR = TextEditingController();
  final billetes5ControllerR = TextEditingController();
  final billetes1ControllerR = TextEditingController();
  final moneda50ControllerR = TextEditingController();
  final moneda25ControllerR = TextEditingController();
  final moneda10ControllerR = TextEditingController();
  final moneda5ControllerR = TextEditingController();

  // Observable
  final isFaltanteVisible = false.obs;

  FaltanteController(this.usuario, this.movimientos, this.bandera) {
    _initializeController();
  }

  void _initializeController() {
    final liquidacion = _findMovimientoByTipo(_TIPO_LIQUIDACION);
    final faltante = _findMovimientoByTipo(_TIPO_FALTANTE);
    final apertura = _findMovimientoByTipo(_TIPO_APERTURA);

    parteTrabajo = _generateParteTrabajo(apertura);
    idMovimientoFaltante = faltante.id?.toString() ?? '0';

    _initializeLiquidacionFields(liquidacion);
    _initializeFaltanteFields(faltante);
  }

  Movimiento _findMovimientoByTipo(String tipo) {
    return movimientos.firstWhere(
      (m) => m.idTipoMovimiento == tipo,
      orElse: () => Movimiento(),
    );
  }

  String _generateParteTrabajo(Movimiento apertura) {
    DateTime fechaApertura = DateTime.parse(apertura.fecha ?? '');
    if (fechaApertura.hour == 23) {
      fechaApertura = fechaApertura.add(const Duration(days: 1));
    }
    String formattedFecha = DateFormat('ddMMyyyy').format(fechaApertura);
    return '${usuario.via ?? '0'}$formattedFecha';
  }

  void _initializeLiquidacionFields(Movimiento liquidacion) {
    parteTrabajoController.text =
        liquidacion.partetrabajo?.toString() ?? parteTrabajo;
    simulacionesCantidadController.text =
        liquidacion.simulaciones?.toString() ?? '';
    simulacionesValorController.text =
        liquidacion.valorsimulaciones?.toString() ?? '';
    anulacionesCantidadController.text =
        liquidacion.anulaciones?.toString() ?? '';
    anulacionesValorController.text =
        liquidacion.valoranulaciones?.toString() ?? '';
    sobrantesController.text = liquidacion.sobrante?.toString() ?? '';
  }

  void _initializeFaltanteFields(Movimiento faltante) {
    // Entrega
    _setControllerValue(billetes20ControllerE, faltante.entrega20D);
    _setControllerValue(billetes10ControllerE, faltante.entrega10D);
    _setControllerValue(billetes5ControllerE, faltante.entrega5D);
    _setControllerValue(billetes1ControllerE, faltante.entrega1D);
    _setControllerValue(moneda50ControllerE, faltante.entrega50C);
    _setControllerValue(moneda25ControllerE, faltante.entrega25C);
    _setControllerValue(moneda10ControllerE, faltante.entrega10C);
    _setControllerValue(moneda5ControllerE, faltante.entrega5C);

    // Recibe
    _setControllerValue(billetes20ControllerR, faltante.recibe20D);
    _setControllerValue(billetes10ControllerR, faltante.recibe10D);
    _setControllerValue(billetes5ControllerR, faltante.recibe5D);
    _setControllerValue(billetes1ControllerR, faltante.recibe1D);
    _setControllerValue(moneda50ControllerR, faltante.recibe50C);
    _setControllerValue(moneda25ControllerR, faltante.recibe25C);
    _setControllerValue(moneda10ControllerR, faltante.recibe10C);
    _setControllerValue(moneda5ControllerR, faltante.recibe5C);
  }

  void _setControllerValue(TextEditingController controller, String? value) {
    if (value != null && value != '0') {
      controller.text = value;
    }
  }

  // ...existing code...
  // ...existing code...
  Future<void> actualizarLiquidacion(BuildContext context) async {
    try {
      final formData = _extractFormData();
      final totalRecibido = _calculateTotalRecibido(formData);

      if (bandera == 1) {
        if (totalRecibido > 0) {
          await _crearNuevoFaltante(formData); // Crea movimiento tipo 6
        }
        await _actualizarSoloLiquidacion(formData); // Actualiza tipo 4
      } else if (bandera == 2) {
        await _procesarLiquidacion(formData);
      }
    } catch (e) {
      _showErrorSnackbar('Ocurrió un error inesperado: ${e.toString()}');
    }
  }
  // ...existing code...
  // ...existing code...

  Map<String, String> _extractFormData() {
    return {
      // Recibe
      'recibe5C': _getControllerValue(moneda5ControllerR),
      'recibe10C': _getControllerValue(moneda10ControllerR),
      'recibe25C': _getControllerValue(moneda25ControllerR),
      'recibe50C': _getControllerValue(moneda50ControllerR),
      'recibe1D': _getControllerValue(billetes1ControllerR),
      'recibe5D': _getControllerValue(billetes5ControllerR),
      'recibe10D': _getControllerValue(billetes10ControllerR),
      'recibe20D': _getControllerValue(billetes20ControllerR),

      // Entrega
      'entrega5C': _getControllerValue(moneda5ControllerE),
      'entrega10C': _getControllerValue(moneda10ControllerE),
      'entrega25C': _getControllerValue(moneda25ControllerE),
      'entrega50C': _getControllerValue(moneda50ControllerE),
      'entrega1D': _getControllerValue(billetes1ControllerE),
      'entrega5D': _getControllerValue(billetes5ControllerE),
      'entrega10D': _getControllerValue(billetes10ControllerE),
      'entrega20D': _getControllerValue(billetes20ControllerE),

      // Liquidación
      'anulaciones': anulacionesCantidadController.text.trim(),
      'valoranulaciones': anulacionesValorController.text.trim(),
      'simulaciones': simulacionesCantidadController.text.trim(),
      'valorsimulaciones': simulacionesValorController.text.trim(),
      'sobrante': sobrantesController.text.trim(),
      'partetrabajo': parteTrabajoController.text.isEmpty
          ? parteTrabajo
          : parteTrabajoController.text.trim(),
    };
  }

  String _getControllerValue(TextEditingController controller) {
    return controller.text.isEmpty ? '0' : controller.text.trim();
  }

  double _calculateTotalRecibido(Map<String, String> data) {
    return (double.parse(data['recibe5C']!) * 0.05) +
        (double.parse(data['recibe10C']!) * 0.10) +
        (double.parse(data['recibe25C']!) * 0.25) +
        (double.parse(data['recibe50C']!) * 0.50) +
        double.parse(data['recibe1D']!) +
        (double.parse(data['recibe5D']!) * 5) +
        (double.parse(data['recibe10D']!) * 10) +
        (double.parse(data['recibe20D']!) * 20);
  }

  Future<void> _guardarParteTrabajo(Map<String, String> data) async {
    final movimiento = _createParteTrabajo(data);
    final response = await _movimientoProvider.create(movimiento);

    if (response.statusCode == 201) {
      _showSuccessSnackbar('El parte de trabajo se ha registrado');
      _navigateToHome();
    } else if (response.statusCode == 202) {
      _showOfflineSnackbar('El parte de trabajo se ha registrado');
      _navigateToHome();
    }
  }

  Future<void> _procesarLiquidacion(Map<String, String> data) async {
    final totalRecibido = _calculateTotalRecibido(data);

    if (totalRecibido > 0) {
      final yaExisteFaltante =
          movimientos.any((m) => m.idTipoMovimiento == _TIPO_FALTANTE);

      if (yaExisteFaltante) {
        await _modificarFaltante(data);
      } else {
        await _crearNuevoFaltante(data);
      }
    } else {
      await _actualizarSoloLiquidacion(data);
    }
  }

  Future<void> _crearNuevoFaltante(Map<String, String> data) async {
    final liquidacion = _findMovimientoByTipo(_TIPO_LIQUIDACION);
    final movimientoFaltante = _createFaltante(data);

    // Verificar si ya existe una liquidación (tiene id válido)
    final bool liquidacionExiste = liquidacion.id != null &&
        liquidacion.id!.isNotEmpty &&
        liquidacion.id != '0';

    print('Intentando crear faltante: ${movimientoFaltante.toJson()}');
    final response = await _movimientoProvider.create(movimientoFaltante);
    print(
        'Respuesta backend faltante: status=${response.statusCode}, body=${response.body}');

    bool liquidacionOk = false;

    if (!liquidacionExiste) {
      // No existe liquidación, crear nueva
      final movimientoNuevo = _createLiquidacionCompleta(data);
      print(
          'Intentando crear liquidacion (no existía): ${movimientoNuevo.toJson()}');
      final responseLiq = await _movimientoProvider.create(movimientoNuevo);
      print(
          'Respuesta backend crear liquidacion: status=${responseLiq.statusCode}');

      if (responseLiq.statusCode == 201 || responseLiq.statusCode == 202) {
        // Actualizar estado del turno
        await _turnoProvider.updateEstado(usuario.idTurno ?? '');
        liquidacionOk = true;
      }
    } else {
      // Ya existe liquidación, actualizar
      final movimientoLiquidacion = _createLiquidacionUpdate(liquidacion, data);
      print(
          'Intentando actualizar liquidacion: ${movimientoLiquidacion.toJson()}');
      final responseApi =
          await _movimientoProvider.updateLiquidacion(movimientoLiquidacion);
      print(
          'Respuesta backend liquidacion: success=${responseApi.success}, message=${responseApi.message}');

      if (responseApi.success == true) {
        // También actualizar el estado del movimiento para marcarlo como liquidado
        if (liquidacion.estado != '1') {
          liquidacion.idSupervisor = _usuarioSession.id;
          liquidacion.estado = '1';
          await _movimientoProvider.updateEstadoMovimiento(liquidacion);
          print('Estado del movimiento actualizado a liquidado');
        }
        liquidacionOk = true;
      }
    }

    if (liquidacionOk && response.statusCode == 201) {
      _showSuccessSnackbar(
          'La liquidación ha sido procesada - se añadió el faltante');
      await _refreshMovimientos();
      _navigateToReporte();
    } else {
      _showErrorSnackbar('Error al procesar la liquidación o el faltante');
    }
  }

  Future<void> _modificarFaltante(Map<String, String> data) async {
    final liquidacion = _findMovimientoByTipo(_TIPO_LIQUIDACION);
    final movimientoLiquidacion = _createLiquidacionUpdate(liquidacion, data);
    final movimientoFaltante = _createFaltanteUpdate(data);

    print('Intentando modificar faltante: ${movimientoFaltante.toJson()}');
    final responseApi =
        await _movimientoProvider.updateLiquidacion(movimientoLiquidacion);
    print(
        'Intentando actualizar liquidacion: ${movimientoLiquidacion.toJson()}');
    print(
        'Respuesta backend liquidacion: success=${responseApi.success}, message=${responseApi.message}');
    final response = await _movimientoProvider.update(movimientoFaltante);
    print(
        'Respuesta backend faltante: status=${response.statusCode}, body=${response.body}');

    if (responseApi.success == true && response.statusCode == 201) {
      _showSuccessSnackbar('La liquidación ha sido modificada');
      await _refreshMovimientos();
      _navigateToHome();
    } else {
      _showErrorSnackbar(
          responseApi.message ?? 'Error al modificar la liquidación');
    }
  }

  Future<void> _actualizarSoloLiquidacion(Map<String, String> data) async {
    final liquidacion = _findMovimientoByTipo(_TIPO_LIQUIDACION);

    // Verificar si ya existe una liquidación (tiene id válido)
    final bool liquidacionExiste = liquidacion.id != null &&
        liquidacion.id!.isNotEmpty &&
        liquidacion.id != '0';

    if (!liquidacionExiste) {
      // No existe liquidación, crear nueva con todos los datos
      final movimientoNuevo = _createLiquidacionCompleta(data);

      print('Intentando crear liquidacion: ${movimientoNuevo.toJson()}');
      final response = await _movimientoProvider.create(movimientoNuevo);
      print(
          'Respuesta backend crear liquidacion: status=${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 202) {
        // Actualizar estado del turno
        await _turnoProvider.updateEstado(usuario.idTurno ?? '');
        _showSuccessSnackbar('La liquidación ha sido creada correctamente');
        await _refreshMovimientos();
        _navigateToReporte();
      } else {
        _showErrorSnackbar('Error al crear la liquidación');
      }
    } else {
      // Ya existe liquidación, actualizar
      final movimientoLiquidacion = _createLiquidacionUpdate(liquidacion, data);

      print(
          'Intentando actualizar solo liquidacion: ${movimientoLiquidacion.toJson()}');
      final responseApi =
          await _movimientoProvider.updateLiquidacion(movimientoLiquidacion);
      print(
          'Respuesta backend liquidacion: success=${responseApi.success}, message=${responseApi.message}');

      if (responseApi.success == true) {
        // También actualizar el estado del movimiento para marcarlo como liquidado
        if (liquidacion.estado != '1') {
          liquidacion.idSupervisor = _usuarioSession.id;
          liquidacion.estado = '1';
          await _movimientoProvider.updateEstadoMovimiento(liquidacion);
          print('Estado del movimiento actualizado a liquidado');
        }
        _showSuccessSnackbar('La liquidación ha sido actualizada');
        await _refreshMovimientos();
        _navigateToReporte();
      } else {
        _showErrorSnackbar(
            responseApi.message ?? 'Error al actualizar la liquidación');
      }
    }
  }

  /// Crea una liquidación completa con todos los campos necesarios
  Movimiento _createLiquidacionCompleta(Map<String, String> data) {
    return Movimiento(
      turno: usuario.turno,
      idturno: usuario.idTurno,
      idSupervisor: _usuarioSession.id,
      idCajero: usuario.id,
      idTipoMovimiento: _TIPO_LIQUIDACION,
      via: usuario.via,
      idPeaje: _usuarioSession.idPeaje,
      partetrabajo: data['partetrabajo'],
      recibe1C: '0',
      recibe5C: '0',
      recibe10C: '0',
      recibe25C: '0',
      recibe50C: '0',
      recibe1DB: '0',
      recibe1D: '0',
      recibe2D: '0',
      recibe5D: '0',
      recibe10D: '0',
      recibe20D: '0',
      entrega1C: '0',
      entrega5C: '0',
      entrega10C: '0',
      entrega25C: '0',
      entrega50C: '0',
      entrega1DB: '0',
      entrega1D: '0',
      entrega5D: '0',
      entrega10D: '0',
      entrega20D: '0',
      anulaciones: data['anulaciones'] ?? '0',
      valoranulaciones: data['valoranulaciones'] ?? '0',
      simulaciones: data['simulaciones'] ?? '0',
      valorsimulaciones: data['valorsimulaciones'] ?? '0',
      sobrante: data['sobrante'] ?? '0',
      estado: '1', // Marcar como liquidado
    );
  }

  // Movement creation methods
  Movimiento _createParteTrabajo(Map<String, String> data) {
    return Movimiento(
      turno: usuario.turno,
      idturno: usuario.idTurno,
      idSupervisor: _usuarioSession.id,
      idCajero: usuario.id,
      idTipoMovimiento: _TIPO_LIQUIDACION,
      via: usuario.via,
      idPeaje: _usuarioSession.idPeaje,
      partetrabajo: data['partetrabajo'],
      recibe1C: '0',
      recibe5C: data['recibe5C'],
      recibe10C: data['recibe10C'],
      recibe25C: data['recibe25C'],
      recibe50C: data['recibe50C'],
      recibe1DB: '0',
      recibe1D: data['recibe1D'],
      recibe2D: '0',
      recibe5D: data['recibe5D'],
      recibe10D: data['recibe10D'],
      recibe20D: data['recibe20D'],
      entrega1C: '0',
      entrega5C: data['entrega5C'],
      entrega10C: data['entrega10C'],
      entrega25C: data['entrega25C'],
      entrega50C: data['entrega50C'],
      entrega1DB: '0',
      entrega1D: data['entrega1D'],
      entrega5D: data['entrega5D'],
      entrega10D: data['entrega10D'],
      entrega20D: data['entrega20D'],
      sobrante: '0',
    );
  }

  Movimiento _createFaltante(Map<String, String> data) {
    return Movimiento(
      turno: usuario.turno,
      idturno: usuario.idTurno,
      idSupervisor: _usuarioSession.id,
      idCajero: usuario.id,
      idTipoMovimiento: _TIPO_FALTANTE,
      via: usuario.via,
      idPeaje: _usuarioSession.idPeaje,
      recibe1C: '0',
      partetrabajo: '0',
      recibe5C: data['recibe5C'],
      recibe10C: data['recibe10C'],
      recibe25C: data['recibe25C'],
      recibe50C: data['recibe50C'],
      recibe1DB: '0',
      recibe1D: data['recibe1D'],
      recibe2D: '0',
      recibe5D: data['recibe5D'],
      recibe10D: data['recibe10D'],
      recibe20D: data['recibe20D'],
      entrega1C: '0',
      entrega5C: data['entrega5C'],
      entrega10C: data['entrega10C'],
      entrega25C: data['entrega25C'],
      entrega50C: data['entrega50C'],
      entrega1DB: '0',
      entrega1D: data['entrega1D'],
      entrega5D: data['entrega5D'],
      entrega10D: data['entrega10D'],
      entrega20D: data['entrega20D'],
    );
  }

  Movimiento _createFaltanteUpdate(Map<String, String> data) {
    return Movimiento(
      id: idMovimientoFaltante,
      turno: usuario.turno,
      idturno: usuario.idTurno,
      idSupervisor: _usuarioSession.id,
      idCajero: usuario.id,
      idTipoMovimiento: _TIPO_FALTANTE,
      via: usuario.via,
      idPeaje: _usuarioSession.idPeaje,
      recibe1C: '0',
      partetrabajo: '0',
      recibe5C: data['recibe5C'],
      recibe10C: data['recibe10C'],
      recibe25C: data['recibe25C'],
      recibe50C: data['recibe50C'],
      recibe1DB: '0',
      recibe1D: data['recibe1D'],
      recibe2D: '0',
      recibe5D: data['recibe5D'],
      recibe10D: data['recibe10D'],
      recibe20D: data['recibe20D'],
      entrega1C: '0',
      entrega5C: data['entrega5C'],
      entrega10C: data['entrega10C'],
      entrega25C: data['entrega25C'],
      entrega50C: data['entrega50C'],
      entrega1DB: '0',
      entrega1D: data['entrega1D'],
      entrega5D: data['entrega5D'],
      entrega10D: data['entrega10D'],
      entrega20D: data['entrega20D'],
      sobrante: '0',
    );
  }

  Movimiento _createLiquidacionUpdate(
      Movimiento liquidacion, Map<String, String> data) {
    return Movimiento(
      id: liquidacion.id,
      idSupervisor: _usuarioSession.id,
      partetrabajo: data['partetrabajo'],
      anulaciones: data['anulaciones'],
      valoranulaciones: data['valoranulaciones'],
      simulaciones: data['simulaciones'],
      valorsimulaciones: data['valorsimulaciones'],
      sobrante: data['sobrante'],
      estado: '1', // Marcar como liquidado
    );
  }

  // Navigation methods
  void _navigateToHome() {
    Get.offNamedUntil('/home', (route) => false, arguments: {'index': 2});
  }

  void _navigateToReporte() {
    Get.off(
      () => ReporteLiquidacion(movimientos: movimientos),
      arguments: usuario,
    );
  }

  // Utility methods
  Future<void> _refreshMovimientos() async {
    final apertura = _findMovimientoByTipo(_TIPO_APERTURA);
    final result =
        await _movimientoProvider.getMovimientoByTurno(apertura.idturno ?? '');
    movimientos.clear();
    movimientos.addAll(result);
  }

  // Snackbar methods
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Operación Exitosa',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _showOfflineSnackbar(String message) {
    Get.snackbar(
      'Transacción Offline',
      message,
      icon: const Icon(Icons.cloud_off_outlined, color: Colors.white),
      backgroundColor: Colors.orange[800],
      colorText: Colors.white,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    // Dispose controllers
    simulacionesCantidadController.dispose();
    simulacionesValorController.dispose();
    anulacionesCantidadController.dispose();
    anulacionesValorController.dispose();
    sobrantesController.dispose();
    parteTrabajoController.dispose();

    billetes20ControllerE.dispose();
    billetes10ControllerE.dispose();
    billetes5ControllerE.dispose();
    billetes1ControllerE.dispose();
    moneda50ControllerE.dispose();
    moneda25ControllerE.dispose();
    moneda10ControllerE.dispose();
    moneda5ControllerE.dispose();

    billetes20ControllerR.dispose();
    billetes10ControllerR.dispose();
    billetes5ControllerR.dispose();
    billetes1ControllerR.dispose();
    moneda50ControllerR.dispose();
    moneda25ControllerR.dispose();
    moneda10ControllerR.dispose();
    moneda5ControllerR.dispose();

    super.onClose();
  }
}
