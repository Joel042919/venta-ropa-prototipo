# 07 · Transversales, casos extraños, pantallas y preguntas abiertas

Volver al [índice](00-indice-roles-y-decisiones.md).

---

## 1. Concurrencia y consistencia

Dos cajas, una supervisora y un conteo pueden tocar el mismo stock a la vez. La interfaz debe ser honesta con eso.

| ID | Situación | Qué ve la persona | Regla |
|---|---|---|---|
| T1 | Dos cajas venden la **última unidad** | La segunda recibe "Acaban de vender la última unidad. [Quitar del carrito] [Buscar otra talla]" al cobrar | Se revalida al confirmar (REG-16) |
| T2 | Se ajusta stock mientras se vende | El ajuste avisa "El stock cambió" (C6 E3) | Gana el valor del servidor |
| T3 | Dos personas editan el mismo producto | Aviso de cambios y opción **Ver cambios** (C2 E1) | No se pisa en silencio |
| T4 | Se cambia un precio con carritos abiertos | Al cobrar: "El precio cambió" (G3 E5) | El cliente ve el precio vigente |
| T5 | Dos personas intentan cerrar o abrir la misma caja | Gana la primera. A la segunda se le informa | Una sesión por caja (DEC-21) |
| T6 | Alguien desactiva un medio de pago a mitad de un cobro | El cobro actual termina. El cambio rige desde la siguiente venta | A4 E4 |
| T7 | Se desactiva un producto con carritos abiertos | Al cobrar: "Este producto fue desactivado" y se quita | G2 E2 |
| T8 | Mismo documento de cliente registrado por dos cajas | La segunda recibe "Ya está registrado" y puede usarlo | F2 E1 |

---

## 2. Conexión, errores y dispositivos

| ID | Situación | Comportamiento esperado |
|---|---|---|
| T9 | **Pérdida de conexión en pantalla** | Aviso no intrusivo "Sin conexión". Lo que no necesita servidor (carrito, espera) sigue. Lo que sí, se explica |
| T10 | **Respuesta incierta** (se cayó la red al confirmar) | La pantalla consulta el estado antes de dejar reintentar (G8, REG-11) |
| T11 | **Doble clic o doble toque** | El botón se bloquea. Nunca se duplica una operación |
| T12 | **Impresora desconectada** | La venta no se pierde. Ofrece reintentar, ver PDF o enviar (G6 E4) |
| T13 | **Escáner que no envía Enter** | Botón **Agregar** junto al buscador |
| T14 | **Sesión expirada** | Pide la contraseña y vuelve al mismo punto, con el carrito (A2 E3) |
| T15 | **Se cierra el navegador o se apaga el equipo** | Recupera carrito, esperas y borradores. Una venta confirmada se consulta en el historial |
| T16 | **Reloj del equipo desfasado** | Aviso permanente (A1 X2) |
| T17 | **Pantalla pequeña (tablet o móvil)** | El carrito pasa a un cajón con botón flotante "Ver venta · S/ …". El botón **Cobrar** queda fijo |
| T18 | **Carga lenta** | Esqueletos y mensajes de progreso, no pantallas en blanco |
| T19 | **Servicio externo caído** (RENIEC, SUNAT) | Se permite continuar con datos manuales y marca **Sin validar** |

---

## 3. Autorización de supervisor (clave)

Una sola ventana reutilizable en todo el sistema.

| Elemento | Detalle |
|---|---|
| Disparador | La persona intenta algo que su rol no permite |
| Ventana | "Esta acción necesita autorización de un supervisor" + campo de clave o clave |
| Motivo | Si la acción lo requiere, un campo de motivo obligatorio dentro de la misma ventana |
| Resultado | Se ejecuta y queda anotado "Autorizó: Rosa (SUP)" cuando el modelo lo permita (DEC-25) |
| Error | clave incorrecto: "clave incorrecto. Te quedan 2 intentos". Tras 3 se cancela y se avisa a SUP |

**Acciones que la usan:** descuento sobre el límite, cambio de precio, vender sin stock, movimiento de caja sobre el límite, diferencia grande de cierre, devolución fuera de plazo, anulación, ajuste de stock negativo, reembolso por medio distinto.

**Excepciones:** SUP no está en la tienda (ADM puede autorizar; si no hay ninguno, la operación espera); la autorización se pide dos veces seguidas por la misma acción (se recuerda durante 2 minutos, propuesta).

---

## 4. Consultas y reportes mínimos

## K1 · Historial de ventas

**Rol:** CAJ (las suyas), SUP y ADM (todas)

**Filtros:** fecha, caja, persona, medio de pago, estado de la venta, estado del comprobante, tipo, canal, cliente, monto. **Búsqueda** por número o escaneo del QR del ticket.
**Detalle:** líneas, pagos, comprobante, movimientos de stock (E2), pedido de delivery si lo hay, línea de tiempo.
**Acciones según estado y rol:** reimprimir, enviar, devolver, cambiar, anular (H4, H5, I).

**Excepciones:** sin resultados con filtros activos ("Sin resultados con estos filtros. [Limpiar filtros]"); muchos resultados (paginación); venta de otra sede (solo ADM).

## K2 · Resumen del día

**Rol:** SUP, ADM

| Bloque | Contenido |
|---|---|
| Ventas | Total, número de ventas, ticket promedio, comparación con ayer |
| Medios de pago | Participación por grupo |
| Caja | Estado de cada caja y diferencias de cierres |
| SUNAT | Pendientes y no aceptados (enlace a H2) |
| Stock | Por reponer (enlace a C9) |
| Delivery | Pedidos atrasados y por estado |
| Alertas | Posible uso compartido de usuario, cajas abiertas fuera de turno |

**Excepciones:** día sin ventas ("Aún no hay ventas hoy. [Ir al punto de venta]"); sin conexión (última lectura con la hora).

## K3 · Reporte de cierre

Es el mismo que B3: ventas por medio de pago, movimientos, apertura, esperado, real y diferencia, con firma. Se puede reimprimir desde el historial de caja.

---

## 5. Tabla de tallas y colores consolidada de casos extraños

Casos poco frecuentes que el diseño debe tener resueltos. Todos están desarrollados en el flujo indicado.

### Ventas y cobro

| # | Caso | Comportamiento | Flujo |
|---|---|---|---|
| 1 | El cliente paga y se cae la red | La pantalla consulta la última venta antes de permitir reintento | G8 |
| 2 | Pago por Yape que "no llega" | Cobro abierto hasta que la cajera valida | G5 E4 |
| 3 | Mismo N.º de operación en dos ventas | Aviso con el comprobante anterior | G5 E3 |
| 4 | Vuelto mayor al efectivo disponible | Bloquea y sugiere otra opción | G5 E6 |
| 5 | Cliente quiere el vuelto por Yape | No soportado: se guía a pago mixto o egreso con nota | B3 X4 |
| 6 | Prenda "separada" con adelanto | No soportado en v1 | G5 X1 |
| 7 | Descuento y pack juntos | No se acumulan (propuesta) | G3 E4 |
| 8 | Precio cambió en el carrito | Se revalida al cobrar | G3 E5 |
| 9 | La prenda está en estantería pero en el sistema hay 0 | Vender sin stock con clave y motivo | G2 E5 |
| 10 | Boleta alta sin identificar | Pide documento | G4 E2 |
| 11 | La clienta quiere factura después de pagar | Anular y reemitir con las mismas prendas | H5 |
| 12 | Cliente no quiere dar datos | Clientes varios | F6 |
| 13 | Dos personas atendidas a la vez | Ventas en espera | G7 |
| 14 | La cajera se va sin cobrar | Bloqueo y espera automática | A2 |
| 15 | El ticket sale sin papel | Reintentar, ver PDF o enviar | G6 E4 |

### Caja

| # | Caso | Comportamiento | Flujo |
|---|---|---|---|
| 16 | Caja olvidada del día anterior | Bloquea la venta y obliga a regularizar | B5 |
| 17 | Fondo distinto al que dejó el turno anterior | Pide observación | B1 E9 |
| 18 | Billete falso al contar | Egreso con categoría y observación | B3 X2 |
| 19 | La caja no cuadra por poco | Diferencia permitida configurable sin observación | B3 |
| 20 | Faltante grande | clave del supervisor y alerta en el resumen | B3 E3 |
| 21 | La cajera se va sin cerrar | cierre hecho por el supervisor por SUP | B3 E8 |
| 22 | Cierre sin internet | Conteo guardado, cierre al reconectar | B3 E6 |
| 23 | Efectivo en caja demasiado alto | Sugerencia de retiro a caja fuerte | B2 X3 |
| 24 | Movimiento extra mal registrado | Movimiento contrario con motivo | B6 |
| 25 | Cerrar por error | Reabrir solo SUP/ADM, el mismo día | B6 |
| 26 | Relevo con desacuerdo en el conteo | Recontar con SUP | B4 E2 |
| 27 | Dos personas abren la misma caja | Gana la primera | B1 X3 |

### Inventario y compras

| # | Caso | Comportamiento | Flujo |
|---|---|---|---|
| 28 | Última unidad vendida por dos cajas | Se avisa a la segunda al cobrar | T1 |
| 29 | Stock negativo en el sistema | Se resalta con enlace al historial de movimientos | C5 E1 |
| 30 | Producto outlet con otro precio | Producto nuevo "(Outlet)" | C1 X1 |
| 31 | Se necesita descontinuar una talla | Stock en 0 y ocultar agotadas | C2 |
| 32 | Talla creada como "m" y "M" | Normalizada y fusionable | C4 |
| 33 | Conteo con ventas durante el proceso | El esperado se ajusta por movimientos | C7 E1 |
| 34 | Conteo abandonado dos días | Aviso y opción de reiniciar | C7 X2 |
| 35 | Compra duplicada | Bloquea con enlace al original | D1 E1 |
| 36 | El total del documento no coincide | No deja registrar sin explicar la diferencia | D1 E6 |
| 37 | Proveedor sin comprobante formal | Tipo "Nota de compra" con número interno | D1 E9 |
| 38 | Devolución a proveedor | Salida con motivo | D1 X2 |
| 39 | Corrección de una compra ya vendida | Solo por lo que queda | D2 |
| 40 | Historial de movimientos que no cuadra con el stock | Chip de alerta y ajuste guiado | E1 E5 |
| 41 | Pack con un componente agotado | No disponible | C8 E1 |

### Comprobantes y devoluciones

| # | Caso | Comportamiento | Flujo |
|---|---|---|---|
| 42 | Comprobante rechazado | Motivo claro y corrección | H3 |
| 43 | Pendientes tras una caída larga | Reenviar todos con avance | H2 E2 |
| 44 | Anular algo de un turno ya cerrado | El efecto de caja cae en la sesión actual | H5 E5 |
| 45 | Devolver un pack parcialmente | Se explica la regla antes de confirmar | I7 |
| 46 | Cambio con precio actual menor | Se cambia por el valor pagado | I3 E2 |
| 47 | Cambio sin stock de lo nuevo | Otras tallas y colores, otras sedes o devolución simple | I3 E1 |
| 48 | Devolución sin ticket | Solo cambio, sin dinero | I4 |
| 49 | Devolución pagada con Yape o tarjeta | Reembolso por el mismo medio sin tocar el efectivo | I5 |
| 50 | Devolución de otra sede | El stock vuelve a la sede actual | I2 E3 |
| 51 | Prenda devuelta con defecto | Reingreso, prenda dañada o revisión | I6 |

### Delivery

| # | Caso | Comportamiento | Flujo |
|---|---|---|---|
| 52 | Dos paquetes con couriers distintos | No soportado: dos pedidos | J1 X1 |
| 53 | Entrega fallida dos veces | Sugiere devolver a tienda | J5 E1 |
| 54 | Contra entrega sin rendir | Aparece en el cierre | J8 E1 |
| 55 | Estado marcado por error | Deshacer por 10 minutos | J2 E2 |
| 56 | Dirección cambia en camino | Solo antes de "En camino" | J1 E9 |
| 57 | Paquete extraviado | Estado y nota de crédito o reposición | J6 X1 |
| 58 | Falta una prenda al preparar | Cambio o quitar del pedido | J3 E1 |
| 59 | Guía repetida | Aviso con el pedido original | J3 E3 |

### Accesos y sistema

| # | Caso | Comportamiento | Flujo |
|---|---|---|---|
| 60 | Dos personas comparten usuario | Alerta a SUP | A1 X1 |
| 61 | Hora del equipo desfasada | Aviso permanente | A1 X2 |
| 62 | Se desactiva a alguien con caja abierta | cierre hecho por el supervisor | A5 X1 |
| 63 | Se renombra un medio de pago | Aviso de que el historial lo mostrará | A4 X2 |
| 64 | Se intenta desactivar "Efectivo" | Bloqueado | A4 X1 |
| 65 | Sede sin series o sin cajas | No deja vender y muestra lo que falta | A3 E8 |

---

## 6. Inventario de pantallas y ventanas

Lista de lo que hay que diseñar. Entre paréntesis, los flujos que la usan.

### Pantallas

| # | Pantalla | Flujos |
|---|---|---|
| 1 | Login | A1 |
| 2 | Bloqueo de sesión | A2 |
| 3 | Asistente de configuración | A3 |
| 4 | Catálogos de configuración | A4 |
| 5 | Usuarios | A5 |
| 6 | Abrir caja | B1 |
| 7 | Resumen de caja | B7 |
| 8 | Cierre de caja y reporte | B3, K3 |
| 9 | Entrega de caja (relevo) | B4 |
| 10 | Punto de venta (catálogo, carrito) | G1–G3 |
| 11 | Historial de ventas y detalle | K1 |
| 12 | Bandeja de comprobantes | H2 |
| 13 | Devoluciones y cambios (asistente) | I1–I7 |
| 14 | Productos (lista, detalle, nuevo) | C1, C2 |
| 15 | Stock (tabla de tallas y colores por producto) | C5 |
| 16 | Toma de inventario | C7 |
| 17 | Por reponer | C9 |
| 18 | Packs | C8 |
| 19 | Compras (lista y nueva) | D1–D3 |
| 20 | Historial de movimientos | E1–E3 |
| 21 | Clientes (lista y ficha) | F1–F5 |
| 22 | Pedidos (tablero y lista) | J2, J9 |
| 23 | Detalle de pedido y línea de tiempo | J3–J10 |
| 24 | Resumen del día | K2 |

### Ventanas y paneles

| # | Elemento | Flujos |
|---|---|---|
| 1 | Autorización de supervisor | Sección 3 |
| 2 | Selector de talla y color (tabla de tallas y colores) | G2 |
| 3 | Cobro (incluye pago mixto) | G5 |
| 4 | Resultado de emisión | G6 |
| 5 | Ventas en espera | G7 |
| 6 | Registro rápido de cliente | F2 |
| 7 | Movimiento de caja | B2 |
| 8 | Datos de envío | J1 |
| 9 | Ajuste de stock | C6 |
| 10 | Registro de pago contra entrega | J8 |
| 11 | Motivo y confirmación (anular, cancelar) | H5, J6 |

### Estados y avisos globales

| Elemento | Cuándo aparece |
|---|---|
| Aviso de SUNAT sin respuesta | H6 nivel 1 |
| Aviso de sin conexión | H6 nivel 2 |
| Aviso de hora desfasada | A1 X2 |
| Aviso de caja abierta fuera de turno | A2 X1, B5 |
| Contador de pendientes | H2 |

---

## 7. Preguntas abiertas (para eliminar ambigüedades)

Cada una cambia lo que se diseña. Se indica **quién decide**.

| # | Pregunta | Por qué importa | Propuesta actual | Decide |
|---|---|---|---|---|
| Q1 | ¿Se **redondea** el efectivo a múltiplos de 0.10? | El pago en efectivo de un total con céntimos genera una diferencia mínima | Sin redondeo hasta definirlo | ADM + contador |
| Q2 | ¿Se permite dar **vuelto por Yape**? | No existe como pago. Afecta el cuadre de caja | No soportado: pago mixto o egreso con nota | ADM |
| Q3 | ¿Se permite **separar prendas con adelanto**? | El modelo cobra la venta completa | No soportado en v1 | ADM |
| Q4 | ¿Los **descuentos aplican a packs**? | Cambia el cálculo y las devoluciones | No se acumulan | ADM |
| Q5 | ¿Cómo se registra una **compra sin comprobante**? | Serie y número son obligatorios | "Nota de compra" con número interno | ADM + contador |
| Q6 | ¿Qué pasa con la **diferencia a favor de la clienta** en un cambio sin efectivo? | No se puede dejar saldo | Otro medio o elegir otra prenda | SUP |
| Q7 | ¿Cuándo se emite el comprobante en **contra entrega**? | Puede ser al pagar o al entregar | A confirmar | Contador |
| Q8 | ¿El **costo de envío** va en el comprobante y en el total de la venta? | Define cómo se ve el total | Se muestra separado | Contador |
| Q9 | ¿El **conteo del dinero es ciego**? | Define si la cajera ve el efectivo esperado | Ciego para CAJ | ADM |
| Q10 | ¿Cuál es el **plazo de devolución** y la política de envío? | Define cuándo se pide clave | 7 días. Envío no reembolsable | ADM |
| Q11 | ¿Qué **monto de boleta** exige identificar al comprador? | Cambia el flujo de cobro | S/ 700 (validar) | Contador |
| Q12 | ¿Qué hace el negocio **sin internet**? | Define si hay modo local | Nivel 1 solo (SUNAT caído) | ADM |
| Q13 | ¿Se necesitan **fotos** y **códigos de barras** de producto? | El modelo no los tiene | Escáner con código y bloque de color | ADM |
| Q14 | ¿Los **supervisores** trabajan en más de una sede? | Un usuario tiene una sola sede | Un usuario, una sede | ADM |
| Q15 | ¿Se necesitan **traslados entre sedes** con trazabilidad? | No hay tabla | Fuera de v1 | ADM |
| Q16 | ¿Hay **vendedoras con comisión**? | No hay campos ni reportes | No contemplado | ADM |
| Q17 | ¿Cuáles son los **límites de descuento y de movimientos extra**? | Definen los clave | 10 / 30 % y S/ 50 | ADM |
| Q18 | ¿La **diferencia permitida de cierre** es S/ 1? | Define cuándo se pide observación | S/ 1 | SUP |
