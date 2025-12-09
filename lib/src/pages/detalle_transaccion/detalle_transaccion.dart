import 'package:asistencia_vial_app/src/models/movimiento.dart';
import 'package:asistencia_vial_app/src/pages/detalle_transaccion/detalle_transaccion_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetalleTransaccion extends StatelessWidget {
  List<Movimiento>? movimientos;
  int? bandera;

  late DetalleTransaccionController detalleTransaccionController;

  DetalleTransaccion({@required this.movimientos, @required this.bandera}) {
    detalleTransaccionController =
        Get.put(DetalleTransaccionController(movimientos!, bandera!));
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: _buildDetails(),
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
          // Título y menú
          Row(
            children: [
              // Ícono del tipo de movimiento
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  movimientos?.first.idTipoMovimiento == '1'
                      ? Icons.paid_outlined
                      : movimientos?.first.idTipoMovimiento == '2'
                          ? Icons.payments_outlined
                          : movimientos?.first.idTipoMovimiento == '3'
                              ? Icons.currency_exchange
                              : movimientos?.first.idTipoMovimiento == '4'
                                  ? Icons.request_page_outlined
                                  : Icons.directions_car,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              // Título
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bandera == 2
                          ? 'Liquidación'
                          : '${movimientos?.first.nombreMovimiento}' ?? '',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      movimientos?.first.fecha ?? 'No registrado',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Menú de opciones
              if ((bandera == 0 || bandera == 2) &&
                  detalleTransaccionController.usuarioSession.roles?.first.id !=
                      '5')
                PopupMenuButton<String>(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.more_vert, color: Colors.white, size: 20),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      onTap: () {
                        final movimiento = movimientos?.first;
                        if (movimiento != null) {
                          detalleTransaccionController
                              .goToEditTransaccion(movimiento);
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xFF368983), size: 20),
                          SizedBox(width: 12),
                          Text('Editar Transacción'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 16),
          // Información del supervisor y cajero
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _infoRow(
                  Icons.work_outline,
                  'Supervisor',
                  movimientos?.first.nombreSupervisor ?? 'No registrado',
                ),
                if (movimientos?.first.idTipoMovimiento != '5') ...[
                  SizedBox(height: 12),
                  _infoRow(
                    Icons.person_outline,
                    'Cajero',
                    movimientos?.first.nombreCajero ?? 'No registrado',
                  ),
                ],
                if (movimientos?.first.via != null &&
                    movimientos?.first.idTipoMovimiento != '5') ...[
                  SizedBox(height: 12),
                  _infoRow(
                    Icons.directions_car_outlined,
                    'Vía',
                    movimientos?.first.via ?? 'No registrado',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Construye los detalles dinámicos según el tipo de movimiento
  Widget _buildDetails() {
    print("Movimiento id ${movimientos?.first.idTipoMovimiento}");
    switch (int.parse(movimientos?.first.idTipoMovimiento ?? '1')) {
      case 1: // Apertura
        return bandera == 2
            ? _buildLiquidacionDetails()
            : _buildAperturaDetails();
      case 2: // Retiro Parcial
        return bandera == 2
            ? _buildLiquidacionDetails()
            : _buildRetiroParcialDetails();
      case 3: // Canje
        return _buildCanjeDetails();
      case 4: // Liquidación
        return _buildLiquidacionDetails();
      case 5: // Fortius
        return _buildFortiusDetails();
      case 6: // Fortius
        return bandera == 2
            ? _buildLiquidacionDetails()
            : _buildFaltanteDetails();
      case 7: // Fortius
        return _buildTagDetails();
      default:
        return Text('Tipo de movimiento no reconocido');
    }
  }

  Widget _buildAperturaDetails() {
    final totalRecibido =
        (int.parse(movimientos?.first.recibe20D ?? '0') * 20) +
            (int.parse(movimientos?.first.recibe10D ?? '0') * 10) +
            (int.parse(movimientos?.first.recibe5D ?? '0') * 5) +
            (int.parse(movimientos?.first.recibe1D ?? '0') * 1) +
            (int.parse(movimientos?.first.recibe50C ?? '0') * 0.5).toDouble() +
            (int.parse(movimientos?.first.recibe25C ?? '0') * 0.25).toDouble();

    final totalEntregado =
        (int.parse(movimientos?.first.entrega10D ?? '0') * 10) +
            (int.parse(movimientos?.first.entrega5D ?? '0') * 5) +
            (int.parse(movimientos?.first.entrega1D ?? '0') * 1) +
            (int.parse(movimientos?.first.entrega50C ?? '0') * 0.5).toDouble() +
            (int.parse(movimientos?.first.entrega25C ?? '0') * 0.25).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDenominationList('Recibido:', {
          '\$20': {
            'cantidad': int.parse(movimientos?.first.recibe20D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$10': {
            'cantidad': int.parse(movimientos?.first.recibe10D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$5': {
            'cantidad': int.parse(movimientos?.first.recibe5D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$1': {
            'cantidad': int.parse(movimientos?.first.recibe1D ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
        }),
        SizedBox(height: 16),
        _detailRow('Total Recibido:', '\$${totalRecibido}'),
        SizedBox(height: 24),
        _buildDenominationList('Entregado:', {
          '\$10': {
            'cantidad': int.parse(movimientos?.first.entrega10D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$5': {
            'cantidad': int.parse(movimientos?.first.entrega5D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$1': {
            'cantidad': int.parse(movimientos?.first.entrega1D ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
        }),
        SizedBox(height: 16),
        _detailRow('Total Entregado:', '\$${totalEntregado}'),
      ],
    );
  }

  Widget _buildDenominationList(
      String title, Map<String, Map<String, dynamic>> denominaciones) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF368983),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Column(
            children: denominaciones.entries.map((entry) {
              final label = entry.key;
              final cantidad = entry.value['cantidad'];
              final icon = entry.value['icon'];

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[200]!,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Ícono de billete/moneda más grande
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF368983).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        icon,
                        height: 36,
                        width: 36,
                      ),
                    ),
                    SizedBox(width: 16),
                    // Denominación
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Spacer(),
                    // Cantidad
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: cantidad > 0
                            ? Color(0xFF368983).withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${cantidad}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cantidad > 0
                              ? Color(0xFF368983)
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Color(0xFF368983).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF368983),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetiroParcialDetails() {
    final totalRecibido =
        (int.parse(movimientos?.first.recibe20D ?? '0') * 20) +
            (int.parse(movimientos?.first.recibe10D ?? '0') * 10) +
            (int.parse(movimientos?.first.recibe5D ?? '0') * 5) +
            (int.parse(movimientos?.first.recibe1D ?? '0') * 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDenominationList('Recibido:', {
          '\$20': {
            'cantidad': int.parse(movimientos?.first.recibe20D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$10': {
            'cantidad': int.parse(movimientos?.first.recibe10D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$5': {
            'cantidad': int.parse(movimientos?.first.recibe5D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$1': {
            'cantidad': int.parse(movimientos?.first.recibe1D ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
        }),
        SizedBox(height: 12),
        SizedBox(width: 15),
        _detailRow('Total:', '\$${totalRecibido}'),
      ],
    );
  }

  Widget _buildCanjeDetails() {
    final totalEntregado =
        (int.parse(movimientos?.first.entrega10D ?? '0') * 10) +
            (int.parse(movimientos?.first.entrega5D ?? '0') * 5) +
            (int.parse(movimientos?.first.entrega1D ?? '0') * 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDenominationList('Recibido:', {
          '\$20': {
            'cantidad': int.parse(movimientos?.first.recibe20D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$10': {
            'cantidad': int.parse(movimientos?.first.recibe10D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$5': {
            'cantidad': int.parse(movimientos?.first.recibe5D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$1': {
            'cantidad': int.parse(movimientos?.first.recibe1D ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
        }),
        SizedBox(height: 8),
        SizedBox(width: 15),
        _buildDenominationList('Entregado:', {
          '\$10': {
            'cantidad': int.parse(movimientos?.first.entrega10D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$5': {
            'cantidad': int.parse(movimientos?.first.entrega5D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$1': {
            'cantidad': int.parse(movimientos?.first.entrega1D ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
        }),
        SizedBox(height: 8),
        _detailRow('Total:', '\$${totalEntregado}'),
      ],
    );
  }

  Widget _buildLiquidacionDetails() {
    // Calcula el total de la liquidación actual

    final liquidacion =
        movimientos?.firstWhere((m) => m.idTipoMovimiento == '4');
    final totalRecibido = (int.parse(liquidacion?.recibe20D ?? '0') * 20) +
        (int.parse(liquidacion?.recibe10D ?? '0') * 10) +
        (int.parse(liquidacion?.recibe5D ?? '0') * 5) +
        (int.parse(liquidacion?.recibe1D ?? '0') * 1) +
        (int.parse(liquidacion?.recibe1DB ?? '0') * 1) +
        (int.parse(liquidacion?.recibe2D ?? '0') * 2) +
        (int.parse(liquidacion?.recibe50C ?? '0') * 0.5).toDouble() +
        (int.parse(liquidacion?.recibe25C ?? '0') * 0.25).toDouble() +
        (int.parse(liquidacion?.recibe10C ?? '0') * 0.1).toDouble() +
        (int.parse(liquidacion?.recibe5C ?? '0') * 0.05).toDouble() +
        (int.parse(liquidacion?.recibe1C ?? '0') * 0.01).toDouble();

    // Calcula el total de los retiros parciales relacionados

    final retirosparciales =
        movimientos?.where((m) => m.idTipoMovimiento == '2').toList();

    final totalRetirosParciales = retirosparciales
            ?.where((mov) => mov.idTipoMovimiento == '2')
            .fold(0, (sum, mov) {
          return sum +
              (int.parse(mov.recibe20D ?? '0') * 20) +
              (int.parse(mov.recibe10D ?? '0') * 10) +
              (int.parse(mov.recibe5D ?? '0') * 5) +
              (int.parse(mov.recibe1D ?? '0') * 1);
        }) ??
        0;

    // Suma el total de la liquidación y los retiros parciales
    final totalGeneral = totalRecibido + totalRetirosParciales;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Detalles de la liquidación
        _buildDenominationList('Recibido:', {
          '\$20': {
            'cantidad': int.parse(movimientos?.first.recibe20D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$10': {
            'cantidad': int.parse(movimientos?.first.recibe10D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$5': {
            'cantidad': int.parse(movimientos?.first.recibe5D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$2': {
            'cantidad': int.parse(movimientos?.first.recibe2D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$1': {
            'cantidad': int.parse(movimientos?.first.recibe1D ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '50C': {
            'cantidad': int.parse(movimientos?.first.recibe50C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '25C': {
            'cantidad': int.parse(movimientos?.first.recibe25C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '10C': {
            'cantidad': int.parse(movimientos?.first.recibe10C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '5C': {
            'cantidad': int.parse(movimientos?.first.recibe5C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '1C': {
            'cantidad': int.parse(movimientos?.first.recibe1C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
        }),
        SizedBox(height: 12),
        _detailRow('Total Recibido:', '\$${totalRecibido.toStringAsFixed(2)}'),
        SizedBox(height: 5),
        _detailRow('Retiros Parciales:',
            '\$${totalRetirosParciales.toStringAsFixed(2)}'),
        SizedBox(height: 12),
        // Detalle del total general de la liquidación
        _detailRow('Total General:', '\$${totalGeneral.toStringAsFixed(2)}'),
        SizedBox(height: 12),
        _confirmButton(movimientos?.first.idturno ?? '0'),
        SizedBox(height: 10),
        detalleTransaccionController.usuarioSession.roles?.first.id == '6' &&
                (bandera == 0 || bandera == 2)
            ? _canjeBottom(movimientos?.first.idturno ?? '')
            : Text(''),
      ],
    );
  }

  Widget _buildFaltanteDetails() {
    final totalEntregado = (int.parse(movimientos?.first.entrega10D ?? '0') *
            10) +
        (int.parse(movimientos?.first.entrega5D ?? '0') * 5) +
        (int.parse(movimientos?.first.entrega1D ?? '0') * 1) +
        (int.parse(movimientos?.first.entrega50C ?? '0') * 0.5).toDouble() +
        (int.parse(movimientos?.first.entrega25C ?? '0') * 0.25).toDouble() +
        (int.parse(movimientos?.first.entrega10C ?? '0') * 0.1).toDouble();

    final totalRecibido =
        (int.parse(movimientos?.first.recibe20D ?? '0') * 20) +
            (int.parse(movimientos?.first.entrega10D ?? '0') * 10) +
            (int.parse(movimientos?.first.recibe5D ?? '0') * 5) +
            (int.parse(movimientos?.first.recibe1D ?? '0') * 1) +
            (int.parse(movimientos?.first.recibe50C ?? '0') * 0.5).toDouble() +
            (int.parse(movimientos?.first.recibe25C ?? '0') * 0.25).toDouble() +
            (int.parse(movimientos?.first.recibe10C ?? '0') * 0.1).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDenominationList('Recibido:', {
          '\$20': {
            'cantidad': int.parse(movimientos?.first.recibe20D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$10': {
            'cantidad': int.parse(movimientos?.first.recibe10D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$5': {
            'cantidad': int.parse(movimientos?.first.recibe5D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$1': {
            'cantidad': int.parse(movimientos?.first.recibe1D ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '50C': {
            'cantidad': int.parse(movimientos?.first.recibe50C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '25C': {
            'cantidad': int.parse(movimientos?.first.recibe25C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '10C': {
            'cantidad': int.parse(movimientos?.first.recibe10C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
        }),
        SizedBox(height: 8),
        SizedBox(width: 15),
        _buildDenominationList('Entregado:', {
          '\$10': {
            'cantidad': int.parse(movimientos?.first.entrega10D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$5': {
            'cantidad': int.parse(movimientos?.first.entrega5D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$1': {
            'cantidad': int.parse(movimientos?.first.entrega1D ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '50C': {
            'cantidad': int.parse(movimientos?.first.entrega50C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '25C': {
            'cantidad': int.parse(movimientos?.first.entrega25C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '10C': {
            'cantidad': int.parse(movimientos?.first.entrega5C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
        }),
        SizedBox(height: 8),
        _detailRow('Total:', '\$${totalRecibido - totalEntregado}'),
      ],
    );
  }

  Widget _buildFortiusDetails() {
    final totalEntregado = (int.parse(movimientos?.first.entrega20D ?? '0') *
            20) +
        (int.parse(movimientos?.first.entrega10D ?? '0') * 10) +
        (int.parse(movimientos?.first.entrega5D ?? '0') * 5) +
        (int.parse(movimientos?.first.entrega1D ?? '0') * 1) +
        (int.parse(movimientos?.first.entrega50C ?? '0') * 0.5).toDouble() +
        (int.parse(movimientos?.first.entrega25C ?? '0') * 0.25).toDouble() +
        (int.parse(movimientos?.first.entrega10C ?? '0') * 0.1).toDouble() +
        (int.parse(movimientos?.first.entrega5C ?? '0') * 0.05).toDouble() +
        (int.parse(movimientos?.first.entrega1C ?? '0') * 0.01).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        movimientos?.first.recibe5D == '0'
            ? _buildDenominationList('Entregado:', {
                '\$20': {
                  'cantidad': int.parse(movimientos?.first.entrega20D ?? '0'),
                  'icon': 'assets/img/billete.png'
                },
                '\$10': {
                  'cantidad': int.parse(movimientos?.first.entrega10D ?? '0'),
                  'icon': 'assets/img/billete.png'
                },
                '\$5': {
                  'cantidad': int.parse(movimientos?.first.entrega5D ?? '0'),
                  'icon': 'assets/img/billete.png'
                },
                '\$1': {
                  'cantidad': int.parse(movimientos?.first.entrega1D ?? '0'),
                  'icon': 'assets/img/moneda.png'
                },
                '50C': {
                  'cantidad': int.parse(movimientos?.first.entrega50C ?? '0'),
                  'icon': 'assets/img/moneda.png'
                },
                '25C': {
                  'cantidad': int.parse(movimientos?.first.entrega25C ?? '0'),
                  'icon': 'assets/img/moneda.png'
                },
                '10C': {
                  'cantidad': int.parse(movimientos?.first.entrega10C ?? '0'),
                  'icon': 'assets/img/moneda.png'
                },
                '5C': {
                  'cantidad': int.parse(movimientos?.first.entrega5C ?? '0'),
                  'icon': 'assets/img/moneda.png'
                },
                '1C': {
                  'cantidad': int.parse(movimientos?.first.entrega1C ?? '0'),
                  'icon': 'assets/img/moneda.png'
                },
              })
            : _buildDenominationList('Entregado:', {
                '\$20': {
                  'cantidad': int.parse(movimientos?.first.entrega20D ?? '0'),
                  'icon': 'assets/img/billete.png'
                },
                '\$10': {
                  'cantidad': int.parse(movimientos?.first.entrega10D ?? '0'),
                  'icon': 'assets/img/billete.png'
                },
              }),
        SizedBox(height: 12),
        SizedBox(width: 15),
        if (movimientos?.first.recibe5D != '0')
          _buildDenominationList('Recibido:', {
            '\$5': {
              'cantidad': int.parse(movimientos?.first.recibe5D ?? '0'),
              'icon': 'assets/img/billete.png'
            },
            '\$1': {
              'cantidad': int.parse(movimientos?.first.recibe1D ?? '0'),
              'icon': 'assets/img/moneda.png'
            },
          }),
        _detailRow('Total:', '\$${totalEntregado}'),
      ],
    );
  }

  Widget _buildTagDetails() {
    // Calcula el total de la liquidación actual
    final totalRecibido =
        (int.parse(movimientos?.first.recibe20D ?? '0') * 20) +
            (int.parse(movimientos?.first.recibe10D ?? '0') * 10) +
            (int.parse(movimientos?.first.recibe5D ?? '0') * 5) +
            (int.parse(movimientos?.first.recibe1D ?? '0') * 1) +
            (int.parse(movimientos?.first.recibe1DB ?? '0') * 1) +
            (int.parse(movimientos?.first.recibe2D ?? '0') * 2) +
            (int.parse(movimientos?.first.recibe50C ?? '0') * 0.5).toDouble() +
            (int.parse(movimientos?.first.recibe25C ?? '0') * 0.25).toDouble() +
            (int.parse(movimientos?.first.recibe10C ?? '0') * 0.1).toDouble() +
            (int.parse(movimientos?.first.recibe5C ?? '0') * 0.05).toDouble() +
            (int.parse(movimientos?.first.recibe1C ?? '0') * 0.01).toDouble();

    // Suma el total de la liquidación y los retiros parciales
    final totalGeneral = totalRecibido;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Detalles de la liquidación
        _buildDenominationList('Recibido:', {
          '\$20': {
            'cantidad': int.parse(movimientos?.first.recibe20D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$10': {
            'cantidad': int.parse(movimientos?.first.recibe10D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$5': {
            'cantidad': int.parse(movimientos?.first.recibe5D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$2': {
            'cantidad': int.parse(movimientos?.first.recibe2D ?? '0'),
            'icon': 'assets/img/billete.png'
          },
          '\$1': {
            'cantidad': int.parse(movimientos?.first.recibe1D ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '50C': {
            'cantidad': int.parse(movimientos?.first.recibe50C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '25C': {
            'cantidad': int.parse(movimientos?.first.recibe25C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '10C': {
            'cantidad': int.parse(movimientos?.first.recibe10C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '5C': {
            'cantidad': int.parse(movimientos?.first.recibe5C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
          '1C': {
            'cantidad': int.parse(movimientos?.first.recibe1C ?? '0'),
            'icon': 'assets/img/moneda.png'
          },
        }),

        SizedBox(height: 12),
        // Detalle del total general de la liquidación
        _detailRow('Total General:', '\$${totalGeneral.toStringAsFixed(2)}'),
        SizedBox(height: 12),
        _confirmButton(movimientos?.first.idturno ?? '0'),
      ],
    );
  }

  Widget _confirmButton(String idturno) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          detalleTransaccionController.goToReportes(idturno);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF368983),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Reporte de Liquidación',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _canjeBottom(String idturno) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          detalleTransaccionController.goToFaltantes(idturno);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF368983),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Agregar Faltantes/Sobrantes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
