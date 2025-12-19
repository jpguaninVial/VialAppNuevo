import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:asistencia_vial_app/src/models/response_api.dart';
import 'package:asistencia_vial_app/src/models/rol.dart';
import 'package:asistencia_vial_app/src/models/usuario.dart';
import 'package:asistencia_vial_app/src/provider/rol_provider.dart';
import 'package:asistencia_vial_app/src/provider/usuario_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../models/peaje.dart';
import '../../provider/peaje_provider.dart';

class RegisterController extends GetxController {
  Usuario usuarioSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});
  Uint8List? signature;

  TextEditingController usuarioController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController apellidoController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController conPasswordController = TextEditingController();

  UsuarioProvider usuarioProvider = UsuarioProvider();
  RolProvider rolProvider = RolProvider();
  PeajeProvider peajeProvider = PeajeProvider();

  ImagePicker picker = ImagePicker();
  File? imageFile;

  //TRAER LA LISTA DE ROLES Y PONERLOS EN EL DROPDOWN
  List<Rol> roles = <Rol>[].obs;

  var idRol = ''.obs;

  void getRoles() async {
    var result = await rolProvider.getAll();
    roles.clear();
    roles.addAll(result);
  }

  //TRAER LA LISTA DE GRUPOS Y PONERLOS EN EL DROPDOWN
  List<String> grupos = <String>[].obs;
  var grupoSeleccionado = ''.obs;
  void getGrupos() async {
    var result = await usuarioProvider.getGrupos();
    grupos.clear();
    grupos.addAll(result);
  }

  //TRAER LA LISTA DE ROLES Y PONERLOS EN EL DROPDOWN
  List<Peaje> peajes = <Peaje>[].obs;
  var idPeaje = ''.obs;

  void getPeajes() async {
    var result = await peajeProvider.getAll();
    peajes.clear();
    peajes.addAll(result);
  }

  //CARGA DE INFORAMCION AL CONSTRUCTOR
  RegisterController() {
    getRoles();
    getGrupos();
    getPeajes();
    update();
  }

  Future<void> register(BuildContext context) async {
    String usuario = usuarioController.text;
    String nombre = nombreController.text;
    String apellido = apellidoController.text;
    String telefono = telefonoController.text;
    String password = passwordController.text;
    String confpassword = conPasswordController.text;

    print('Usuario: $usuario');
    print('Constraseña: $password');
    print('IdRol: $idRol');
    print('IdPeaje: $idPeaje');

    if (usuarioSession.roles?.first.id == '1') {
      grupoSeleccionado.value = '1';
    } else {
      idRol.value = '3';
      idPeaje.value = usuarioSession.idPeaje ?? '';
    }

    if (isValidForm(
        usuario, nombre, apellido, telefono, password, confpassword)) {
      ProgressDialog progressDialog = ProgressDialog(context: context);
      progressDialog.show(max: 100, msg: 'Registrando datos..');
      print('Registro: validación OK, iniciando petición al servidor');
      try {
        Usuario usuarios = Usuario(
          usuario: usuario,
          nombre: nombre,
          apellido: apellido,
          telefono: telefono,
          password: password,
          //CAMBIE EL TIPO DE DATO Y QUITE LOS PARSE

          grupo: grupoSeleccionado.value,
          idRol: idRol.value,
          idPeaje: idPeaje.value,
        );

        if (imageFile == null && signature == null) {
          Response response = await usuarioProvider.create(usuarios);
          print(
              'Registro: respuesta sin imagen/firmas -> code: ${response.statusCode}, body: ${response.body}');
          progressDialog.close();
          if (response.statusCode == 201) {
            Fluttertoast.showToast(
              msg: 'Usuario registrado exitosamente',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.green.shade600,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            Get.offNamedUntil('/home', (route) => false,
                arguments: {'index': 3});
          } else {
            Fluttertoast.showToast(
              msg: response.body['message'] ?? 'Error al registrar usuario',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red.shade600,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else if (imageFile != null && signature == null) {
          Stream stream =
              await usuarioProvider.createWithImage(usuarios, imageFile!);
          progressDialog.close();

          stream.listen((res) {
            print('Registro: respuesta con imagen recibida: $res');
            ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));

            if (responseApi.success == true) {
              Fluttertoast.showToast(
                msg: 'Usuario registrado exitosamente',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.green.shade600,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              Get.offNamedUntil('/home', (route) => false,
                  arguments: {'index': 3});
            } else {
              Fluttertoast.showToast(
                msg: responseApi.message ?? 'Error al registrar usuario',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.red.shade600,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          }, onError: (error, stack) {
            print('Registro: error en stream imagen -> $error');
            print(stack);
            Fluttertoast.showToast(
              msg: 'Error al registrar (imagen): ${error.toString()}',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red.shade600,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          });
        } else if (imageFile == null && signature != null) {
          File signatureFile = await convertUint8ListToFile(signature!);
          print(
              'Registro: Usuario a enviar -> ${json.encode(usuarios.toJson())}');
          print(
              'Registro: Archivo firma -> path: ${signatureFile.path}, existe: ${await signatureFile.exists()}, tamaño: ${await signatureFile.length()}');
          Stream stream = await usuarioProvider.createWithSignature(
              usuarios, signatureFile);
          progressDialog.close();

          stream.listen((res) {
            print('Registro: respuesta con firma recibida: $res');
            ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));

            if (responseApi.success == true) {
              Fluttertoast.showToast(
                msg: 'Usuario registrado exitosamente',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.green.shade600,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              Get.offNamedUntil('/home', (route) => false,
                  arguments: {'index': 3});
            } else {
              Fluttertoast.showToast(
                msg: responseApi.message ?? 'Error al registrar usuario',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.red.shade600,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          }, onError: (error, stack) {
            print('Registro: error en stream firma -> $error');
            print(stack);
            Fluttertoast.showToast(
              msg: 'Error al registrar (firma): ${error.toString()}',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red.shade600,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          });
        } else {
          File signatureFile = await convertUint8ListToFile(signature!);
          print(
              'Registro: Usuario a enviar con firma+imagen -> ${json.encode(usuarios.toJson())}');
          print(
              'Registro: Archivo firma -> path: ${signatureFile.path}, tamaño: ${await signatureFile.length()}');
          print(
              'Registro: Archivo imagen -> path: ${imageFile!.path}, tamaño: ${await imageFile!.length()}');
          Stream stream = await usuarioProvider.createWithSignatureAndImage(
              usuarios, signatureFile, imageFile!);
          progressDialog.close();

          stream.listen((res) {
            print('Registro: respuesta con firma e imagen recibida: $res');
            ResponseApi responseApi = ResponseApi.fromJson(json.decode(res));

            if (responseApi.success == true) {
              Fluttertoast.showToast(
                msg: 'Usuario registrado exitosamente',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.green.shade600,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              Get.offNamedUntil('/home', (route) => false,
                  arguments: {'index': 3});
            } else {
              Fluttertoast.showToast(
                msg: responseApi.message ?? 'Error al registrar usuario',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.red.shade600,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          }, onError: (error, stack) {
            print('Registro: error en stream firma+imagen -> $error');
            print(stack);
            Fluttertoast.showToast(
              msg: 'Error al registrar (firma+imagen): ${error.toString()}',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red.shade600,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          });
        }
      } catch (e, s) {
        print('Registro: excepción capturada en controlador -> $e');
        print(s);
        Fluttertoast.showToast(
          msg: 'Error al registrar: ${e.toString()}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red.shade600,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        rethrow; // permite que la UI también capture y loguee
      }
    }
  }

  bool isValidForm(String usuario, String nombre, String apellido,
      String telefono, String password, String confpassword) {
    if (idRol.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Debe seleccionar un rol',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.orange.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }

    if (idPeaje.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Debe seleccionar un peaje',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.orange.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }

    if (usuario.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Debe ingresar el usuario',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.orange.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
    if (nombre.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Debe ingresar el nombre',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.orange.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
    if (apellido.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Debe ingresar el apellido',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.orange.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }
    if (telefono.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Debe ingresar el teléfono',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.orange.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }

    if (password.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Debe ingresar la contraseña',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.orange.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }

    if (confpassword.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Debe confirmar la contraseña',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.orange.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }

    if (confpassword != password) {
      Fluttertoast.showToast(
        msg: 'Las contraseñas no coinciden',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }

    if (idRol.value == '') {
      Fluttertoast.showToast(
        msg: 'Debe seleccionar un rol',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.orange.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }

    if (idPeaje.value == '') {
      Fluttertoast.showToast(
        msg: 'Debe seleccionar un peaje',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.orange.shade600,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }

    return true;
  }

  void clearField() {
    usuarioController.clear();
    nombreController.clear();
    apellidoController.clear();
    telefonoController.clear();
    passwordController.clear();
    conPasswordController.clear();
  }

  Future selectImage(ImageSource imageSource) async {
    XFile? image = await picker.pickImage(source: imageSource);
    if (image != null) {
      imageFile = File(image.path);
      update();
    }
  }

  void showAlertDialog(BuildContext context) {
    // Personalización del botón de la galería
    Widget galleryButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        shadowColor: Theme.of(context).colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        Get.back();
        selectImage(ImageSource.gallery);
      },
      child: Text('GALERÍA', style: TextStyle(fontWeight: FontWeight.bold)),
    );

    Widget cameraButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        shadowColor: Theme.of(context).colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        Get.back();
        selectImage(ImageSource.camera);
      },
      child: Text('CÁMARA', style: TextStyle(fontWeight: FontWeight.bold)),
    );

    // Creación del AlertDialog con Material You
    AlertDialog alertDialog = AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'Seleccione una opción',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      actions: [
        galleryButton,
        cameraButton,
      ],
    );

    // Mostrar el cuadro de diálogo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      },
    );
  }

  void saveSignature(Uint8List newSignature) {
    signature = newSignature;
    update(); // Actualiza la interfaz si es necesario
  }

  Future<File> convertUint8ListToFile(Uint8List signature) async {
    try {
      print('Registro: convirtiendo firma, tamaño: ${signature.length} bytes');
      final tempDir = await getTemporaryDirectory();
      print('Registro: directorio temporal: ${tempDir.path}');
      final tempFile = File(
          '${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(signature);
      print(
          'Registro: firma guardada en: ${tempFile.path}, existe: ${await tempFile.exists()}, tamaño: ${await tempFile.length()} bytes');
      return tempFile;
    } catch (e, s) {
      print('Registro: ERROR al convertir firma -> $e');
      print(s);
      rethrow;
    }
  }
}
