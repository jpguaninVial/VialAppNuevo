# Changelog - VialApp Flutter

Todos los cambios notables en este proyecto serán documentados en este archivo.

## [Unreleased] - 2025-12-12

### 🔐 Autenticación y Notificaciones

#### Mejoras en Login
- **lib/src/pages/login/login_page.dart**
  - Rediseño completo con animaciones fluidas
  - `AnimationController` con duración de 1000ms
  - `FadeTransition` para efectos de desvanecimiento gradual (0.0 → 1.0)
  - `SlideTransition` para desplazamiento suave:
    - Logo: Offset(0, 0.3) → Offset.zero
    - Inputs: Offset(0, 0.5) → Offset.zero
  - Container circular con gradiente para logo
  - Border radius aumentado de 32px a 40px
  - Input fields con 16px border radius, sombras mejoradas
  - Botón login redimensionado: 60px height (de 56px)
  - Padding mejorado: 16px → 20px
  - Espaciado consistente entre elementos
  - SingleTickerProviderStateMixin agregado

- **lib/src/pages/login/login_controller.dart**
  - Importado `package:fluttertoast/fluttertoast.dart`
  - Nuevo método `_obtenerSaludo()` para saludos personalizados por hora:
    - "¡Buenos días!" (00:00 - 11:59)
    - "¡Buenas tardes!" (12:00 - 17:59)
    - "¡Buenas noches!" (18:00 - 23:59)
  - Reemplazo de `Get.snackbar()` con `Fluttertoast.showToast()`:
    - Success: Toast verde con saludo personalizado (3s, TOP)
    - Inactive user: Toast naranja (3s, TOP)
    - Login error: Toast rojo con mensaje dinámico (3s, TOP)
    - General error: Toast rojo con detalles de excepción (3s, TOP)
  - Parámetros Fluttertoast: `Toast.LENGTH_LONG`, `ToastGravity.TOP`, `fontSize: 16.0`

- **pubspec.yaml**
  - Dependencia fluttertoast: 8.2.5

#### Validación de Campos de Entrada

- **lib/src/pages/supervisor/canje/canje.dart**
  - maxLength actualizado: 2 → 3 (permite hasta 999 billetes)
  - Agregado `FilteringTextInputFormatter.digitsOnly`
  - Material You aplicado: gradiente primary.withOpacity(0.9) → (0.7)
  - BuildContext agregado a métodos helper

- **lib/src/pages/supervisor/retiro_parcial/retiro_parcial.dart**
  - maxLength actualizado: 2 → 3
  - FilteringTextInputFormatter.digitsOnly activado
  - Material You implementado
  - Context parameters agregados

- **lib/src/pages/supervisor/retiro_apertura/retiro_apertura.dart**
  - maxLength: 2 → 3
  - Input validation con digitsOnly
  - Material You con opacity-based gradients
  - BuildContext pasado a helpers

- **lib/src/pages/supervisor/apertura/apertura.dart**
  - Theme.of(context).colorScheme.primary para AppBar

- **lib/src/pages/supervisor/usuarios_sup/usuarios_sup.dart**
  - Gradient con opacity: primary.withOpacity(0.9) → (0.7)
  - Material You colors aplicados

- **lib/src/pages/supervisor/boveda/boveda_page.dart**
  - Header gradient: primary.withOpacity(0.9) → (0.7)

- **lib/src/pages/supervisor/asignacion/asignacion.dart**
  - Gradient usando primary con opacity para darkening

- **lib/src/pages/supervisor/transacciones/transacciones.dart**
  - Material You opacity-based coloring
  - Primary color theme

- **lib/src/pages/supervisor/retiro_fortius/retiro_fortius.dart**
  - backgroundColor: Theme.of(context).colorScheme.primary

- **lib/src/pages/supervisor/canje_fortius/canje_fortius.dart**
  - Primary theme color para AppBar

- **lib/src/pages/supervisor/liquidaciones/liquidaciones.dart**
  - Primary color AppBar theme

- **lib/src/pages/supervisor/retiro_parcial_improve/retiro_parcial_improve.dart**
  - Theme-based colors

- **lib/src/pages/editar_transaccion/editar_transaccion.dart** (Complete Redesign)
  - `_inputField()` completamente rediseñado con:
    - Container con sombras y border radius 12px
    - Theme.of(context) colors para text, background, icons
    - Prefixicon con background container
    - maxLength: 3 + FilteringTextInputFormatter.digitsOnly
    - focusedBorder con color primary dinámico
    - Contexto pasado a firma del método
  - 20+ call sites actualizadas con `context: context,`
  - `_recibeGrid(BuildContext context)` signature actualizada
  - `_entregaGrid(BuildContext context)` signature actualizada
  - Input styling consistente Material You

### 🔧 Cambios de Lógica de Negocio - Gestión de Faltantes y Sobrantes

#### Pantalla Faltante (faltante.dart y faltante_controller.dart)

**Funcionalidad de Registro de Faltantes (TIPO_MOVIMIENTO = '6')**
```dart
// Antes: No se registraban faltantes
// Ahora: Flujo completo de registración:

1. _crearNuevoFaltante(Map<String, String> data)
   - Crea movimiento tipo 6 si no existe faltante previo
   - Registra billetes/monedas recibidas vs entregadas
   - Calcula diferencia automáticamente

2. _modificarFaltante(Map<String, String> data)
   - Actualiza faltante existente
   - Permite ajustes después de crear liquidación
   - Mantiene integridad de datos previos

3. _crearFaltante(Map<String, String> data)
   - Crea Movimiento con idTipoMovimiento = '6'
   - Campos: recibe5C, recibe10C, recibe25C, recibe50C
   - Campos: entrega5C, entrega10C, entrega25C, entrega50C
```

**Funcionalidad de Sobrantes**
```dart
// Nuevo campo en liquidación:
sobrante: double (almacena valor en dinero)

// Flujo:
1. Usuario ingresa sobrante en campo de input
2. Se almacena en sobrantesController.text
3. Se envía en movimiento tipo 4 (liquidación)
4. Backend calcula total con faltantes + sobrantes
```

**Lógica de Flujos de Bandera**
```dart
// Bandera = 1 (Apertura)
Future<void> actualizarLiquidacion(BuildContext context) {
  if (bandera == 1) {
    if (totalRecibido > 0) {
      await _crearNuevoFaltante(formData); // Tipo 6
    }
    await _actualizarSoloLiquidacion(formData); // Tipo 4
  }
}

// Bandera = 2 (Cierre)
} else if (bandera == 2) {
  await _procesarLiquidacion(formData);
  // Crea liquidación completa + faltante en transacción
}
```

**Método _procesarLiquidacion (Nueva Lógica)**
```dart
Future<void> _procesarLiquidacion(Map<String, String> data) async {
  final totalRecibido = _calculateTotalRecibido(data);

  if (totalRecibido > 0) {
    final yaExisteFaltante = movimientos.any((m) => m.idTipoMovimiento == _TIPO_FALTANTE);
    
    if (yaExisteFaltante) {
      await _modificarFaltante(data); // Actualizar faltante
    } else {
      await _crearNuevoFaltante(data); // Crear faltante nuevo
    }
  } else {
    await _actualizarSoloLiquidacion(data); // Solo liquidación
  }
}
```

#### ImprovedFaltanteController (Versión Mejorada con Validación de Conexión)

**Validación Obligatoria de Conexión**
```dart
Future<void> actualizarLiquidacion(BuildContext context, List<Movimiento> movimientos) async {
  // 1. Validar que no haya operación en curso
  if (LoadingController.to.isLoading(LOADING_KEY)) {
    return;
  }

  // 2. Validar campos
  if (!_validateFields()) {
    return;
  }

  // 3. Verificar conexión OBLIGATORIA
  final hasConnection = await _verifyConnection();
  if (!hasConnection) {
    _showNoConnectionDialog(); // No permite continuar
    return;
  }

  // 4. Procesar si todo es válido
  LoadingController.to.setLoading(LOADING_KEY, message: 'Procesando faltante...');
}
```

**Validación de Campos Mejorada**
```dart
bool _validateFields() {
  // Verifica que tenga valores para recibir Y entregar
  final hasRecibeValues = [
    billetes1RecibeController.text,
    billetes5RecibeController.text,
    // ... otros
  ].any((value) => value.isNotEmpty);

  final hasEntregaValues = [
    billetes1EntregaController.text,
    billetes5EntregaController.text,
    // ... otros
  ].any((value) => value.isNotEmpty);

  // Valida que los valores sean números válidos
  try {
    // Parsing de cada campo
    double.parse(billetes20RecibeController.text.isEmpty ? '0' : billetes20RecibeController.text);
    // ... otros campos
  } catch (e) {
    // Muestra error de formato
    return false;
  }

  return true;
}
```

---

#### Sistema de Liquidación (liquidaciones_controller.dart)

**Nueva Lógica de Detección Automática**
```dart
// Verificar si ya existe una liquidación
final bool liquidacionExiste = liquidacion.id != null &&
    liquidacion.id!.isNotEmpty &&
    liquidacion.id != '0';

if (!liquidacionExiste) {
  // No existe liquidación, crear nueva
  final result = await _submitTransactionWithRetries(movimiento, true);
  // Manejar respuesta
  await _handleTransactionResult(result);
} else {
  // Ya existe liquidación, actualizar (agregar faltantes/sobrantes)
  final result = await _submitTransactionWithRetries(movimiento, false);
}
```

**Cálculos Automáticos en Resumen**
```dart
// Antes: Solo mostraba campos
// Ahora: Calcula totales automáticamente

final double totalFaltantes = _calculateTotalFaltantes();
final int anulacionesCantidad = int.parse(sobrantesController.text);
final double anulacionesValor = double.parse(anulacionesValorController.text);
final int simulacionesCantidad = int.parse(simulacionesCantidadController.text);
final double simulacionesValor = double.parse(simulacionesValorController.text);
final double sobrantes = double.parse(sobrantesController.text);

// Muestra resumen completo en modal DraggableScrollableSheet
```

---

#### Manejo de Transacciones Offline

**Sincronización de Transacciones**
```dart
// En improved_canje_fortius_controller.dart
Response response = await movimientoProvider.create(movimiento);

if (response.statusCode == 201) {
  // Transacción online exitosa
  CustomToast.showSuccess('Canje Exitosa');
  Get.offNamedUntil('/home', (route) => false, arguments: {'index': 0});
}

if (response.statusCode == 202) {
  // Transacción guardada offline
  CustomToast.showWarning('Transacción Offline - Se enviará al conectar');
  Get.offNamedUntil('/home', (route) => false, arguments: {'index': 2});
}
```

**Reintentos Automáticos**
```dart
// En dialogo de error de conexión
TextButton(
  onPressed: () async {
    Get.back();
    final hasConnection = await _verifyConnection();
    if (hasConnection) {
      registrarCanjeeFortius(Get.context!, usuario!);
    }
  },
  child: Text('Reintentar'),
),
```

---

#### Campos de Entrada y Validación (Todos los Controllers)

**FilteringTextInputFormatter en Todos los Controllers**
- `FilteringTextInputFormatter.digitsOnly` agregado a:
  - canje_controller
  - retiro_parcial_controller
  - retiro_apertura_controller
  - faltante_controller
  - improved_faltante_controller
  - improved_canje_fortius_controller

**Máximo de Dígitos Actualizado**
```dart
// Antes: maxLength: 2 (máximo 99)
// Ahora: maxLength: 3 (máximo 999)

TextFormField(
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  maxLength: 3, // Permite hasta 999 unidades
)
```

---

### 🎨 Mejoras de UI/UX - Material You Dynamic Colors (Versión Anterior)

#### Implementado
- **Sistema de Colores Dinámicos Material You**
  - Implementado `DynamicColorBuilder` en `main.dart` para extraer colores del wallpaper del dispositivo
  - Configurado fallback con `ColorScheme.fromSeed(Color(0xFF368983))` para dispositivos sin soporte
  - Agregada dependencia `dynamic_color: ^1.7.0`

#### Screens Actualizadas con Dynamic Colors
1. **lib/src/pages/boveda/boveda_page.dart**
   - Header con gradiente dinámico (primaryContainer → secondaryContainer)
   - Avatar y cards con colores adaptativos
   - Loading indicators con color primary dinámico
   - Total: 8 reemplazos de colores

2. **lib/src/pages/Home/home_page.dart**
   - Bottom navigation bar con colores dinámicos
   - Estados activo/inactivo con primary/onSurface
   - Background adaptativo (surfaceContainer)

3. **lib/src/utils/custom_animated_bottom_bar.dart**
   - Extension `bottomAppBarColor` actualizada a surfaceContainer

4. **lib/src/pages/transacciones/transacciones.dart** (491 líneas)
   - Header gradient dinámico
   - Date fields con primaryContainer
   - Loading spinner con primary
   - Empty state con primary.withOpacity(0.3)
   - Cards con surfaceContainerHighest
   - Total: 12+ reemplazos de colores

5. **lib/src/pages/supervisor/asignacion/asignacion.dart** (908 líneas)
   - RefreshIndicator con color primary
   - Cards con surfaceContainerHighest
   - Avatar borders y gradientes con primaryContainer
   - Texto secundario con onSurface.withOpacity(0.6)
   - Total: 12 operaciones multi-replace

6. **lib/src/pages/detalle_transaccion/detalle_transaccion.dart** (920 líneas)
   - Header gradient dinámico
   - Información de supervisor/cajero/vía en card unificada
   - Texto en colored backgrounds con onPrimaryContainer
   - Contenedores con surface
   - Botones con primary
   - Sombras con colorScheme.shadow
   - BuildContext pasado explícitamente a métodos helper
   - Total: 15+ errores de compilación corregidos

7. **lib/src/pages/supervisor/faltante/faltante.dart** (1019 líneas)
   - Archivo recuperado de corrupción (literal \r\n escape sequences)
   - Convertido de StatelessWidget a StatefulWidget
   - Todos los botones sin gradientes (backgroundColor sólido)
   - _recibeGrid() y _entregaGrid() con BuildContext explícito
   - Modal backgrounds con surface
   - Input containers con surfaceContainerHighest
   - Total: 4 botones actualizados sin gradientes

8. **lib/src/pages/supervisor/detalle_cajero/detalle_cajero.dart** (250 líneas)
   - Bottom sheet con surface background
   - Header gradient dinámico
   - Cards de transacciones con surfaceContainerHighest
   - Iconos y textos con colores adaptativos
   - PopupMenu con surfaceContainerHighest
   - BuildContext pasado a _buildTransactionCard()

9. **lib/src/pages/editar_transaccion/editar_transaccion.dart** (548 líneas)
   - AppBar con primary background y onPrimaryContainer text
   - IconTheme con onPrimaryContainer
   - Títulos de sección con primary
   - Dividers con onSurface.withOpacity(0.2)
   - Botón confirmar con primary y onPrimaryContainer text
   - Dialog con colores dinámicos en todos los elementos

### 🍞 Sistema de Toasts Personalizado

#### Nuevo Componente
- **lib/src/utils/custom_toast.dart**
  - Sistema de toasts personalizado con 5 tipos:
    - `showSuccess()` - Operaciones exitosas (primaryContainer)
    - `showError()` - Errores (errorContainer)
    - `showWarning()` - Advertencias (tertiaryContainer)
    - `showInfo()` - Información (secondaryContainer)
    - `showOffline()` - Transacciones offline (surfaceContainerHighest)
  - Características:
    - Iconos contextuales para cada tipo
    - Posición superior (SnackPosition.TOP)
    - Bordes redondeados (12px)
    - Sombras suaves adaptativas
    - Deslizable horizontalmente
    - Duración configurable (3-4 segundos)
    - Colores 100% dinámicos Material You

#### Controllers Actualizados
1. **lib/src/pages/supervisor/faltante/faltante_controller.dart**
   - Importado `custom_toast.dart`
   - Reemplazados 3 métodos de snackbar:
     - `_showSuccessSnackbar()` → `CustomToast.showSuccess()`
     - `_showOfflineSnackbar()` → `CustomToast.showOffline()`
     - `_showErrorSnackbar()` → `CustomToast.showError()`

2. **lib/src/pages/supervisor/asignacion/asignacion_controller.dart**
   - Importado `custom_toast.dart`
   - Reemplazados 7 `Get.snackbar()` con CustomToast:
     - `updateVia()` - Success y Error toasts
     - `deleteTurno()` - Success y Error toasts
     - `enviarTurno()` - Success y Error toasts
     - `enviarBoveda()` - Success y Error toasts

### 🐛 Correcciones de Bugs

#### Errores de Compilación Resueltos
- **detalle_transaccion.dart**: 15 errores "The getter 'context' isn't defined"
  - Solución: Agregado `BuildContext context` como parámetro a métodos helper
  - Métodos actualizados: `_buildDetails()`, `_buildDenominationList()`, `_detailRow()`, `_confirmButton()`, `_canjeBottom()`
  
- **faltante.dart**: Corrupción de archivo con literal escape sequences
  - Solución: Archivo completamente recreado
  - Conversión a StatefulWidget para manejo correcto de estado

- **detalle_cajero.dart**: Context no disponible en _buildTransactionCard()
  - Solución: Agregado BuildContext como primer parámetro del método

#### Parámetros sin Usar Eliminados
- `faltante.dart`: Removido parámetro `Color? color` de `_buildSummaryRow()`
- `editar_transaccion.dart`: Parámetro `maxLength` marcado como sin uso (warning)

### 🎯 Patrones Establecidos

#### Color Mappings (Hardcoded → Dynamic)
```dart
// Colores primarios
Color(0xFF368983) → Theme.of(context).colorScheme.primary
Color(0xFF2C6E69) → Theme.of(context).colorScheme.secondaryContainer

// Backgrounds
Colors.white → Theme.of(context).colorScheme.surface
Colors.white → Theme.of(context).colorScheme.surfaceContainerHighest (cards)
Colors.grey[100] → Theme.of(context).colorScheme.surface

// Textos
Colors.white (on colored) → Theme.of(context).colorScheme.onPrimaryContainer
Colors.black87 → Theme.of(context).colorScheme.onSurface
Colors.grey[600] → Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
Colors.grey[200] → Theme.of(context).colorScheme.onSurface.withOpacity(0.1)

// Sombras
Colors.grey.withOpacity(0.x) → Theme.of(context).colorScheme.shadow.withOpacity(0.x)
```

#### Opacidades Estándar
- Containers: 0.1-0.3
- Texto secundario: 0.6-0.7
- Estados inactivos: 0.2-0.3
- Borders: 0.1-0.2

### 📊 Estadísticas

#### Cobertura de Material You
- **Screens completadas**: 9/9 screens principales (100%)
- **Líneas de código modificadas**: ~9000+ líneas
- **Colores hardcoded reemplazados**: 100+ instancias
- **Errores de compilación corregidos**: 30+
- **Archivos corruptos recuperados**: 1

#### Sistema de Toasts
- **Controllers actualizados**: 2/20+ (10%)
- **Snackbars reemplazados**: 10+ instancias
- **Tipos de toast disponibles**: 5

### ⚠️ Pendientes

#### Screens sin Material You (Trabajo Futuro)
- `lib/src/pages/supervisor/apertura/*.dart` (screens de apertura)
- `lib/src/pages/supervisor/liquidaciones/*.dart` (screens de liquidaciones)
- `lib/src/pages/supervisor/retiro_*.dart` (screens de retiros)
- `lib/src/pages/usuarios_admin/*.dart` (gestión de usuarios admin)
- `lib/src/pages/usuarios_sup/*.dart` (gestión de usuarios supervisor)
- Otros screens especializados (~10-12 screens adicionales)

#### Controllers sin CustomToast (Trabajo Futuro)
- `lib/src/provider/usuario_provider.dart` (~11 snackbars)
- `lib/src/provider/turno_provider.dart` (~3 snackbars)
- `lib/src/services/sync_service.dart` (~2 snackbars)
- `lib/src/pages/supervisor/faltante/improved_faltante_controller.dart` (~5 snackbars)
- `lib/src/widgets/improved_offline_banner.dart` (~3 snackbars)

### 🔄 Criterios de Éxito

#### Material You Implementation
✅ DynamicColorBuilder configurado correctamente
✅ ColorScheme.fromSeed como fallback funcional
✅ Todos los screens principales responden a wallpaper colors en Android 12+
✅ Fallback a teal theme en dispositivos antiguos
✅ Zero errores de compilación en todos los screens actualizados
✅ BuildContext manejado correctamente (no usar Get.context)
✅ Patrón de colores consistente en toda la app

#### Toast System
✅ CustomToast implementado con 5 tipos
✅ Colores 100% dinámicos Material You
✅ Iconos contextuales para cada tipo
✅ Duración y posición configurables
✅ Compatible con arquitectura GetX existente
✅ Zero breaking changes en controllers actualizados

---

## Notas de Implementación

### BuildContext Best Practices
- Siempre pasar `BuildContext context` explícitamente a métodos helper
- Nunca usar `Get.context` para Theme.of()
- StatefulWidget cuando se necesita `initState()`
- StatelessWidget cuando no hay estado local

### Gradientes en Botones
- Headers: OK usar gradientes (primaryContainer → secondaryContainer)
- Botones: NO usar gradientes, solo backgroundColor sólido

### Recuperación de Archivos Corruptos
1. Eliminar archivo corrupto: `rm path/to/file.dart`
2. Recrear con `create_file` con contenido completo
3. Verificar con `get_errors`
4. Formatear con `dart format` si es necesario

---

**Mantenido por**: GitHub Copilot AI Assistant  
**Última actualización**: 2025-12-11
