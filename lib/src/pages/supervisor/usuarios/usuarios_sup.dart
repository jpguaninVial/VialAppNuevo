import 'package:asistencia_vial_app/src/pages/supervisor/usuarios/usuarios_sup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../helper/connection_controller.dart';
import '../../../helper/offline_banner.dart';
import '../../../models/usuario.dart';

class UsuariosSup extends StatelessWidget {
  UsuariosSupController usuariosSupController =
      Get.put(UsuariosSupController());
  List<String> groupLabels = ['A', 'B', 'C', 'D', 'E'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(170),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.9),
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 16, left: 24, right: 24, bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Cajeros',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => usuariosSupController
                                        .gotoRegisterPage(),
                                    icon: Icon(Icons.person_add,
                                        color: Colors.white, size: 28),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      int groupIndex = usuariosSupController
                                          .currentTabIndex.value;
                                      await usuariosSupController
                                          .loadUsuariosGrupoActual(
                                              groupIndex,
                                              usuariosSupController
                                                      .usuarioSession.idPeaje ??
                                                  '1');
                                      _showAssignDialog(groupIndex);
                                    },
                                    icon: Icon(Icons.fact_check,
                                        color: Colors.white, size: 28),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      TabBar(
                        tabAlignment: TabAlignment.center,
                        isScrollable: true,
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        onTap: (index) {
                          usuariosSupController.updateTabIndex(index);
                        },
                        tabs: List<Widget>.generate(5, (index) {
                          return Tab(
                            child: Text('Grupo ${groupLabels[index]}'),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: List<Widget>.generate(5, (index2) {
                return FutureBuilder(
                  future: usuariosSupController.getUsuariosGrupo(
                      (index2 + 1).toString(),
                      usuariosSupController.usuarioSession.idPeaje ??
                          '1'), // Cambia para manejar los grupos
                  builder: (context, AsyncSnapshot<List<Usuario>> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data?.length ?? 0,
                        itemBuilder: (_, index) {
                          return _cardUsuario(context, snapshot.data![index]);
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              }),
            ),
          ),
          // ✅ Aquí va la barra flotante "Offline"
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Obx(() {
              if (Get.find<ConnectionController>().isOffline.value) {
                return const OfflineBanner();
              } else {
                return const SizedBox.shrink(); // Oculta si hay conexión
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _cardUsuario(BuildContext context, Usuario usuario) {
    return GestureDetector(
      onTap: () => usuariosSupController.openBottomSheet(context, usuario),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Color(0xFF368983).withOpacity(0.2), width: 1),
                gradient: usuario.imagen == null || usuario.imagen == ''
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF368983).withOpacity(0.15),
                          Color(0xFF2C6E69).withOpacity(0.15),
                        ],
                      )
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: usuario.imagen != null && usuario.imagen != ''
                    ? FadeInImage(
                        image: NetworkImage(usuario.imagen!),
                        fit: BoxFit.cover,
                        fadeOutDuration: Duration(milliseconds: 50),
                        placeholder: AssetImage('assets/img/no-image.png'),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.person,
                              size: 32,
                              color: Color(0xFF368983),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: Color(0xFF368983),
                        ),
                      ),
              ),
            ),
            title: Text(
              '${usuario.nombre} ${usuario.apellido}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              usuario.telefono ?? 'Sin teléfono',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Color(0xFF368983),
                size: 24.0,
              ),
              itemBuilder: (BuildContext context) =>
                  _getPopupMenuItems(context, usuario),
            ),
          ),
        ),
      ),
    );
  }

  void _showAssignDialog(int groupIndex) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.assignment, color: Color(0xFF368983), size: 28),
              SizedBox(width: 12),
              Text(
                'Asignar Turno',
                style: TextStyle(
                  color: Color(0xFF368983),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            '¿Deseas asignar todo el Grupo ${groupIndex}?',
            style: TextStyle(color: Colors.black87, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                usuariosSupController.asignarTurnoLote(context);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF368983),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Asignar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _getPopupMenuItems(
      BuildContext context, Usuario usuario) {
    return [
      PopupMenuItem<String>(
          child: Row(
            children: [
              Icon(Icons.work_history, color: Colors.green),
              SizedBox(width: 10),
              Text("Asignar Turno"),
            ],
          ),
          onTap: () => usuariosSupController.asignarTuno(context, usuario)),
      PopupMenuItem<String>(
          child: Row(
            children: [
              Icon(Icons.update, color: Colors.blue),
              SizedBox(width: 10),
              Text("Actualizar Perfil"),
            ],
          ),
          onTap: () => usuariosSupController.goToActualizar(usuario)),
    ];
  }
}
