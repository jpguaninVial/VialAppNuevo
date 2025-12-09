import 'package:asistencia_vial_app/src/pages/supervisor/canje_fortius/improved_canje_fortius_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/improved_connection_controller.dart';
import '../../../controllers/loading_controller.dart';
import '../../../widgets/improved_offline_banner.dart';
import '../../../models/usuario.dart';

class CanjeFortiusPage extends StatelessWidget {

  late ImprovedCanjeFortiusController canjefortiusController;

  Usuario? usuario;


  CanjeFortiusPage({@required this.usuario}){
    canjefortiusController=Get.put(ImprovedCanjeFortiusController(usuario!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Canje de Fortius',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.white),
                ),
                backgroundColor: Color(0xFF368983),
                elevation: 0,
              ),
              body: Column(
                children: [
                  ImprovedOfflineBanner(),
                  Expanded(
                    child: LoadingWrapper(
                      loadingKey: ImprovedCanjeFortiusController.LOADING_KEY,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             _sectionTitle('Recibe de Fortius'),
                            _recibeGrid(),
                            SizedBox(height: 10),
                            Divider(thickness: 1, color: Colors.grey[300]),
                            SizedBox(height: 20),
                            _sectionTitle('Entrega Supervisor'),
                            SizedBox(height: 10),
                            _entregaGrid(),
                            SizedBox(height: 30),
                            _confirmButton(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            
    );
  }

  /// **Widget: Título de Sección**
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF368983),
      ),
    );
  }

  /// **Widget: Campo de Entrada**
  Widget _inputField({
    required String label,
    IconData? icon, // Cambiado para admitir null
    String? assetIcon, // Agregado para soportar íconos de assets
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        style: TextStyle(color: Colors.black),
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: controller.text.isEmpty ? Colors.grey : Colors.black),
          prefixIcon: assetIcon != null
              ? Padding(
            padding: const EdgeInsets.all(10.0), // Ajuste del tamaño del ícono
            child: Image.asset(
              assetIcon,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          )
              : Icon(icon, color: Color(0xFF368983)), // Ícono estándar si no hay assetIcon
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF368983)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF368983), width: 2),
          ),
        ),
      ),
    );
  }


  Widget _recibeGrid() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _inputField(
                label: '\$ 10',
                assetIcon: 'assets/img/billete.png',
                controller: canjefortiusController.billetes10RecibeController,
              ),
            ),
            SizedBox(width: 10), // Espaciado horizontal entre columnas
            Expanded(
              child: _inputField(
                label: '\$ 5',
                assetIcon: 'assets/img/billete.png',
                controller: canjefortiusController.billetes5RecibeController,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _inputField(
                label: '\$ 1',
                assetIcon: 'assets/img/moneda.png',
                controller: canjefortiusController.billetes1RecibeController,
              ),
            ),
            SizedBox(width: 10), // Espaciado horizontal entre columnas
            Expanded(
              child: Text(''),
            ),
          ],
        ),
        SizedBox(height: 8), // Espaciado vertical entre filas

      ],
    );
  }

  Widget _entregaGrid() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _inputField(
                label: '\$ 20',
                assetIcon: 'assets/img/billete.png',
                controller: canjefortiusController.billetes20EntregaController,
              ),
            ),
            SizedBox(width: 10), // Espaciado horizontal entre columnas
            Expanded(
              child: _inputField(
                label: '\$ 10',
                assetIcon: 'assets/img/billete.png',
                controller: canjefortiusController.billetes10EntregaController,
              ),
            ),
          ],
        ),
        SizedBox(height: 8), // Espaciado vertical entre filas

      ],
    );
  }


  /// **Widget: Botón de Confirmación**
  Widget _confirmButton(BuildContext context) {
    return Center(
      child: Obx(() => ElevatedButton(
        onPressed: LoadingController.to.isLoading(ImprovedCanjeFortiusController.LOADING_KEY)
          ? null
          : () => canjefortiusController.registrarCanjeeFortius(context, usuario!),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF368983),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: LoadingController.to.isLoading(ImprovedCanjeFortiusController.LOADING_KEY)
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              'Confirmar Canje',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
      )),
    );
}
}

