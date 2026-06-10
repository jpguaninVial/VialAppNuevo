import 'package:asistencia_vial_app/src/helper/connection_controller.dart';
import 'package:asistencia_vial_app/src/controllers/improved_connection_controller.dart';
import 'package:asistencia_vial_app/src/controllers/loading_controller.dart';
import 'package:asistencia_vial_app/src/services/sync_service.dart';
import 'package:asistencia_vial_app/src/models/boveda.dart';
import 'package:asistencia_vial_app/src/models/estado.dart';
import 'package:asistencia_vial_app/src/models/movimiento.dart';
import 'package:asistencia_vial_app/src/models/rol.dart';
import 'package:asistencia_vial_app/src/models/turno.dart';
import 'package:asistencia_vial_app/src/models/usuario.dart';
import 'package:asistencia_vial_app/src/pages/admin/Usuarios/usuarios_admin.dart';
import 'package:asistencia_vial_app/src/pages/admin/estadisticas/estadisticas_page.dart';
import 'package:asistencia_vial_app/src/pages/detalle_transaccion/detalle_transaccion.dart';
import 'package:asistencia_vial_app/src/pages/profile/info/admin_profile.dart';
import 'package:asistencia_vial_app/src/pages/profile/update/admin_update.dart';
import 'package:asistencia_vial_app/src/pages/login/login_page.dart';
import 'package:asistencia_vial_app/src/pages/register/register_page.dart';
import 'package:asistencia_vial_app/src/pages/Home/home_page.dart';
import 'package:asistencia_vial_app/src/pages/supervisor/apertura/apertura.dart';
import 'package:asistencia_vial_app/src/pages/supervisor/asignacion/asignacion.dart';
import 'package:asistencia_vial_app/src/pages/supervisor/canje/canje.dart';
import 'package:asistencia_vial_app/src/pages/supervisor/detalle_cajero/detalle_cajero.dart';
import 'package:asistencia_vial_app/src/pages/supervisor/liquidaciones/liquidaciones.dart';
import 'package:asistencia_vial_app/src/pages/supervisor/retiro_apertura/retiro_apertura.dart';
import 'package:asistencia_vial_app/src/pages/supervisor/retiro_fortius/retiro_fortius.dart';
import 'package:asistencia_vial_app/src/pages/supervisor/retiros_parciales/retiro_parcial.dart';
import 'package:asistencia_vial_app/src/pages/supervisor/usuarios/usuarios_sup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'src/pages/detalle/detalle_usuario.dart';
import 'src/pages/supervisor/canje_fortius/canje_fortius.dart';
import 'src/pages/transacciones/transacciones.dart';

Usuario userSession = Usuario.fromJson(GetStorage().read('usuario') ?? {});
Rol? rol =
    userSession.roles?.isNotEmpty == true ? userSession.roles!.first : null;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(UsuarioAdapter());
  Hive.registerAdapter(EstadoAdapter());
  Hive.registerAdapter(MovimientoAdapter());
  Hive.registerAdapter(BovedaAdapter());
  Hive.registerAdapter(TurnoAdapter());
  await Hive.openBox<Boveda>('boveda');
  await Hive.openBox<Usuario>('usuarios');
  await Hive.openBox<Estado>('estado');
  await Hive.openBox<Movimiento>('movimientos');
  await Hive.openBox<Movimiento>('transacciones');
  await Hive.openBox<Movimiento>('updateTransacciones');
  await Hive.openBox<Movimiento>('liquidacionTransacciones');
  await Hive.openBox<Movimiento>('tipoMovimiento');
  await Hive.openBox<Turno>('turno');

  await GetStorage.init();

  // Inicializar controladores ANTES de runApp
  Get.put(LoadingController());
  Get.put(ImprovedConnectionController());
  Get.put(SyncService());

  // Mantener compatibilidad con ConnectionController original (como proxy)
  Get.put(ConnectionController());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Si hay colores dinámicos disponibles, usarlos; sino, usar el esquema personalizado
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null) {
          // Usar completamente los colores del sistema (dinámicos)
          lightColorScheme = lightDynamic;
        } else {
          // Fallback al esquema de color personalizado
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF368983),
            brightness: Brightness.light,
          );
        }

        if (darkDynamic != null) {
          darkColorScheme = darkDynamic;
        } else {
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF368983),
            brightness: Brightness.dark,
          );
        }

        return GetMaterialApp(
          title: 'Asistencias App',
          debugShowCheckedModeBanner: false,
          initialRoute: userSession.id != null ? rol?.ruta : '/',
          getPages: [
            GetPage(name: '/', page: () => LoginPage()),
            GetPage(name: '/register', page: () => RegisterPage()),
            GetPage(name: '/home', page: () => HomePage()),
            GetPage(name: '/detalle', page: () => DetalleUsuario()),
            GetPage(name: '/transacciones', page: () => Transacciones()),
            GetPage(
                name: '/detalletransaccion', page: () => DetalleTransaccion()),
            GetPage(
                name: '/admin/estadisticas', page: () => EstadisticasPage()),
            GetPage(name: '/admin/usuarios', page: () => UsuariosAdmin()),
            GetPage(name: '/supervisor/usuarios', page: () => UsuariosSup()),
            GetPage(name: '/profile/info', page: () => AdminProfile()),
            GetPage(name: '/profile/update', page: () => AdminUpdate()),
            GetPage(
                name: '/supervisor/asignacion', page: () => AsignacionPage()),
            GetPage(name: '/supervisor/canje', page: () => CanjePage()),
            GetPage(
                name: '/supervisor/detallecajero', page: () => DetalleCajero()),
            GetPage(
                name: '/supervisor/retiroparcial',
                page: () => RetiroParcialPage()),
            GetPage(
                name: '/supervisor/retiroapertura',
                page: () => RetiroAperturaPage()),
            GetPage(
                name: '/supervisor/liquidaciones',
                page: () => LiquidacionesPage()),
            GetPage(name: '/supervisor/apertura', page: () => AperturaPage()),
            GetPage(
                name: '/supervisor/retirofortius',
                page: () => RetiroFortiusPage()),
            GetPage(
                name: '/supervisor/canjefortius',
                page: () => CanjeFortiusPage()),
          ],
          themeMode: ThemeMode.system,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            appBarTheme: AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: lightColorScheme.primary,
              foregroundColor: Colors.white,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              surfaceTintColor: Colors.transparent,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            chipTheme: ChipThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            appBarTheme: AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: darkColorScheme.primary,
              foregroundColor: Colors.white,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              surfaceTintColor: Colors.transparent,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            chipTheme: ChipThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          navigatorKey: Get.key,
        );
      },
    );
  }
}
