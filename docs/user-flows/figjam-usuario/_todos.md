# AgaShop · Flujos de usuario (Mermaid)

## U1 · Quiero empezar a vender

```mermaid
flowchart TD
  T(("Llega y empieza su turno")):::disp --> P1["Inicio de sesión"]:::pant
  P1 -->|"Escribe usuario y contraseña"| D0{"¿Quedó una caja abierta de ayer?"}:::dec
  D0 -->|"Sí"| R1["Cerrar la caja de ayer<br/>antes de continuar"]:::rec
  R1 --> P2
  D0 -->|"No"| P2["Abrir caja<br/>caja y turno ya sugeridos"]:::pant
  P2 -->|"Confirma o cambia la caja"| P3["Dinero para vuelto"]:::pant
  P3 --> D1{"¿El dinero para vuelto es el que dejó<br/>el turno anterior?"}:::dec
  D1 -->|"Sí"| OK(["Caja abierta, lista para vender"]):::logro
  D1 -->|"No"| P4["Escribe el motivo de la diferencia"]:::pant
  P4 --> OK
classDef disp fill:#292524,stroke:#292524,color:#ffffff,stroke-width:1.5px;
classDef pant fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef dec fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef sup fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
classDef rec fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef logro fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
```

## U2 · Una clienta quiere comprar

```mermaid
flowchart TD
  T(("Una clienta llega con prendas")):::disp --> P1["Punto de venta<br/>busca o escanea la prenda"]:::pant
  P1 --> D1{"¿La prenda tiene varias<br/>tallas o colores?"}:::dec
  D1 -->|"Sí"| P2["Elige talla y color<br/>solo ve lo disponible"]:::pant
  P2 --> P3
  D1 -->|"No"| P3["Venta actual<br/>revisa prendas y total"]:::pant
  P3 --> D2{"¿La clienta quiere factura?"}:::dec
  D2 -->|"Sí"| P4["Busca a la empresa por RUC"]:::pant
  P4 --> D3
  D2 -->|"No"| D3{"¿Le hace un descuento?"}:::dec
  D3 -->|"Más de su límite"| S1["Su supervisor autoriza con clave"]:::sup
  S1 --> P5
  D3 -->|"No, o dentro de su límite"| P5["Cobro<br/>elige cómo paga la clienta"]:::pant
  P5 --> D4{"¿Paga con un solo medio?"}:::dec
  D4 -->|"No"| P6["Divide el pago<br/>el sistema dice cuánto falta"]:::pant
  P6 --> P7
  D4 -->|"Sí"| P7["Confirmar"]:::pant
  P7 -->|"Algo falla"| R1["Mensaje claro<br/>la venta no se pierde"]:::rec
  R1 --> P5
  P7 --> OK(["Entrega el ticket y despide a la clienta"]):::logro
classDef disp fill:#292524,stroke:#292524,color:#ffffff,stroke-width:1.5px;
classDef pant fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef dec fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef sup fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
classDef rec fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef logro fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
```

## U3 · Una clienta quiere cambiar o devolver

```mermaid
flowchart TD
  T(("Una clienta vuelve con una prenda")):::disp --> P1["Devoluciones<br/>busca la compra con ticket, QR o DNI"]:::pant
  P1 --> D1{"¿Se encuentra la compra?"}:::dec
  D1 -->|"No"| S1["Su supervisor decide:<br/>solo cambio por otra prenda, sin dinero"]:::sup
  S1 --> OK2(["Cambio resuelto"]):::logro
  D1 -->|"Sí"| D2{"¿Qué quiere la clienta?"}:::dec
  D2 -->|"Otra talla o color"| P2["Elige la prenda nueva<br/>ve el stock de cada talla"]:::pant
  P2 --> D3{"¿Hay stock?"}:::dec
  D3 -->|"No"| R1["Otra talla, otra sede<br/>o convertir en devolución"]:::rec
  R1 --> D2
  D3 -->|"Sí"| P3["Ve la diferencia:<br/>igual, a pagar o a favor"]:::pant
  P3 --> OK1(["Cambio hecho, comprobantes impresos"]):::logro
  D2 -->|"Quiere su dinero"| D4{"¿Está dentro del plazo?"}:::dec
  D4 -->|"No"| S2["Su supervisor autoriza"]:::sup
  S2 --> P4
  D4 -->|"Sí"| P4["Elige cómo devolver<br/>sugerido: el mismo medio que usó"]:::pant
  P4 --> OK3(["Devolución hecha, stock y caja al día"]):::logro
classDef disp fill:#292524,stroke:#292524,color:#ffffff,stroke-width:1.5px;
classDef pant fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef dec fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef sup fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
classDef rec fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef logro fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
```

## U4 · Quiero cerrar mi turno sin problemas

```mermaid
flowchart TD
  T(("Termina su turno")):::disp --> P1["Cerrar caja"]:::pant
  P1 --> D1{"¿Quedan ventas en espera?"}:::dec
  D1 -->|"Sí"| R1["Las cobra o las descarta"]:::rec
  R1 --> P2
  D1 -->|"No"| P2["Conteo<br/>cuenta billetes y monedas"]:::pant
  P2 -->|"Confirma el total contado"| D2{"¿Cuadra con lo esperado?"}:::dec
  D2 -->|"Sí"| OK(["Turno cerrado, reporte impreso"]):::logro
  D2 -->|"No"| P3["Escribe qué cree que pasó"]:::pant
  P3 --> D3{"¿La diferencia es grande?"}:::dec
  D3 -->|"Sí"| S1["Su supervisor revisa con clave"]:::sup
  S1 --> OK
  D3 -->|"No"| OK
classDef disp fill:#292524,stroke:#292524,color:#ffffff,stroke-width:1.5px;
classDef pant fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef dec fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef sup fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
classDef rec fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef logro fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
```

## U5 · Llegó mercadería y quiero que el stock quede correcto

```mermaid
flowchart TD
  T(("Llega el proveedor con la mercadería")):::disp --> P1["Nueva compra<br/>escribe el RUC del proveedor"]:::pant
  P1 --> P2["Documento<br/>serie, número y fecha"]:::pant
  P2 --> D1{"¿Ya registró este documento?"}:::dec
  D1 -->|"Sí"| R1["Abre la compra existente<br/>para no duplicar"]:::rec
  D1 -->|"No"| P3["Prendas<br/>escanea o usa la tabla de tallas y colores de tallas"]:::pant
  P3 --> D2{"¿La prenda ya existe?"}:::dec
  D2 -->|"No"| P4["La crea ahí mismo<br/>sin salir de la compra"]:::pant
  P4 --> P5
  D2 -->|"Sí"| P5["Compara con el total del documento"]:::pant
  P5 --> D3{"¿Coincide?"}:::dec
  D3 -->|"No"| R2["Revisa cantidades o costos"]:::rec
  R2 --> P5
  D3 -->|"Sí"| OK(["Stock al día<br/>decide si actualiza costos y precios"]):::logro
classDef disp fill:#292524,stroke:#292524,color:#ffffff,stroke-width:1.5px;
classDef pant fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef dec fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef sup fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
classDef rec fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef logro fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
```

## U6 · Quiero saber si algo va mal hoy

```mermaid
flowchart TD
  T(("Quiere saber si todo va bien")):::disp --> P1["Resumen del día<br/>solo lo que requiere acción"]:::pant
  P1 --> D1{"¿Hay algo en rojo?"}:::dec
  D1 -->|"No"| OK1(["Tranquila: todo en orden"]):::logro
  D1 -->|"Comprobantes sin enviar"| A1["Bandeja de comprobantes<br/>reenvía o corrige"]:::pant
  D1 -->|"Stock bajo"| A2["Por reponer<br/>crea la compra"]:::pant
  D1 -->|"Caja con diferencia"| A3["Revisa el cierre<br/>y la observación"]:::pant
  D1 -->|"Pedidos atrasados"| A4["Pedidos<br/>contacta al courier o al cliente"]:::pant
  A1 --> OK2(["Problema resuelto o delegado"]):::logro
  A2 --> OK2
  A3 --> OK2
  A4 --> OK2
classDef disp fill:#292524,stroke:#292524,color:#ffffff,stroke-width:1.5px;
classDef pant fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef dec fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef sup fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
classDef rec fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef logro fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
```

## U7 · Una clienta pide que le lleven su pedido

```mermaid
flowchart TD
  T(("Una clienta pide envío")):::disp --> P1["Venta<br/>activa Envío"]:::pant
  P1 --> P2["Datos de entrega<br/>teléfono, dirección y referencia"]:::pant
  P2 --> D1{"¿Paga ahora o al recibir?"}:::dec
  D1 -->|"Ahora"| P3["Cobra como una venta normal"]:::pant
  D1 -->|"Al recibir"| P3b["Queda pendiente de pago"]:::pant
  P3 --> P4["Preparar pedido<br/>escanea cada prenda"]:::pant
  P3b --> P4
  P4 --> P5["Enviar<br/>courier y guía, la clienta recibe aviso"]:::pant
  P5 --> D2{"¿Se entregó?"}:::dec
  D2 -->|"Sí"| OK(["Entregado y cobrado"]):::logro
  D2 -->|"No estaba"| R1["Reprograma o devuelve a tienda"]:::rec
  R1 --> P5
classDef disp fill:#292524,stroke:#292524,color:#ffffff,stroke-width:1.5px;
classDef pant fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef dec fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef sup fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
classDef rec fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef logro fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
```

## U8 · Algo salió mal con un comprobante

```mermaid
flowchart TD
  T(("Un comprobante tiene un problema")):::disp --> P1["Comprobantes<br/>abre el comprobante"]:::pant
  P1 --> D1{"¿Qué pasó?"}:::dec
  D1 -->|"SUNAT no lo aceptó por un dato"| P2["Corrige el dato<br/>y lo reenvía"]:::pant
  P2 --> OK(["Todo queda al día:<br/>comprobante, stock y caja"]):::logro
  D1 -->|"El monto o las prendas estaban mal"| S1["Autoriza con clave<br/>y escribe el motivo"]:::sup
  D1 -->|"La clienta pidió factura después"| S1
  S1 --> P3["Ve el efecto en stock y caja<br/>antes de confirmar"]:::pant
  P3 --> OK
  D1 -->|"La clienta devolvió la prenda"| P4["Va a Devoluciones"]:::pant
  P4 --> OK
classDef disp fill:#292524,stroke:#292524,color:#ffffff,stroke-width:1.5px;
classDef pant fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef dec fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef sup fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
classDef rec fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef logro fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
```

## U9 · Quiero abrir una tienda nueva

```mermaid
flowchart TD
  T(("Se abre una tienda nueva")):::disp --> P1["Asistente de configuración"]:::pant
  P1 --> P2["Datos de la tienda<br/>RUC, dirección e IGV"]:::pant
  P2 --> P3["Cajas y series"]:::pant
  P3 --> P4["Turnos y medios de pago"]:::pant
  P4 --> P5["Equipo<br/>usuarios y roles"]:::pant
  P5 --> D1{"¿Falta algo para poder vender?"}:::dec
  D1 -->|"Sí"| R1["El asistente muestra qué falta<br/>y lleva directo ahí"]:::rec
  R1 --> P2
  D1 -->|"No"| OK(["Tienda lista para vender"]):::logro
classDef disp fill:#292524,stroke:#292524,color:#ffffff,stroke-width:1.5px;
classDef pant fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef dec fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef sup fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
classDef rec fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef logro fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
```

