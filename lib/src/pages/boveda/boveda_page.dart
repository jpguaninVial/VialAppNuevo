import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../helper/connection_controller.dart';
import '../../helper/offline_banner.dart';
import '../../models/usuario.dart';
import 'boveda_controller.dart';

class BovedaPage extends StatelessWidget {
  final BovedaController bovedaSupController = Get.put(BovedaController());
  final Usuario usuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  @override
  Widget build(BuildContext context) {
    // Llamar a la función para cargar la bóveda
    bovedaSupController.getBoveda(usuario.idPeaje ?? '0');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // Fondo dinámico
      body: RefreshIndicator(
        onRefresh: _pullToRefresh,
        color: Color(0xFF368983),
        child: Column(
          children: [
            Obx(() {
              if (Get.find<ConnectionController>().isOffline.value) {
                return const OfflineBanner();
              } else {
                return const SizedBox.shrink();
              }
            }),
            Obx(() => _headerSection(context)), // Encabezado dinámico
            Expanded(
              child: Obx(() => _denominacionesList(context)), // Lista dinámica
            ),
          ],
        ),
      ),
    );
  }

  /// 🟢 **Función para refrescar la pantalla al deslizar hacia abajo**
  Future<void> _pullToRefresh() async {
    bovedaSupController.getBoveda(usuario.idPeaje ?? '0');
  }

  /// **Header: Usuario en sesión y total en bóveda**
  Widget _headerSection(BuildContext context) {
    final boveda = bovedaSupController.boveda.value;
    final totalBovedaFormatted = boveda?.total != null
        ? NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2)
            .format(double.tryParse(boveda!.total!) ?? 0.0)
        : "Cargando...";

    return Container(
      padding:
          EdgeInsets.only(left: 24.0, top: 16.0, right: 24.0, bottom: 32.0),
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
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primera fila: Avatar y nombre del usuario
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundImage:
                              usuario.imagen != null && usuario.imagen != ''
                                  ? NetworkImage(usuario.imagen!)
                                  : null,
                          child: usuario.imagen == null || usuario.imagen == ''
                              ? Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                )
                              : null,
                          radius: 28,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.3),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenido',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              usuario.nombre != null
                                  ? '${usuario.nombre} ${usuario.apellido}'
                                  : 'Usuario',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                _buildActionMenu(context, boveda),
              ],
            ),
            SizedBox(height: 28),
            // Segunda fila: Total en bóveda
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withOpacity(0.7),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Total en Bóveda",
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    totalBovedaFormatted,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, dynamic boveda) {
    return PopupMenuButton<int>(
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.more_vert, color: Colors.white),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<int>> items = [
          PopupMenuItem<int>(
            value: 1,
            child: _buildMenuItem(Icons.person, 'Ver Perfil', Colors.blue),
            onTap: () => bovedaSupController.gotoProfile(),
          ),
          PopupMenuItem<int>(
            value: 2,
            child: _buildMenuItem(Icons.logout, 'Cerrar Sesión', Colors.red),
            onTap: () => bovedaSupController.signOut(),
          ),
        ];

        // Lógica de roles (simplificada para legibilidad)
        if (usuario.roles?.first.id == '1' || usuario.roles?.first.id == '5') {
          items.add(PopupMenuDivider());
          if (usuario.idPeaje == '1') {
            items.add(PopupMenuItem(
              value: 3,
              child: _buildMenuItem(Icons.change_circle_outlined,
                  'Cambiar a Los Angeles', Colors.green),
              onTap: () => bovedaSupController.actualizarPeaje(context, '2'),
            ));
          } else {
            items.add(PopupMenuItem(
              value: 4,
              child: _buildMenuItem(Icons.change_circle_outlined,
                  'Cambiar a Congoma', Colors.green),
              onTap: () => bovedaSupController.actualizarPeaje(context, '1'),
            ));
          }
        }

        // Agregar más opciones según roles si es necesario...
        // Manteniendo la lógica original pero visualmente mejorada
        if (usuario.roles?.first.id == '1') {
          items.add(PopupMenuDivider());
          items.add(PopupMenuItem(
            value: 8,
            child: _buildMenuItem(
                Icons.account_balance, 'Depósito Fortius', Colors.purple),
            onTap: () => bovedaSupController.goToRetiroFortius(usuario),
          ));
          items.add(PopupMenuItem(
            value: 9,
            child: _buildMenuItem(
                Icons.currency_exchange, 'Canje Fortius', Colors.deepPurple),
            onTap: () => bovedaSupController.goToCanjeFortius(usuario),
          ));
          items.add(PopupMenuItem(
            value: 5,
            child:
                _buildMenuItem(Icons.edit, 'Modificar Boveda', Colors.orange),
            onTap: () => bovedaSupController.goToModificarBoveda(boveda!),
          ));
          items.add(PopupMenuItem(
            value: 7,
            child: _buildMenuItem(
                Icons.local_atm, 'Informe de Bóveda', Colors.teal),
            onTap: () => bovedaSupController.goToInformeBoveda(boveda!, 1),
          ));
        } else if (usuario.roles?.first.id == '2' ||
            usuario.roles?.first.id == '6' ||
            usuario.roles?.first.id == '5') {
          items.add(PopupMenuDivider());
          // Opciones de Fortius solo para supervisores (rol 2)
          if (usuario.roles?.first.id == '2') {
            items.add(PopupMenuItem(
              value: 8,
              child: _buildMenuItem(
                  Icons.account_balance, 'Depósito Fortius', Colors.purple),
              onTap: () => bovedaSupController.goToRetiroFortius(usuario),
            ));
            items.add(PopupMenuItem(
              value: 9,
              child: _buildMenuItem(
                  Icons.currency_exchange, 'Canje Fortius', Colors.deepPurple),
              onTap: () => bovedaSupController.goToCanjeFortius(usuario),
            ));
          }
          items.add(PopupMenuItem(
            value: 6,
            child: _buildMenuItem(
                Icons.request_page, 'Recaudación por turno', Colors.indigo),
            onTap: () => bovedaSupController.goToReporteRecaudaciones(usuario),
          ));
          items.add(PopupMenuItem(
            value: 7,
            child: _buildMenuItem(
                Icons.local_atm, 'Informe de Bóveda', Colors.teal),
            onTap: () => usuario.roles?.first.id == '5'
                ? bovedaSupController.goToInformeBovedaActual(boveda!, 1)
                : bovedaSupController.goToInformeBoveda(boveda!, 1),
          ));
        }

        return items;
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 12),
        Text(text, style: TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  /// **Lista de denominaciones**
  Widget _denominacionesList(BuildContext context) {
    final boveda = bovedaSupController.boveda.value;

    if (boveda == null) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary),
        ),
      );
    }

    final numberFormat =
        NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 2);

    final denominaciones = [
      {
        "label": "\$20",
        "key": boveda.billete20,
        "factor": 20.0,
        "icon": 'assets/img/billete.png'
      },
      {
        "label": "\$10",
        "key": boveda.billete10,
        "factor": 10.0,
        "icon": 'assets/img/billete.png'
      },
      {
        "label": "\$5",
        "key": boveda.billete5,
        "factor": 5.0,
        "icon": 'assets/img/billete.png'
      },
      {
        "label": "\$1",
        "key": boveda.moneda1,
        "factor": 1.0,
        "icon": 'assets/img/moneda.png'
      },
      {
        "label": "50¢",
        "key": boveda.moneda05,
        "factor": 0.50,
        "icon": 'assets/img/moneda.png'
      },
      {
        "label": "25¢",
        "key": boveda.moneda025,
        "factor": 0.25,
        "icon": 'assets/img/moneda.png'
      },
      {
        "label": "10¢",
        "key": boveda.moneda01,
        "factor": 0.10,
        "icon": 'assets/img/moneda.png'
      },
      {
        "label": "5¢",
        "key": boveda.moneda005,
        "factor": 0.05,
        "icon": 'assets/img/moneda.png'
      },
      {
        "label": "1¢",
        "key": boveda.moneda001,
        "factor": 0.01,
        "icon": 'assets/img/moneda.png'
      },
    ];

    return ListView.builder(
      padding:
          EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 120.0),
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: denominaciones.length,
      itemBuilder: (context, index) {
        final item = denominaciones[index];
        final cantidad = int.tryParse(item['key'] as String? ?? "0") ?? 0;
        final valor = (cantidad * (item['factor'] as double));
        final valorFormatted = numberFormat.format(valor);

        return Container(
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
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: item['icon'] is String
                  ? Image.asset(
                      item['icon'] as String,
                      height: 24.0,
                      width: 24.0,
                    )
                  : Icon(Icons.attach_money, color: Colors.white),
            ),
            title: Text(
              item['label'] as String,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$$valorFormatted',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '$cantidad unidades',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
