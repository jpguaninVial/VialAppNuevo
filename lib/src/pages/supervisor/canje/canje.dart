import 'package:asistencia_vial_app/src/pages/supervisor/canje/improved_canje_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/movimiento.dart';
import '../../../models/usuario.dart';
import '../../../controllers/loading_controller.dart';
import '../../../widgets/improved_offline_banner.dart';

class CanjePage extends StatelessWidget {
  late ImprovedCanjeController canjeController;
  Usuario? usuario;
  List<Movimiento>? movimientos;

  CanjePage({@required this.usuario}) {
    canjeController = Get.put(ImprovedCanjeController(usuario!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildModernHeader(context),
          ImprovedOfflineBanner(),
          Expanded(
            child: LoadingWrapper(
              loadingKey: ImprovedCanjeController.LOADING_KEY,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Recibe del Cajero', Icons.arrow_downward),
                    SizedBox(height: 16),
                    _recibeGrid(),
                    SizedBox(height: 24),
                    _sectionTitle('Entrega al Cajero', Icons.arrow_upward),
                    SizedBox(height: 16),
                    _entregaGrid(),
                    SizedBox(height: 32),
                    _confirmButton(context),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **Header moderno sin curvas**
  Widget _buildModernHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF368983),
            Color(0xFF2C6E69),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding:
              EdgeInsets.only(left: 8.0, top: 8.0, right: 20.0, bottom: 16.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Canje',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${usuario!.nombre} ${usuario!.apellido}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.currency_exchange,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **Widget: Título de Sección**
  Widget _sectionTitle(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFF368983).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF368983).withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF368983), size: 24),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF368983),
            ),
          ),
        ],
      ),
    );
  }

  /// **Widget: Campo de Entrada Mejorado**
  Widget _inputField({
    required String label,
    IconData? icon,
    String? assetIcon,
    required TextEditingController controller,
    int? maxLength,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        maxLength: maxLength ?? 3,
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          counterText: '',
          labelText: label,
          labelStyle: TextStyle(
            color:
                controller.text.isEmpty ? Colors.grey[600] : Color(0xFF368983),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: assetIcon != null
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(0xFF368983).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      assetIcon,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(icon, color: Color(0xFF368983), size: 28),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF368983), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _recibeGrid() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _inputField(
                  label: '\$ 20',
                  assetIcon: 'assets/img/billete.png',
                  controller: canjeController.billetes20Controller,
                  maxLength: 2,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  label: '\$ 10',
                  assetIcon: 'assets/img/billete.png',
                  controller: canjeController.billetes10RecibeController,
                  maxLength: 2,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _inputField(
                  label: '\$ 5',
                  assetIcon: 'assets/img/billete.png',
                  controller: canjeController.billetes5RecibeController,
                  maxLength: 2,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  label: '\$ 1',
                  assetIcon: 'assets/img/moneda.png',
                  controller: canjeController.billetes1RecibeController,
                  maxLength: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _entregaGrid() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _inputField(
                  label: '\$ 10',
                  assetIcon: 'assets/img/billete.png',
                  controller: canjeController.billetes10EntregaController,
                  maxLength: 2,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  label: '\$ 5',
                  assetIcon: 'assets/img/billete.png',
                  controller: canjeController.billetes5EntregaController,
                  maxLength: 2,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _inputField(
                  label: '\$ 1',
                  assetIcon: 'assets/img/moneda.png',
                  controller: canjeController.billetes1EntregaController,
                  maxLength: 3,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  label: '50¢',
                  assetIcon: 'assets/img/moneda.png',
                  controller: canjeController.moneda50EntregaController,
                  maxLength: 3,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _inputField(
                  label: '25¢',
                  assetIcon: 'assets/img/moneda.png',
                  controller: canjeController.moneda25EntregaController,
                  maxLength: 3,
                ),
              ),
              SizedBox(width: 12),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }

  /// **Widget: Botón de Confirmación Mejorado**
  Widget _confirmButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF368983),
            Color(0xFF2C6E69),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF368983).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          _confirmCanje(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              'Confirmar Canje',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCanje(BuildContext context) {
    final billetes20 = canjeController.billetes20Controller.text.isEmpty
        ? '0'
        : canjeController.billetes20Controller.text;
    final billetes10Recibe =
        canjeController.billetes10RecibeController.text.isEmpty
            ? '0'
            : canjeController.billetes10RecibeController.text;
    final billetes5Recibe =
        canjeController.billetes5RecibeController.text.isEmpty
            ? '0'
            : canjeController.billetes5RecibeController.text;
    final billetes1Recibe =
        canjeController.billetes1RecibeController.text.isEmpty
            ? '0'
            : canjeController.billetes1RecibeController.text;

    final billetes10Entrega =
        canjeController.billetes10EntregaController.text.isEmpty
            ? '0'
            : canjeController.billetes10EntregaController.text;
    final billetes5Entrega =
        canjeController.billetes5EntregaController.text.isEmpty
            ? '0'
            : canjeController.billetes5EntregaController.text;
    final billetes1Entrega =
        canjeController.billetes1EntregaController.text.isEmpty
            ? '0'
            : canjeController.billetes1EntregaController.text;
    final moneda50Entrega =
        canjeController.moneda50EntregaController.text.isEmpty
            ? '0'
            : canjeController.moneda50EntregaController.text;
    final moneda25Entrega =
        canjeController.moneda25EntregaController.text.isEmpty
            ? '0'
            : canjeController.moneda25EntregaController.text;

    final totalEntrega = (int.parse(billetes10Entrega) * 10) +
        (int.parse(billetes5Entrega) * 5) +
        (int.parse(billetes1Entrega) * 1) +
        (int.parse(moneda50Entrega) * 0.5).toDouble() +
        (int.parse(moneda25Entrega) * 0.25).toDouble();

    final totalRecibe = (int.parse(billetes10Recibe) * 10) +
        (int.parse(billetes20) * 20) +
        (int.parse(billetes5Recibe) * 5) +
        (int.parse(billetes1Recibe) * 1);

    if (totalEntrega != totalRecibe) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Text("Error en los valores",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: Text(
              "Los valores entregados (\$$totalEntrega) no coinciden con los recibidos (\$$totalRecibe).\n\n"
              "Por favor, revisa las denominaciones antes de continuar.",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Aceptar",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.library_add_check_outlined,
                  color: Color(0xFF368983), size: 28),
              SizedBox(width: 12),
              Text("Confirmación",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("¿Estás seguro de realizar este canje?",
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 12),
                Divider(color: Colors.grey[300]),
                SizedBox(height: 12),
                Text("Recibe de Cajero:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                Text("• $billetes20 billetes de \$20"),
                Text("• $billetes10Recibe billetes de \$10"),
                Text("• $billetes5Recibe billetes de \$5"),
                Text("• $billetes1Recibe monedas de \$1"),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF368983).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Total Recibido: \$${totalRecibe.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF368983)),
                  ),
                ),
                SizedBox(height: 16),
                Text("Entrega al Cajero:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                Text("• $billetes10Entrega billetes de \$10"),
                Text("• $billetes5Entrega billetes de \$5"),
                Text("• $billetes1Entrega monedas de \$1"),
                Text("• $moneda50Entrega monedas de 50¢"),
                Text("• $moneda25Entrega monedas de 25¢"),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF368983).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Total Entregado: \$${totalEntrega.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF368983)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                canjeController.registrarCanje(context, usuario!);
              },
              child: Obx(() {
                final isLoading = LoadingController.to
                    .isLoading(ImprovedCanjeController.LOADING_KEY);
                return isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Confirmar',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold));
              }),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                backgroundColor: Color(0xFF368983),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalisisTable() {
    int totalEntregada20 = movimientos!
        .fold(0, (sum, m) => sum + (int.tryParse(m.entrega20D ?? '0') ?? 0));
    int totalEntregada10 = movimientos!
        .fold(0, (sum, m) => sum + (int.tryParse(m.entrega10D ?? '0') ?? 0));
    int totalEntregada5 = movimientos!
        .fold(0, (sum, m) => sum + (int.tryParse(m.entrega5D ?? '0') ?? 0));
    int totalEntregada1 = movimientos!
        .fold(0, (sum, m) => sum + (int.tryParse(m.entrega1D ?? '0') ?? 0));

    int totalRecibida20 = movimientos!
        .fold(0, (sum, m) => sum + (int.tryParse(m.recibe20D ?? '0') ?? 0));
    int totalRecibida10 = movimientos!
        .fold(0, (sum, m) => sum + (int.tryParse(m.recibe10D ?? '0') ?? 0));
    int totalRecibida5 = movimientos!
        .fold(0, (sum, m) => sum + (int.tryParse(m.recibe5D ?? '0') ?? 0));
    int totalRecibida1 = movimientos!
        .fold(0, (sum, m) => sum + (int.tryParse(m.recibe1D ?? '0') ?? 0));

    final data = [
      {
        "denominacion": "\$20",
        "entregada": totalEntregada20,
        "recibida": totalRecibida20
      },
      {
        "denominacion": "\$10",
        "entregada": totalEntregada10,
        "recibida": totalRecibida10
      },
      {
        "denominacion": "\$5",
        "entregada": totalEntregada5,
        "recibida": totalRecibida5
      },
      {
        "denominacion": "\$1",
        "entregada": totalEntregada1,
        "recibida": totalRecibida1
      },
    ];

    bool hayDatos = data
        .any((d) => (d["entregada"] as int) > 0 || (d["recibida"] as int) > 0);
    if (!hayDatos) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Análisis", Icons.analytics),
        SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[300]),
              children: [
                _tableCell("Denominación", isHeader: true),
                _tableCell("Entregada", isHeader: true),
                _tableCell("Recibida", isHeader: true),
                _tableCell("Índice", isHeader: true),
              ],
            ),
            ...data.map((d) {
              int entregada = d["entregada"] as int;
              int recibida = d["recibida"] as int;
              int indice = recibida - entregada;

              return TableRow(
                children: [
                  _tableCell(d["denominacion"] as String),
                  _tableCell(entregada.toString()),
                  _tableCell(recibida.toString()),
                  _tableCell(indice.toString(),
                      color: indice < 0 ? Colors.red : Colors.green),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _tableCell(String text,
      {bool isHeader = false, Color color = Colors.black}) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
          color: color,
        ),
      ),
    );
  }
}
