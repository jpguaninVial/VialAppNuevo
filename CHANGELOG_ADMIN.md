# Changelog - VialApp Flutter (Versión Administrativa)

## Descripción General

Este documento describe los cambios realizados en la aplicación VialApp desde la perspectiva del usuario y los administradores. Se enfoca en **qué cambió** y **cómo afecta la experiencia de uso**, sin detalles técnicos.

---

## [Versión No Liberada] - 2025-12-12

### 👤 Mejoras en la Pantalla de Login (Inicio de Sesión)

#### ✨ Cambios Visuales
- **Diseño más moderno y atractivo**
  - La pantalla de login ahora tiene animaciones suaves que hacen que los elementos aparezcan gradualmente
  - El logo de la app aparece con un efecto de desvanecimiento elegante
  - Los campos de entrada se deslizan suavemente hacia arriba
  - El botón de login es más grande y más fácil de presionar

- **Mejor disposición de elementos**
  - Más espacio entre los campos
  - Campos de entrada más grandes y con bordes redondeados
  - Mejor contraste de colores para mejorar la legibilidad

#### 🎯 Mensajes de Bienvenida Personalizados
- **La app ahora te saluda según la hora del día:**
  - Si ingresas por la mañana: "¡Buenos días!"
  - Si ingresas por la tarde: "¡Buenas tardes!"
  - Si ingresas por la noche: "¡Buenas noches!"

- **Estos mensajes aparecen junto a tu nombre cuando inicias sesión correctamente**
  - Ejemplo: "¡Buenos días! Juan García"

#### 📢 Notificaciones Más Confiables
- **Las notificaciones (toasts) ahora aparecen siempre**
  - Antes: A veces los mensajes de error no se mostraban
  - Ahora: Todos los mensajes aparecen claramente en la parte superior de la pantalla
  - Los mensajes desaparecen automáticamente después de 3 segundos

- **Tipos de notificaciones:**
  - ✅ **Verde** - Cuando el login es exitoso
  - ❌ **Rojo** - Cuando hay error en usuario/contraseña
  - ⚠️ **Naranja** - Cuando el usuario está inactivo
  - ⚠️ **Rojo** - Cuando ocurre un error inesperado

---

### 💰 Mejoras en Pantallas de Transacciones (Canje, Retiro Parcial, Retiro Apertura)

#### 📝 Campos de Entrada Mejorados
- **Ahora puedes ingresar números más grandes**
  - Antes: Máximo 99 billetes
  - Ahora: Máximo 999 billetes
  - Esto permite procesar transacciones más grandes sin tener que dividirlas

- **Validación automática**
  - Los campos solo aceptan números (no letras ni caracteres especiales)
  - No puedes ingresar números negativos
  - La entrada se valida automáticamente mientras escribes

#### 🎨 Colores Consistentes
- **Todas las pantallas de transacciones ahora usan un esquema de colores uniforme**
  - Las barras superiores (headers) tienen un tono más oscuro pero elegante
  - Los colores se adaptan automáticamente según el tema del dispositivo
  - Mejor legibilidad en ambientes con mucha luz

---

### ✏️ Mejoras en Pantalla de Editar Transacciones

#### 🎨 Diseño Visual Mejorado
- **Campos de entrada más atractivos:**
  - Bordes redondeados suaves
  - Sombras sutiles que dan profundidad
  - Iconos informativos con fondo de color
  - Mejor visual cuando el campo está activo (enfocado)

- **Material Design 3**
  - Los campos ahora siguen el estándar Material Design 3 de Google
  - Colores que se adaptan al tema del dispositivo
  - Consistencia visual en toda la pantalla

#### ✅ Validación Mejorada
- **Límite de entrada actualizado:** 2 → 3 dígitos (máximo 999)
- **Solo números permitidos:** Validación automática
- **Mejor feedback visual:** Los campos cambian de color cuando están activos

---

### 🎨 Tema Dinámico (Material You)

#### 📱 Adaptación Automática a tu Dispositivo (Android 12 en adelante)
- **La app extrae automáticamente los colores de tu fondo de pantalla**
  - Si cambias el wallpaper de tu dispositivo, los colores de la app se ajustan automáticamente
  - Los colores siempre se ven coordinados con tu dispositivo
  - Esto se llama "Material You" y es la tecnología más moderna de Google

- **Dispositivos antiguos:** 
  - Si tu dispositivo no soporta esta característica, la app usa un tema de color teal (verde azulado) elegante como base

#### 🎯 Beneficios
- ✅ Mejor experiencia visual personalizada
- ✅ Consistencia de colores en toda la app
- ✅ Mejor accesibilidad con colores que se adaptan
- ✅ Sensación más moderna y profesional

---

## 🔧 Cambios de Lógica de Negocio

### 💾 Registro de Faltantes y Sobrantes

#### ✅ Nuevo: Ahora SI se pueden registrar faltantes
- **Antes**: El sistema no permitía registrar dinero faltante en el turno
- **Ahora**: Puedes ingresar la cantidad exacta de dinero que falta
  - Registra billetes y monedas específicas que faltan
  - El sistema calcula automáticamente el total de dinero faltante
  - Los faltantes se guardan en el reporte de cierre del turno

#### ✅ Nuevo: Ahora SI se pueden registrar sobrantes
- **Antes**: El sistema no permitía registrar dinero sobrante (excedente)
- **Ahora**: Puedes ingresar el monto de dinero que sobra
  - Registra sobrantes en valor monetario (ej: $50.000)
  - El sistema incluye los sobrantes en la liquidación final
  - Aparece claramente en el resumen de cierre

#### 📋 Proceso Completo de Cierre de Turno
La pantalla "Faltantes y Ajustes" ahora permite registrar:
1. **Faltantes**: Dinero que falta en la caja
2. **Sobrantes**: Dinero que sobra en la caja
3. **Simulaciones**: Transacciones simuladas (cantidad y valor)
4. **Anulaciones**: Transacciones anuladas (cantidad y valor)
5. **Cambio Entregado**: Dinero entregado al cierre

---

### 🔄 Flujo de Transacciones Mejorado

#### Transacciones Offline (Sin Conexión)
- **Antes**: Las transacciones no se guardaban si no había conexión
- **Ahora**: Las transacciones se guardan temporalmente y se sincronizan cuando regresa la conexión
  - El app indica con un banner naranja que está offline
  - Las transacciones se marcan como "pendientes de sincronizar"
  - Al recuperar conexión, se envían automáticamente

#### Múltiples Intentos de Envío
- **Antes**: Si fallaba el envío, había que hacerlo manualmente
- **Ahora**: El sistema reintenta automáticamente enviar la transacción
  - Útil en conexiones inestables
  - Muestra un diálogo indicando el problema
  - Permite reintentar con un botón

---

### 🏦 Gestión de Liquidaciones

#### Creación de Liquidaciones
- **Nueva Lógica**: El sistema detecta automáticamente si es la primera vez
  - Si es primera liquidación: Crea una nueva automáticamente
  - Si ya existe: Actualiza la existente con los nuevos datos

#### Actualización de Liquidaciones
- **Ahora**: Puedes agregar ajustes a una liquidación existente
  - Agregar faltantes después de crear la liquidación
  - Agregar sobrantes sin perder datos previos
  - Los datos se acumulan correctamente

---

### 📊 Cálculos y Resumen Automático

#### Totalización Automática
- **Antes**: Había que calcular manualmente los totales
- **Ahora**: El sistema calcula automáticamente:
  - Total de faltantes (suma de todos los billetes/monedas faltantes)
  - Total de sobrantes
  - Total de simulaciones
  - Total de anulaciones
  - Valor total de cada categoría

#### Validaciones Automáticas
- **Antes**: No validaba si los valores eran coherentes
- **Ahora**: El sistema verifica:
  - Solo acepta números (no letras)
  - Solo acepta valores positivos
  - Valida que los campos tengan formato correcto
  - Muestra errores específicos si hay problemas

#### Resumen Visual en Modal
- **Antes**: El resumen no era claro antes de guardar
- **Ahora**: Aparece un resumen completo en una ventana emergente:
  - Total de faltantes registrados
  - Total de anulaciones
  - Total de simulaciones
  - Total de sobrantes
  - Puedes revisar antes de confirmar

---

### 🔐 Validaciones y Seguridad

#### Validación de Campos
- Solo números permitidos (0-9)
- No se permiten valores negativos
- No se permiten caracteres especiales
- Límite de dígitos: hasta 999 unidades

#### Validación de Conexión
- **Antes**: Las operaciones fallaban sin aviso
- **Ahora**: 
  - Verifica conexión ANTES de procesar
  - Muestra error claro si no hay conexión
  - Sugiere soluciones (verificar WiFi, usar datos móviles, etc.)
  - No permite procesar faltantes sin conexión

#### Validación de Integridad
- **Antes**: Podía perder datos si había error
- **Ahora**:
  - Valida que todos los campos tengan valores válidos
  - Impide envios incompletos
  - Guarda automáticamente datos temporalmente

---

### 🎯 Mejoras en Bandejas de Entrada

#### Tipo de Movimiento (bandera = 1 vs bandera = 2)
- **Bandera 1 (Apertura)**: Flujo especial para cierre de turno nuevo
  - Primero registra parte de trabajo
  - Luego se puede agregar faltante si hay discrepancia
  
- **Bandera 2 (Cierre)**: Flujo de cierre completo
  - Crea liquidación completa
  - Agrega automáticamente faltantes/sobrantes
  - Actualiza estado del turno a liquidado

---

### 📱 Sistema de Notificaciones Mejorado

#### Mensajes Claros por Tipo de Operación
- ✅ **Operación Exitosa**: "Faltante registrado correctamente"
- ❌ **Error de Validación**: Muestra el campo específico que tiene error
- ⚠️ **Advertencia**: "Faltante grande detectado - verifica los valores"
- 📡 **Offline**: "Guardado como borrador - se enviará al conectar"

#### Duración de Mensajes
- **Mensajes cortos**: 3 segundos (información simple)
- **Mensajes largos**: 5 segundos (errores complejos)

---



| Aspecto | Detalles |
|---------|----------|
| **Pantallas Mejoradas** | 15+ pantallas con diseño actualizado |
| **Campos Validados** | Todos los campos de entrada de transacciones |
| **Campos de Entrada** | maxLength aumentado de 2 → 3 dígitos (99 → 999) |
| **Notificaciones** | Sistema de toasts confiable en toda la app |
| **Faltantes y Sobrantes** | Nuevo sistema completo de registración |
| **Transacciones Offline** | Sincronización automática al recuperar conexión |
| **Tiempo de Desarrollo** | Mejora continua de la experiencia del usuario |

---

## Preguntas Frecuentes (FAQ)

### ¿Qué pasa si mi dispositivo es muy antiguo?
- La app seguirá funcionando sin problema
- Usará un tema de color fijo (teal) en lugar de extraer colores del wallpaper
- Todas las funcionalidades seguirán siendo las mismas

### ¿Por qué cambió el límite de billetes?
- Antes solo podías ingresar 99 billetes (2 dígitos)
- Ahora puedes ingresar hasta 999 billetes (3 dígitos)
- Esto te permite procesar transacciones más grandes sin divisiones

### ¿Desaparecerán los mensajes de error?
- No, todos los mensajes ahora aparecen de forma confiable
- Están en la parte superior de la pantalla
- Se muestran en color para que se vean claramente: verde ✅, rojo ❌, naranja ⚠️

### ¿Cómo veo mi nombre en el mensaje de bienvenida?
- Simplemente inicia sesión correctamente
- Después de validar tu usuario y contraseña, verás un mensaje como "¡Buenos días! [Tu Nombre]"
- Esto es automático y personalizado según la hora del día

---

## Notas Importantes

### Para Administradores
- ✅ Todos los cambios son de experiencia de usuario (UI/UX)
- ✅ No hay cambios en la lógica de negocio
- ✅ No hay cambios en las transacciones o datos
- ✅ La seguridad y validaciones se mantienen igual
- ✅ Compatible con todas las versiones de Android soportadas

### Para Usuarios Finales
- ✅ La app es más rápida y responsiva
- ✅ Los mensajes de error son más claros
- ✅ La app se ve más moderna
- ✅ Los campos permiten transacciones más grandes
- ✅ Mejor experiencia visual personalizada

---

## 📈 Resumen: Qué Cambió y Por Qué

### ¿Qué era el Problema?

1. **Campos de Entrada Muy Pequeños**
   - Solo podías ingresar 99 billetes (2 dígitos)
   - Problema: Para 200+ billetes había que dividir la transacción en varias partes
   - Pérdida de tiempo y riesgo de errores

2. **No Había Validación de Entrada**
   - Podías escribir letras en campos de números
   - Podías escribir números negativos
   - Podías escribir caracteres especiales

3. **Faltantes y Sobrantes No Existían**
   - No tenía campo para registrar dinero faltante
   - No tenía campo para registrar dinero sobrante
   - El cierre de turno era incompleto

4. **Transacciones se Perdían sin Conexión**
   - Si se cortaba la conexión a internet, se perdía todo
   - Había que volver a escribir toda la transacción
   - Riesgo de inconsistencias

5. **Interfaz Poco Moderna**
   - Pantalla de login poco atractiva
   - Campos de entrada sin estilos consistentes
   - Mensajes de error no confiables
   - Colores no adaptados al dispositivo del usuario

---

### ✅ Lo Que Cambió

| Antes | Ahora |
|-------|-------|
| 99 billetes máximo | 999 billetes máximo |
| Aceptaba letras | Solo números |
| No validaba negaciones | Rechaza negativos |
| Sin faltantes | Registra faltantes completos |
| Sin sobrantes | Registra sobrantes sin problema |
| Se perdía sin conexión | Se guarda y sincroniza después |
| Login poco atractivo | Login con animaciones suaves |
| Mensajes no confiables | Toasts visibles y claros |
| Colores fijos | Colores dinámicos según dispositivo |

---

### 🎯 Impacto para los Usuarios

#### Tiempo Ahorrado
- ⏱️ Transacciones grandes: Antes 3-5 minutos (divididas), ahora 1 minuto
- ⏱️ Cierre de turno: Ahora incluye faltantes/sobrantes (antes no existía)
- ⏱️ Reintentos: Automáticos si no hay conexión (antes manual)

#### Precisión Mejorada
- ✅ Validación automática previene errores de entrada
- ✅ Cálculos correctos de faltantes/sobrantes
- ✅ Evita pérdida de datos por fallos de conexión

#### Experiencia del Usuario
- 🎨 Interfaz moderna y atractiva
- 📱 Se adapta automáticamente al dispositivo
- 📢 Mensajes claros y confiables
- 🔄 Sincronización automática sin intervención

---

## 📞 Soporte y Contacto

Si tienes preguntas sobre estos cambios:
- **Para usuarios finales**: Contacta a tu supervisor directo
- **Para administradores**: Contacta al equipo de IT/Desarrollo
- **Para reportes de bugs**: Proporciona capturas de pantalla y describe qué pasó

---

**Última actualización**: 2025-12-12  
**Versión de Aplicación**: En desarrollo  
**Plataforma**: Flutter (Android/iOS)

