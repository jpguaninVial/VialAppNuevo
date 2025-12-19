import 'package:asistencia_vial_app/src/models/movimiento.dart';
import 'package:asistencia_vial_app/src/pages/supervisor/retiro_apertura/improved_retiro_apertura_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/loading_controller.dart';
import '../../../widgets/improved_offline_banner.dart';
import '../../../models/usuario.dart';

class RetiroAperturaPage extends StatelessWidget {
  late ImprovedRetiroAperturaController retiroAperturaController;

  Usuario? usuario;
  Movimiento? movimiento;

  RetiroAperturaPage({@required this.usuario, @required this.movimiento}) {
    retiroAperturaController =
        Get.put(ImprovedRetiroAperturaController(usuario!, movimiento!));
    retiroAperturaController.verificarApertura();
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
              loadingKey: ImprovedRetiroAperturaController.LOADING_KEY,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                        context, 'Recibe de Cajero', Icons.arrow_downward),
                    SizedBox(height: 16),
                    _recibeGrid(
                        context,
                        !retiroAperturaController.enProgresoApertura.value &&
                            retiroAperturaController.aperturaCompleta.value),
                    SizedBox(height: 24),
                    _sectionTitle(
                        context, 'Entregó Supervisor', Icons.arrow_upward),
                    SizedBox(height: 10),
                    _entregaGrid(context),
                    SizedBox(height: 32),
                    if (!retiroAperturaController.aperturaCompleta.value)
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
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
                      'Retiro de Apertura',
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
                  Icons.account_balance_wallet_outlined,
                  color: Theme.of(context).colorScheme.onPrimary,
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
    String? assetIcon,
    required TextEditingController controller,
    int? maxLength,
    bool readOnly = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
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
        readOnly: readOnly,
        controller: controller,
        maxLength: maxLength ?? 3,
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
                          .primary
                          .withOpacity(0.1),
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
              : null, // No icon if assetIcon is null
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

  Widget _recibeGrid(BuildContext context, bool aperturaCompleta) {
    bool mostrarTodasDenominaciones = usuario!.idRol == '4';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
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
          // Fila de $20 y $10 (Siempre se muestra)
          Row(
            children: [
              Expanded(
                child: _inputField(
                  context: context,
                  label: '\$ 20',
                  assetIcon: 'assets/img/billete.png',
                  controller: retiroAperturaController.billetes20Controller,
                  readOnly: aperturaCompleta,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  context: context,
                  label: '\$ 10',
                  assetIcon: 'assets/img/billete.png',
                  controller:
                      retiroAperturaController.billetes10RecibeController,
                  readOnly: aperturaCompleta,
                ),
              ),
            ],
          ), // Fila de $5 y $1 (Siempre se muestra)
          Row(
            children: [
              Expanded(
                child: _inputField(
                  context: context,
                  label: '\$ 5',
                  assetIcon: 'assets/img/billete.png',
                  controller:
                      retiroAperturaController.billetes5RecibeController,
                  readOnly: aperturaCompleta,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  context: context,
                  label: '\$ 1',
                  assetIcon: 'assets/img/moneda.png',
                  controller:
                      retiroAperturaController.billetes1RecibeController,
                  readOnly: aperturaCompleta,
                ),
              ),
            ],
          ),

          // Otras denominaciones (Solo si el rol es 3)
          if (mostrarTodasDenominaciones) ...[
            Row(
              children: [
                Expanded(
                  child: _inputField(
                    context: context,
                    label: '50c',
                    assetIcon: 'assets/img/moneda.png',
                    controller:
                        retiroAperturaController.Moneda50RecibeController,
                    readOnly: aperturaCompleta,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _inputField(
                    context: context,
                    label: '25c',
                    assetIcon: 'assets/img/moneda.png',
                    controller:
                        retiroAperturaController.Moneda25RecibeController,
                    readOnly: aperturaCompleta,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _inputField(
                    context: context,
                    label: '10c',
                    assetIcon: 'assets/img/moneda.png',
                    controller:
                        retiroAperturaController.Moneda10RecibeController,
                    readOnly: aperturaCompleta,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _inputField(
                    context: context,
                    label: '5c',
                    assetIcon: 'assets/img/moneda.png',
                    controller:
                        retiroAperturaController.Moneda5RecibeController,
                    readOnly: aperturaCompleta,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _inputField(
                    context: context,
                    label: '1c',
                    assetIcon: 'assets/img/moneda.png',
                    controller:
                        retiroAperturaController.Moneda1RecibeController,
                    readOnly: aperturaCompleta,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _entregaGrid(BuildContext context) {
    bool mostrarTodasDenominaciones = usuario!.idRol == '4';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
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
          // Fila de $10 y $5
          Row(
            children: [
              Expanded(
                child: _inputField(
                  context: context,
                  label: '\$ 10',
                  assetIcon: 'assets/img/billete.png',
                  controller:
                      retiroAperturaController.billetes10EntregaController,
                  readOnly: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  context: context,
                  label: '\$ 5',
                  assetIcon: 'assets/img/billete.png',
                  controller:
                      retiroAperturaController.billetes5EntregaController,
                  readOnly: true,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _inputField(
                  context: context,
                  label: '\$ 1',
                  assetIcon: 'assets/img/moneda.png',
                  controller:
                      retiroAperturaController.billetes1EntregaController,
                  readOnly: true,
                ),
              ),
              SizedBox(width: 12),
              if (mostrarTodasDenominaciones) ...[
                Expanded(
                  child: _inputField(
                    context: context,
                    label: '50c',
                    assetIcon: 'assets/img/moneda.png',
                    controller:
                        retiroAperturaController.Moneda50EntregaController,
                    readOnly: true,
                  ),
                ),
              ] else
                Expanded(child: Container()),
            ],
          ),
          if (mostrarTodasDenominaciones) ...[
            Row(
              children: [
                Expanded(
                  child: _inputField(
                    context: context,
                    label: '25c',
                    assetIcon: 'assets/img/moneda.png',
                    controller:
                        retiroAperturaController.Moneda25EntregaController,
                    readOnly: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _inputField(
                    context: context,
                    label: '10c',
                    assetIcon: 'assets/img/moneda.png',
                    controller:
                        retiroAperturaController.Moneda10EntregaController,
                    readOnly: true,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _inputField(
                    context: context,
                    label: '5c',
                    assetIcon: 'assets/img/moneda.png',
                    controller:
                        retiroAperturaController.Moneda5EntregaController,
                    readOnly: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _inputField(
                    context: context,
                    label: '1c',
                    assetIcon: 'assets/img/moneda.png',
                    controller:
                        retiroAperturaController.Moneda1EntregaController,
                    readOnly: true,
                  ),
                ),
              ],
            ),
          ],
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
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          _confirmRetiroApertura(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Obx(() {
          final isLoading = LoadingController.to
              .isLoading(ImprovedRetiroAperturaController.LOADING_KEY);
          return isLoading
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                )
              : Text(
                  'Retirar Apertura',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
        }),
      ),
    );
  }

  /// **Método: Confirmar Retiro de Apertura**
  void _confirmRetiroApertura(BuildContext context) {
    bool mostrarTodasDenominaciones = usuario!.idRol == '4';

    // Validar valores vacíos y asignar 0 por defecto
    String getValue(TextEditingController controller) =>
        controller.text.isEmpty ? '0' : controller.text;

    final billetes20 = getValue(retiroAperturaController.billetes20Controller);
    final billetes10Recibe =
        getValue(retiroAperturaController.billetes10RecibeController);
    final billetes5Recibe =
        getValue(retiroAperturaController.billetes5RecibeController);
    final billetes1Recibe =
        getValue(retiroAperturaController.billetes1RecibeController);

    final billetes10Entrega =
        getValue(retiroAperturaController.billetes10EntregaController);
    final billetes5Entrega =
        getValue(retiroAperturaController.billetes5EntregaController);
    final billetes1Entrega =
        getValue(retiroAperturaController.billetes1EntregaController);

    // Si el usuario es idRol = 3, también incluir denominaciones pequeñas
    final moneda50Recibe = mostrarTodasDenominaciones
        ? getValue(retiroAperturaController.Moneda50RecibeController)
        : '0';
    final moneda25Recibe = mostrarTodasDenominaciones
        ? getValue(retiroAperturaController.Moneda25RecibeController)
        : '0';
    final moneda10Recibe = mostrarTodasDenominaciones
        ? getValue(retiroAperturaController.Moneda10RecibeController)
        : '0';
    final moneda5Recibe = mostrarTodasDenominaciones
        ? getValue(retiroAperturaController.Moneda5RecibeController)
        : '0';
    final moneda1Recibe = mostrarTodasDenominaciones
        ? getValue(retiroAperturaController.Moneda1RecibeController)
        : '0';

    final moneda50Entrega = mostrarTodasDenominaciones
        ? getValue(retiroAperturaController.Moneda50EntregaController)
        : '0';
    final moneda25Entrega = mostrarTodasDenominaciones
        ? getValue(retiroAperturaController.Moneda25EntregaController)
        : '0';
    final moneda10Entrega = mostrarTodasDenominaciones
        ? getValue(retiroAperturaController.Moneda10EntregaController)
        : '0';
    final moneda5Entrega = mostrarTodasDenominaciones
        ? getValue(retiroAperturaController.Moneda5EntregaController)
        : '0';
    final moneda1Entrega = mostrarTodasDenominaciones
        ? getValue(retiroAperturaController.Moneda1EntregaController)
        : '0';

    // Cálculo del total entregado por el supervisor
    final totalEntrega = (int.parse(billetes10Entrega) * 10) +
        (int.parse(billetes5Entrega) * 5) +
        (int.parse(billetes1Entrega) * 1) +
        (int.parse(moneda50Entrega) * 0.5).toDouble() +
        (int.parse(moneda25Entrega) * 0.25).toDouble() +
        (int.parse(moneda10Entrega) * 0.1).toDouble() +
        (int.parse(moneda5Entrega) * 0.05).toDouble() +
        (int.parse(moneda1Entrega) * 0.01).toDouble();

    // Cálculo del total recibido por el cajero
    final totalRecibe = (int.parse(billetes10Recibe) * 10) +
        (int.parse(billetes20) * 20) +
        (int.parse(billetes5Recibe) * 5) +
        (int.parse(billetes1Recibe) * 1) +
        (int.parse(moneda50Recibe) * 0.5).toDouble() +
        (int.parse(moneda25Recibe) * 0.25).toDouble() +
        (int.parse(moneda10Recibe) * 0.1).toDouble() +
        (int.parse(moneda5Recibe) * 0.05).toDouble() +
        (int.parse(moneda1Recibe) * 0.01).toDouble();

    // **Si los valores no coinciden, mostrar alerta de error**
    if (totalEntrega < totalRecibe) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 10),
                Expanded(
                  // Evita desbordamiento
                  child: Text(
                    "Error en los valores",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow:
                        TextOverflow.ellipsis, // Corta el texto si es muy largo
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              // ⬅ Agregado para evitar overflow
              child: Text(
                "Los valores entregados (\$$totalEntrega) no coinciden con los recibidos (\$$totalRecibe).\n\n"
                "Por favor, revisa las denominaciones antes de continuar.",
                style: TextStyle(fontSize: 16),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                },
                child: Text("Aceptar", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      return; // **Sale de la función y no muestra el diálogo de confirmación**
    }

    // **Si los valores coinciden, mostrar el diálogo de confirmación**
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.library_add_check_outlined,
                    color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 10),
                Text("Confirmación",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("¿Estás seguro de retirar esta apertura?",
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 5),
                Divider(color: Colors.grey[300]),
                SizedBox(height: 5),
                Text("Recibe de Cajero:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("- $billetes20 billetes de \$20"),
                Text("- $billetes10Recibe billetes de \$10"),
                Text("- $billetes5Recibe billetes de \$5"),
                Text("- $billetes1Recibe monedas de \$1"),
                if (mostrarTodasDenominaciones) ...[
                  Text("- $moneda50Recibe monedas de 50c"),
                  Text("- $moneda25Recibe monedas de 25c"),
                  Text("- $moneda10Recibe monedas de 10c"),
                  Text("- $moneda5Recibe monedas de 5c"),
                  Text("- $moneda1Recibe monedas de 1c"),
                ],
                SizedBox(height: 5),
                Text("Total Recibido: \$${totalRecibe.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
                Text("Entregó Supervisor:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("- $billetes10Entrega billetes de \$10"),
                Text("- $billetes5Entrega billetes de \$5"),
                Text("- $billetes1Entrega monedas de \$1"),
                if (mostrarTodasDenominaciones) ...[
                  Text("- $moneda50Entrega monedas de 50c"),
                  Text("- $moneda25Entrega monedas de 25c"),
                  Text("- $moneda10Entrega monedas de 10c"),
                  Text("- $moneda5Entrega monedas de 5c"),
                  Text("- $moneda1Entrega monedas de 1c"),
                ],
                SizedBox(height: 5),
                Text("Total Entregado: \$${totalEntrega.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                },
                child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  retiroAperturaController.registrarRetiroApertura(
                      context, usuario!);
                },
                child: Obx(() {
                  final isLoading = LoadingController.to
                      .isLoading(ImprovedRetiroAperturaController.LOADING_KEY);
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
                      : Text('Confirmar');
                }),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
