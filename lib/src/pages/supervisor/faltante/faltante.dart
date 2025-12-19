import 'package:asistencia_vial_app/src/pages/supervisor/faltante/faltante_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../helper/connection_controller.dart';
import '../../../helper/offline_banner.dart';
import '../../../models/movimiento.dart';
import '../../../models/usuario.dart';

class FaltantesPage extends StatefulWidget {
  final List<Movimiento>? movimientos;
  final int? bandera;

  FaltantesPage({@required this.movimientos, @required this.bandera});

  @override
  State<FaltantesPage> createState() => _FaltantesPageState();
}

class _FaltantesPageState extends State<FaltantesPage> {
  late FaltanteController faltanteController;

  @override
  void initState() {
    super.initState();
    final Usuario usuario = Get.arguments;
    faltanteController = Get.put(
        FaltanteController(usuario, widget.movimientos!, widget.bandera!));
    print('Bandera ${widget.bandera}');
  }

  @override
  Widget build(BuildContext context) {
    final Usuario usuario = Get.arguments;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Column(
            children: [
              _buildModernHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                          "Parte de Trabajo", Icons.work_outline),
                      SizedBox(height: 16),
                      _buildNumberInputField("Parte de Trabajo",
                          faltanteController.parteTrabajoController),
                      const SizedBox(height: 24),
                      if (widget.bandera == 1 || widget.bandera == 2) ...[
                        _buildToggleFaltantesButton(),
                        const SizedBox(height: 16),
                        Obx(() => Visibility(
                              visible:
                                  faltanteController.isFaltanteVisible.value,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle("Faltante Recibido",
                                      Icons.arrow_downward),
                                  const SizedBox(height: 16),
                                  _recibeGrid(context),
                                  const SizedBox(height: 24),
                                  _buildSectionTitle(
                                      "Cambio Entregado", Icons.arrow_upward),
                                  const SizedBox(height: 16),
                                  _entregaGrid(context),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            )),
                      ],
                      _buildSectionTitle("Simulaciones", Icons.phone_android),
                      const SizedBox(height: 16),
                      _buildDualInputRow(
                        "Cantidad",
                        faltanteController.simulacionesCantidadController,
                        "Valor (\$)",
                        faltanteController.simulacionesValorController,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Anulaciones", Icons.cancel_outlined),
                      const SizedBox(height: 16),
                      _buildDualInputRow(
                        "Cantidad",
                        faltanteController.anulacionesCantidadController,
                        "Valor (\$)",
                        faltanteController.anulacionesValorController,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle("Sobrantes", Icons.add_circle_outline),
                      const SizedBox(height: 16),
                      _buildNumberInputField(
                          "Sobrantes", faltanteController.sobrantesController),
                      SizedBox(height: 32),
                      widget.bandera == 1
                          ? _confirmParteTrabajo(usuario, context)
                          : _confirmButton(context),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Obx(() {
              if (Get.find<ConnectionController>().isOffline.value) {
                return const OfflineBanner();
              } else {
                return const SizedBox.shrink();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
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
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 24),
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Faltantes y Ajustes',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.edit_note,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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

  Widget _buildToggleFaltantesButton() {
    return ElevatedButton(
      onPressed: () {
        faltanteController.isFaltanteVisible.value =
            !faltanteController.isFaltanteVisible.value;
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                faltanteController.isFaltanteVisible.value
                    ? Icons.visibility_off
                    : Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 22,
              ),
              SizedBox(width: 12),
              Text(
                faltanteController.isFaltanteVisible.value
                    ? "Ocultar Faltantes"
                    : "Agregar Faltantes",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildNumberInputField(
      String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          TextInputFormatter.withFunction((oldValue, newValue) {
            final text = newValue.text;
            if (text.isEmpty) return newValue;
            final decimalPoints = '.'.allMatches(text).length;
            if (decimalPoints > 1) return oldValue;
            if (text.contains(',')) {
              final newText = text.replaceAll(',', '.');
              return TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(offset: newText.length),
              );
            }
            return newValue;
          }),
        ],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: controller.text.isEmpty
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                : Theme.of(context).colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          hintText: 'Usa punto para decimales',
          hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              fontSize: 14),
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
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _recibeGrid(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
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
                      context: context,
                      label: '\$ 20',
                      assetIcon: 'assets/img/billete.png',
                      controller: faltanteController.billetes20ControllerR)),
              SizedBox(width: 8),
              Expanded(
                  child: _inputField(
                      context: context,
                      label: '\$ 10',
                      assetIcon: 'assets/img/billete.png',
                      controller: faltanteController.billetes10ControllerR)),
              SizedBox(width: 8),
              Expanded(
                  child: _inputField(
                      context: context,
                      label: '\$ 5',
                      assetIcon: 'assets/img/billete.png',
                      controller: faltanteController.billetes5ControllerR)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _inputField(
                      context: context,
                      label: '\$ 1',
                      assetIcon: 'assets/img/moneda.png',
                      controller: faltanteController.billetes1ControllerR)),
              SizedBox(width: 8),
              Expanded(
                  child: _inputField(
                      context: context,
                      label: '50¢',
                      assetIcon: 'assets/img/moneda.png',
                      controller: faltanteController.moneda50ControllerR)),
              SizedBox(width: 8),
              Expanded(
                  child: _inputField(
                      context: context,
                      label: '25¢',
                      assetIcon: 'assets/img/moneda.png',
                      controller: faltanteController.moneda25ControllerR)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _inputField(
                      context: context,
                      label: '10¢',
                      assetIcon: 'assets/img/moneda.png',
                      controller: faltanteController.moneda10ControllerR)),
              SizedBox(width: 8),
              Expanded(
                  child: _inputField(
                      context: context,
                      label: '5¢',
                      assetIcon: 'assets/img/moneda.png',
                      controller: faltanteController.moneda5ControllerR)),
              SizedBox(width: 8),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _entregaGrid(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
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
                      context: context,
                      label: '\$ 10',
                      assetIcon: 'assets/img/billete.png',
                      controller: faltanteController.billetes10ControllerE)),
              SizedBox(width: 8),
              Expanded(
                  child: _inputField(
                      context: context,
                      label: '\$ 5',
                      assetIcon: 'assets/img/billete.png',
                      controller: faltanteController.billetes5ControllerE)),
              SizedBox(width: 8),
              Expanded(
                  child: _inputField(
                      context: context,
                      label: '\$ 1',
                      assetIcon: 'assets/img/moneda.png',
                      controller: faltanteController.billetes1ControllerE)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _inputField(
                      context: context,
                      label: '50¢',
                      assetIcon: 'assets/img/moneda.png',
                      controller: faltanteController.moneda50ControllerE)),
              SizedBox(width: 8),
              Expanded(
                  child: _inputField(
                      context: context,
                      label: '25¢',
                      assetIcon: 'assets/img/moneda.png',
                      controller: faltanteController.moneda25ControllerE)),
              SizedBox(width: 8),
              Expanded(
                  child: _inputField(
                      context: context,
                      label: '10¢',
                      assetIcon: 'assets/img/moneda.png',
                      controller: faltanteController.moneda10ControllerE)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _inputField(
                      context: context,
                      label: '5¢',
                      assetIcon: 'assets/img/moneda.png',
                      controller: faltanteController.moneda5ControllerE)),
              SizedBox(width: 8),
              Expanded(child: Container()),
              SizedBox(width: 8),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDualInputRow(
    String label1,
    TextEditingController controller1,
    String label2,
    TextEditingController controller2,
  ) {
    return Row(
      children: [
        Expanded(child: _buildNumberInputField(label1, controller1)),
        const SizedBox(width: 12),
        Expanded(child: _buildNumberInputField(label2, controller2)),
      ],
    );
  }

  Widget _inputField({
    required BuildContext context,
    required String label,
    IconData? icon,
    String? assetIcon,
    required TextEditingController controller,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold),
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: controller.text.isEmpty
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                : Theme.of(context).colorScheme.primary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: assetIcon != null
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Image.asset(
                      assetIcon,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(icon,
                      color: Theme.of(context).colorScheme.primary, size: 20),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _confirmButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: confirmFaltante(context),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 24),
          SizedBox(width: 12),
          Text(
            widget.bandera == 2 ? 'Guardar' : 'Liquidar Turno',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmParteTrabajo(Usuario usuario, BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _showParteTrabajoConfirm(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.save_outlined,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 24),
          SizedBox(width: 12),
          Text(
            'Confirmar Parte de Trabajo',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showParteTrabajoConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.save_outlined,
                  color: Theme.of(context).colorScheme.primary, size: 28),
              SizedBox(width: 12),
              Text("Guardar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${faltanteController.parteTrabajoController.text}",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar",
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                faltanteController.actualizarLiquidacion(context);
              },
              child: Text("Guardar",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer)),
            ),
          ],
        );
      },
    );
  }

  Widget confirmFaltante(BuildContext context) {
    final double totalFaltantes = _calculateTotalFaltantes();
    final int anulacionesCantidad = int.parse(
        faltanteController.anulacionesCantidadController.text.isEmpty
            ? '0'
            : faltanteController.anulacionesCantidadController.text);
    final double anulacionesValor = double.parse(
        faltanteController.anulacionesValorController.text.isEmpty
            ? '0.0'
            : faltanteController.anulacionesValorController.text);
    final int simulacionesCantidad = int.parse(
        faltanteController.simulacionesCantidadController.text.isEmpty
            ? '0'
            : faltanteController.simulacionesCantidadController.text);
    final double simulacionesValor = double.parse(
        faltanteController.simulacionesValorController.text.isEmpty
            ? '0.0'
            : faltanteController.simulacionesValorController.text);
    final double sobrantes = double.parse(
        faltanteController.sobrantesController.text.isEmpty
            ? '0.0'
            : faltanteController.sobrantesController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Text(
          "Resumen de Faltantes y Ajustes",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 20),
        _buildSummaryRow(context, "Total Faltantes:",
            "\$${totalFaltantes.toStringAsFixed(2)}"),
        _buildSummaryRow(context, "Anulaciones:",
            "$anulacionesCantidad - \$${anulacionesValor.toStringAsFixed(2)}"),
        _buildSummaryRow(context, "Simulaciones:",
            "$simulacionesCantidad - \$${simulacionesValor.toStringAsFixed(2)}"),
        _buildSummaryRow(
            context, "Sobrantes:", "\$${sobrantes.toStringAsFixed(2)}"),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            faltanteController.actualizarLiquidacion(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: 14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 22),
              SizedBox(width: 12),
              Text(
                "Generar Reporte",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateTotalFaltantes() {
    final double recibe20 = double.parse(
            faltanteController.billetes20ControllerR.text.isEmpty
                ? '0.0'
                : faltanteController.billetes20ControllerR.text) *
        20;
    final double recibe10 = double.parse(
            faltanteController.billetes10ControllerR.text.isEmpty
                ? '0.0'
                : faltanteController.billetes10ControllerR.text) *
        10;
    final double recibe5 = double.parse(
            faltanteController.billetes5ControllerR.text.isEmpty
                ? '0.0'
                : faltanteController.billetes5ControllerR.text) *
        5;
    final double recibe1 = double.parse(
        faltanteController.billetes1ControllerR.text.isEmpty
            ? '0.0'
            : faltanteController.billetes1ControllerR.text);
    final double recibe50C = double.parse(
            faltanteController.moneda50ControllerR.text.isEmpty
                ? '0.0'
                : faltanteController.moneda50ControllerR.text) *
        0.50;
    final double recibe25C = double.parse(
            faltanteController.moneda25ControllerR.text.isEmpty
                ? '0.0'
                : faltanteController.moneda25ControllerR.text) *
        0.25;
    final double recibe10C = double.parse(
            faltanteController.moneda10ControllerR.text.isEmpty
                ? '0.0'
                : faltanteController.moneda10ControllerR.text) *
        0.10;
    final double recibe5C = double.parse(
            faltanteController.moneda5ControllerR.text.isEmpty
                ? '0.0'
                : faltanteController.moneda5ControllerR.text) *
        0.05;

    final double totalRecibido = recibe20 +
        recibe10 +
        recibe5 +
        recibe1 +
        recibe50C +
        recibe25C +
        recibe10C +
        recibe5C;

    final double entrega10 = double.parse(
            faltanteController.billetes10ControllerE.text.isEmpty
                ? '0.0'
                : faltanteController.billetes10ControllerE.text) *
        10;
    final double entrega5 = double.parse(
            faltanteController.billetes5ControllerE.text.isEmpty
                ? '0.0'
                : faltanteController.billetes5ControllerE.text) *
        5;
    final double entrega1 = double.parse(
        faltanteController.billetes1ControllerE.text.isEmpty
            ? '0.0'
            : faltanteController.billetes1ControllerE.text);
    final double entrega50C = double.parse(
            faltanteController.moneda50ControllerE.text.isEmpty
                ? '0.0'
                : faltanteController.moneda50ControllerE.text) *
        0.50;
    final double entrega25C = double.parse(
            faltanteController.moneda25ControllerE.text.isEmpty
                ? '0.0'
                : faltanteController.moneda25ControllerE.text) *
        0.25;
    final double entrega10C = double.parse(
            faltanteController.moneda10ControllerE.text.isEmpty
                ? '0.0'
                : faltanteController.moneda10ControllerE.text) *
        0.10;
    final double entrega5C = double.parse(
            faltanteController.moneda5ControllerE.text.isEmpty
                ? '0.0'
                : faltanteController.moneda5ControllerE.text) *
        0.05;

    final double totalEntregado = entrega10 +
        entrega5 +
        entrega1 +
        entrega50C +
        entrega25C +
        entrega10C +
        entrega5C;

    return totalRecibido - totalEntregado;
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
