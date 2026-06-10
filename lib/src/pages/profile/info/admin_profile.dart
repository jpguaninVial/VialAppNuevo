import 'package:asistencia_vial_app/src/pages/profile/info/admin_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/rol.dart';

class AdminProfile extends StatelessWidget {
  final AdminProfileController adminProfileController =
      Get.put(AdminProfileController());

  AdminProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => Stack(
            children: [
              _backgroundCover(context),
              _boxForm(context),
              _imageCover(context),
              _buttonSignOut(),
              _buttonBack(),
            ],
          )),
    );
  }

  Widget _backgroundCover(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 1,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _imageCover(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 25),
        alignment: Alignment.topCenter,
        child: CircleAvatar(
          backgroundImage: adminProfileController.usuario.value.imagen != null
              ? NetworkImage(adminProfileController.usuario.value.imagen!)
              : const AssetImage('assets/img/editar.png') as ImageProvider,
          radius: 60,
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  Widget _boxForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: MediaQuery.of(context).size.height * 1,
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.27),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -20),
            spreadRadius: -7,
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), // Radio superior izquierdo
          topRight: Radius.circular(20), // Radio superior derecho
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _textName(context),
            _textUsuario(context),
            _textphone(context),
            _textRol(context),
            _textPeaje(context),
          ],
        ),
      ),
    );
  }

  Widget _buttonBack() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 20),
        child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.white),
      ),
    );
  }

  Widget _bottomUpdate(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 10, // Controla la intensidad de la sombra
            shadowColor:
                Theme.of(context).colorScheme.shadow, // Color de la sombra
          ),
          onPressed: () => adminProfileController.gotoUpdate(),
          child: const Text(
            'ACTUALIZAR DATOS',
          )),
    );
  }

  Widget _textName(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ListTile(
          leading:
              Icon(Icons.perm_contact_cal_sharp, color: colorScheme.primary),
          title: Text(
              '${adminProfileController.usuario.value.nombre ?? ''} ${adminProfileController.usuario.value.apellido ?? ''}',
              style: TextStyle(color: colorScheme.onSurface)),
          subtitle: const Text('Nombres'),
        ));
  }

  Widget _textRol(BuildContext context) {
    Rol? rol = adminProfileController.usuario.value.roles?.isNotEmpty == true
        ? adminProfileController.usuario.value.roles!.first
        : null;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ListTile(
          leading: Icon(Icons.work, color: colorScheme.primary),
          title: Text('${rol?.nombre ?? ''}',
              style: TextStyle(color: colorScheme.onSurface)),
          subtitle: const Text('Rol'),
        ));
  }

  Widget _textUsuario(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ListTile(
          leading: Icon(Icons.person_outlined, color: colorScheme.primary),
          title: Text(
            '${adminProfileController.usuario.value.usuario ?? ''}',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: const Text('Usuario'),
        ));
  }

  Widget _textphone(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ListTile(
          leading: Icon(Icons.phone, color: colorScheme.primary),
          title: Text(
            '${adminProfileController.usuario.value.telefono ?? ''}',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: const Text('Telefono'),
        ));
  }

  Widget _textPeaje(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ListTile(
          leading: Icon(Icons.gps_fixed, color: colorScheme.primary),
          title: Text(
            '${adminProfileController.usuario.value.nombrePeaje ?? ''}',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: const Text('Peaje'),
        ));
  }

  Widget _buttonSignOut() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        alignment: Alignment.topRight,
        child: IconButton(
            onPressed: () => adminProfileController.signOut(),
            icon: const Icon(Icons.output_sharp),
            color: Colors.white),
      ),
    );
  }
}
