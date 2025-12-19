import 'dart:convert';
import 'dart:typed_data';

import 'package:asistencia_vial_app/src/provider/archivo_provider.dart';
import 'package:asistencia_vial_app/src/utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../models/movimiento.dart';
import '../../../models/usuario.dart';

class ReporteLiquidacionController extends GetxController {
  Usuario usuarioSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});
  ArchivoProvider archivoProvider = ArchivoProvider();
  List<Movimiento>? movimientos;
  Function? onPDFClosed; // Callback para cuando se cierre el PDF

  ReporteLiquidacionController(List<Movimiento> movimientos,
      {this.onPDFClosed}) {
    this.movimientos = movimientos;
  }

  // Nuevo método para guardar PDF
  Future<void> guardarPDFEnServidor(Uint8List pdfBytes) async {
    print('🚀 Iniciando guardarPDFEnServidor');
    try {
      print('📦 Codificando PDF a base64...');
      final String base64PDF = base64Encode(pdfBytes);
      print('✅ PDF codificado, tamaño: ${base64PDF.length} caracteres');

      final liquidacion =
          movimientos?.firstWhere((m) => m.idTipoMovimiento == '4');

      if (liquidacion == null || liquidacion.fecha == null) {
        print('❌ Error: No se encontró liquidación o fecha');
        throw Exception("No se encontró la liquidación o no tiene fecha.");
      }
      print('✅ Liquidación encontrada: ${liquidacion.nombreCajero}');

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
      final String nombreArchivo =
          'Liquidacion_${liquidacion.nombreCajero}_$fechaFormateada.pdf';
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
      print('📤 Llamando a archivoProvider.guardarPDF...');
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
            'tipo': 1,
            'totalMovimientos': movimientos?.length,
          });

      print('📥 Respuesta recibida del provider: $respuesta');
      print('📥 respuesta[exito] = ${respuesta['exito']}');
      print('📥 Tipo de respuesta[exito]: ${respuesta['exito'].runtimeType}');

      // Manejar la respuesta con un Toast que siempre se verá
      if (respuesta['exito'] == true) {
        print('✅ Mostrando toast de éxito');
        _showSuccessToast();
      } else {
        print('❌ Mostrando toast de error: ${respuesta['mensaje']}');
        _showErrorToast(respuesta['mensaje'] ?? 'No se pudo guardar el PDF');
      }
    } catch (e) {
      print('⚠️ Excepción capturada: $e');
      Get.dialog(
        AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.red.shade50,
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Error al enviar el PDF: $e',
            style: TextStyle(color: Colors.red.shade800),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Get.isDialogOpen ?? false) {
                  Navigator.of(Get.overlayContext!).pop();
                }
              },
              child:
                  Text('Cerrar', style: TextStyle(color: Colors.red.shade700)),
            ),
          ],
        ),
        barrierDismissible: true,
      );
    }
  }

  void _showSuccessToast() {
    print('✅ Mostrando toast de éxito');
    CustomToast.showSuccess(
      title: 'Archivo Subido',
      message: 'El PDF se guardó exitosamente en el servidor',
    );
    // Cerrar PDF viewer después de mostrar el toast
    Future.delayed(Duration(milliseconds: 500), () {
      print('✅ Cerrando PDF viewer después del toast');
      Navigator.pop(Get.context!);
      // Ejecutar callback después de cerrar el PDF
      Future.delayed(Duration(milliseconds: 300), () {
        if (onPDFClosed != null) {
          print('✅ Ejecutando callback onPDFClosed');
          onPDFClosed!();
        }
      });
    });
  }

  void _showErrorToast(String mensaje) {
    print('❌ Mostrando toast de error');
    CustomToast.showError(
      title: 'Error al Subir',
      message: mensaje,
    );
  }
}
