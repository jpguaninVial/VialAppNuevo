import 'package:asistencia_vial_app/src/helper/offline_banner.dart';
import 'package:asistencia_vial_app/src/pages/supervisor/retiros_parciales/retiro_parcial_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/usuario.dart';

class RetiroParcialPage extends StatefulWidget {
  final Usuario usuario;

  const RetiroParcialPage({Key? key, required this.usuario}) : super(key: key);

  @override
  _RetiroParcialPageState createState() => _RetiroParcialPageState();
}

class _RetiroParcialPageState extends State<RetiroParcialPage> {
  RetiroParcialController retiroParcialController = Get.find();

  @override
  void initState() {
    super.initState();
    retiroParcialController = Get.put(RetiroParcialController(widget.usuario));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Retiro Parcial',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          OfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información del Cajero',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF368983),
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildInfoRow('Nombre:',
                              '${widget.usuario.nombre ?? ''} ${widget.usuario.apellido ?? ''}'),
                          _buildInfoRow(
                              'Turno:', widget.usuario.turno ?? 'N/A'),
                          _buildInfoRow('Vía:', widget.usuario.via ?? 'N/A'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Denominaciones a Recibir',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF368983),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Billetes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildDenominacionField(
                            controller:
                                retiroParcialController.billetes20Controller,
                            label: 'Billetes de \$20',
                            icon: Icons.money,
                          ),
                          _buildDenominacionField(
                            controller: retiroParcialController
                                .billetes10RecibeController,
                            label: 'Billetes de \$10',
                            icon: Icons.money,
                          ),
                          _buildDenominacionField(
                            controller: retiroParcialController
                                .billetes5RecibeController,
                            label: 'Billetes de \$5',
                            icon: Icons.money,
                          ),
                          _buildDenominacionField(
                            controller: retiroParcialController
                                .billetes1RecibeController,
                            label: 'Billetes de \$1',
                            icon: Icons.money,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Obx(() {
                    return ElevatedButton(
                      onPressed: retiroParcialController.cargando.value
                          ? null
                          : () => retiroParcialController.registarRetiroParcial(
                              context, widget.usuario),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF368983),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: retiroParcialController.cargando.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'PROCESAR RETIRO PARCIAL',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDenominacionField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF368983)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF368983)),
          ),
        ),
      ),
    );
  }
}
