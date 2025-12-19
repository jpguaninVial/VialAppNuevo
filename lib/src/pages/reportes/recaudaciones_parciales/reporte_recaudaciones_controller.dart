import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../models/movimiento.dart';
import '../../../models/usuario.dart';
import '../../../provider/archivo_provider.dart';
import '../../../utils/custom_toast.dart';

class ReporteRecaudacionesController extends GetxController {
  Usuario usuarioSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});
  ArchivoProvider archivoProvider = ArchivoProvider();

  Usuario? usuario;
  List<Movimiento>? movimientos;

  ReporteRecaudacionesController(
      Usuario usuario, List<Movimiento> movimientos) {
    this.usuario = usuario;
    this.movimientos = movimientos;
  }

  // Nuevo método para guardar PDF
  Future<void> guardarPDFEnServidor(Uint8List pdfBytes) async {
    try {
      final String base64PDF = base64Encode(pdfBytes);
      final liquidacion =
          movimientos?.firstWhere((m) => m.idTipoMovimiento == '4');

      if (liquidacion == null || liquidacion.fecha == null) {
        throw Exception("No se encontró la liquidación o no tiene fecha.");
      }

      // Convertir a DateTime
      final DateTime fechaLiquidacion = DateTime.parse(liquidacion.fecha!);

      // 📆 Fecha completa en formato 01-02-2025
      final String fechaFormateada =
          "${fechaLiquidacion.day.toString().padLeft(2, '0')}-"
          "${fechaLiquidacion.month.toString().padLeft(2, '0')}-"
          "${fechaLiquidacion.year}";

      // 🗓️ Mes en texto
      final List<String> meses = [
        "Enero",
        "Febrero",
        "Marzo",
        "Abril",
        "Mayo",
        "Junio",
        "Julio",
        "Agosto",
        "Septiembre",
        "Octubre",
        "Noviembre",
        "Diciembre"
      ];
      final String nombreMes = meses[fechaLiquidacion.month - 1];

      // 📅 Año
      final String anio = fechaLiquidacion.year.toString();

      // 📄 Nombre del archivo y datos adicionales
      final String nombreArchivo = 'RP_$fechaFormateada.pdf';
      final String fechaParaBackend = fechaFormateada;
      final String turno = liquidacion.turno ?? "Sin turno";

      // 🏷️ Nombre del peaje
      String nombrePeaje = "Desconocido";
      if (liquidacion.idPeaje == '1') {
        nombrePeaje = "Congoma";
      } else if (liquidacion.idPeaje == '2') {
        nombrePeaje = "Los Angeles";
      }

      // Llamar al provider para guardar el archivo
      final respuesta = await archivoProvider.guardarPDF(
          nombreArchivo: nombreArchivo,
          contenidoPDF: base64PDF,
          mes: nombreMes,
          anio: anio,
          fecha: fechaParaBackend,
          turno: turno,
          peaje: nombrePeaje,
          metadata: {
            'fecha': DateTime.now().toIso8601String(),
            'tipo': 2,
            'totalMovimientos': movimientos?.length,
          });

      // Manejar la respuesta
      if (respuesta['exito']) {
        CustomToast.showSuccess(
          title: 'Éxito',
          message: 'PDF guardado exitosamente en el servidor',
        );
      } else {
        CustomToast.showError(
          title: 'Error',
          message:
              'No se pudo guardar el PDF: ${respuesta['mensaje'] ?? 'Error desconocido'}',
        );
      }
    } catch (e) {
      CustomToast.showError(
        title: 'Error',
        message: 'Error al enviar el PDF: $e',
      );
    }
  }
}
