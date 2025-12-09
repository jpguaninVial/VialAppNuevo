import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/movimiento.dart';
import 'detalle_cajero_controller.dart';

class DetalleCajero extends StatelessWidget {
  List<Movimiento>? movimientos;
  late DetalleCajeroController detalleCajeroController;

  DetalleCajero({@required this.movimientos}) {
    detalleCajeroController = Get.put(DetalleCajeroController(movimientos!));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header moderno con gradiente
          _buildModernHeader(context),
          // Contenido scrollable
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(20.0),
              itemCount: movimientos?.length ?? 0,
              itemBuilder: (context, index) {
                final movimiento = movimientos?[index];
                return _buildTransactionCard(movimiento!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 12, bottom: 16, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF368983),
            Color(0xFF2C6E69),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Barra de arrastre
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Título
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.list_alt,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Detalle de Transacciones',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Movimiento movimiento) {
    // Calcula el valor total sumando denominaciones recibidas
    final totalRecibido = (int.parse(movimiento.recibe20D ?? '0') * 20) +
        (int.parse(movimiento.recibe10D ?? '0') * 10) +
        (int.parse(movimiento.recibe5D ?? '0') * 5) +
        (int.parse(movimiento.recibe1D ?? '0') * 1) +
        (int.parse(movimiento.recibe2D ?? '0') * 2) +
        (int.parse(movimiento.recibe50C ?? '0') * 0.5) +
        (int.parse(movimiento.recibe25C ?? '0') * 0.25) +
        (int.parse(movimiento.recibe10C ?? '0') * 0.1) +
        (int.parse(movimiento.recibe5C ?? '0') * 0.05) +
        (int.parse(movimiento.recibe1C ?? '0') * 0.01);

    final totalEntregado = (int.parse(movimiento.entrega10D ?? '0') * 10) +
        (int.parse(movimiento.entrega5D ?? '0') * 5) +
        (int.parse(movimiento.entrega1D ?? '0') * 1) +
        (int.parse(movimiento.entrega50C ?? '0') * 0.5).toDouble() +
        (int.parse(movimiento.entrega25C ?? '0') * 0.25).toDouble() +
        (int.parse(movimiento.entrega5C ?? '0') * 0.05).toDouble() +
        (int.parse(movimiento.entrega10C ?? '0') * 0.1).toDouble() +
        (int.parse(movimiento.entrega1C ?? '0') * 0.01).toDouble();

    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Ícono con fondo
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF368983).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                movimiento.idTipoMovimiento == '1'
                    ? Icons.paid_outlined
                    : movimiento.idTipoMovimiento == '2'
                        ? Icons.payments_outlined
                        : movimiento.idTipoMovimiento == '3'
                            ? Icons.currency_exchange
                            : movimiento.idTipoMovimiento == '4'
                                ? Icons.request_page_outlined
                                : Icons.directions_car,
                color: Color(0xFF368983),
                size: 32,
              ),
            ),
            SizedBox(width: 16),
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movimiento.nombreMovimiento ?? 'Sin Tipo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    movimiento.fecha ?? 'Sin Fecha',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF368983).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      movimiento.idTipoMovimiento == '1'
                          ? '\$${totalEntregado.toStringAsFixed(2)}'
                          : '\$${totalRecibido.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF368983),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Menú de opciones
            PopupMenuButton<String>(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.more_vert,
                  color: Colors.grey[700],
                  size: 20,
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  onTap: () =>
                      detalleCajeroController.goToEditTransaccion(movimiento),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Color(0xFF368983), size: 20),
                      SizedBox(width: 12),
                      Text('Editar transacción'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
