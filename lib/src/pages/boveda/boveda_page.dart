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
      backgroundColor: Colors.grey[100], // Fondo más claro y moderno
      body: RefreshIndicator(
        onRefresh: _pullToRefresh,
        color: Color(0xFF368983),
        child: Column(
          children: [
            Obx(() => _headerSection(context)), // Encabezado dinámico
            Expanded(
              child: Obx(() => _denominacionesList(context)), // Lista dinámica
            ),
          ],
        ),
      ),
      // Banner flotante
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: Obx(() {
        if (Get.find<ConnectionController>().isOffline.value) {
          return const OfflineBanner();
        } else {
          return const SizedBox.shrink();
        }
      }),
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
          EdgeInsets.only(left: 24.0, top: 60.0, right: 24.0, bottom: 30.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF368983),
            Color(0xFF2C6E69), // Un tono un poco más oscuro para profundidad
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundImage: usuario.imagen != null
                          ? NetworkImage(usuario.imagen!)
                          : AssetImage('assets/img/no-image.png')
                              as ImageProvider,
                      radius: 22,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola,',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        usuario.nombre != null
                            ? '${usuario.nombre} ${usuario.apellido}'
                            : 'Usuario',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildActionMenu(context, boveda),
            ],
          ),
          SizedBox(height: 30),
          Text(
            "Total en Bóveda",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalBovedaFormatted,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.account_balance_wallet, color: Colors.white),
              )
            ],
          ),
        ],
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
          items.add(PopupMenuItem(
            value: 5,
            child:
                _buildMenuItem(Icons.edit, 'Modificar Boveda', Colors.orange),
            onTap: () => bovedaSupController.goToModificarBoveda(boveda!),
          ));
        } else if (usuario.roles?.first.id == '2' ||
            usuario.roles?.first.id == '6' ||
            usuario.roles?.first.id == '5') {
          items.add(PopupMenuDivider());
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
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF368983)),
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
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF368983).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: item['icon'] is String
                  ? Image.asset(
                      item['icon'] as String,
                      height: 24.0,
                      width: 24.0,
                    )
                  : Icon(Icons.attach_money, color: Color(0xFF368983)),
            ),
            title: Text(
              item['label'] as String,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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
                    color: Color(0xFF368983),
                  ),
                ),
                Text(
                  '$cantidad unidades',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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
