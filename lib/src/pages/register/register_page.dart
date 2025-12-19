import 'package:asistencia_vial_app/src/pages/register/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/list_notifier.dart';
import 'package:signature/signature.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../models/peaje.dart';
import '../../models/rol.dart';
import '../../provider/rol_provider.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterController registerController = Get.put(RegisterController());
  RolProvider rolProvider = RolProvider();
  final SignatureController signatureController = SignatureController();

  @override
  void dispose() {
    Get.delete<RegisterController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => Stack(
            children: [
              _backgroundCover(context),
              _boxForm(context),
              SingleChildScrollView(
                //scrolear para registrarse
                child: Column(
                  children: [
                    _imageCover(context),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: () {
                    Get.delete<RegisterController>();
                    Get.back();
                  },
                ),
              ),
            ],
          )),
    );
  }

  Widget _backgroundCover(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 1,
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
    );
  }

  Widget _imageCover(context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 15),
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => registerController.showAlertDialog(context),
          child: GetBuilder<RegisterController>(
            builder: (value) => CircleAvatar(
              backgroundImage: registerController.imageFile != null
                  ? FileImage(registerController.imageFile!)
                  : AssetImage('assets/img/editar.png'),
              radius: 50,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _boxForm(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 1,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.15),
              blurRadius: 15,
              offset: Offset(0, 0.75))
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _textoLogin(),
            _textFieldUsuario(),
            _textFieldNombre(),
            _textFieldApellido(),
            _textFieldTelefono(),
            _textFieldPassword(),
            _textFieldConfPassword(),
            if (registerController.usuarioSession.roles?.first.id == '1') ...[
              _dropDownRoles(registerController.roles),
              _dropdownPeaje(registerController.peajes),
            ] else ...[
              _dropdownGrupo(registerController.grupos),
            ],
            _signatureBox(context),
            _bottomLogin(context),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropDowItemsRoles(List<Rol> roles) {
    List<DropdownMenuItem<String>> list = [];
    roles.forEach((rol) {
      list.add(DropdownMenuItem(
        child: Text(rol.nombre ?? ''),
        value: rol.id,
      ));
    });
    return list;
  }

  Widget _dropDownRoles(List<Rol> roles) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 65, vertical: 5),
        child: DropdownButton(
          underline: Container(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          elevation: 3,
          isExpanded: true,
          hint: Text(
            'Seleccione el rol',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
          ),
          items: _dropDowItemsRoles(roles),
          value: registerController.idRol.value == ''
              ? null
              : registerController.idRol.value,
          onChanged: (option) {
            registerController.idRol.value = option.toString();
          },
        ));
  }

  List<DropdownMenuItem<String>> _dropDownItemsPeaje(List<Peaje> peajes) {
    List<DropdownMenuItem<String>> list = [];
    peajes.forEach((peaje) {
      list.add(DropdownMenuItem(
        child: Text(peaje.nombre ?? ''),
        value: peaje.id,
      ));
    });
    return list;
  }

  Widget _dropdownPeaje(List<Peaje> peajes) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 65, vertical: 5),
        child: DropdownButton(
          underline: Container(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          elevation: 3,
          isExpanded: true,
          hint: Text(
            'Seleccione el peaje',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
          ),
          items: _dropDownItemsPeaje(peajes),
          value: registerController.idPeaje.value == ''
              ? null
              : registerController.idPeaje.value,
          onChanged: (option) {
            registerController.idPeaje.value = option.toString();
          },
        ));
  }

  Widget _bottomLogin(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(vertical: 15),
            elevation: 3,
            shadowColor: Theme.of(context).colorScheme.shadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            try {
              print('Registro: iniciando solicitud');
              Fluttertoast.showToast(
                msg: 'Enviando solicitud de registro...',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 2,
                backgroundColor: Theme.of(context).colorScheme.primary,
                textColor: Colors.white,
                fontSize: 14.0,
              );
              await registerController.register(context);
              print('Registro: finalizado (ver toasts para resultado)');
            } catch (e, s) {
              print('Registro: error -> $e');
              print(s);
              Fluttertoast.showToast(
                msg: 'Error al registrar: ${e.toString()}',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.red.shade600,
                textColor: Colors.white,
                fontSize: 14.0,
              );
            }
          },
          child: Text(
            'Registrar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          )),
    );
  }

  Widget _textFieldUsuario() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: TextField(
        controller: registerController.usuarioController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            hintText: 'Usuario',
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            prefixIcon: Icon(Icons.account_circle,
                color: Theme.of(context).colorScheme.primary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2),
            )),
      ),
    );
  }

  Widget _textFieldNombre() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: TextField(
        controller: registerController.nombreController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            hintText: 'Nombre',
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            prefixIcon: Icon(Icons.supervised_user_circle,
                color: Theme.of(context).colorScheme.primary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2),
            )),
      ),
    );
  }

  Widget _textFieldApellido() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: TextField(
        controller: registerController.apellidoController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            hintText: 'Apellido',
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            prefixIcon: Icon(Icons.supervised_user_circle_outlined,
                color: Theme.of(context).colorScheme.primary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2),
            )),
      ),
    );
  }

  Widget _textFieldTelefono() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: TextField(
        controller: registerController.telefonoController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
            hintText: 'Teléfono',
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            prefixIcon:
                Icon(Icons.call, color: Theme.of(context).colorScheme.primary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2),
            )),
      ),
    );
  }

  Widget _textFieldPassword() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: TextField(
        controller: registerController.passwordController,
        keyboardType: TextInputType.text,
        obscureText: true,
        decoration: InputDecoration(
            hintText: 'Contraseña',
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            prefixIcon:
                Icon(Icons.lock, color: Theme.of(context).colorScheme.primary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2),
            )),
      ),
    );
  }

  Widget _textFieldConfPassword() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: TextField(
        controller: registerController.conPasswordController,
        keyboardType: TextInputType.text,
        obscureText: true,
        decoration: InputDecoration(
            hintText: 'Confirmar Contraseña',
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            prefixIcon:
                Icon(Icons.lock, color: Theme.of(context).colorScheme.primary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2),
            )),
      ),
    );
  }

  Widget _textoLogin() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        'REGISTRO DE USUARIOS',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _dropDowItemsGrupos(List<String> grupos) {
    List<DropdownMenuItem<String>> list = [];
    grupos.forEach((grupo) {
      list.add(DropdownMenuItem(
        child: Text('Grupo: $grupo' ?? ''),
        value: grupo,
      ));
    });
    return list;
  }

  Widget _dropdownGrupo(List<String> grupos) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 65, vertical: 5),
        child: DropdownButton(
          underline: Container(
            alignment: Alignment.centerRight,
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          elevation: 3,
          isExpanded: true,
          hint: Text(
            'Seleccione el grupo',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
          ),
          items: _dropDowItemsGrupos(grupos),
          value: registerController.grupoSeleccionado.value == ''
              ? null
              : registerController.grupoSeleccionado.value,
          onChanged: (option) {
            registerController.grupoSeleccionado.value = option.toString();
          },
        ));
  }

  Widget _signatureBox(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSignaturePad(context),
      child: GetBuilder<RegisterController>(
        builder: (controller) => Container(
          margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.3),
          ),
          child: Column(
            children: [
              controller.signature == null
                  ? Column(
                      children: [
                        Icon(Icons.edit,
                            size: 30,
                            color: Theme.of(context).colorScheme.primary),
                        SizedBox(height: 5),
                        Text(
                          'Capturar Firma',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6)),
                        ),
                      ],
                    )
                  : Image.memory(
                      controller.signature!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSignaturePad(BuildContext context) {
    final signatureController = SignatureController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text("Captura tu Firma",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Signature(
                  controller: signatureController,
                  height: 150,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => signatureController.clear(),
                      child: Text("Borrar"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (signatureController.isNotEmpty) {
                          final signature =
                              await signatureController.toPngBytes();
                          if (signature != null) {
                            registerController.saveSignature(signature);
                          }
                          Navigator.of(context).pop(); // Cierra el diálogo
                        } else {
                          Fluttertoast.showToast(
                            msg: 'La firma está vacía',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            timeInSecForIosWeb: 2,
                            backgroundColor: Colors.red.shade600,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                      },
                      child: Text("Guardar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
