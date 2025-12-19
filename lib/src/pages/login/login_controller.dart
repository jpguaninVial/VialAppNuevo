import 'package:asistencia_vial_app/src/models/response_api.dart';
import 'package:asistencia_vial_app/src/models/rol.dart';
import 'package:asistencia_vial_app/src/provider/usuario_provider.dart';
import 'package:asistencia_vial_app/src/controllers/loading_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../models/usuario.dart';

class LoginController extends GetxController {
  static const String LOADING_KEY = 'login_process';

  TextEditingController usuarioController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  UsuarioProvider usuarioProvider = UsuarioProvider();

  void gotoRegisterPage() {
    Get.toNamed('/register');
  }

  void gotoTrackerPage() {
    Get.offNamedUntil('/admin/home', (route) => false);
  }

  void login() async {
    String usuario = usuarioController.text.trim();
    String password = passwordController.text;

    if (LoadingController.to.isLoading(LOADING_KEY)) {
      return;
    }

    try {
      if (isValidForm(usuario, password)) {
        LoadingController.to.setLoading(LOADING_KEY);
        ResponseApi responseApi =
            await usuarioProvider.login(usuario, password);
        print(responseApi.data);
        if (responseApi.success == true) {
          Usuario user = Usuario.fromJson(responseApi.data);
          if (user.estado == '1') {
            GetStorage().write('usuario',
                responseApi.data); //ALMACENANDO LOS DATOS DEL USUARIO EN SESION
            Usuario usuario =
                Usuario.fromJson(GetStorage().read('usuario') ?? {});

            Rol? rol =
                usuario.roles?.isNotEmpty == true ? usuario.roles!.first : null;

            // Mensaje personalizado según la hora del día
            String saludo = _obtenerSaludo();
            String mensajeBienvenida = '$saludo ${usuario.nombre}';

            Fluttertoast.showToast(
              msg: mensajeBienvenida,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.green.shade600,
              textColor: Colors.white,
              fontSize: 16.0,
            );

            Get.offNamedUntil(rol?.ruta ?? '', (route) => false);
          } else {
            Fluttertoast.showToast(
              msg:
                  'Este usuario se encuentra desactivado. Contacta con el administrador.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.orange.shade600,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: responseApi.message ?? 'Usuario o contraseña incorrectos',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red.shade600,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Ocurrió un error inesperado: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      LoadingController.to.clearLoading(LOADING_KEY);
    }
  }

  String _obtenerSaludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) {
      return '¡Buenos días!';
    } else if (hora < 18) {
      return '¡Buenas tardes!';
    } else {
      return '¡Buenas noches!';
    }
  }

  bool isValidForm(String usuario, String password) {
    if (usuario.isEmpty) {
      Get.snackbar('Error', 'Debe ingresar el usuario');
      return false;
    }
    if (password.isEmpty) {
      Get.snackbar('Error', 'Debe ingresar la contraseña');
      return false;
    }

    return true;
  }

  void goToPageRol(Rol rol) {
    Get.offNamedUntil(rol.ruta ?? '', (route) => false);
  }
}
