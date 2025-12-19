import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'connection_controller.dart';
import '../controllers/improved_connection_controller.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<ConnectionController>();
      final isOffline = controller.isOffline.value;

      // Verificar si está en verificación inicial
      try {
        final improvedController = Get.find<ImprovedConnectionController>();
        if (improvedController.isCheckingConnection.value &&
            improvedController.lastConnectionCheck.value
                    .difference(DateTime.now())
                    .inSeconds
                    .abs() <
                3) {
          return const SizedBox.shrink();
        }
      } catch (e) {
        // Si ImprovedConnectionController no está disponible, continuar normalmente
      }

      if (!isOffline) return const SizedBox.shrink(); // Oculta si hay internet

      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.only(top: 10, left: 10, right: 20, bottom: 10),
        color: Colors.redAccent,
        alignment: Alignment.center,
        child: const Text(
          'Modo Offline',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      );
    });
  }
}
