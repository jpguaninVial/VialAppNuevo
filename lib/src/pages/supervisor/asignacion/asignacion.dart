import 'package:asistencia_vial_app/src/pages/supervisor/asignacion/asignacion_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../helper/connection_controller.dart';
import '../../../helper/offline_banner.dart';
import '../../../models/movimiento.dart';
import '../../../models/usuario.dart';

class AsignacionPage extends StatelessWidget {
  AsignacionController asignacionController = Get.put(AsignacionController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => DefaultTabController(
          length: asignacionController.estados.length,
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            body: Stack(
              children: [
                Column(
                  children: [
                    _buildModernHeader(context),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _pullToRefresh,
                        color: Color(0xFF368983),
                        child: TabBarView(
                          children: List<Widget>.generate(
                              asignacionController.estados.length, (index2) {
                            return FutureBuilder(
                              future: asignacionController.getUsuarios(
                                (index2 + 1).toString(),
                                asignacionController.usuario.idPeaje ?? '1',
                              ),
                              builder: (context,
                                  AsyncSnapshot<List<Usuario>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF368983)),
                                    ),
                                  );
                                }
                                if (snapshot.hasData &&
                                    snapshot.data!.isNotEmpty) {
                                  return ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        top: 20.0,
                                        bottom: 120.0),
                                    itemCount: snapshot.data?.length ?? 0,
                                    itemBuilder: (_, index) {
                                      return _cardUsuario(context,
                                          snapshot.data![index], index2);
                                    },
                                  );
                                }
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_off_outlined,
                                          size: 80, color: Colors.grey[400]),
                                      SizedBox(height: 16),
                                      Text(
                                        "No hay usuarios asignados",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: 20.0, top: 8.0, right: 20.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Asignación de Turnos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(),
                      icon: Icon(Icons.refresh, color: Colors.white, size: 22),
                      onPressed: () {
                        asignacionController.getEstados();
                      },
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
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              labelPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tabs: List<Widget>.generate(
                asignacionController.estados.length,
                (index) => Tab(
                  child: Text(
                    asignacionController.estados[index].nombre ?? ' ',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pullToRefresh() async {
    asignacionController.getUsuarios(
        "1", asignacionController.usuario.idPeaje ?? '1');
  }

  Widget _cardUsuario(BuildContext context, Usuario usuario, int cardIndex) {
    return FutureBuilder<List<Movimiento?>>(
      future:
          asignacionController.getMovimientoPorUsuario(usuario.idTurno ?? ''),
      builder: (context, snapshot) {
        String aperturaEstado = "Sin Apertura";
        String estadoLiquidacion = "Sin Liquidar";

        if (snapshot.connectionState == ConnectionState.waiting) {
          aperturaEstado = "Cargando...";
          estadoLiquidacion = "Cargando...";
        } else if (snapshot.hasData) {
          List<Movimiento?> movimientosApertura =
              snapshot.data!.where((m) => m?.idTipoMovimiento == '1').toList();
          if (movimientosApertura.isNotEmpty) {
            aperturaEstado = _validarApertura(movimientosApertura.first!);
          } else {
            aperturaEstado = "Sin Apertura";
          }

          List<Movimiento?> movimientosLiquidacion =
              snapshot.data!.where((m) => m?.idTipoMovimiento == '4').toList();
          if (movimientosLiquidacion.isNotEmpty) {
            estadoLiquidacion =
                _validarEstadoLiquidacion(movimientosLiquidacion.first!);
          } else {
            estadoLiquidacion = "No hay apertura registrada";
          }
        }

        return GestureDetector(
          onTap: () => cardIndex == 2
              ? asignacionController.openBottomSheetLiquidacion(
                  context, usuario.idTurno ?? '0', 2)
              : asignacionController.openBottomSheet(
                  context, usuario.idTurno ?? '0'),
          child: Container(
            margin: EdgeInsets.only(bottom: 12, left: 16, right: 16),
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
                  // Avatar del usuario
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Color(0xFF368983).withOpacity(0.3), width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/img/no-image.png',
                        image: usuario.imagen ?? '',
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/img/no-image.png');
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Información del usuario
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${usuario.nombre} ${usuario.apellido}' ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.directions_car,
                                size: 14, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              usuario.via != null
                                  ? 'Vía ${usuario.via}'
                                  : 'Vía no asignada',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(cardIndex, aperturaEstado,
                                    estadoLiquidacion)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusText(
                                cardIndex, aperturaEstado, estadoLiquidacion),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _getStatusColor(
                                  cardIndex, aperturaEstado, estadoLiquidacion),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Menú de opciones
                  if (asignacionController.usuario.roles?.first.id != '5')
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
                      itemBuilder: (BuildContext context) {
                        return _getOptionsForCard(
                            context,
                            cardIndex,
                            usuario,
                            usuario.id ?? '1',
                            usuario.idTurno ?? '1',
                            aperturaEstado);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(
      int cardIndex, String aperturaEstado, String estadoLiquidacion) {
    if (cardIndex == 2) {
      if (estadoLiquidacion == "Liquidado") return Colors.green;
      if (estadoLiquidacion == "Sin liquidar") return Colors.redAccent;
      return Colors.orangeAccent;
    } else if (cardIndex == 1) {
      if (aperturaEstado == "Apertura Completa" ||
          aperturaEstado == "Apertura Incompleta") {
        return Colors.green;
      }
      return Colors.redAccent;
    } else {
      if (aperturaEstado == "Apertura Completa") return Colors.green;
      if (aperturaEstado == "Cargando...") return Colors.blue;
      if (aperturaEstado == "Sin Apertura") return Colors.redAccent;
      return Colors.orangeAccent;
    }
  }

  String _getStatusText(
      int cardIndex, String aperturaEstado, String estadoLiquidacion) {
    if (cardIndex == 2) {
      return estadoLiquidacion;
    } else if (cardIndex == 1) {
      if (aperturaEstado == "Apertura Completa" ||
          aperturaEstado == "Apertura Incompleta") {
        return "Apertura Entregada";
      }
      return "Sin Apertura";
    } else {
      return aperturaEstado;
    }
  }

  List<PopupMenuEntry<String>> _getOptionsForCard(
      BuildContext context,
      int cardIndex,
      Usuario usuario,
      String idCajero,
      String idTurno,
      String aperturaEstado) {
    asignacionController.getApertura(usuario.idTurno ?? '');
    asignacionController.getFaltante(usuario.idTurno ?? '');

    print("Apertura estado ${aperturaEstado}");

    switch (cardIndex) {
      case 0:
        return [
          PopupMenuItem<String>(
            value: "Canje",
            child: Row(
              children: [
                Icon(Icons.currency_exchange, color: Colors.blue, size: 20),
                SizedBox(width: 12),
                Text("Canje"),
              ],
            ),
            onTap: () => asignacionController.goToCanje(usuario),
          ),
          PopupMenuItem<String>(
            value: "Rparcial",
            child: Row(
              children: [
                Icon(Icons.paid, color: Colors.green, size: 20),
                SizedBox(width: 12),
                Text("Retiro Parcial"),
              ],
            ),
            onTap: () => asignacionController.goToRetiroParcial(usuario),
          ),
          PopupMenuItem<String>(
            child: Row(
              children: [
                Icon(Icons.arrow_circle_down, color: Colors.green, size: 20),
                SizedBox(width: 12),
                Text("Retiro Apertura"),
              ],
            ),
            onTap: () {
              aperturaEstado == "Sin Apertura"
                  ? asignacionController.goToApertura(usuario)
                  : asignacionController.goToRetiroApertura(
                      usuario, asignacionController.movimiento);
            },
          ),
          if (asignacionController.usuario.roles?.first.id == '2') ...[
            PopupMenuItem<String>(
              child: Row(
                children: [
                  Icon(Icons.directions_car, color: Colors.yellow, size: 20),
                  SizedBox(width: 12),
                  Text("Cambio de Vía"),
                ],
              ),
              onTap: () => Future.delayed(
                Duration.zero,
                () => _showViaSelectionDialog(context, idTurno),
              ),
            ),
          ],
          PopupMenuItem<String>(
            child: Row(
              children: [
                Icon(Icons.edit_calendar_outlined,
                    color: Colors.cyan, size: 20),
                SizedBox(width: 12),
                Text("Parte de Trabajo"),
              ],
            ),
            onTap: () => asignacionController.faltante.partetrabajo == null
                ? asignacionController.goToFaltantes(usuario, 1)
                : Get.dialog(
                    AlertDialog(
                      title: Text("Parte de Trabajo registrado!"),
                      content: Text("Ya se ha registrado el parte de trabajo"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: Text("Aceptar"),
                        ),
                      ],
                    ),
                  ),
          ),
          if (asignacionController.usuario.roles?.first.id == '2') ...[
            PopupMenuItem<String>(
              child: Row(
                children: [
                  Icon(Icons.price_check, color: Colors.orange, size: 20),
                  SizedBox(width: 12),
                  Text("Liquidacion temprana"),
                ],
              ),
              onTap: () => aperturaEstado == "Apertura Completa"
                  ? asignacionController.goToLiquidaciones(usuario)
                  : Get.dialog(
                      AlertDialog(
                        title: Text("Apertura Incompleta!"),
                        content: Text(
                            "No se ha retirado la apertura de ${usuario.nombre} ${usuario.apellido}"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text("Regresar"),
                          ),
                          TextButton(
                            onPressed: () {
                              asignacionController.goToRetiroApertura(
                                  usuario, asignacionController.movimiento);
                            },
                            child: Text("Retirar apertura"),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
          if (asignacionController.usuario.roles?.first.id == '1') ...[
            PopupMenuItem<String>(
              child: Row(
                children: [
                  Icon(Icons.arrow_forward_ios_sharp,
                      color: Colors.orange, size: 20),
                  SizedBox(width: 12),
                  Text("Enviar a Boveda"),
                ],
              ),
              onTap: () => asignacionController.enviarBoveda(
                  usuario.id ?? '', usuario.idTurno ?? ''),
            ),
          ],
        ];
      case 1:
        return [
          if (asignacionController.usuario.roles?.first.id == '2') ...[
            PopupMenuItem<String>(
              child: Row(
                children: [
                  Icon(Icons.arrow_circle_up, color: Colors.green, size: 20),
                  SizedBox(width: 12),
                  Text("Apertura"),
                ],
              ),
              onTap: () {
                if (asignacionController.movimiento.id == null) {
                  print(
                      "Valor de movimiento: ${asignacionController.movimiento.id}");
                  asignacionController.goToApertura(usuario);
                } else {
                  usuario.idRol != '4'
                      ? Get.dialog(
                          AlertDialog(
                            title: Text("Apertura Registrada!"),
                            content: Text(
                                "Ya se ha registrado la apertura previamente."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text("Aceptar"),
                              ),
                            ],
                          ),
                        )
                      : asignacionController.goToRetiroApertura(
                          usuario, asignacionController.movimiento);
                }
              },
            ),
            PopupMenuItem<String>(
              child: Row(
                children: [
                  Icon(Icons.price_check, color: Colors.orange, size: 20),
                  SizedBox(width: 12),
                  Text("Liquidacion"),
                ],
              ),
              onTap: () => aperturaEstado == "Apertura Completa"
                  ? asignacionController.goToLiquidaciones(usuario)
                  : Get.dialog(
                      AlertDialog(
                        title: Text("Apertura Incompleta!"),
                        content: Text(
                            "No se ha retirado la apertura de ${usuario.nombre} ${usuario.apellido}"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text("Regresar"),
                          ),
                          TextButton(
                            onPressed: () {
                              asignacionController.goToRetiroApertura(
                                  usuario, asignacionController.movimiento);
                            },
                            child: Text("Retirar apertura"),
                          ),
                        ],
                      ),
                    ),
            ),
            PopupMenuItem<String>(
              child: Row(
                children: [
                  Icon(Icons.directions_car, color: Colors.yellow, size: 20),
                  SizedBox(width: 12),
                  Text("Asignacion de Vía"),
                ],
              ),
              onTap: () => Future.delayed(
                Duration.zero,
                () => _showViaSelectionDialog(context, idTurno),
              ),
            ),
            PopupMenuItem<String>(
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Text("Enviar a Turno "),
                ],
              ),
              onTap: () {
                aperturaEstado == "Sin Apertura"
                    ? Get.dialog(
                        AlertDialog(
                          title: Text("Sin Apertura!"),
                          content: Text(
                              "No se puede enviar a turno sin asignar una apertura al usuario: ${usuario.nombre} ${usuario.apellido}"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text("Regresar"),
                            ),
                            TextButton(
                              onPressed: () {
                                asignacionController.goToApertura(usuario);
                              },
                              child: Text("Asignar apertura"),
                            ),
                          ],
                        ),
                      )
                    : WidgetsBinding.instance.addPostFrameCallback((_) {
                        _showTurnoConfirmationDialog(context, usuario);
                      });
              },
            ),
            PopupMenuItem<String>(
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.orange, size: 20),
                  SizedBox(width: 12),
                  Text("Eliminar"),
                ],
              ),
              onTap: () => aperturaEstado == "Sin Apertura"
                  ? WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showDeleteConfirmationDialog(context, usuario);
                    })
                  : Get.dialog(
                      AlertDialog(
                        title: Text("Apertura Incompleta!"),
                        content: Text(
                            "No se ha retirado la apertura de ${usuario.nombre} ${usuario.apellido}"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text("Regresar"),
                          ),
                          TextButton(
                            onPressed: () {
                              asignacionController.goToRetiroApertura(
                                  usuario, asignacionController.movimiento);
                            },
                            child: Text("Retirar apertura"),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ];
      case 2:
        return [
          if (asignacionController.usuario.roles?.first.id == '6') ...[
            PopupMenuItem<String>(
              value: "Faltante",
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.orange, size: 20),
                  SizedBox(width: 12),
                  Text("Faltante"),
                ],
              ),
              onTap: () {
                asignacionController.goToFaltantes(usuario, 2);
              },
            ),
          ],
          PopupMenuItem<String>(
            child: Row(
              children: [
                Icon(Icons.request_page, color: Colors.green, size: 20),
                SizedBox(width: 12),
                Text("Reporte"),
              ],
            ),
            onTap: () => asignacionController.goToReportes(usuario),
          ),
        ];
      default:
        return [];
    }
  }

  String _validarApertura(Movimiento movimiento) {
    final totalEntregado = (int.tryParse(movimiento.entrega10D ?? '0') ?? 0) *
            10 +
        (int.tryParse(movimiento.entrega5D ?? '0') ?? 0) * 5 +
        (int.tryParse(movimiento.entrega1D ?? '0') ?? 0) * 1 +
        ((int.tryParse(movimiento.entrega50C ?? '0') ?? 0) * 0.5).toDouble() +
        ((int.tryParse(movimiento.entrega25C ?? '0') ?? 0) * 0.25).toDouble() +
        ((int.tryParse(movimiento.entrega5C ?? '0') ?? 0) * 0.05).toDouble() +
        ((int.tryParse(movimiento.entrega10C ?? '0') ?? 0) * 0.1).toDouble() +
        ((int.tryParse(movimiento.entrega1C ?? '0') ?? 0) * 0.01).toDouble();

    final totalRecibido = (int.tryParse(movimiento.recibe20D ?? '0') ?? 0) *
            20 +
        (int.tryParse(movimiento.recibe10D ?? '0') ?? 0) * 10 +
        (int.tryParse(movimiento.recibe5D ?? '0') ?? 0) * 5 +
        (int.tryParse(movimiento.recibe1D ?? '0') ?? 0) * 1 +
        ((int.tryParse(movimiento.recibe50C ?? '0') ?? 0) * 0.5).toDouble() +
        ((int.tryParse(movimiento.recibe25C ?? '0') ?? 0) * 0.25).toDouble() +
        ((int.tryParse(movimiento.recibe5C ?? '0') ?? 0) * 0.05).toDouble() +
        ((int.tryParse(movimiento.recibe10C ?? '0') ?? 0) * 0.1).toDouble() +
        ((int.tryParse(movimiento.recibe1C ?? '0') ?? 0) * 0.1).toDouble();

    return (totalEntregado - totalRecibido) == 0
        ? "Apertura Completa"
        : "Apertura Incompleta";
  }

  String _validarEstadoLiquidacion(Movimiento movimiento) {
    return (movimiento.estado == '1') ? "Liquidado" : "Sin liquidar";
  }

  void _showDeleteConfirmationDialog(BuildContext context, Usuario usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar eliminación"),
          content: Text(
            "¿Estás seguro de eliminar el turno de ${usuario.nombre} ${usuario.apellido}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                asignacionController.deleteTurno(usuario.id ?? '1');
              },
              child: Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void _showTurnoConfirmationDialog(BuildContext context, Usuario usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Turno"),
          content: Text(
            "¿Estás seguro que deseas enviar a Turno a ${usuario.nombre} ${usuario.apellido}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                asignacionController.enviarTurno(usuario.id ?? '1');
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  void _showViaSelectionDialog(BuildContext context, String idTurno) {
    List<int> vias = [1, 2, 3, 4, 5, 6, 7, 8, 104, 105];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Selecciona una vía",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: vias.length,
              itemBuilder: (BuildContext context, int index) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    print("Vía ${vias[index]} seleccionada");
                    asignacionController.updateVia(
                        vias[index].toString(), idTurno);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF368983),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "${vias[index]}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize:
                          (vias[index] == 104 || vias[index] == 105) ? 7 : 16,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
