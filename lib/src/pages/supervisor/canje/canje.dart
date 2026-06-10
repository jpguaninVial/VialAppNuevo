import 'package:asistencia_vial_app/src/pages/supervisor/canje/improved_canje_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../models/movimiento.dart';
import '../../../models/usuario.dart';
import '../../../controllers/loading_controller.dart';
import '../../../widgets/improved_offline_banner.dart';
import '../../../widgets/denomination_card.dart';

class CanjePage extends StatelessWidget {
  late ImprovedCanjeController canjeController;
  Usuario? usuario;
  List<Movimiento>? movimientos;

  CanjePage({@required this.usuario, super.key}) {
    canjeController = Get.put(ImprovedCanjeController(usuario!));
  }

  void _changeValue(TextEditingController controller, int delta) {
    int value = int.tryParse(controller.text) ?? 0;
    value += delta;
    if (value < 0) value = 0;
    controller.text = value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
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
                    _sectionTitle(
                        context, 'Recibe del Cajero', Icons.arrow_downward),
                    SizedBox(height: 16),
                    _recibeGrid(context),
                    SizedBox(height: 24),
                    _sectionTitle(
                        context, 'Entrega al Cajero', Icons.arrow_upward),
                    SizedBox(height: 16),
                    _entregaGrid(context),
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
            Theme.of(context).colorScheme.primary.withOpacity(0.9),
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
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
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).colorScheme.onPrimary, size: 24),
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
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${usuario!.nombre} ${usuario!.apellido}',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.8),
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
  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// **Widget: Campo de Entrada Mejorado**
  Widget _inputField({
    required BuildContext context,
    required String label,
    IconData? icon,
    String? assetIcon,
    required TextEditingController controller,
    int? maxLength,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold),
        maxLength: maxLength ?? 3,
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: '',
          labelText: label,
          labelStyle: TextStyle(
            color: controller.text.isEmpty
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: assetIcon != null
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.5),
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
                  child: Icon(icon,
                      color: Theme.of(context).colorScheme.primary, size: 28),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _recibeGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DenominationCard(
                label: '\$ 20',
                assetIcon: 'assets/img/billete.png',
                controller: canjeController.billetes20Controller,
                onIncrement: () =>
                    _changeValue(canjeController.billetes20Controller, 1),
                onDecrement: () =>
                    _changeValue(canjeController.billetes20Controller, -1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DenominationCard(
                label: '\$ 10',
                assetIcon: 'assets/img/billete.png',
                controller: canjeController.billetes10RecibeController,
                onIncrement: () =>
                    _changeValue(canjeController.billetes10RecibeController, 1),
                onDecrement: () => _changeValue(
                    canjeController.billetes10RecibeController, -1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DenominationCard(
                label: '\$ 5',
                assetIcon: 'assets/img/billete.png',
                controller: canjeController.billetes5RecibeController,
                onIncrement: () =>
                    _changeValue(canjeController.billetes5RecibeController, 1),
                onDecrement: () =>
                    _changeValue(canjeController.billetes5RecibeController, -1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DenominationCard(
                label: '\$ 1',
                assetIcon: 'assets/img/moneda.png',
                controller: canjeController.billetes1RecibeController,
                onIncrement: () =>
                    _changeValue(canjeController.billetes1RecibeController, 1),
                onDecrement: () =>
                    _changeValue(canjeController.billetes1RecibeController, -1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _entregaGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DenominationCard(
                label: '\$ 10',
                assetIcon: 'assets/img/billete.png',
                controller: canjeController.billetes10EntregaController,
                onIncrement: () => _changeValue(
                    canjeController.billetes10EntregaController, 1),
                onDecrement: () => _changeValue(
                    canjeController.billetes10EntregaController, -1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DenominationCard(
                label: '\$ 5',
                assetIcon: 'assets/img/billete.png',
                controller: canjeController.billetes5EntregaController,
                onIncrement: () =>
                    _changeValue(canjeController.billetes5EntregaController, 1),
                onDecrement: () => _changeValue(
                    canjeController.billetes5EntregaController, -1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DenominationCard(
                label: '\$ 1',
                assetIcon: 'assets/img/moneda.png',
                controller: canjeController.billetes1EntregaController,
                onIncrement: () =>
                    _changeValue(canjeController.billetes1EntregaController, 1),
                onDecrement: () => _changeValue(
                    canjeController.billetes1EntregaController, -1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DenominationCard(
                label: '50¢',
                assetIcon: 'assets/img/moneda.png',
                controller: canjeController.moneda50EntregaController,
                onIncrement: () =>
                    _changeValue(canjeController.moneda50EntregaController, 1),
                onDecrement: () =>
                    _changeValue(canjeController.moneda50EntregaController, -1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DenominationCard(
                label: '25¢',
                assetIcon: 'assets/img/moneda.png',
                controller: canjeController.moneda25EntregaController,
                onIncrement: () =>
                    _changeValue(canjeController.moneda25EntregaController, 1),
                onDecrement: () =>
                    _changeValue(canjeController.moneda25EntregaController, -1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

  /// **Widget: Botón de Confirmación Mejorado**
  Widget _confirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: () {
          _confirmCanje(context);
        },
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 24),
            SizedBox(width: 12),
            Text(
              'Confirmar Canje',
              style: TextStyle(
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
        // _sectionTitle requiere BuildContext, no disponible aquí
        Text(
          "Análisis",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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
