import 'package:asistencia_vial_app/src/pages/admin/Usuarios/usuarios_admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../models/rol.dart';
import '../../../models/usuario.dart';

class UsuariosAdmin extends StatelessWidget {
  UsuariosAdminController usuariosAdminController =
      Get.put(UsuariosAdminController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => DefaultTabController(
          length: usuariosAdminController.roles.length,
          child: Scaffold(
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerLowest,
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
                                'Usuarios',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    usuariosAdminController.gotoRegisterPage(),
                                icon: Icon(Icons.person_add,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    size: 28),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TabBar(
                        tabAlignment: TabAlignment.center,
                        isScrollable: true,
                        indicatorColor: Theme.of(context).colorScheme.onPrimary,
                        labelColor: Theme.of(context).colorScheme.onPrimary,
                        unselectedLabelColor: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.7),
                        tabs: List<Widget>.generate(
                            usuariosAdminController.roles.length, (index) {
                          return Tab(
                            child: Text(
                                usuariosAdminController.roles[index].nombre ??
                                    ' '),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: usuariosAdminController.roles.map<Widget>((Rol rol) {
                return FutureBuilder(
                    future: usuariosAdminController.getUsuarios(rol.id ?? '1'),
                    builder: (context, AsyncSnapshot<List<Usuario>> snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data?.length ?? 0,
                            itemBuilder: (_, index) {
                              return _cardUsuario(
                                  context,
                                  snapshot.data![index],
                                  int.parse(rol.id ?? '1'));
                            });
                      } else {
                        return Container();
                      }
                    });
              }).toList(),
            ),
          ),
        ));
  }

  Widget _cardUsuario(BuildContext context, Usuario usuario, int cardIndex) {
    return GestureDetector(
      onTap: () => usuariosAdminController.openBottomSheet(context, usuario),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
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
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    width: 1),
                gradient: usuario.imagen == null || usuario.imagen == ''
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.15),
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
              ),
            ),
            title: Text(
              '${usuario.nombre} ${usuario.apellido}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              usuario.telefono ?? 'Sin teléfono',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.primary,
                size: 24.0,
              ),
              itemBuilder: (BuildContext context) {
                return _getOptionsForCard(context, usuario, cardIndex);
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Método para obtener las opciones según el índice de la tarjeta
  List<PopupMenuEntry<String>> _getOptionsForCard(
      BuildContext context, Usuario usuario, int cardIndex) {
    switch (cardIndex) {
      case 1:
        return [
          PopupMenuItem<String>(
              value: "Actualizar",
              child: Row(
                children: [
                  Icon(Icons.update,
                      color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 10),
                  Text("Actualizar"),
                ],
              ),
              onTap: () => usuariosAdminController.goToActualizar(usuario)),
          PopupMenuItem<String>(
            value: "Eliminar",
            child: Row(
              children: [
                Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error),
                SizedBox(width: 10),
                Text("Eliminar"),
              ],
            ),
            onTap: () {
              // Mostrar el cuadro de diálogo de confirmación
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showDeleteConfirmationDialog(context, usuario);
              });
            },
          ),
        ];
      case 2:
        return [
          PopupMenuItem<String>(
              value: "Actualizar",
              child: Row(
                children: [
                  Icon(Icons.update,
                      color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 10),
                  Text("Actualizar"),
                ],
              ),
              onTap: () => usuariosAdminController.goToActualizar(usuario)),
          PopupMenuItem<String>(
            value: "Eliminar",
            child: Row(
              children: [
                Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error),
                SizedBox(width: 10),
                Text("Eliminar"),
              ],
            ),
            onTap: () {
              // Mostrar el cuadro de diálogo de confirmación
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showDeleteConfirmationDialog(context, usuario);
              });
            },
          ),
        ];
      case 3:
        return [
          PopupMenuItem<String>(
              value: "Actualizar",
              child: Row(
                children: [
                  Icon(Icons.update,
                      color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 10),
                  Text("Actualizar"),
                ],
              ),
              onTap: () => usuariosAdminController.goToActualizar(usuario)),
          PopupMenuItem<String>(
            value: "Eliminar",
            child: Row(
              children: [
                Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error),
                SizedBox(width: 10),
                Text("Eliminar"),
              ],
            ),
            onTap: () {
              // Mostrar el cuadro de diálogo de confirmación
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showDeleteConfirmationDialog(context, usuario);
              });
            },
          ),
        ];
      default:
        return [
          PopupMenuItem<String>(
              value: "Actualizar",
              child: Row(
                children: [
                  Icon(Icons.update,
                      color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 10),
                  Text("Actualizar"),
                ],
              ),
              onTap: () => usuariosAdminController.goToActualizar(usuario)),
          PopupMenuItem<String>(
            value: "Eliminar",
            child: Row(
              children: [
                Icon(Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error),
                SizedBox(width: 10),
                Text("Eliminar"),
              ],
            ),
            onTap: () {
              // Mostrar el cuadro de diálogo de confirmación
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showDeleteConfirmationDialog(context, usuario);
              });
            },
          ),
        ];
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Usuario usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error, size: 28),
              SizedBox(width: 12),
              Text(
                'Confirmar eliminación',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar al usuario ${usuario.nombre} ${usuario.apellido}?',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                usuariosAdminController.deleteUsuario(usuario.id ?? '1');
              },
              child: Text(
                'Eliminar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
