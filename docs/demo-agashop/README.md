# AgaShop · Demo mobile first

Archivo: [`index.html`](index.html). Se abre con doble clic y no necesita instalar nada. Las tipografías (Anton e Inter) se descargan si hay internet; sin internet usa unas parecidas del sistema y todo sigue funcionando.

```bash
start docs/demo-agashop/index.html
```

**Es un demo con datos de ejemplo.** Sigue la estructura de las 31 tablas de la base, pero no se conecta a ella: la base de Neon está vacía y no se escribió nada en ella. Lo que haces en el demo se guarda en tu navegador. En la cuenta (arriba a la derecha) puedes reiniciarlo.

## Cómo probarlo

1. Elige con quién entrar: **Cajero/a**, **Supervisor/a** o **Administrador/a**.
2. Como cajera, abre la caja. Sin caja abierta no se puede vender.
3. En **Vender**, busca una prenda o escribe un código y pulsa Enter. Ejemplo: `VES-001-TER-M`.
4. Prueba cosas que piden la **clave del supervisor** (clave de ejemplo: `1234`): descuento mayor al 10 %, ajustar stock, anular, devolver fuera de plazo, registrar una compra.
5. En la cuenta, cambia el rol para ver qué cambia. También puedes simular que **SUNAT no responde**.

## Qué incluye

| Sección | Qué puedes hacer |
|---|---|
| **Inicio** | Estado de tu caja, ventas del día y lo que necesita atención (comprobantes, tallas por reponer, pedidos atrasados) |
| **Vender** | Buscar o escanear, elegir talla y color con el stock de cada una, descuento, cliente, boleta o factura, envío, venta en espera |
| **Cobro** | Efectivo con vuelto, Yape, Plin, tarjeta y **pago mixto** (el segundo medio completa lo que falta solo) |
| **Pedidos** | Estados, verificar prendas, courier y guía, entrega fallida, contra entrega, cancelar |
| **Inventario** | Stock por talla con semáforo, ajustes de entrada y salida con motivo, prenda nueva |
| **Más › Caja** | Movimientos de efectivo, conteo por billetes, diferencia y cierre |
| **Más › Comprobantes** | Reenviar, corregir un comprobante no aceptado, devolver, cambiar de prenda y anular |
| **Más › Clientes** | Buscar, registrar con validación de ejemplo, ver sus compras |
| **Más › Compras** | Recibir mercadería, con control de duplicados y de total |
| **Más › Historial de movimientos** | Qué pasó con el stock de cada talla, y si coincide con el stock actual |
| **Más › Tienda** | Qué hay configurado y el equipo |

## Sistema de diseño

**Estilo: negro, crema y lima.** Paneles que alternan oscuro y claro, titulares condensados en mayúsculas con la frase clave en lima, botones lima con texto negro y una barra de navegación negra. Sin degradados y con esquinas suaves (máximo 10 %).

**Tipografía:** Bebas Neue para titulares, números y totales; Inter para el texto. Sin internet se usan Anton o Impact como respaldo.

**Paleta:**

| Color | Uso |
|---|---|
| `#0b0c09` negro | Cabecera, paneles oscuros, menú, texto y botones secundarios |
| `#f2f0e8` crema | Fondo de la app y de las ventanas |
| `#c4ec2c` lima | Acción principal, frase clave de cada titular, elemento activo, selección y totales sobre negro |
| `#e7e4d8` crema oscuro | Fondos de apoyo, selección al pasar el mouse |
| `#8b8d84` gris | Solo sobre fondo negro (etiquetas del menú) |

El lima nunca se usa como texto sobre fondo claro (da 1.2:1): sobre crema va como resaltado con letra negra. Negro sobre lima da 14.4:1.

Cada sección tiene su panel de titular: oscuro (Inicio, Vender, Inventario, Comprobantes, Compras y Tienda) o claro con la frase resaltada en lima (Pedidos, Más, Caja, Clientes e Historial).

Tonos derivados: texto secundario `#4b4d73` (6:1 sobre el fondo) y borde de campos `#7c8094` (3.9:1). Los avisos de verde, ámbar y rojo no están en tu paleta: se agregaron porque el stock y los errores necesitan significar algo distinto. Siempre van con texto, nunca solo color.

**Tres modos de pantalla (se parte del teléfono y se agrega espacio):**

| Modo | Desde | Cómo cambia |
|---|---|---|
| **Teléfono** | 0 px (diseñado para 375 px) | Una columna, 5 secciones en la barra de abajo, ventanas que suben desde abajo, la venta en una hoja con barra azul flotante |
| **Tablet** | 768 px | Listas en 2 columnas, ventanas centradas, barra inferior más amplia, contenido con ancho máximo |
| **Escritorio** | 1024 px | **Menú lateral** con las 10 secciones (Caja, Comprobantes, Clientes, Compras, Historial y Tienda ya no se esconden en "Más"), catálogo en 2 o 3 columnas y **la venta siempre visible a la derecha** |

Al cambiar el tamaño de la ventana, la pantalla se adapta sin perder lo que estabas haciendo.

**Reglas mobile first:**
- Se diseñó primero para 375 px de ancho.
- Todo lo que se toca mide **44 px o más**.
- **Se adapta al espacio disponible, no solo a tres tamaños**: las listas calculan cuántas columnas caben (nunca más angostas de 330 px), así que ningún texto se pisa, desde 320 px hasta 1920 px.
- **Un solo scroll por pantalla**: en escritorio el menú lateral y la cabecera quedan quietos y solo se mueve el contenido. Los scrolls son finos y planos; el menú lateral no muestra scroll.
- Los botones de cobro quedan pegados abajo, sin dejar ver contenido por detrás.
- **Esquinas suaves, nunca más del 10 %**: ningún elemento supera el 10 % de redondeo respecto de su alto (botones 5 px, tarjetas 6 a 10 px, ventanas 12 px). Solo se redondean botones, campos, tarjetas, indicadores, miniaturas y ventanas; las filas de lista, las barras y los bloques de cabecera quedan rectos.
- **Ventanas con scroll solo en el contenido**: la cabecera queda fija y el scroll es fino, transparente y redondeado.
- Navegación con **5 secciones abajo**; lo menos frecuente está en Más.
- Las acciones secundarias se abren en **hojas desde abajo**, no en pantallas nuevas.
- El botón principal (**Cobrar S/ 152.10**) siempre queda fijo abajo, a la vista.
- Los errores se explican con lo que se puede hacer; las acciones borrables se pueden **deshacer**.
- Respeta `prefers-reduced-motion` y se puede usar con teclado (Escape cierra las hojas).

## Qué no incluye (a propósito)

Packs promocionales, toma de inventario físico, relevo de caja entre dos personas, edición de la configuración y reportes por periodo. Los datos de la base están preparados para todo eso; se pueden sumar después.


## Controles con diseño propio

Ningún control usa el aspecto nativo del navegador:

- **Pestañas** de texto con separadores finos; la activa va en negrita con una línea lima debajo.
- **Selector**: lista propia que se abre sobre la ventana, con teclado (flechas, Inicio, Fin, Enter, Escape y búsqueda por letra) y marca de la opción elegida.
- **Calendario** propio con mes, navegación, botón Hoy y flechas del teclado.
- **Búsqueda** con botón para borrar.
- **Casilla** propia, **campos** sin flechas de número y **botones** con estado al pasar, al presionar y al enfocar; los principales de ancho completo llevan flecha.
