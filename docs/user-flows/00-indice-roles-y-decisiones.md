# AgaShop — User flows (UX) · Índice, roles, reglas y decisiones

**Fuente:** `AGASHOP.sql` (31 tablas) · **Alcance:** solo experiencia de usuario. No se propone ni se modifica la base de datos; cuando el modelo deja una ambigüedad que afecta la experiencia, se registra como **decisión de UX (DEC)** con una propuesta para confirmar.
**Fecha:** 2026-11-18 · **Estado:** primera versión completa para validar con el negocio.

---

## 0. Cómo leer estos documentos

| Archivo | Contenido |
|---|---|
| **00** (este) | Roles, mapa tablas → flujos, ambigüedades del modelo (DEC), reglas transversales (REG) |
| [01-acceso-y-configuracion](01-acceso-y-configuracion.md) | Login, bloqueo, configuración de sede, catálogos, usuarios |
| [02-caja](02-caja.md) | Apertura, movimientos extra, conteo del dinero, cierre, relevo, caja olvidada |
| [03-inventario-compras-kardex](03-inventario-compras-kardex.md) | Productos, tallas y colores, stock, ajustes, conteo, packs, compras, historial de movimientos |
| [04-clientes-y-ventas](04-clientes-y-ventas.md) | Clientes, venta en mostrador, carrito, cobro (incl. pago mixto), post-venta |
| [05-comprobantes-y-devoluciones](05-comprobantes-y-devoluciones.md) | Estados SUNAT, reintentos, anulación, notas de crédito, devoluciones y cambios |
| [06-delivery](06-delivery.md) | Pedidos con envío, estados, courier, entrega fallida, contra entrega |
| [07-transversales-y-casos-extranos](07-transversales-y-casos-extranos.md) | Concurrencia, offline, permisos, consultas, tabla de tallas y colores de casos extraños, pantallas, preguntas abiertas |

**Convenciones**

- **Flujo:** código de letra + número (A1, B3, G5…). Cada flujo trae: rol, tablas, precondiciones, flujo principal (usuario / sistema), excepciones **E**, casos extraños **X**, reglas de UX y resultado.
- **Roles:** `CAJ` cajero/a o vendedor/a · `SUP` supervisor/a o jefe/a de tienda · `ADM` administrador/a o dueño/a.
- **DEC-xx:** decisión de UX que se debe confirmar (ver sección 3). **REG-xx:** regla transversal (ver sección 4).
- **(propuesta):** valor sugerido y configurable, a confirmar con el negocio.
- **(validar):** regla normativa o de proveedor (SUNAT, proveedor de facturación). Debe confirmarla tu contador o el proveedor antes de implementarla.
- Los montos y umbrales son **ejemplos**, no valores definitivos.

---

## 1. Roles y permisos

El modelo **no tiene rol** en `usuario` (DEC-01). La experiencia necesita al menos tres perfiles, porque hay acciones que no deben estar al alcance de quien cobra.

| Acción | CAJ | SUP | ADM |
|---|:---:|:---:|:---:|
| Vender, cobrar, imprimir | ✅ | ✅ | ✅ |
| Descuento hasta 10 % (propuesta) | ✅ | ✅ | ✅ |
| Descuento de 10 % a 30 % | clave SUP | ✅ | ✅ |
| Descuento mayor a 30 % | ❌ | clave ADM | ✅ |
| Cambiar precio de una línea | ❌ | ✅ + motivo | ✅ |
| Vender sin stock en sistema | ❌ | ✅ + motivo | ✅ |
| Abrir y cerrar su propia caja | ✅ | ✅ | ✅ |
| Movimiento extra de caja hasta S/ 50 (propuesta) | ✅ | ✅ | ✅ |
| Movimiento extra mayor | clave SUP | ✅ | ✅ |
| Cerrar o reabrir la caja de otra persona | ❌ | ✅ | ✅ |
| Anular comprobante / nota de crédito | ❌ | ✅ + motivo | ✅ |
| Devolución o cambio con comprobante | ✅ en plazo | ✅ | ✅ |
| Devolución fuera de plazo o sin comprobante | ❌ | ✅ | ✅ |
| Ajuste de stock, conteo físico | ❌ | ✅ | ✅ |
| Crear o editar productos y precios | ❌ | ✅ | ✅ |
| Registrar compras | ❌ | ✅ | ✅ |
| Ver historial de movimientos | solo lectura | ✅ | ✅ |
| Gestionar clientes | crear y editar básico | ✅ | ✅ |
| Cambiar estado de delivery | ✅ hasta "En camino" | ✅ | ✅ |
| Configuración (series, cajas, medios de pago, usuarios) | ❌ | ❌ | ✅ |

**Autorización por clave:** cuando CAJ intenta una acción de SUP, aparece una ventana pequeña: "Esta acción necesita autorización" + campo de clave o clave de SUP. Nunca se cierra la sesión de CAJ ni se pierde el carrito (REG-04).

---

## 2. Mapa de datos → flujos (referencia para el equipo técnico)

| Tabla | Para qué la ve el usuario | Flujos |
|---|---|---|
| `empresa` | Razón social y RUC de la empresa | A3 |
| `sede` | Tienda: dirección, RUC de sede, % de IGV | A3, G1, J1 |
| `usuario` | Quién inicia sesión, activo o no | A1, A2, A5 |
| `turno` | Mañana, tarde, noche con horario | A4, B1 |
| `caja` | Cajas físicas de la sede | A4, B1 |
| `caja_turno` | Sesión de caja: apertura, cierre, diferencia | B1–B7 |
| `serie_correlativo` | Series (B001, F001…) y su número siguiente, por caja | A3, A4, G6, H1–H6 |
| `grupo_medio_pago`, `medio_pago` | Efectivo, digital, tarjeta… configurables por sede | A4, G5 |
| `categoria` | Árbol de categorías por sede | C3 |
| `producto` | Prenda base (nombre, código base, categoría, estado) | C1, C2 |
| `marca`, `talla`, `color` | Catálogos de atributos | C4 |
| `producto_variante` | Talla × color × marca con código, precio y costo | C1, C2, G2 |
| `inventario_sede` | Stock por talla y color y por sede, stock mínimo | C5–C9, G2 |
| `cliente` | Clientes (DNI, RUC, contacto) | F1–F6, G4 |
| `venta`, `venta_detalle` | Venta y sus líneas | G1–G9, I1–I7, K1 |
| `venta_pago` | Uno o varios pagos por venta | G5, I5 |
| `comprobante_sunat` | Boleta, factura y notas con su estado | G6, H1–H6 |
| `delivery_estado`, `delivery`, `delivery_historial` | Pedidos con envío y su historial | A4, J1–J10 |
| `compra`, `compra_detalle` | Ingreso de mercadería | D1–D3 |
| `kardex_movimiento` | Historial de movimientos de stock | E1–E3, C6, C7 |
| `categoria_movimiento_caja`, `caja_movimiento_extra` | Ingresos y egresos de caja fuera de ventas | A4, B2 |
| `producto_pack`, `producto_pack_detalle` | Combos con precio promocional | C8, G3, I7 |

---

## 3. Dudas del modelo de datos que afectan la experiencia (DEC) — para el equipo técnico y el negocio

Cada fila es un punto donde, **sin decidir**, la pantalla queda ambigua. Se incluye la propuesta que usan los flujos.

### 3.1 Usuarios, permisos y clientes

| ID | Qué se ve en el modelo | Por qué es ambiguo para la UX | Decisión propuesta | Confirma |
|---|---|---|---|---|
| DEC-01 | `usuario` no tiene rol | No se sabe quién puede dar descuentos, anular o cerrar cajas de otros | 3 roles (CAJ, SUP, ADM) y autorización por clave (sección 1) | ADM |
| DEC-02 | `venta.cliente_id` es obligatorio. `cliente.numero_documento` es único global, pero `cliente.sede_id` es obligatorio | Hace falta un "Clientes varios", y no puede existir uno por sede. Un mismo cliente no se podría registrar en dos sedes | "Clientes varios" fijo en la pantalla (no editable ni eliminable). Si el documento ya existe en otra sede, mensaje claro y opción de usarlo | ADM |
| DEC-23 | Cada `usuario` pertenece a una sola `sede` | Un supervisor que cubre dos tiendas no puede entrar a ambas | v1: un usuario, una sede. Un selector de sede solo para ADM si luego se habilita | ADM |
| DEC-28 | `comprobante_sunat` no guarda nombre ni dirección del cliente, solo la venta y el cliente | Si se edita al cliente, una reimpresión podría mostrar datos distintos a los emitidos | Bloquear la edición de documento y nombre de un cliente con comprobantes. Solo contacto y dirección editables | SUP |

### 3.2 Ventas, precios y pagos

| ID | Qué se ve en el modelo | Por qué es ambiguo | Decisión propuesta | Confirma |
|---|---|---|---|---|
| DEC-03 | `precio_venta` sin indicar si incluye IGV. `sede.igv` es un porcentaje | El usuario no sabe si ve precio con o sin IGV | Siempre "Precio incluye IGV" en catálogo y punto de venta. El IGV aparece como "incluye". Si el % es 0, mostrar "Exonerado" | ADM + contador |
| DEC-04 | `venta.estado` default `completada`, sin lista de valores | No hay forma de mostrar anuladas, devueltas o en espera | Estados: completada, anulado, devuelta en parte, devuelta, pago pendiente (contra entrega) | SUP |
| DEC-08 | `venta_pago.monto` no distingue lo recibido del vuelto | El vuelto es de la pantalla, pero la caja debe esperar el efectivo neto | El sistema muestra el vuelto, pero registra y cuenta solo el monto aplicado | SUP |
| DEC-09 | Varias filas de `venta_pago` por venta | Hay que soportar pago mixto (efectivo + Yape) | Hasta 3 medios por venta (propuesta). Ver G5 | SUP |
| DEC-10 | Descuento solo en `venta`, sin motivo ni autorizador. `venta_detalle` sí guarda `precio_unitario` | No hay descuento por línea ni constancia del porqué | Descuento global con límite por rol. Precio por línea solo SUP con motivo. El motivo se pide aunque el modelo no lo guarde (ver DEC-25) | ADM |
| DEC-18 | `venta_detalle` no registra el pack | En el ticket y en devoluciones no se sabe si una línea viene de un pack | El pack se muestra como grupo con etiqueta, y al devolver se avisa de la regla de componentes | SUP |
| DEC-29 | No hay regla de redondeo en efectivo | Pagos en efectivo de montos con céntimos | **Pregunta abierta** (ver sección 7 del archivo 07) | ADM + contador |

### 3.3 Caja

| ID | Qué se ve en el modelo | Por qué es ambiguo | Decisión propuesta | Confirma |
|---|---|---|---|---|
| DEC-21 | Nada impide dos `caja_turno` abiertos para la misma caja o persona | Duplicidad de sesiones | Regla: una caja = una sesión abierta, una persona = una sesión abierta. La pantalla lo previene | SUP |
| DEC-22 | Solo hay un `monto_cierre_esperado/real` | Se entiende que es efectivo. Yape y tarjeta no tienen conteo | Conteo del dinero del efectivo. Los medios digitales y tarjeta se muestran en un resumen informativo | SUP |
| DEC-31 | `caja_movimiento_extra` no tiene anulación | Un movimiento mal registrado no se puede corregir | Se corrige con un movimiento contrario con motivo (B6) | SUP |
| DEC-32 | `estado` de `caja_turno` es texto libre (`abierta` por defecto) | No hay estados para "cierre hecho por el supervisor" o con diferencia | abierta, cerrada, cerrada por el supervisor. La diferencia se muestra aparte | SUP |

### 3.4 Inventario, catálogo y compras

| ID | Qué se ve en el modelo | Por qué es ambiguo | Decisión propuesta | Confirma |
|---|---|---|---|---|
| DEC-11 | `kardex_movimiento` no guarda usuario, motivo ni costo | No se sabe quién ajustó ni por qué. No hay valorización | La pantalla pide motivo y muestra "quién" donde exista. La falta se documenta como requisito pendiente | ADM |
| DEC-12 | No hay tabla de transferencias entre sedes | No se puede trasladar stock con trazabilidad | v1: fuera de alcance. Se hace como salida en una sede y entrada en otra, con motivo | ADM |
| DEC-13 | No hay tabla de conteos físicos | El conteo necesita sesión, pausa y reanudación | El conteo guarda su borrador en el dispositivo. Al confirmar, genera ajustes | SUP |
| DEC-14 | `producto` y `producto_variante` no tienen foto ni código de barras | El punto de venta suele apoyarse en fotos y escáner | Escáner lee el `sku_variante`. Sin foto: bloque de color con iniciales | ADM |
| DEC-15 | `talla` y `color` no tienen orden ni código de color | Tallas aparecen como L, M, S. No hay muestra de color | La interfaz ordena por un orden lógico (XS, S, M, L, XL; numéricas de menor a mayor). Muestra de color solo si se agrega el dato | SUP |
| DEC-16 | `marca`, `talla`, `color` sin `estado` | No se pueden ocultar ni desactivar | Evitar duplicados al crear (sin distinguir mayúsculas) y avisar el impacto al renombrar | SUP |
| DEC-26 | `producto_variante` sin estado. Solo `producto.estado` | No se puede descontinuar una sola talla y color | Desactivar el producto completo o dejar la talla y color en 0 y ocultar las agotadas | SUP |
| DEC-17 | `compra` sin tabla de proveedor, sin estado ni forma de pago | Proveedor se tipea cada vez. No se puede anular | Autocompletar proveedor por RUC o historial. Corrección con ajuste (D2) | ADM |
| DEC-30 | `categoria` es por sede. `producto` y precios son globales | Una categoría de una sede se usa en productos de todas | Los productos usan las categorías de la sede donde se crean | ADM |

### 3.5 Comprobantes y delivery

| ID | Qué se ve en el modelo | Por qué es ambiguo | Decisión propuesta | Confirma |
|---|---|---|---|---|
| DEC-05 | `estado_sunat` default `pendiente`, sin lista de valores | No hay nombres para rechazado, observado, anulado | pendiente, aceptado, con observaciones, no aceptado, anulado. Textos en lenguaje de tienda (REG-10) | Contador |
| DEC-06 | `serie_correlativo` no indica el tipo de comprobante | El tipo se infiere por la letra de la serie | La pantalla de series obliga a elegir el tipo. El punto de venta solo ofrece series válidas para la caja | ADM |
| DEC-07 | No hay tabla de devoluciones. La nota de crédito no referencia el comprobante original | Devolver y cambiar es un flujo diario y no tiene "dónde" | La devolución se guía con un asistente que genera nota de crédito, movimiento de stock y de caja | ADM + contador |
| DEC-24 | `número de comprobante` es un número que avanza | Si falla el envío, no debe haber huecos en la numeración | El número queda reservado y se reintenta con el mismo número. Nunca se salta ni se reutiliza (H2, H3) | Contador |
| DEC-19 | `delivery.costo_envio` no está en `venta.total` | No se sabe si el envío se suma al total ni al comprobante | La pantalla separa "Productos + Envío = Total a cobrar". El tratamiento fiscal lo define el contador | Contador |
| DEC-20 | `venta_pago` exige medio de pago. No hay "pago pendiente" | El contra entrega no tiene dónde vivir | Estado de venta pago pendiente y registro del pago al entregar (J8) | SUP |
| DEC-27 | `delivery.venta_id` es único | Solo un envío por venta. No hay envíos parciales | Un pedido grande con dos couriers no se soporta. La interfaz lo explica y sugiere dos pedidos | ADM |
| DEC-25 | Sin auditoría general (descuentos, precios, anulaciones) | No se sabe quién hizo qué en varios casos | Cada pantalla muestra "registrado por" cuando exista el dato. Los flujos piden motivo igualmente | ADM |

---

## 4. Reglas transversales de UX (REG)

| ID | Regla | Ejemplo |
|---|---|---|
| REG-01 | **Reversible = "Deshacer". Irreversible = confirmar.** Quitar una prenda del carrito se deshace. Emitir un comprobante, cerrar caja o anular se confirma con el efecto explicado | "Se emitirá la boleta B001-00000432 por S/ 205.20. No se puede editar después" |
| REG-02 | **Nunca perder el trabajo.** El carrito, las ventas en espera, los borradores de compra y de conteo se guardan en el dispositivo | Recarga accidental: el carrito vuelve igual |
| REG-03 | **Todo error dice qué pasó, qué hacer y ofrece un botón** | "No hay conexión con SUNAT. La venta se guardó. [Ver pendientes]" |
| REG-04 | **Autorización sin romper el flujo.** clave del supervisor en una ventana. La sesión de CAJ y el carrito siguen | Descuento de 20 % → clave → vuelve al cobro |
| REG-05 | **Una caja, una sesión; una persona, una sesión.** Se previene en pantalla antes de intentar | Caja ocupada: "En uso por Valeria desde 08:02" |
| REG-06 | **Los estados se ven con color, texto e ícono.** Nunca solo color | ✔ Aceptado · ⏳ Pendiente · ✖ Rechazado |
| REG-07 | **El dinero es consistente.** `S/` y dos decimales, alineado a la derecha. El total y el vuelto siempre visibles al cobrar | "S/ 1,250.00" |
| REG-08 | **Acciones de red con tiempo visible.** Pasados 10 s se ofrece "Seguir esperando" o "Reintentar" | Barra de progreso con mensaje |
| REG-09 | **Teclado y escáner primero en el punto de venta.** Foco automático en el buscador, Enter agrega, atajos visibles | F2 punto de venta, F4 espera, F9 cobrar |
| REG-10 | **Lenguaje de tienda, no de SUNAT.** "Enviado y aceptado", no "constancia de SUNAT". La jerga solo en el detalle técnico | "Aceptado por SUNAT" |
| REG-11 | **Doble clic no duplica.** El botón se bloquea y muestra progreso. Tras un fallo de red incierto se consulta el estado antes de permitir reintentar | G8 |
| REG-12 | **Todo registro muestra quién y cuándo.** Fecha, hora y usuario en cada movimiento, venta y cambio de estado | "Ajuste por Valeria, 18/11 17:42" |
| REG-13 | **Los campos obligatorios se anticipan.** Se muestran antes de intentar guardar, y el error aparece junto al campo | "Falta la descripción" bajo el campo |
| REG-14 | **Estados vacíos con siguiente paso.** Nunca una tabla vacía sin explicación | "Aún no hay ventas hoy. [Ir al punto de venta]" |
| REG-15 | **Objetivos táctiles de 44 px o más** en el punto de venta y letra base de 14 px. Caja se usa a veces en tablet | — |
| REG-16 | **Comprobar al confirmar, no solo al elegir.** Stock y precio se revalidan al cobrar | "El stock cambió: ahora quedan 1" |
