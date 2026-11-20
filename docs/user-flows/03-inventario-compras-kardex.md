# 03 · Inventario, compras y historial de movimientos

Volver al [índice](00-indice-roles-y-decisiones.md).

**Idea central:** una prenda (`producto`) tiene varias **tallas y colores** (talla × color × marca). El **stock** está en la talla y color **y** por sede. Todo cambio de stock deja un movimiento en el historial de movimientos.

---

## C1 · Crear un producto con tallas y colores

**Rol:** SUP, ADM

**Flujo principal**

| # | La persona | El sistema |
|---|---|---|
| 1 | Inventario → **Nuevo producto** | Formulario en 3 pasos: Datos, Tallas y colores, Revisión |
| 2 | **Datos:** nombre (hasta 100), código base, categoría, descripción | Sugiere un código base automático (editable). Categoría como árbol con búsqueda |
| 3 | **Tallas y colores:** elige tallas y colores (chips) | Genera la **tabla de tallas y colores**. Se pueden quitar combinaciones que no existen |
| 4 | Completa **precio, costo, stock inicial y stock mínimo** | Botones "Aplicar a todas" por columna. Muestra el margen por talla y color |
| 5 | **Revisión** | Resumen: "6 tallas y colores · stock total 24 · margen 52 %" |
| 6 | **Guardar** | Crea producto, tallas y colores y stock de esta sede. Registra el stock inicial en el historial de movimientos |
| 7 | — | Ofrece **Imprimir etiquetas**, **Crear otro igual** o **Ir al inventario** |

**Excepciones**

| # | Situación | Resultado |
|---|---|---|
| E1 | código base repetido | "Ya existe. ¿Usar VES-002?" |
| E2 | código de cada talla y color repetido | Se marca la fila exacta con el conflicto |
| E3 | La talla o el color no existen | **+ Crear "XL"** en línea (C4) |
| E4 | Precio menor que el costo | Aviso de margen negativo, requiere confirmar |
| E5 | Precio o costo en 0 | Bloquea el guardado |
| E6 | Producto sin talla ni color (un collar) | Opción **Sin tallas y colores**: crea una sola talla y color sin talla ni color |
| E7 | Más de 50 combinaciones | Aviso "¿Seguro? Se crearán 64 tallas y colores" |
| E8 | Nombre igual a otro producto con otro código | Aviso "Ya existe un producto con ese nombre" |
| E9 | Sale sin guardar | Confirmación y borrador guardado (REG-02) |
| E10 | Categoría inexistente | Crear categoría en línea (C3) |
| E11 | Sin conexión | Se mantiene el borrador. "Guardar cuando haya conexión" |

**Casos extraños**

- **X1 · Producto outlet con el mismo diseño y otro precio:** una talla y color tiene un solo precio. Se guía a crear un producto nuevo "… (Outlet)".
- **X2 · Una talla con 6 colores y otra con 1:** la tabla de tallas y colores permite quitar celdas.
- **X3 · Prenda con dos marcas:** la marca es de la talla y color. Se permite elegirla por talla y color.
- **X4 · Se necesita "Duplicar producto":** copia datos y tallas y colores, y pide un nuevo código base.

---

## C2 · Editar un producto o una talla y color

**Rol:** SUP, ADM

| Cambio | Regla |
|---|---|
| Precio | Aplica a ventas nuevas. Si hay carritos abiertos en otras cajas, al cobrar se revalida y avisa "El precio cambió de S/ 129 a S/ 119" (REG-16) |
| Costo | Solo afecta márgenes futuros |
| Nombre, descripción, categoría | Libre, con aviso del alcance |
| Talla o color de una talla y color con ventas | **Bloqueado**: cambiaría la historia. Se guía a crear una talla y color nueva |
| código de cada talla y color con ventas | Bloqueado con la misma explicación |
| Desactivar producto | Desaparece del punto de venta. Sigue en el historial. No se puede desactivar con stock sin aviso |
| Descontinuar una sola talla y color | No existe estado por talla y color (DEC-26): se deja el stock en 0 y se oculta con el filtro "Ocultar agotados" |

**Excepciones**

| # | Situación | Resultado |
|---|---|---|
| E1 | Dos personas editan el mismo producto | La segunda ve "Este producto cambió hace un momento. [Ver cambios] [Sobrescribir]" |
| E2 | Precio con céntimos raros | Sugerencia de redondeo, no obligatoria |
| E3 | Editar producto desactivado | Permitido, con etiqueta "Desactivado" visible |

**X1 · Cambio masivo de precios** (por categoría o por porcentaje): asistente con **vista previa** antes y después de cada precio y confirmación explícita. No se puede deshacer, pero se muestra una lista descargable de lo cambiado.

---

## C3 · Gestión de categorías

**Rol:** ADM, SUP

Árbol de categorías por sede (una categoría puede tener padre).

| Acción | Regla |
|---|---|
| Crear y subcategorías | Profundidad recomendada: máximo 3 |
| Mover | Arrastrar o botón **Mover a…** |
| Desactivar | Si tiene productos: "N productos usan esta categoría. Elige a dónde moverlos" |

**Excepciones:** nombre repetido dentro del mismo padre; mover una categoría dentro de sus propios hijos (se bloquea con "No puedes mover una categoría dentro de sí misma"); producto sin categoría (aparece como "Sin categoría" con alerta de limpieza).

---

## C4 · Marcas, tallas y colores

**Rol:** SUP, ADM

| Situación | Regla |
|---|---|
| Crear desde cualquier selector | Botón **+ Crear "…"** sin salir de la pantalla |
| Duplicados | "m" y "M" son el mismo valor. Muestra "Ya existe 'M'" |
| Orden de tallas | La interfaz usa un orden lógico (DEC-15). Si la talla es nueva, se pregunta dónde va |
| Renombrar | Aviso "Se verá cambiado en N productos" |
| Eliminar | No se elimina si está en uso (DEC-16) |

**X1 · Se crean "Rojo", "rojo" y "Rojo "** por error: el sistema normaliza espacios y mayúsculas y ofrece **fusionar** (se avisa del número de tallas y colores afectadas).

---

## C5 · Consultar el stock

**Rol:** todos (CAJ solo lectura), SUP/ADM para otras sedes

**Vista principal:** lista de productos con el stock total y el estado (semáforo contra el stock mínimo). Al abrir un producto aparece la **tabla de tallas y colores** con las cantidades.

| Estado | Condición | Presentación |
|---|---|---|
| Disponible | Stock mayor al mínimo | Verde, ícono ✔ |
| Stock bajo | Stock mayor a 0 y menor o igual al mínimo | Ámbar, ícono ⚠, texto "Quedan N" |
| Agotado | Stock en 0 | Rojo, ícono ✖ |
| No habilitado | La talla y color no tiene fila de stock en esta sede | Gris "No habilitado aquí" con **Habilitar** |

**Filtros:** categoría, marca, estado, búsqueda por nombre o código.

**Excepciones**

| # | Situación | Resultado |
|---|---|---|
| E1 | Stock negativo en pantalla | Se resalta en rojo con "Revisar" y enlace al historial de movimientos |
| E2 | Stock mínimo en 0 | Sin alerta. Se muestra "Sin alerta" |
| E3 | Producto sin tallas y colores habilitadas | Estado "No habilitado" con el botón |
| E4 | SUP/ADM consultando otra sede | Selector de sede visible. Datos en solo lectura |
| E5 | Lista muy larga | Carga progresiva y búsqueda siempre visible |

**X1 · Cliente pregunta por una talla que no hay:** desde el punto de venta, SUP/CAJ puede consultar "Disponible en otras sedes" (solo informativo, no reserva ni traslada: DEC-12).

---

## C6 · Ajuste de stock

**Rol:** SUP, ADM

**Flujo principal**

| # | La persona | El sistema |
|---|---|---|
| 1 | Inventario → **Ajustar stock** (o botón en una talla y color) | Pide buscar o escanear la talla y color |
| 2 | Elige **Entrada** o **Salida** | Cambia la lista de motivos |
| 3 | Escribe la **cantidad** | Muestra "Pasará de 5 a 8 unidades" |
| 4 | Elige el **motivo** | Lista abajo |
| 5 | (Opcional) nota | — |
| 6 | **Guardar** | Actualiza el stock y crea el movimiento en el historial de movimientos |

**Motivos**

| Tipo | Motivos |
|---|---|
| Entrada | Devolución de cliente, hallazgo en conteo, corrección de error |
| Salida | Prenda dañada o perdida, robo o pérdida, muestra o regalo, corrección de conteo |
| Redirigidos | "Ingreso de proveedor" lleva a **Compras** (D1) para no perder el costo. "Traslado a otra sede" explica la regla de DEC-12 |

**Excepciones**

| # | Situación | Resultado |
|---|---|---|
| E1 | Salida mayor al stock | Bloqueada: "Solo hay 2". SUP puede forzar con clave y motivo |
| E2 | Cantidad 0 o vacía | Error junto al campo |
| E3 | Alguien vendió la talla y color mientras se ajustaba | "El stock cambió: ahora son 4. ¿Recalcular?" (REG-16) |
| E4 | Doble clic | Un solo movimiento |
| E5 | Talla y color no habilitada en la sede | Pide **Habilitar** primero |
| E6 | Motivo sin elegir | Error junto al campo |
| E7 | Entrada sin costo conocido | Aviso "Este movimiento no tiene costo" |

**X1 · Ajustar una talla y color que ya tiene stock negativo:** se muestra el valor real y se guía a un ajuste de corrección con motivo.
**X2 · Muchas tallas y colores a la vez:** se redirige a **Toma de inventario** (C7).

---

## C7 · Toma de inventario físico

**Rol:** SUP, ADM

**Flujo principal**

| # | La persona | El sistema |
|---|---|---|
| 1 | Inventario → **Contar** | Pide el alcance: toda la tienda, una categoría o una zona |
| 2 | Escanea o busca cada prenda | Suma 1 por escaneo. Muestra el contador de cada talla y color |
| 3 | Pausa o continúa | Guarda el progreso en el dispositivo |
| 4 | **Terminar conteo** | Compara lo contado con el sistema y muestra la lista de **diferencias** |
| 5 | Revisa cada diferencia y confirma o corrige | Muestra "Ventas durante el conteo: −2" para no culpar al conteo |
| 6 | **Aplicar ajustes** | Crea los movimientos "Corrección de conteo" |

**Excepciones**

| # | Situación | Resultado |
|---|---|---|
| E1 | Se vendió algo durante el conteo | El esperado se ajusta con los movimientos posteriores al inicio |
| E2 | Tallas y colores del alcance sin contar | "12 tallas y colores no se contaron. ¿Contarlas como 0 o excluirlas?" |
| E3 | Código desconocido | "No existe. ¿Buscarla por nombre?". Solo con permiso, puede crearse (C1) |
| E4 | Dos personas contando zonas distintas | Cada una guarda su parte. Se combinan al terminar. Si se pisan, se pide resolver |
| E5 | El dispositivo se apaga | Al volver: "Continuar conteo del 18/11" |
| E6 | Muchas diferencias grandes | Aviso "El 40 % no coincide. ¿Revisar antes de aplicar?" |

**X1 · Prenda sin etiqueta:** búsqueda por nombre con foto (si existe) o color. **X2 · El conteo se abandona dos días:** aviso de que el esperado ya cambió bastante, con opción de reiniciar.

---

## C8 · Packs (combos)

**Rol:** SUP, ADM

**Crear:** nombre, componentes (tallas y colores concretas y cantidad), precio promocional. La pantalla muestra "Suma regular S/ 237 · Pack S/ 199 · Ahorro S/ 38".
**Disponibilidad:** el pack está disponible mientras **todas** las tallas y colores tengan stock. Se calcula la cantidad máxima posible.

**Excepciones**

| # | Situación | Resultado |
|---|---|---|
| E1 | Un componente se agota | El pack aparece **No disponible**, con el componente que falta |
| E2 | Precio promocional mayor a la suma regular | Aviso "El pack cuesta más que comprar por separado" |
| E3 | Editar componentes con el pack en un carrito | El carrito avisa al cobrar |
| E4 | Desactivar el pack | Desaparece del punto de venta, el historial se conserva |
| E5 | Pack con talla a elegir | El modelo fija la talla y color. Para ofrecer tallas hay que crear varios packs (explicado en pantalla) |

**X1 · Pack con una prenda en oferta aparte:** se avisa que descuentos y packs no se acumulan (G3).

---

## C9 · Alertas de stock mínimo y reposición

**Rol:** SUP, ADM

Bandeja **Por reponer** (también en el resumen del día): tallas y colores con stock menor o igual al mínimo.

| Elemento | Detalle |
|---|---|
| Orden | Agotados primero, luego por menor cobertura |
| Sugerencia | Cantidad a pedir (propuesta: el doble del mínimo menos el stock actual) |
| Acción | Seleccionar varias y **Crear compra** (D1) prellenada |
| Posponer | "No avisar por 7 días" |

**Excepciones:** stock mínimo en 0 no genera alerta; talla y color descontinuada se oculta con **No volver a avisar**; el aviso no se repite cada día si ya se creó una compra.

---

## D1 · Registrar una compra (ingreso de mercadería)

**Rol:** SUP, ADM

**Flujo principal**

| # | La persona | El sistema |
|---|---|---|
| 1 | Compras → **Nueva compra** | Formulario de documento del proveedor |
| 2 | Escribe el **RUC** del proveedor | Valida 11 dígitos y completa el nombre desde el historial. Si es nuevo, intenta consultar |
| 3 | Elige el **tipo de comprobante**, **serie**, **número** y **fecha de emisión** | Avisa si ya existe esa combinación (E1) |
| 4 | Agrega **ítems**: escanea o busca la talla y color, o usa el **modo tabla de tallas y colores** para ingresar varias tallas y colores a la vez | Cada fila muestra cantidad y **costo unitario** prellenado con el último costo |
| 5 | Revisa los **totales** | Subtotal, IGV y total calculados. Campo **Total del documento** para comparar |
| 6 | **Registrar compra** | Suma stock, crea los registro en el historial "Compra" y guarda el documento |
| 7 | — | Pregunta "El costo cambió en 3 tallas y colores. ¿Actualizar costo? ¿Revisar precios de venta?" con el nuevo margen |
| 8 | — | Ofrece **Imprimir etiquetas** |

**Excepciones**

| # | Situación | Resultado |
|---|---|---|
| E1 | Mismo proveedor, serie y número ya registrados | Bloquea con enlace a la compra existente |
| E2 | Fecha futura | Bloqueada |
| E3 | Fecha de hace más de 60 días | Aviso "¿Es correcta?" (propuesta) |
| E4 | RUC inválido | Error junto al campo |
| E5 | El nombre del proveedor difiere del histórico | Aviso con ambas versiones |
| E6 | El total no coincide con el del documento | Muestra la diferencia y no deja registrar hasta explicar o corregir |
| E7 | Costo en 0 o cantidad en 0 | Error en la fila |
| E8 | El mismo ítem agregado dos veces | Se suma en una sola fila |
| E9 | Proveedor sin comprobante formal | La serie y el número son obligatorios en el modelo. Se guía a usar un tipo "Nota de compra" con un número interno (pregunta abierta, archivo 07) |
| E10 | Llegó menos de lo facturado | Se registra lo recibido y se anota la diferencia en el comentario |
| E11 | Se corta la conexión al registrar | Se conserva el borrador. Aviso "No se registró. [Reintentar]" y se verifica antes de repetir (REG-11) |
| E12 | Proveedor exonerado (IGV 0) | Permite IGV en 0 con un aviso |

**Casos extraños**

- **X1 · Compra con producto que aún no existe:** ver D3.
- **X2 · Devolución a proveedor:** no hay documento. Se registra como ajuste de **Salida** con el motivo "Devolución a proveedor" (C6).
- **X3 · Fletes o gastos extra de la compra:** no tienen campo. Se anotan en el comentario y no afectan el costo.
- **X4 · Compra a otra sede por error:** se corrige con D2.
- **X5 · Cientos de tallas y colores:** el **modo tabla de tallas y colores** y el borrador evitan empezar de nuevo.

---

## D2 · Corregir o anular una compra

**Rol:** SUP, ADM

No existe estado de anulación en la compra (DEC-17). La experiencia ofrece dos caminos:

| Caso | Camino |
|---|---|
| Mismo día y sin ventas de esa mercadería | **Corregir compra**: se editan cantidades y costos. Se generan movimientos contrarios y nuevos |
| Ya se vendió parte | Bloquea la edición. Muestra por talla y color "Ingresaron 5, ya se vendieron 3". Ofrece **ajuste de salida** solo por lo que queda |

**Excepciones:** la corrección dejaría stock negativo (se bloquea la talla y color afectada); persona sin permiso (solo SUP/ADM); compra de otra sede (solo desde esa sede).

---

## D3 · Alta rápida de producto desde una compra

**Rol:** SUP, ADM

Mini formulario dentro de la compra: nombre, categoría, tabla de tallas y colores de tallas y colores, costo y precio. Al guardar, **vuelve a la compra con las tallas y colores ya agregadas** y la cantidad pendiente de completar.
**Excepciones:** código repetido, categoría inexistente (se crea en línea), cancelar a la mitad (se descarta lo creado solo si no se guardó).

---

## E1 · Consultar el historial de movimientos de una talla y color

**Rol:** CAJ (lectura), SUP, ADM

**Vista:** línea de tiempo con columnas **Fecha y hora · Tipo · Documento · Entrada · Salida · Saldo · Registrado por***.

| Tipo de movimiento | Etiqueta | Origen |
|---|---|---|
| Compra | ↑ Compra | Documento de compra |
| Venta | ↓ Venta | Comprobante de la venta |
| Devolución de cliente | ↑ Devolución | Nota de crédito |
| Anulación | ↑ Anulación | Comprobante anulado |
| Ajuste de entrada o salida | ↕ Ajuste | Motivo |
| Prenda dañada | ↓ Prenda dañada | Motivo |
| Conteo | ↕ Conteo | Sesión de conteo |
| Stock inicial | ↑ Inicial | Alta del producto |

\* **Registrado por** depende de que el modelo lo guarde (DEC-11). Si no existe, la columna se omite y se documenta como pendiente.

**Funciones:** filtros por fecha, tipo y sede; saldo inicial del rango; clic en el documento para abrir la venta o la compra; **chip de coherencia** "Saldo del historial de movimientos = stock actual ✔" o "Diferencia de 2 unidades. [Revisar]".

**Excepciones**

| # | Situación | Resultado |
|---|---|---|
| E1 | Sin movimientos | "Esta talla y color aún no tiene movimientos" |
| E2 | Talla y color no habilitada en la sede | "No habilitada en esta sede" |
| E3 | Documento referenciado que no se puede abrir | Etiqueta "Documento no disponible" |
| E4 | Rango de fechas muy grande | Paginación y carga progresiva |
| E5 | El saldo del historial de movimientos no coincide con el stock actual | Chip de alerta y guía hacia un ajuste de corrección con motivo |
| E6 | Tipo de movimiento desconocido | Etiqueta genérica con el texto original |

**Casos extraños**

- **X1 · Dos movimientos casi al mismo tiempo:** se ordenan por registro. Si empatan, por un criterio estable para no mover filas al refrescar.
- **X2 · Compra con fecha antigua:** el historial de movimientos muestra el **orden de registro**. El documento muestra su fecha de emisión aparte.
- **X3 · Stock negativo histórico:** se muestra el saldo tal cual con ícono de alerta.

---

## E2 · "¿Qué movió esta venta o compra?"

Desde el detalle de una venta, una compra o una nota de crédito, un bloque **Movimientos de stock** lista las tallas y colores afectadas y sus cantidades. Sirve para entender una devolución o un ajuste sin ir al historial de movimientos.

## E3 · Exportar el historial de movimientos

Botón **Exportar** (hoja de cálculo y PDF) respeta los filtros actuales y encabeza con sede, rango y fecha de emisión. Excepción: rangos enormes, se generan en segundo plano con aviso al terminar.
