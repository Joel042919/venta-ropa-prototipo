# Evaluación UX — Demo punto de venta "Estilo & Moda"

**Qué es:** un demo (prototipo) de punto de venta, inventario y facturación electrónica para una boutique de moda femenina en Perú. Sirve para mostrarle a la dueña cómo sería el sistema.
**Fecha:** 2026-11-08
**Estado:** primera evaluación. Falta validar en el navegador y con usuarias (ver sección 6).

---

## 1. Cómo leer este documento

- **Qué se revisó:** las 6 pantallas (Resumen del día, Punto de Venta, Inventario, Comprobantes, Clientes, Reportes) y el login, leyendo el código y calculando contrastes de color.
- **Qué no se hizo todavía:** probar la app en pantalla, probarla con personas ni usar un lector de código de barras real. Lo que depende de eso está marcado **"por confirmar"**.
- **Es un demo.** Por eso hay cosas que son correctas para presentar y no se cuentan como errores: los datos de ejemplo, que SUNAT siempre acepte, los KPIs fijos. Cuando algo estaría mal en un sistema real, se indica con la etiqueta **Producto real**.
- Cada hallazgo tiene tres partes: **qué pasa**, **por qué importa** y **mejora propuesta**.

**Prioridad:**

| Prioridad | Significa |
|---|---|
| 🔴 Alta | Afecta la demo o la venta ahora mismo. Corregir primero. |
| 🟡 Media | Mejora clara de experiencia. Corregir después. |
| 🟢 Baja | Detalle de pulido. |

**Etiqueta "Aplica a":** **Demo** = se nota al presentar. **Producto real** = importa solo si el sistema se usa en una tienda de verdad.

---

## 2. Resumen en 30 segundos

**Lo que ya está bien**
1. **Identidad visual propia.** Colores terracota y crema, y tipografía con serifa en precios y títulos. Se siente boutique, no software contable.
2. **Menú claro.** 6 módulos con nombres fáciles de entender y todas las pantallas con la misma estructura.
3. **El punto de venta entiende la moda.** Se elige talla y color, y las tarjetas avisan cuando queda poco stock.
4. **El cobro da confianza.** La animación de 3 pasos (firma, envío a SUNAT, aceptado) y el vuelto automático se entienden al instante.
5. **Está pensado para Perú.** Yape, Plin, soles, DNI y RUC, boleta y factura, IGV 18 %.

**Los 5 puntos que más conviene mejorar**
1. 🔴 **Cobro en efectivo:** el modal parece abrir con S/ 0 y el botón bloqueado (por confirmar).
2. 🔴 **Resumen de totales confuso:** los números no se leen como una suma.
3. 🔴 **Letra muy pequeña y poco contraste** en gran parte de la pantalla.
4. 🔴 **La pantalla de login no aparece al iniciar,** aunque el guion de la demo empieza por ahí.
5. 🟡 **No está pensado para tablet o pantallas pequeñas** (por confirmar), que es lo habitual en una caja.

---

## 3. Hallazgos y mejoras

### 3.1 Punto de Venta (la pantalla estrella)

| # | Qué pasa | Por qué importa | Mejora propuesta | Prioridad | Aplica a |
|---|---|---|---|---|---|
| P1 | El resumen muestra *Op. Gravada*, *IGV* y luego *Descuento*, pero el total ya incluye el descuento. Los números no se leen como una suma. | La dueña puede pensar que el sistema calcula mal. Es la zona donde más mira el dinero. | Reordenar así: **Subtotal → Descuento → Op. Gravada → IGV → Total**, con una línea separadora antes del total. | 🔴 | Demo |
| P2 | Cada vez que se agrega una prenda aparece un aviso que dura 4.5 s. Con el escáner se apilan varios. | Tapan la esquina inferior derecha y repiten lo que el carrito ya muestra. | Quitar el aviso al agregar (el carrito se actualiza solo) y dejarlo para errores, como "stock insuficiente". Opcional: un pequeño destello en la fila agregada. | 🟡 | Demo |
| P3 | "Vaciar" y el botón de basura borran sin confirmar y sin poder deshacer. | Un toque accidental en plena venta borra todo. | Agregar un aviso "Prenda eliminada · **Deshacer**" durante unos segundos. Para "Vaciar", pedir confirmación. | 🟡 | Demo y real |
| P4 | Al elegir talla y color se pueden combinar por separado, y no se ve el stock de cada combinación. | Se puede agregar una talla y color que no existe o no tiene stock. | Mostrar el stock junto a cada talla/color y desactivar las combinaciones agotadas. | 🟡 | Producto real |
| P5 | El buscador no reacciona a la tecla **Enter** y no tiene foco automático. Los lectores reales de código de barras escriben el código y envían Enter. | El escáner real probablemente no agregue el producto (por confirmar). La cajera tiene que hacer clic en el buscador cada vez. | Foco automático en el buscador. Si lo escrito coincide con un código de barras, al pulsar Enter agregar la prenda y limpiar el campo. | 🟡 | Producto real |
| P6 | Los datos del cliente son dos campos sueltos. No se puede elegir una clienta del directorio. | Las clientas frecuentes deberían ser un clic, no teclear el DNI cada vez. | Un buscador de clientas con sugerencias (nombre o documento) que rellene los datos. | 🟡 | Demo y real |
| P7 | El panel del carrito reúne 5 bloques en poco espacio: tipo de comprobante, cliente, lista, descuento y totales. | En pantallas bajas la lista de prendas, lo más importante, queda diminuta. | Dar prioridad a la lista y plegar los datos del cliente en un bloque que se despliega. Para "Boleta con Clientes Varios", dejarlo ya resuelto. | 🟢 | Demo |
| P8 | Se llama "Comanda / Venta Actual". *Comanda* es palabra de restaurante. | Suena ajeno al rubro de moda. | Renombrar a **"Venta actual"**. | 🟢 | Demo |

### 3.2 Cobro (Pago)

| # | Qué pasa | Por qué importa | Mejora propuesta | Prioridad | Aplica a |
|---|---|---|---|---|---|
| C1 | **Por confirmar (captura 07):** el campo de efectivo parece abrir en **S/ 0** y el botón de confirmar queda gris hasta escribir un monto. El modal conserva el valor de la venta anterior. | Es el primer cobro que se hace en la demo. Si no sale de un toque, se rompe el efecto "wow". | Al abrir el modal, proponer el **total exacto** como monto por defecto y reiniciar el modal en cada venta. | 🔴 | Demo y real |
| C2 | Los botones de billetes rápidos son siempre S/ 50, 100 y 200. | Con un total de S/ 230 ninguno alcanza y solo sirve "Exacto". | Sugerir billetes según el total, por ejemplo los dos siguientes a la cifra a cobrar (S/ 250 y S/ 300), además de "Exacto". | 🟢 | Demo y real |
| C3 | Yape y Plin comparten un solo botón, pero el sistema los guarda como métodos distintos. Siempre se registra "Yape". | La venta queda con el método de pago equivocado. | Separar en dos opciones, o añadir un selector "Yape / Plin" dentro del panel. | 🟡 | Producto real |
| C4 | El número de operación Yape y la referencia de tarjeta ya vienen escritos. | En demo ayuda a mostrar rápido. En una tienda real, esa cifra se registraría como verdadera. | Dejarlos **vacíos con ejemplo gris (placeholder)** y no hacerlos obligatorios. | 🟡 | Producto real |
| C5 | Al activar "SUNAT en modo sin conexión" en el encabezado, el cobro sigue diciendo "Aceptado por SUNAT". | Dos mensajes contradictorios en la misma demo si se prueba el interruptor. | Si hay modo sin conexión, que el cobro diga **"Comprobante emitido. Se enviará a SUNAT al reconectar"**. Es un buen momento para mostrar que el sistema no se detiene. | 🟡 | Demo |
| C6 | Al cambiar a **Factura** se rellena automáticamente un RUC y una empresa de ejemplo. | En demo ahorra tiempo. En real, la cajera podría facturar a la empresa equivocada sin darse cuenta. | Para la demo, mantenerlo pero marcarlo con una etiqueta "Datos de ejemplo". En real, dejar vacío y **exigir RUC de 11 dígitos validado** antes de cobrar. | 🟡 | Demo y real |

### 3.3 Inventario

| # | Qué pasa | Por qué importa | Mejora propuesta | Prioridad | Aplica a |
|---|---|---|---|---|---|
| I1 | En el ajuste de stock, el motivo que aparece en pantalla puede no ser el que se guarda (el valor inicial no existe entre las opciones). | Se registraría un motivo distinto al que ve quien ajusta. | Que el motivo inicial sea la primera opción de la lista. | 🟡 | Demo y real |
| I2 | El ajuste pide el **nuevo total**, no cuántas unidades entran o salen, y ajusta el stock total de la prenda, no por talla. | La cajera tiene que hacer la cuenta mentalmente. Las boutiques manejan stock por talla y color. | Un selector **Entrada / Salida** con la cantidad, y mostrar el stock por talla dentro del mismo modal. | 🟡 | Demo y real |
| I3 | "Nuevo Producto" siempre crea las mismas dos tallas y colores (S rosa y M terracota). No se pueden elegir tallas ni colores. | Al enseñar el módulo, la dueña va a querer agregar una prenda propia. | Permitir elegir tallas (chips S, M, L, XL) y colores, y asignar stock a cada una. | 🟡 | Demo y real |
| I4 | El stock por talla solo se ve al pasar el mouse sobre la letra. | En una tablet no hay mouse. | Mostrar en la tabla "S·4  M·6  L·2" visible. | 🟡 | Producto real |
| I5 | Se llama "Historial de movimientos" pero no existe un historial de movimientos. | La palabra promete un registro que no aparece. | Agregar una pestaña o panel **Movimientos** con fecha, motivo y cantidad. Si no va a existir, usar solo "Inventario". | 🟡 | Demo |
| I6 | La tabla tiene 9 columnas, sin orden ni paginación. | Con muchas prendas será larga y difícil de recorrer. | Poder ordenar por stock y margen, y paginar. En pantallas pequeñas, mostrar tarjetas en lugar de tabla. | 🟢 | Producto real |

### 3.4 Resumen del día, Comprobantes, Clientes

| # | Qué pasa | Por qué importa | Mejora propuesta | Prioridad | Aplica a |
|---|---|---|---|---|---|
| D1 | El botón **"Reponer"** del Resumen del día suma 12 unidades en un clic, sin preguntar. | Es una acción de inventario muy fácil de pulsar sin querer. | Abrir un mini modal pidiendo cantidad (con 12 sugerido) y confirmar. | 🟡 | Demo y real |
| D2 | "Ventas del mes" y los porcentajes (+18.4 %, +24.2 %) son fijos. "Ventas del día" suma todos los comprobantes. | En demo está bien. Pero si se hace una venta y el "mes" no se mueve, se nota. | Sumar al KPI del mes la venta recién hecha, y rotular los porcentajes como "ejemplo" si no se calculan. | 🟢 | Demo |
| D3 | "Alertas de stock" cuenta también las prendas agotadas bajo la palabra "Prendas". | Mezcla dos situaciones distintas: queda poco y ya no queda. | Mostrar "3 agotadas · 5 por agotarse" en la misma tarjeta. | 🟢 | Demo |
| D4 | No hay forma de **anular** un comprobante ni emitir una nota de crédito. Todos salen "Aceptado". | En facturación real, anular y corregir es de uso diario. En una demo, la dueña casi seguro preguntará. | Para la demo, añadir un botón **"Anular"** en el detalle del comprobante con motivo. Para producto real, flujo completo de nota de crédito y estados de SUNAT (rechazado, pendiente). | 🟡 | Demo y real |
| D5 | Las tablas de Inventario, Comprobantes y Clientes no tienen mensaje cuando una búsqueda no encuentra nada. Solo el punto de venta lo tiene. | Se ve una tabla vacía sin explicación. | Un mensaje con ícono: "No encontramos resultados. Prueba con otro filtro". | 🟢 | Demo |
| D6 | En Clientes, si se deja el teléfono o el correo vacío, el sistema inventa uno. | Llena la base de datos con datos falsos. | Guardar el campo vacío y mostrar "—". | 🟡 | Producto real |
| D7 | El README promete "historial de compras" de cada clienta, pero la pantalla solo muestra el total acumulado. | Si la dueña lo pide, no hay qué mostrar. | Agregar un panel lateral al hacer clic en una clienta, con sus últimas compras (los datos ya existen en los comprobantes). | 🟡 | Demo |

### 3.5 Letra, color y accesibilidad

| # | Qué pasa | Por qué importa | Mejora propuesta | Prioridad | Aplica a |
|---|---|---|---|---|---|
| A1 | El tamaño base de la letra es 12 px y muchas etiquetas usan **10 px y 9 px** (código, stock, tallas, estados). | En una caja, con luz de tienda y a un brazo de distancia, cuesta leer. | Subir el tamaño base a **14 px** y el mínimo a **12 px**. Reservar lo más pequeño para datos secundarios. | 🔴 | Demo y real |
| A2 | El texto blanco sobre el botón terracota `#c26d60` tiene un contraste de **3.72:1** (para letra pequeña se recomienda 4.5:1). | Es el color de todos los botones importantes. Con mucho brillo de pantalla, se lee peor. | **Se mantiene el terracota original** (decisión de marca). Se compensa sin cambiarlo: letra en **negrita** de 16 px o más en los botones, el botón principal ("Cobrar") a **19 px**, y un tono más oscuro de la misma familia (`#9a4a40`) solo para **texto** de marca sobre fondo claro. Ver sección 3.8. | 🟡 | Demo y real |
| A3 | El texto gris claro sobre blanco (código, notas, marcas de ayuda) tiene **2.52:1**. | Casi desaparece. | Usar un gris más oscuro para todo texto que se deba leer. | 🔴 | Demo y real |
| A4 | Las insignias de stock tienen letra blanca sobre ámbar (**2.15:1**) y sobre verde (**3.77:1**). | Justo la información de "quedan pocas" es la que más se necesita ver. | Usar fondo claro con texto oscuro (como ya hace Inventario) o fondos más oscuros. | 🟡 | Demo y real |
| A5 | Los botones de cantidad (+ y −) miden unos 20 a 24 px. | En tablet o pantalla táctil es fácil equivocarse. | Hacerlos de **40 px** como mínimo. | 🟡 | Producto real |
| A6 | Las tarjetas de producto no se pueden usar con el teclado, y las etiquetas de los formularios no están conectadas a sus campos. | Quien usa teclado o lector de pantalla queda fuera. | Convertir la tarjeta en botón, asociar cada etiqueta a su campo y permitir cerrar los modales con **Escape**. | 🟡 | Producto real |
| A7 | Aparecen emojis (🔍 🟢 ✅ ⚡) mezclados con los íconos de línea. | Rompen la coherencia visual y se ven distinto en cada dispositivo. | Reemplazarlos por los íconos que ya usa el sistema. | 🟢 | Demo |

### 3.6 Pantallas pequeñas *(por confirmar con captura)*

| # | Qué pasa | Por qué importa | Mejora propuesta | Prioridad | Aplica a |
|---|---|---|---|---|---|
| R1 | El menú lateral tiene un ancho fijo de 256 px, sin versión plegable. | En una tablet vertical se come un tercio de la pantalla. | Menú que se pliega a solo íconos en pantallas medianas y a un botón "hamburguesa" en pequeñas. | 🟡 | Producto real |
| R2 | El punto de venta usa alturas fijas y, en pantallas más angostas, el carrito se apila debajo del catálogo. | El botón de cobrar podría quedar fuera de vista. | En pantallas pequeñas, un **botón flotante** "Ver carrito · S/ 129.00" que abra el carrito como cajón. | 🟡 | Producto real |

### 3.7 Entrada al sistema

| # | Qué pasa | Por qué importa | Mejora propuesta | Prioridad | Aplica a |
|---|---|---|---|---|---|
| E1 | Al abrir la app se entra directo al Resumen del día. La pantalla de login solo aparece si se cierra sesión. El README y el guion de la demo empiezan por el login. | Se pierde el primer paso de la presentación y el guion no coincide con lo que se ve. | Decidir una de dos cosas: que el login aparezca al abrir (alineado con el guion), o quitar el login del guion. | 🔴 | Demo |
| E2 | Al recargar la página se pierde todo lo hecho (ventas, stock, clientes nuevos). | Una recarga accidental en plena reunión rompe el hilo. | Guardar el estado en el navegador (localStorage) y ofrecer un botón **"Reiniciar demo"** escondido en el menú. | 🟡 | Demo |
| E3 | Todas las fotos vienen de Unsplash (internet). | Sin internet en la reunión, el catálogo se ve vacío. | Guardar las imágenes dentro del proyecto (carpeta `public/`) y mostrar un fondo con el nombre de la prenda si una imagen falla. | 🔴 | Demo |

---

### 3.8 Evaluación UI (parte visual) — manteniendo el terracota original

**Decisión de marca:** el color principal sigue siendo el terracota `#c26d60`. No se oscurece. Lo que se evalúa es cómo se usa.

**Base de la evaluación:** código de la app real y el demo mejorado probado en pantalla (a ancho de escritorio, tablet y móvil). La app real no se renderizó en el navegador, así que sus puntos visuales salen de leer el código.

#### Contraste del terracota (medido)

| Combinación | Contraste | Para qué sirve |
|---|---|---|
| Blanco sobre `#c26d60` | **3.72:1** | Válido para texto grande (18.7 px en negrita o más). **No llega** a 4.5:1 en letra pequeña. |
| Blanco sobre `#b05c50` (el hover original) | **4.67:1** | Cumple. |
| `#c26d60` como texto sobre blanco | 3.72:1 | Solo títulos y cifras grandes. |
| `#c26d60` como texto sobre rosa claro `#fbeeea` | 3.28:1 | No usar en letra pequeña. |
| `#9a4a40` (misma familia, más oscuro) sobre blanco | **6.13:1** | Texto de marca pequeño. |
| `#9a4a40` sobre rosa claro | **5.40:1** | Texto de marca pequeño. |

**Reglas para usar el terracota sin cambiarlo:**
1. **Rellenos** (botones, chips activos, menú activo): `#c26d60` con letra blanca en **negrita** y de **16 px o más**. El botón principal de cobro, a **19 px**.
2. **Texto de marca pequeño** (etiquetas, enlaces, estados activos sobre fondo claro): usar `#9a4a40`, no el terracota base.
3. **Cifras grandes** (el total, 28 px): se pueden dejar en `#c26d60`.
4. **Hover:** `#b05c50` (el original), que además mejora el contraste.

> **Opción B, si más adelante quieres cumplir el 4.5:1 en todos los botones:** usar `#b05c50` como color base del relleno. Es un tono de la misma familia que ya existe en el sistema. Es tu decisión de marca; el demo usa la opción A (terracota intacto).

#### Evaluación por aspecto visual

| Aspecto | Veredicto | Qué se observa | Mejora propuesta | Prioridad |
|---|---|---|---|---|
| **Identidad y paleta** | ✅ Fuerte | Terracota, crema y piedra dan un aire de boutique. Cada color tiene un rol claro: terracota = acción, verde = ok, ámbar = atención, rojo = agotado. | Mantener. Documentar estos roles como guía de estilo. | — |
| **Jerarquía visual** | ✅ Buena | Los precios y totales (tipografía con serifa) se leen primero. El botón "Cobrar" destaca como acción principal. | En el demo, el botón muestra el monto ("Cobrar S/ 124.00") para que el total y la acción vayan juntos. | 🟡 |
| **Tipografía** | ⚠️ Mejorable | Combinar serifa (títulos y cifras) con sans (datos) funciona. Pero la app real usa mucho 12 px, 10 px y 9 px. | Base de **14 px**, mínimo de **12 px**. | 🔴 |
| **Espaciado y densidad** | ⚠️ Mejorable | Los bloques de datos (tablas, tarjetas) respiran bien. El panel del carrito apila 5 bloques y la lista de prendas queda pequeña. | Plegar los datos del cliente (ya hecho en el demo) y dar altura mínima a la lista. | 🟡 |
| **Botones** | ⚠️ Mejorable | Bien diferenciados (primario terracota, secundario gris, oscuro para acciones de apoyo). Dos acentos compiten: terracota y negro. En la app real, varios botones son de menos de 30 px de alto. | Alto mínimo de **44 px** en cobro y **36 px** en acciones secundarias. Reservar el negro solo para acciones de apoyo (como "Simular escáner"). | 🟡 |
| **Chips y filtros** | ✅ Buenos | Claros y consistentes. El estado activo se ve bien. | En el demo, el activo va en negrita. Evitar que el texto se parta en dos líneas (`nowrap`). | 🟢 |
| **Tarjetas de producto** | ✅ Buenas | Foto grande, nombre, precio y estado de stock a simple vista. | Texto de las insignias con mejor contraste (fondo claro y texto oscuro). Si la foto falla, mostrar un bloque de color con iniciales (hecho en el demo). | 🟡 |
| **Tablas** | ✅ Buenas | Filas cómodas y estados con color más texto. Los encabezados en 10 px, en mayúsculas. | Encabezados a 12 px. En pantallas pequeñas, pasar de tabla a tarjetas. | 🟢 |
| **Modales** | ⚠️ Mejorable | Buena jerarquía interna. Sin cierre con Escape ni al hacer clic fuera. En pantallas bajas el contenido puede cortarse. | Cierre con Escape y clic fuera, máximo `92vh` con scroll interno (hecho en el demo). | 🟡 |
| **Íconos y emojis** | ⚠️ Mejorable | Los íconos de línea son coherentes. Hay emojis sueltos (🔍 🟢 ✅). | Usar solo íconos de línea. | 🟢 |
| **Colores de métodos de pago** | ✅ Aceptable | Yape (morado) y tarjeta (azul) añaden tonos ajenos a la paleta, pero ayudan a reconocer cada medio. | Mantenerlos solo dentro del modal de pago, y no usarlos en otras partes. | — |
| **Encabezado** | ⚠️ Mejorable | Está cargado: nombre, etiqueta "punto de venta Boutique", sucursal, reloj, SUNAT, pantalla completa, avatar y salir. | Quitar la etiqueta "punto de venta Boutique" y agrupar reloj y pantalla completa. Mostrar la caja solo en pantallas anchas. | 🟢 |
| **Menú lateral** | ⚠️ Mejorable | La tarjeta de "Datos fiscales" y el texto "Versión 2.4.0 (Enterprise)" ocupan espacio de poco valor para quien cobra. | Mover los datos fiscales a un menú de perfil y eliminar textos de relleno. | 🟢 |
| **Estados interactivos** | ⚠️ Mejorable | Hay hover, deshabilitado y vacío bien resueltos. Parte del feedback depende solo del mouse (`hover`, tooltips). El foco del teclado casi no se ve. | Anillo de foco visible (azul de 3 px) y no depender del hover. | 🟡 |
| **Avisos (toasts)** | ⚠️ Mejorable | Aparecen abajo a la derecha y pueden tapar el total o el botón de cobrar. | Subirlos cuando haya botón flotante, y en el cajón del carrito mostrarlos arriba (hecho en el demo). | 🟡 |
| **Login** | ✅ Buena | Foto de moda a un lado y formulario limpio al otro. | Comprobar que el texto blanco sobre la foto se lea con cualquier imagen. | 🟢 |

#### Problemas visuales que apareció al probar el demo (ya corregidos)

Al revisar el demo en pantalla, aparecieron fallos que **no se veían en el código** y que sirven como ejemplo de por qué conviene validar visualmente:

| Fallo | Dónde | Cómo se corrigió |
|---|---|---|
| El encabezado se cortaba: el nombre se partía en dos líneas y la píldora de SUNAT quedaba recortada. | Ancho de tablet | Texto en una sola línea y ocultar la sucursal en pantallas medianas. |
| La barra flotante del demo tapaba el botón "Ver venta". | Ancho de tablet | Separarlas en vertical y ocultar la barra con el carrito abierto. |
| El carrito abierto dejaba el botón "Cobrar" fuera de pantalla en ventanas bajas. | Tablet y móvil | El panel hace scroll y el bloque del total queda fijo abajo. |
| Los avisos cubrían los totales del carrito. | Carrito abierto | En ese caso se muestran arriba. |

> Este último caso refuerza la mejora **R2** (carrito en cajón con botón de cobro siempre visible). Es el punto más delicado de pantallas pequeñas.

---

## 4. Plan de mejoras

**Fase 1 — Antes de presentar la demo** (rápido, mucho impacto)
1. C1 · Cobro en efectivo con el total ya propuesto.
2. P1 · Reordenar el resumen de totales.
3. E1 · Alinear login y guion.
4. E3 · Imágenes locales.
5. A1 a A3 · Letra más grande y colores con mejor contraste.

**Fase 2 — Pulido de la demo** (mejora lo que se ve y se pregunta)
P2, P3, P6, C5, C6, D1, D4, D7, I1, I3, I5, E2.

**Fase 3 — Si pasa a producto real**
P4, P5, C3, C4, D6, A4 a A6, R1, R2, I2, I4, I6, anulación y estados de SUNAT completos.

---

## 5. Qué ya se resolvió bien (para destacar en el portafolio)

- **Jerarquía visual:** los precios y totales se leen primero gracias a la tipografía con serifa.
- **Flujo de cobro con feedback:** el usuario siempre sabe en qué paso está.
- **Estados de stock con color y texto:** no depende solo del color.
- **Voz y vocabulario peruano** coherentes en todo el sistema.
- **Estructura repetible:** cada módulo usa el mismo patrón de cabecera, indicadores y tabla, así que aprender uno enseña los demás.

---

## 6. Qué falta validar

1. **Confirmar en el navegador** los hallazgos marcados "por confirmar": C1 (cobro en efectivo), P5 (escáner), R1 y R2 (pantallas pequeñas).
2. **Capturas** de antes y después para el portafolio. Las pantallas recomendadas están en la lista de capturas que se acordó en el chat.
3. **Prueba con 3 a 5 personas** (dueñas o cajeras de boutiques) en tres tareas: vender 2 prendas y cobrar con vuelto, emitir una factura a una empresa y reponer una prenda agotada. Medir si lo logran, cuánto tardan y cuántos errores cometen.
4. **Revisión de accesibilidad** con una herramienta automática (Lighthouse o axe).

> **Nota de honestidad para el portafolio:** distingue qué hallazgos salen de revisar el diseño y cuáles se comprobaron con personas. Mostrar ambos tipos por separado da más credibilidad.
