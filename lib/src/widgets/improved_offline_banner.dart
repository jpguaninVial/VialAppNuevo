import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/improved_connection_controller.dart';
import '../services/sync_service.dart';

class ImprovedOfflineBanner extends StatelessWidget {
  const ImprovedOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final connectionController = ImprovedConnectionController.to;
      final syncService = SyncService.to;
      
      final isOffline = connectionController.isOffline.value;
      final isSyncing = syncService.isSyncing.value;
      final pendingCount = syncService.pendingTransactions.value;
      
      if (!isOffline && pendingCount == 0 && !isSyncing) {
        return const SizedBox.shrink();
      }

      Color backgroundColor;
      IconData icon;
      String title;
      String subtitle;

      if (isSyncing) {
        backgroundColor = Colors.blue[800]!;
        icon = Icons.sync;
        title = 'Sincronizando...';
        subtitle = 'Enviando transacciones al servidor';
      } else if (isOffline) {
        backgroundColor = Colors.orange[800]!;
        icon = Icons.wifi_off;
        title = 'Modo Offline';
        subtitle = pendingCount > 0 
            ? '$pendingCount transacciones pendientes'
            : 'Sin conexión al servidor';
      } else if (pendingCount > 0) {
        backgroundColor = Colors.amber[800]!;
        icon = Icons.cloud_queue;
        title = 'Sincronización Pendiente';
        subtitle = '$pendingCount transacciones por enviar';
      } else {
        return const SizedBox.shrink();
      }

      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: double.infinity,
        color: backgroundColor,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: isSyncing 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          icon,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (pendingCount > 0 && !isSyncing)
                  GestureDetector(
                    onTap: () => _showSyncOptions(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Opciones',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showSyncOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.sync_alt, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Opciones de Sincronización',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Información actual
            Obx(() {
              final pendingCount = SyncService.to.pendingTransactions.value;
              final lastSync = SyncService.to.lastSyncTime.value;
              final isOffline = ImprovedConnectionController.to.isOffline.value;
              
              return Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estado Actual:', style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    Text('• Transacciones pendientes: $pendingCount'),
                    Text('• Estado: ${isOffline ? "Offline" : "Online"}'),
                    Text('• Última sincronización: ${_formatTime(lastSync)}'),
                  ],
                ),
              );
            }),
            
            SizedBox(height: 20),
            
            // Botón de sincronización manual
            ElevatedButton.icon(
              onPressed: () async {
                Get.back();
                Get.snackbar(
                  'Sincronización Manual',
                  'Iniciando sincronización...',
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
                
                final result = await SyncService.to.forceManuaSync();
                
                if (result.success) {
                  Get.snackbar(
                    'Sincronización Exitosa',
                    '${result.successCount} transacciones enviadas',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } else {
                  Get.snackbar(
                    'Error de Sincronización',
                    result.error ?? 'Error desconocido',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              icon: Icon(Icons.refresh),
              label: Text('Sincronizar Ahora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            
            SizedBox(height: 10),
            
            // Botón para limpiar transacciones (con confirmación)
            OutlinedButton.icon(
              onPressed: () => _showClearConfirmation(context),
              icon: Icon(Icons.delete_outline, color: Colors.red),
              label: Text('Limpiar Transacciones Offline'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
              ),
            ),
            
            SizedBox(height: 10),
            
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    Get.back(); // Cerrar el bottom sheet anterior
    
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirmar Eliminación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Está seguro de que desea eliminar todas las transacciones offline?'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Esta acción es irreversible. Las transacciones no enviadas se perderán.',
                      style: TextStyle(color: Colors.red[800], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              SyncService.to.clearAllOfflineData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar Todo'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Hace unos segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
