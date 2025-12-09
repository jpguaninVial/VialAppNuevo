import 'package:asistencia_vial_app/src/models/response_api.dart';
import 'package:asistencia_vial_app/src/models/rol.dart';
import 'package:asistencia_vial_app/src/provider/usuario_provider.dart';
import 'package:asistencia_vial_app/src/controllers/loading_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
            Get.snackbar(
                'Bienvenido/a ${usuario.nombre}', 'Inicio de sesion exitoso',
                backgroundColor: Colors.green, colorText: Colors.white);

            Get.offNamedUntil(rol?.ruta ?? '', (route) => false);
          } else {
            Get.snackbar('Error', 'Este usuario se encuentra inactivo');
          }
        } else {
          Get.snackbar('Login fallido', responseApi.message ?? '');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un error inesperado: ${e.toString()}');
    } finally {
      LoadingController.to.clearLoading(LOADING_KEY);
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
