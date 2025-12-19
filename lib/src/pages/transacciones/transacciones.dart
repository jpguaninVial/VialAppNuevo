import 'package:asistencia_vial_app/src/models/movimiento.dart';
import 'package:asistencia_vial_app/src/pages/transacciones/transacciones_controller.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/connection_controller.dart';
import '../../helper/offline_banner.dart';

class Transacciones extends StatelessWidget {
  TransaccionesController transaccionesController =
      Get.put(TransaccionesController());
  int? index2;

  @override
  Widget build(BuildContext context) {
    return Obx(() => DefaultTabController(
          length: transaccionesController.tipoMovimientos.length,
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Stack(
              children: [
                Column(
                  children: [
                    _buildModernHeader(context),
                    Expanded(
                      child: TabBarView(
                        children: List.generate(
                          transaccionesController.tipoMovimientos.length,
                          (index) => _buildTabContent(index + 1),
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
          ),
        ));
  }

  /// 🎨 **Header moderno sin curvas**
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: 20.0, top: 8.0, right: 20.0, bottom: 8.0),
              child: Text(
                'Transacciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        String? fechaSeleccionada =
                            await _selectDate(context, true);
                        if (fechaSeleccionada != null) {
                          transaccionesController.fechaInicio.value =
                              fechaSeleccionada;
                          _checkAndSearch();
                        }
                      },
                      child: _modernDateField(
                        label: 'Fecha Inicio',
                        value: transaccionesController.fechaInicio.value,
                        context: context,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        String? fechaSeleccionada =
                            await _selectDate(context, false);
                        if (fechaSeleccionada != null) {
                          transaccionesController.fechaFin.value =
                              fechaSeleccionada;
                          _checkAndSearch();
                        }
                      },
                      child: _modernDateField(
                        label: 'Fecha Fin',
                        value: transaccionesController.fechaFin.value,
                        context: context,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(),
                      icon:
                          Icon(Icons.clear_all, color: Colors.white, size: 22),
                      onPressed: _clearFilters,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            TabBar(
              tabAlignment: TabAlignment.center,
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.9),
              labelStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
              labelPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tabs: transaccionesController.tipoMovimientos
                  .map((tipo) => Tab(text: tipo.nombreMovimiento ?? ' '))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernDateField(
      {required String label,
      required String value,
      required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .onPrimaryContainer
                .withOpacity(0.3),
            width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.white),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              value.isEmpty ? label : value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int idTipoMovimiento) {
    return RefreshIndicator(
      onRefresh: () => _pullToRefresh(idTipoMovimiento),
      color: Theme.of(Get.context!).colorScheme.primary,
      child: FutureBuilder(
        future: transaccionesController.getMovimientos(
          transaccionesController.fechaInicio.value,
          transaccionesController.fechaFin.value,
          idTipoMovimiento.toString(),
          transaccionesController.usuarioSession.idPeaje ?? '1',
        ),
        builder: (context, AsyncSnapshot<List<Movimiento>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(Get.context!).colorScheme.primary),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.builder(
              padding: EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 20.0, bottom: 120.0),
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                return _transactionCard(
                    context, snapshot.data![index], idTipoMovimiento);
              },
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined,
                    size: 80,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                SizedBox(height: 16),
                Text(
                  "No hay transacciones disponibles",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pullToRefresh(int idTipoMovimiento) async {
    await transaccionesController.getMovimientos(
      transaccionesController.fechaInicio.value,
      transaccionesController.fechaFin.value,
      idTipoMovimiento.toString(),
      transaccionesController.usuarioSession.idPeaje ?? '1',
    );
  }

  void _checkAndSearch() {
    if (transaccionesController.fechaInicio.isNotEmpty &&
        transaccionesController.fechaFin.isNotEmpty) {
      int currentIndex = DefaultTabController.of(Get.context!)?.index ?? 0;
      int idTipoMovimiento = currentIndex + 1;

      transaccionesController.getMovimientos(
        transaccionesController.fechaInicio.value,
        transaccionesController.fechaFin.value,
        idTipoMovimiento.toString(),
        transaccionesController.usuarioSession.idPeaje ?? '1',
      );
    }
  }

  void _clearFilters() {
    transaccionesController.fechaInicio.value = '';
    transaccionesController.fechaFin.value = '';
    _checkAndSearch();
  }

  Widget _transactionCard(
      BuildContext context, Movimiento movimiento, int idTipoMovimiento) {
    String valor;
    String detalle;
    IconData icono = Icons.paid_outlined;
    Color iconColor = Theme.of(context).colorScheme.primary;

    switch (idTipoMovimiento) {
      case 1:
        valor =
            "\$${(int.parse(movimiento.entrega1D ?? '0') * 1) + (int.parse(movimiento.entrega50C ?? '0') * 0.5).toDouble() + (int.parse(movimiento.entrega25C ?? '0') * 0.25).toDouble() + (int.parse(movimiento.entrega5D ?? '0') * 5) + (int.parse(movimiento.entrega10D ?? '0') * 10)}";
        detalle =
            "${movimiento.nombreCajero}\n${formatDate(DateTime.parse(movimiento.fecha ?? '0'), [
              dd,
              '/',
              mm,
              '/',
              yyyy
            ])}\nTurno ${movimiento.turno}";
        icono = Icons.paid_outlined;
        break;
      case 2:
        valor =
            "\$${(int.parse(movimiento.recibe1D ?? '0') * 1) + (int.parse(movimiento.recibe5D ?? '0') * 5) + (int.parse(movimiento.recibe10D ?? '0') * 10) + (int.parse(movimiento.recibe20D ?? '0') * 20)}";
        detalle =
            "${movimiento.nombreCajero}\nVía ${movimiento.via}\n${formatDate(DateTime.parse(movimiento.fecha ?? '0'), [
              dd,
              '/',
              mm,
              '/',
              yyyy
            ])}\nTurno ${movimiento.turno}";
        icono = Icons.payments_outlined;
        break;
      case 3:
        valor =
            "\$${(int.parse(movimiento.recibe1D ?? '0') * 1) + (int.parse(movimiento.recibe5D ?? '0') * 5) + (int.parse(movimiento.recibe10D ?? '0') * 10) + (int.parse(movimiento.recibe20D ?? '0') * 20)}";
        detalle =
            "${movimiento.nombreCajero}\nVía ${movimiento.via}\n${formatDate(DateTime.parse(movimiento.fecha ?? '0'), [
              dd,
              '/',
              mm,
              '/',
              yyyy
            ])}\nTurno ${movimiento.turno}";
        icono = Icons.currency_exchange;
        break;
      case 4:
        valor =
            "\$${((int.parse(movimiento.recibe1C ?? '0') * 0.01) + (int.parse(movimiento.recibe5C ?? '0') * 0.05) + (int.parse(movimiento.recibe10C ?? '0') * 0.1) + (int.parse(movimiento.recibe25C ?? '0') * 0.25) + (int.parse(movimiento.recibe50C ?? '0') * 0.5) + (int.parse(movimiento.recibe2D ?? '0') * 2) + (int.parse(movimiento.recibe1D ?? '0') * 1) + (int.parse(movimiento.recibe1DB ?? '0') * 1) + (int.parse(movimiento.recibe5D ?? '0') * 5) + (int.parse(movimiento.recibe10D ?? '0') * 10) + (int.parse(movimiento.recibe20D ?? '0') * 20)).toStringAsFixed(2)}";
        detalle =
            "${movimiento.nombreCajero}\n${formatDate(DateTime.parse(movimiento.fecha ?? '0'), [
              dd,
              '/',
              mm,
              '/',
              yyyy
            ])}\nTurno: ${movimiento.turno}";
        icono = Icons.request_page_outlined;
        break;
      case 5:
        valor =
            "\$${((int.parse(movimiento.entrega1C ?? '0') * 0.01) + (int.parse(movimiento.entrega5C ?? '0') * 0.05) + (int.parse(movimiento.entrega10C ?? '0') * 0.1) + (int.parse(movimiento.entrega25C ?? '0') * 0.25) + (int.parse(movimiento.entrega50C ?? '0') * 0.5) + (int.parse(movimiento.entrega1D ?? '0') * 1) + (int.parse(movimiento.entrega5D ?? '0') * 5) + (int.parse(movimiento.entrega10D ?? '0') * 10) + (int.parse(movimiento.entrega20D ?? '0') * 20)).toStringAsFixed(2)}";
        detalle =
            "${movimiento.nombreSupervisor}\n${formatDate(DateTime.parse(movimiento.fecha ?? '0'), [
              dd,
              '/',
              mm,
              '/',
              yyyy
            ])}\nTurno ${movimiento.turno}";
        icono = Icons.directions_car;
        break;
      case 6:
        valor =
            "\$${(((int.parse(movimiento.recibe1C ?? '0') * 0.01) + (int.parse(movimiento.recibe5C ?? '0') * 0.05) + (int.parse(movimiento.recibe10C ?? '0') * 0.1) + (int.parse(movimiento.recibe25C ?? '0') * 0.25) + (int.parse(movimiento.recibe50C ?? '0') * 0.5) + (int.parse(movimiento.recibe2D ?? '0') * 2) + (int.parse(movimiento.recibe1D ?? '0') * 1) + (int.parse(movimiento.recibe1DB ?? '0') * 1) + (int.parse(movimiento.recibe5D ?? '0') * 5) + (int.parse(movimiento.recibe10D ?? '0') * 10) + (int.parse(movimiento.recibe20D ?? '0') * 20)) - ((int.parse(movimiento.entrega1C ?? '0') * 0.01) + (int.parse(movimiento.entrega5C ?? '0') * 0.05) + (int.parse(movimiento.entrega10C ?? '0') * 0.1) + (int.parse(movimiento.entrega25C ?? '0') * 0.25) + (int.parse(movimiento.entrega50C ?? '0') * 0.5) + (int.parse(movimiento.entrega1D ?? '0') * 1) + (int.parse(movimiento.entrega1DB ?? '0') * 1) + (int.parse(movimiento.entrega5D ?? '0') * 5) + (int.parse(movimiento.entrega10D ?? '0') * 10) + (int.parse(movimiento.entrega20D ?? '0') * 20))).toStringAsFixed(2)}";
        detalle =
            "${movimiento.nombreCajero}\n${formatDate(DateTime.parse(movimiento.fecha ?? '0'), [
              dd,
              '/',
              mm,
              '/',
              yyyy
            ])}\nTurno ${movimiento.turno}";
        icono = Icons.error_outline;
        break;
      case 7:
        valor =
            "\$${((int.parse(movimiento.recibe1C ?? '0') * 0.01) + (int.parse(movimiento.recibe5C ?? '0') * 0.05) + (int.parse(movimiento.recibe10C ?? '0') * 0.1) + (int.parse(movimiento.recibe25C ?? '0') * 0.25) + (int.parse(movimiento.recibe50C ?? '0') * 0.5) + (int.parse(movimiento.recibe2D ?? '0') * 2) + (int.parse(movimiento.recibe1D ?? '0') * 1) + (int.parse(movimiento.recibe1DB ?? '0') * 1) + (int.parse(movimiento.recibe5D ?? '0') * 5) + (int.parse(movimiento.recibe10D ?? '0') * 10) + (int.parse(movimiento.recibe20D ?? '0') * 20)).toStringAsFixed(2)}";
        detalle =
            "${movimiento.nombreCajero}\n${formatDate(DateTime.parse(movimiento.fecha ?? '0'), [
              dd,
              '/',
              mm,
              '/',
              yyyy
            ])}\nTurno ${movimiento.turno}";
        icono = Icons.credit_card_sharp;
        break;
      default:
        valor = "\$0.00";
        detalle = "Información no disponible";
    }

    return GestureDetector(
      onTap: () => transaccionesController.openBottomSheet(
        context,
        movimiento,
        transaccionesController.bandera.value,
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
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
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icono,
                  color: iconColor,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      valor,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      detalle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF368983),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      return "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
    }
    return null;
  }
}
