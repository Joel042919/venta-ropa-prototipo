# 01 · Acceso y configuración

Volver al [índice](00-indice-roles-y-decisiones.md).

---

## A1 · Inicio de sesión

**Rol:** CAJ, SUP, ADM
**Precondiciones:** el usuario existe y está activo (`estado = true`).

**Flujo principal**

| # | La persona | El sistema |
|---|---|---|
| 1 | Abre la aplicación | Muestra el login: **Usuario** (no correo, máximo 20 caracteres), **Contraseña** con botón mostrar/ocultar |
| 2 | Escribe usuario y contraseña, pulsa **Ingresar** | Valida. Botón bloqueado con "Ingresando…" (REG-11) |
| 3 | — | Detecta la sede del usuario y la muestra en el encabezado |
| 4a | Si es CAJ sin caja abierta | Lleva a **Abrir caja** (B1) |
| 4b | Si es CAJ con caja abierta propia | Lleva directo al punto de venta, con un aviso "Caja 01 abierta desde 08:02" |
| 4c | Si es SUP o ADM | Lleva al **resumen del día** (K2) |

**Excepciones**

| # | Situación | Qué ve y qué puede hacer | Resultado |
|---|---|---|---|
| E1 | Usuario o contraseña incorrectos | Mensaje genérico "Usuario o contraseña incorrectos" (no revela cuál falló). Contador de intentos | Reintenta |
| E2 | 5 intentos fallidos | "Demasiados intentos. Espera 5 minutos o pide ayuda a tu supervisor" (propuesta) | Bloqueo temporal |
| E3 | Usuario desactivado | "Tu usuario está desactivado. Habla con tu supervisor" | No entra |
| E4 | Mayúsculas activadas | Aviso discreto bajo el campo de contraseña | Informa |
| E5 | Sin conexión | "No hay conexión. Revisa el internet e intenta de nuevo" con botón Reintentar | No entra |
| E6 | Primera vez, con contraseña temporal | Obliga a crear una contraseña nueva antes de continuar | Contraseña propia |
| E7 | Olvidó la contraseña | No hay recuperación automática (no hay correo). Muestra "Pídele a tu administrador que la restablezca" y el nombre del contacto de la sede | Ver A5 |
| E8 | Ya tiene una sesión abierta en otro dispositivo | "Tu usuario está en uso en otro equipo. [Continuar aquí cerrando el otro] [Cancelar]". Solo cierra la otra pantalla, no la caja | Una pantalla activa |

**Casos extraños**

- **X1 · Dos personas comparten un usuario:** si ocurren dos ingresos en minutos desde equipos distintos, aviso a SUP en el resumen ("Posible uso compartido de usuario").
- **X2 · Reloj del equipo mal puesto:** si la hora del dispositivo difiere de la del servidor más de 5 minutos, aviso permanente "La hora de este equipo está desfasada. Los comprobantes pueden salir con fecha incorrecta".
- **X3 · Usuario escrito con espacios o mayúsculas:** se limpian espacios; el usuario no distingue mayúsculas.
- **X4 · Cambio de sede de un usuario mientras tiene sesión:** al siguiente movimiento, cierra sesión con el mensaje "Tu sede cambió. Vuelve a ingresar".
- **X5 · Sesión caducada a mitad de una venta:** ver A2 y REG-02, el carrito se conserva.

**Resultado:** sesión iniciada, sede visible, camino correcto según el rol y el estado de caja.

---

## A2 · Bloqueo rápido y cambio de persona

**Rol:** CAJ, SUP

**Flujo principal**

| # | La persona | El sistema |
|---|---|---|
| 1 | Se aleja del puesto, o pulsa **Bloquear** | Tras 5 minutos sin actividad (propuesta), cubre la pantalla con el nombre de quien tiene la caja. El carrito sigue por debajo |
| 2 | Escribe su contraseña (o clave) | Desbloquea en el mismo punto exacto |
| 3 | (Alternativa) Pulsa **Cambiar de usuario** | Si hay caja abierta con ventas, propone **Entregar caja** (B4) en vez de cerrar sesión |

**Excepciones**

| # | Situación | Resultado |
|---|---|---|
| E1 | Una venta en pantalla sin cobrar | Se pasa a **espera** automática (G7) antes de cerrar sesión |
| E2 | Otra persona intenta desbloquear con su propia clave | Pregunta "¿Es el relevo de caja?" y deriva a B4. No vende con la sesión de otra persona |
| E3 | Sesión expirada en el servidor | Pide contraseña; al volver, restaura la pantalla y el carrito |
| E4 | Contraseña olvidada en el bloqueo | SUP la restablece con su clave (A5) |

**X1 · La cajera deja la pantalla bloqueada y se va de turno:** a la hora de fin del turno, el sistema avisa a SUP en su resumen ("Caja 01 sigue abierta tras el turno").

---

## A3 · Configuración inicial de una sede

**Rol:** ADM

La experiencia es un **asistente de 10 pasos** con barra de avance. La sede queda "lista para vender" cuando cumple los mínimos.

| Paso | Qué se pide | Mínimo para vender |
|---|---|---|
| 1 Empresa | Razón social, RUC (11 dígitos, validado) | ✅ |
| 2 Sede | Nombre, dirección, RUC de la sede, **IGV** (18 % por defecto) | ✅ |
| 3 Cajas | Nombre ("Caja 01") | ✅ al menos una |
| 4 Series | Una serie de boleta y una de factura por caja (B001, F001) con número inicial | ✅ boleta |
| 5 Turnos | Nombre y horario (Mañana 08:00–14:00) | ✅ al menos uno |
| 6 Medios de pago | Grupos (Efectivo, Digital, Tarjeta) y medios (Yape, Plin, Visa…) con instrucciones | ✅ Efectivo |
| 7 Categorías | Árbol inicial | recomendado |
| 8 Categorías de movimiento de caja | Ingresos y egresos típicos | recomendado |
| 9 Estados de delivery | Pendiente, En camino, Entregado… con su orden | solo si hace delivery |
| 10 Usuarios | Personas, rol y contraseña temporal | ✅ un SUP |

**Excepciones**

| # | Situación | Resultado |
|---|---|---|
| E1 | RUC con formato inválido | Error junto al campo, no se avanza |
| E2 | RUC de la sede distinto al de la empresa | Aviso "El RUC de la sede no coincide con el de la empresa. ¿Es correcto?" |
| E3 | IGV en 0 | Confirmación "Esta sede venderá exonerada de IGV" |
| E4 | Serie ya existente (la serie es única en todo el sistema) | "La serie B001 ya existe en otra caja. Usa B002" con sugerencia |
| E5 | Serie con formato inválido | Debe tener 4 caracteres y empezar con B o F (ver DEC-06) |
| E6 | Número de comprobante inicial mayor a 0 (migración desde otro sistema) | Advertencia clara "No se puede volver atrás" |
| E7 | Abandona el asistente a medias | Guarda el avance. Al volver: "Continuar con el paso 4" |
| E8 | Intenta vender sin cumplir los mínimos | El punto de venta no abre y muestra la lista de lo que falta con enlaces |

**X1 · Sede nueva que comparte catálogo con otra:** los productos son globales, pero su stock por sede empieza sin habilitar. Mensaje "Esta sede aún no tiene stock de los productos existentes. [Habilitar productos]" (C5).
**X2 · Empresa con varias sedes con distinto IGV:** cada sede guarda el suyo; el precio sigue siendo uno solo.

---

## A4 · Mantenimiento de catálogos de configuración

**Rol:** ADM

Regla común: **se desactiva, no se elimina** cuando ya hay uso.

| Catálogo | Qué se puede hacer | Restricciones y mensajes |
|---|---|---|
| **Cajas** | Crear, renombrar, desactivar | Desactivar con sesión abierta: bloqueado "Caja 01 tiene un turno abierto" |
| **Turnos** | Crear, editar horario | Si la hora fin es menor que la de inicio, se interpreta como turno que cruza la medianoche, con una nota. No se permiten horarios que se pisen sin aviso |
| **Series** | Crear por caja; elegir tipo | No se edita ni elimina una serie con comprobantes. El número de comprobante solo lo toca ADM con advertencia fuerte |
| **Grupos y medios de pago** | Crear, ordenar, activar/desactivar, texto de instrucciones | Desactivar un medio con ventas históricas: se oculta del cobro, el historial lo conserva. No se puede dejar la sede sin Efectivo activo |
| **Categorías de movimiento de caja** | Crear con tipo Ingreso o Egreso | No cambiar el tipo si tiene movimientos |
| **Estados de delivery** | Crear, ordenar | Cambiar el orden con pedidos en curso: aviso "N pedidos se verán afectados". No eliminar estados en uso |

**Excepciones comunes**

| # | Situación | Resultado |
|---|---|---|
| E1 | Nombre duplicado (sin distinguir mayúsculas) | "Ya existe un medio llamado 'Yape'" |
| E2 | Desactivar el último medio de pago de un grupo | Aviso de que el grupo quedará vacío |
| E3 | Reordenar con arrastrar y soltar en táctil | Alternativa con botones subir/bajar |
| E4 | Cambios hechos con ventas en curso en otras cajas | Los cambios se aplican en la siguiente venta, nunca a mitad de un cobro (aviso breve) |

**X1 · Se desactiva por error "Efectivo":** el sistema lo impide. **X2 · Se renombra "Yape" a "Yape/Plin":** se advierte que el historial mostrará el nombre nuevo.

---

## A5 · Gestión de usuarios

**Rol:** ADM (SUP puede restablecer contraseñas de CAJ)

**Flujo principal (crear)**

| # | ADM | Sistema |
|---|---|---|
| 1 | Usuarios → **Nuevo** | Formulario: usuario (único, hasta 20), nombre para mostrar, rol, sede, contraseña temporal |
| 2 | Guarda | Muestra la contraseña temporal una sola vez, con botón copiar. Pide cambiarla en el primer ingreso (A1 E6) |

**Otras acciones**

| Acción | Regla |
|---|---|
| Desactivar | Si tiene una caja abierta, primero debe cerrarse (SUP). Nunca se elimina un usuario con historial |
| Reactivar | Pide una contraseña nueva |
| Restablecer contraseña | Genera una temporal, con motivo |

**Excepciones**

| # | Situación | Resultado |
|---|---|---|
| E1 | Usuario ya existe | Sugiere tallas y colores ("valeria.m") |
| E2 | Desactivar al último ADM | Bloqueado |
| E3 | Una persona se desactiva a sí misma | Bloqueado, con explicación |
| E4 | Contraseña débil | Indicador de fuerza y reglas visibles antes de guardar |
| E5 | Persona que cambia de sede | Se desactiva en la anterior y se crea en la nueva (DEC-23) |

**X1 · Persona que se va a mitad de turno:** ADM o SUP desactiva el usuario y, si había caja abierta, la cierra como **cierre hecho por el supervisor** (B3 E8).
