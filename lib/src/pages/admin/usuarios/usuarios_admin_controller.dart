import 'package:asistencia_vial_app/src/provider/rol_provider.dart';
import 'package:asistencia_vial_app/src/provider/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../models/rol.dart';
import '../../../models/usuario.dart';
import '../../detalle/detalle_usuario.dart';
import '../../profile/update/admin_update.dart';

class UsuariosAdminController extends GetxController {
  Usuario usuario = Usuario.fromJson(GetStorage().read('usuario') ?? {});

  UsuarioProvider usuarioProvider = UsuarioProvider();

  RolProvider rolProvider = RolProvider();
  List<Rol> roles = <Rol>[].obs;

  UsuariosAdminController() {
    getRoles();
  }

  Future<List<Usuario>> getUsuarios(String idRol) async {
    return await usuarioProvider.findByRol(idRol);
  }

  void getRoles() async {
    var result = await rolProvider.getAll();
    roles.clear();
    roles.addAll(result);
    update();
  }

  void openBottomSheet(BuildContext context, Usuario usuario) {
    showBarModalBottomSheet(
        context: context,
        builder: (context) => DetalleUsuario(usuario: usuario));
  }

  void goToActualizar(Usuario usuario) {
    Get.to(
      () => AdminUpdate(usuario: usuario), // Página a la que navegas
      arguments: usuario, // Envía el objeto Usuario como argumento
    );
  }

  Future<void> deleteUsuario(String idUsuario) async {
    try {
      print('Eliminando usuario: $idUsuario');
      var response = await usuarioProvider.eliminar(idUsuario);
      print(
          'Respuesta eliminación: ${response.statusCode}, body: ${response.body}');
      if (response.isOk) {
        Fluttertoast.showToast(
          msg: 'Usuario eliminado exitosamente',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green.shade600,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        getRoles();
      } else {
        Fluttertoast.showToast(
          msg:
              'Error al eliminar usuario: ${response.body['message'] ?? 'Error desconocido'}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red.shade600,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e, s) {
      print('Error al eliminar usuario: $e');
      print(s);
      Fluttertoast.showToast(
        msg: 'Error al eliminar usuario: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void gotoRegisterPage() {
    Get.toNamed('/register');
  }
}
