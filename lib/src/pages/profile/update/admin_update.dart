import 'package:asistencia_vial_app/src/pages/profile/update/admin_update_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../models/peaje.dart';
import '../../../models/rol.dart';
import '../../../models/usuario.dart';

class AdminUpdate extends StatefulWidget {
  final Usuario? usuario;

  AdminUpdate({this.usuario});

  @override
  State<AdminUpdate> createState() => _AdminUpdateState();
}

class _AdminUpdateState extends State<AdminUpdate> {
  late AdminUpdateController adminUpdateController;
  final SignatureController signatureController = SignatureController();

  @override
  void initState() {
    super.initState();
    adminUpdateController = Get.put(AdminUpdateController(widget.usuario));
  }

  @override
  void dispose() {
    Get.delete<AdminUpdateController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Stack(
          children: [
            _backgroundCover(context),
            _boxForm(context),
            SingleChildScrollView(
              //scrolear para registrarse
              child: Column(
                children: [
                  _imageCover(context, widget.usuario),
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
                  Get.delete<AdminUpdateController>();
                  Get.back();
                },
              ),
            ),
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

  Widget _dropdownGrupo(BuildContext context, List<String> grupos) {
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
          value: adminUpdateController.grupoSeleccionado.value == ''
              ? null
              : adminUpdateController.grupoSeleccionado.value,
          onChanged: (option) {
            adminUpdateController.grupoSeleccionado.value = option.toString();
          },
        ));
  }

  Widget _dropDownRoles(BuildContext context, List<Rol> roles) {
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
          value: adminUpdateController.idRol.value == ''
              ? null
              : adminUpdateController.idRol.value,
          onChanged: (option) {
            adminUpdateController.idRol.value = option.toString();
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

  Widget _dropdownPeaje(BuildContext context, List<Peaje> peajes) {
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
          value: adminUpdateController.idPeaje.value == ''
              ? null
              : adminUpdateController.idPeaje.value,
          onChanged: (option) {
            adminUpdateController.idPeaje.value = option.toString();
          },
        ));
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

  Widget _imageCover(BuildContext context, Usuario? usuario) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 15),
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => adminUpdateController.showAlertDialog(context),
          child: GetBuilder<AdminUpdateController>(
            builder: (value) => CircleAvatar(
              backgroundImage: adminUpdateController.imageFile != null
                  ? FileImage(adminUpdateController.imageFile!)
                  : (usuario?.imagen != null && usuario!.imagen!.isNotEmpty)
                      ? NetworkImage(usuario.imagen!)
                      : AssetImage('assets/img/no-image.png') as ImageProvider,
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
            _textoUpdate(context),
            _textFieldNombre(context),
            _textFieldApellido(context),
            _textFieldTelefono(context),
            if (adminUpdateController.usuarioSession.roles?.first.id ==
                '1') ...[
              _dropDownRoles(context, adminUpdateController.roles),
              _dropdownGrupo(context, adminUpdateController.grupos),
              _dropdownPeaje(context, adminUpdateController.peajes),
            ] else ...[
              _dropdownGrupo(context, adminUpdateController.grupos),
            ],
            _signatureBox(context),
            _bottomUpdate(context),
          ],
        ),
      ),
    );
  }

  Widget _bottomUpdate(BuildContext context) {
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
          onPressed: () => adminUpdateController.actualizar(context),
          child: Text(
            'Actualizar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          )),
    );
  }

  Widget _textFieldNombre(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: TextField(
        controller: adminUpdateController.nombreController,
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

  Widget _textFieldApellido(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: TextField(
        controller: adminUpdateController.apellidoController,
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

  Widget _textFieldTelefono(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: TextField(
        controller: adminUpdateController.telefonoController,
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

  Widget _textoUpdate(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        'ACTUALIZACIÓN DE DATOS',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _signatureBox(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSignaturePad(context),
      child: GetBuilder<AdminUpdateController>(
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
                            adminUpdateController.saveSignature(signature);
                          }
                          Navigator.of(context).pop();
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
