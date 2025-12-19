import 'package:asistencia_vial_app/src/pages/supervisor/retiros_parciales/improved_retiro_parcial_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/loading_controller.dart';
import '../../../widgets/improved_offline_banner.dart';
import '../../../models/usuario.dart';

class RetiroParcialPage extends StatelessWidget {
  late ImprovedRetiroParcialController retiroParcialController;
  Usuario? usuario;

  RetiroParcialPage({@required this.usuario}) {
    retiroParcialController =
        Get.put(ImprovedRetiroParcialController(usuario!));
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
              loadingKey: ImprovedRetiroParcialController.LOADING_KEY,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                        context, 'Recibe del Cajero', Icons.arrow_downward),
                    SizedBox(height: 16),
                    _recibeGrid(context),
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
                      'Retiro Parcial',
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
                  Icons.payments_outlined,
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
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: maxLength ?? 3,
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
          Row(
            children: [
              Expanded(
                child: _inputField(
                  context: context,
                  label: '\$ 20',
                  assetIcon: 'assets/img/billete.png',
                  controller: retiroParcialController.billetes20Controller,
                  maxLength: 3,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  context: context,
                  label: '\$ 10',
                  assetIcon: 'assets/img/billete.png',
                  controller:
                      retiroParcialController.billetes10RecibeController,
                  maxLength: 3,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _inputField(
                  context: context,
                  label: '\$ 5',
                  assetIcon: 'assets/img/billete.png',
                  controller: retiroParcialController.billetes5RecibeController,
                  maxLength: 3,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  context: context,
                  label: '\$ 1',
                  assetIcon: 'assets/img/moneda.png',
                  controller: retiroParcialController.billetes1RecibeController,
                  maxLength: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
          _confirmRetiroParcial(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.onPrimary, size: 24),
            SizedBox(width: 12),
            Text(
              'Confirmar Retiro',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRetiroParcial(BuildContext context) {
    final billetes20 = retiroParcialController.billetes20Controller.text.isEmpty
        ? '0'
        : retiroParcialController.billetes20Controller.text;
    final billetes10 =
        retiroParcialController.billetes10RecibeController.text.isEmpty
            ? '0'
            : retiroParcialController.billetes10RecibeController.text;
    final billetes5 =
        retiroParcialController.billetes5RecibeController.text.isEmpty
            ? '0'
            : retiroParcialController.billetes5RecibeController.text;
    final billetes1 =
        retiroParcialController.billetes1RecibeController.text.isEmpty
            ? '0'
            : retiroParcialController.billetes1RecibeController.text;

    final totalRecibe = (int.parse(billetes10) * 10) +
        (int.parse(billetes20) * 20) +
        (int.parse(billetes5) * 5) +
        (int.parse(billetes1) * 1);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.library_add_check_outlined,
                  color: Theme.of(context).colorScheme.primary, size: 28),
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
                Text("¿Estás seguro de realizar este retiro?",
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 12),
                Divider(color: Colors.grey[300]),
                SizedBox(height: 12),
                Text("Recibes del Cajero:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                Text("• $billetes20 billetes de \$20"),
                Text("• $billetes10 billetes de \$10"),
                Text("• $billetes5 billetes de \$5"),
                Text("• $billetes1 monedas de \$1"),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Total Recibido: \$${totalRecibe.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
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
                retiroParcialController.registrarRetiroParcial(
                    context, usuario!);
              },
              child: Obx(() {
                final isLoading = LoadingController.to
                    .isLoading(ImprovedRetiroParcialController.LOADING_KEY);
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        );
      },
    );
  }
}
