# AgaShop · Diagramas (Mermaid)

## Mapa general: cómo se conectan los módulos

```mermaid
flowchart LR
  subgraph CFG["Configuración"]
    A3["A3 Sede lista<br/>cajas, series y medios de pago"]:::pin
  end
  subgraph STK["Inventario"]
    C1["C1 Productos y tallas y colores"]:::sistema
    D1["D1 Compras"]:::sistema
    C6["C6 Ajustes y conteo"]:::sistema
    E1["E1 Historial de movimientos"]:::ok
  end
  subgraph CAJ["Caja"]
    B1["B1 Apertura"]:::persona
    B3["B3 Cierre"]:::persona
  end
  subgraph VTA["Venta"]
    G1["G1 Venta en mostrador"]:::persona
    H1["H Comprobante SUNAT"]:::sistema
  end
  subgraph POST["Posventa"]
    I1["I Devoluciones y cambios"]:::error
    J1["J Delivery"]:::decision
  end
  A3 --> B1
  A3 --> C1
  C1 --> D1
  D1 --> E1
  C6 --> E1
  B1 --> G1
  G1 --> H1
  G1 --> E1
  G1 --> B3
  G1 --> J1
  H1 --> I1
  I1 --> E1
  I1 --> B3
  J1 --> I1
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## Estados de la turno de caja

```mermaid
stateDiagram-v2
    state "Sin turno de caja" as Sin
    state "Abierta" as Ab
    state "Cerrando" as En
    state "Cerrada" as Ce
    state "Cerrada por el supervisor" as Fo
    [*] --> Sin
    Sin --> Ab: Abre la caja
    Ab --> Ab: Ventas y movimientos
    Ab --> En: Cerrar caja
    En --> Ab: Cancela el cierre
    En --> Ce: Confirma el conteo
    En --> Fo: Cierra el supervisor
    Ce --> Ab: Reabre el supervisor
    Ce --> [*]
    Fo --> [*]
```

## Estados de una venta (propuesta)

```mermaid
stateDiagram-v2
    state "En espera" as Es
    state "Completada" as Co
    state "Pago pendiente" as Pp
    state "Devuelta en parte" as Dp
    state "Devuelta" as Dt
    state "Anulada" as An
    [*] --> Es: Pone en espera
    [*] --> Co: Cobra
    [*] --> Pp: Envío contra entrega
    Es --> Co: Cobra
    Es --> [*]: Descarta
    Pp --> Co: Cobra al entregar
    Co --> Dp: Devuelve una parte
    Co --> Dt: Devuelve todo
    Co --> An: Se anula
    Dp --> Dt: Devuelve el resto
```

## Estados de un comprobante SUNAT

```mermaid
stateDiagram-v2
    state "En proceso" as Pr
    state "Aceptado" as Ac
    state "Aceptado con observaciones" as Ob
    state "No aceptado" as Re
    state "Anulado" as An
    state "Con nota de crédito" as Nc
    [*] --> Pr
    Pr --> Ac
    Pr --> Ob
    Pr --> Re
    Pr --> Pr: Reintenta
    Re --> Pr: Corrige y reenvía
    Ac --> An: Se anula
    Ac --> Nc: Nota de crédito
    Ob --> An
    Ob --> Nc
```

## Estados de un pedido con delivery

```mermaid
stateDiagram-v2
    state "Pendiente" as Pe
    state "Preparando" as Pr
    state "Listo para enviar" as Li
    state "En camino" as En
    state "Entregado" as Et
    state "Fallido" as Fa
    state "Devuelto a tienda" as Dv
    state "Cancelado" as Ca
    [*] --> Pe
    Pe --> Pr
    Pr --> Li
    Li --> En
    En --> Et
    En --> Fa
    Fa --> En: Reprograma
    Fa --> Dv
    En --> Dv
    Pe --> Ca
    Pr --> Ca
    Li --> Ca
```

## A1 · Inicio de sesión

```mermaid
flowchart TD
  S(["Abre la aplicación"]):::persona --> L["Pantalla de login<br/>usuario y contraseña"]:::sistema
  L --> I("Escribe credenciales y pulsa Ingresar"):::persona
  I --> V{"¿Credenciales correctas?"}:::decision
  V -->|"No"| E1["Mensaje genérico<br/>y contador de intentos"]:::error
  E1 --> N{"¿5 intentos fallidos?"}:::decision
  N -->|"Sí"| B["Bloqueo de 5 min<br/>o pedir ayuda a SUP"]:::error
  N -->|"No"| L
  V -->|"Sí"| U{"¿Usuario activo?"}:::decision
  U -->|"No"| D["Tu usuario está desactivado<br/>habla con tu supervisor"]:::error
  U -->|"Sí"| T{"¿Contraseña temporal?"}:::decision
  T -->|"Sí"| C["Obliga a crear<br/>contraseña nueva"]:::sistema
  C --> O
  T -->|"No"| O{"¿Sesión abierta<br/>en otro equipo?"}:::decision
  O -->|"Sí"| K["Continuar aquí cerrando el otro<br/>o cancelar"]:::sistema
  K --> R
  O -->|"No"| R{"¿Qué rol tiene?"}:::decision
  R -->|"CAJ sin caja abierta"| B1(["Abrir caja B1"]):::ok
  R -->|"CAJ con caja abierta"| P(["Entra directo al punto de venta"]):::ok
  R -->|"SUP o ADM"| Q(["Resumen del día K2"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## A2 · Bloqueo rápido y cambio de persona

```mermaid
flowchart TD
  S(["Se aleja del puesto<br/>o pulsa Bloquear"]):::persona --> T["Pasan 5 min sin actividad<br/>o bloqueo manual"]:::sistema
  T --> V{"¿Hay una venta<br/>sin cobrar en pantalla?"}:::decision
  V -->|"Sí"| W["Pasa a espera automática G7"]:::sistema
  V -->|"No"| C
  W --> C["Cubre la pantalla<br/>con el nombre de quien tiene la caja"]:::sistema
  C --> Q{"¿Qué hace la persona?"}:::decision
  Q -->|"Escribe su contraseña"| P{"¿Es correcta?"}:::decision
  P -->|"Sí"| OK(["Vuelve al mismo punto exacto<br/>con su carrito"]):::ok
  P -->|"No"| E["Error e intentos"]:::error
  E --> C
  Q -->|"Otra persona escribe su clave"| R["¿Es el relevo de caja?"]:::decision
  R -->|"Sí"| B4(["Entregar caja B4"]):::ok
  R -->|"No"| X["No vende con la sesión de otra persona"]:::error
  Q -->|"Cambiar de usuario"| H{"¿Caja abierta con ventas?"}:::decision
  H -->|"Sí"| B4
  H -->|"No"| L(["Cierra sesión"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## A3 · Configuración inicial de una sede

```mermaid
flowchart TD
  S(["Sede nueva"]):::persona --> P1["1 Empresa<br/>razón social y RUC"]:::persona
  P1 --> V1{"¿RUC válido?"}:::decision
  V1 -->|"No"| X1["Error junto al campo"]:::error
  X1 --> P1
  V1 -->|"Sí"| P2["2 Sede<br/>dirección, RUC y IGV"]:::persona
  P2 --> V2{"¿IGV en 0?"}:::decision
  V2 -->|"Sí"| X2["Confirmar que la sede vende exonerada"]:::sistema
  X2 --> P3
  V2 -->|"No"| P3["3 Cajas"]:::persona
  P3 --> P4["4 Series por caja<br/>boleta y factura"]:::persona
  P4 --> V4{"¿Serie ya existe?"}:::decision
  V4 -->|"Sí"| X4["Sugerir la siguiente<br/>ejemplo B002"]:::error
  X4 --> P4
  V4 -->|"No"| P5["5 Turnos"]:::persona
  P5 --> P6["6 Medios de pago<br/>mínimo Efectivo"]:::persona
  P6 --> P7["7 Categorías"]:::persona
  P7 --> P8["8 Categorías de movimiento de caja"]:::persona
  P8 --> P9["9 Estados de delivery<br/>si hace envíos"]:::persona
  P9 --> P10["10 Usuarios y roles"]:::persona
  P10 --> M{"¿Cumple los mínimos?<br/>caja, serie de boleta,<br/>turno, Efectivo, un SUP"}:::decision
  M -->|"No"| X5["El punto de venta no abre<br/>y muestra lo que falta"]:::error
  X5 --> P3
  M -->|"Sí"| OK(["Tienda lista para vender"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## A5 · Gestión de usuarios

```mermaid
flowchart TD
  S(["Usuarios"]):::persona --> Q{"¿Qué quiere hacer?"}:::decision
  Q -->|"Crear"| C["Formulario: usuario, rol,<br/>sede y contraseña temporal"]:::persona
  C --> U{"¿Usuario ya existe?"}:::decision
  U -->|"Sí"| X1["Sugiere tallas y colores"]:::error
  X1 --> C
  U -->|"No"| G["Guarda y muestra la temporal<br/>una sola vez"]:::sistema
  G --> OK1(["Usuario creado"]):::ok
  Q -->|"Desactivar"| D{"¿Es el último ADM<br/>o es uno mismo?"}:::decision
  D -->|"Sí"| X2["Bloqueado con explicación"]:::error
  D -->|"No"| K{"¿Tiene caja abierta?"}:::decision
  K -->|"Sí"| F["cierre hecho por el supervisor por SUP primero B3"]:::pin
  F --> OK2
  K -->|"No"| OK2(["Usuario desactivado<br/>el historial se conserva"]):::ok
  Q -->|"Restablecer contraseña"| R["Genera temporal con motivo"]:::sistema
  R --> OK3(["Pedirá cambiarla al ingresar"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## B1 · Apertura de caja

```mermaid
flowchart TD
  S(["Entra al punto de venta"]):::persona --> A{"¿Tiene sesión<br/>abierta propia?"}:::decision
  A -->|"Sí"| PV(["Continúa en el punto de venta"]):::ok
  A -->|"No"| B{"¿Hay una sesión abierta<br/>de un día anterior?"}:::decision
  B -->|"Sí"| B5["Regularizar primero B5"]:::error
  B -->|"No"| C["Pantalla Abrir caja"]:::sistema
  C --> D("Elige la caja"):::persona
  D --> E{"¿La caja está libre?"}:::decision
  E -->|"No"| E1["En uso por otra persona<br/>elegir otra o avisar a SUP"]:::error
  E1 --> D
  E -->|"Sí"| F{"¿Tiene serie de boleta?"}:::decision
  F -->|"No"| F1["Bloquea con el motivo<br/>y enlace a ADM"]:::error
  F -->|"Sí"| G["Turno sugerido por la hora"]:::sistema
  G --> G1{"¿Fuera del horario<br/>del turno?"}:::decision
  G1 -->|"Sí"| G2["Aviso suave"]:::sistema
  G2 --> H
  G1 -->|"No"| H("Escribe el monto de apertura"):::persona
  H --> I{"¿Monto válido?"}:::decision
  I -->|"No"| I1["Error junto al campo"]:::error
  I1 --> H
  I -->|"Es 0"| I2["¿Abrir sin dinero para vuelto?"]:::decision
  I2 --> J
  I -->|"Sí"| J{"¿Difiere de lo que dejó<br/>el turno anterior?"}:::decision
  J -->|"Sí"| J1["Pide observación"]:::sistema
  J1 --> K
  J -->|"No"| K{"¿Hay conexión?"}:::decision
  K -->|"No"| K1["Necesitas conexión para abrir"]:::error
  K -->|"Sí"| L["Crea la sesión abierta"]:::sistema
  L --> OK(["Caja abierta<br/>entra al punto de venta"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## B2 · Movimiento extra de caja

```mermaid
flowchart TD
  S(["Menú de caja<br/>Movimiento"]):::persona --> T{"¿Ingreso o egreso?"}:::decision
  T --> C("Elige categoría<br/>y escribe el monto"):::persona
  C --> V1{"¿Es un egreso<br/>mayor al efectivo disponible?"}:::decision
  V1 -->|"Sí"| X1["Bloqueado: solo hay S/ X en caja"]:::error
  X1 --> C
  V1 -->|"No"| D("Escribe la descripción"):::persona
  D --> V2{"¿Descripción vacía?"}:::decision
  V2 -->|"Sí"| X2["Error junto al campo"]:::error
  X2 --> D
  V2 -->|"No"| V3{"¿Mismo monto y categoría<br/>hace menos de 1 min?"}:::decision
  V3 -->|"Sí"| X3["¿Ya lo registraste?"]:::sistema
  X3 --> V4
  V3 -->|"No"| V4{"¿Supera el límite del rol?"}:::decision
  V4 -->|"Sí"| P["clave del supervisor"]:::pin
  P --> G
  V4 -->|"No"| G["Registra el movimiento"]:::sistema
  G --> OK(["Vale imprimible<br/>y visible en la lista del turno"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## B3 · Conteo y cierre de caja

```mermaid
flowchart TD
  S(["Cerrar caja"]):::persona --> A{"¿Hay ventas en espera?"}:::decision
  A -->|"Sí"| A1["Bloqueado: cobrar o descartar"]:::error
  A -->|"No"| B["Revisa pendientes:<br/>comprobantes sin enviar<br/>y contra entrega por rendir"]:::sistema
  B --> C["Resumen del turno<br/>el efectivo esperado se oculta"]:::sistema
  C --> D("Cuenta el efectivo<br/>por billetes y monedas"):::persona
  D --> E["¿Contaste S/ X? confirmar"]:::sistema
  E --> F["Calcula esperado:<br/>apertura + ventas efectivo + ingresos<br/>- egresos - devoluciones efectivo"]:::sistema
  F --> G{"¿La diferencia está<br/>dentro de la diferencia permitida?"}:::decision
  G -->|"Sí"| G1["Caja cuadrada"]:::ok
  G -->|"No"| H("Escribe la observación<br/>obligatoria"):::persona
  H --> H1{"¿Diferencia mayor a S/ 20?"}:::decision
  H1 -->|"Sí"| H2["clave del supervisor"]:::pin
  H2 --> I
  H1 -->|"No"| I
  G1 --> I("Opcional: retirar efectivo<br/>a caja fuerte"):::persona
  I --> J{"¿Hay conexión?"}:::decision
  J -->|"No"| J1["Guarda el conteo en el equipo<br/>cierra al reconectar"]:::error
  J -->|"Sí"| K["Estado cerrada"]:::sistema
  K --> OK(["Reporte de cierre imprimible"]):::ok
  Z(["La persona no está"]):::persona -.-> Y["SUP hace cierre hecho por el supervisor<br/>con conteo y observación"]:::pin
  Y -.-> K
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## B4 · Relevo de turno

```mermaid
flowchart TD
  S(["Saliente pulsa<br/>Entregar caja a..."]):::persona --> A{"¿Ventas en espera?"}:::decision
  A -->|"Sí"| A1["Resolverlas antes"]:::error
  A -->|"No"| B("Saliente hace el conteo<br/>como en B3"):::persona
  B --> C{"¿La persona entrante<br/>inicia sesión?"}:::decision
  C -->|"No"| C1["El relevo queda pendiente<br/>se sigue con B3 normal"]:::error
  C -->|"Sí"| D("Entrante revisa el conteo"):::persona
  D --> E{"¿Está de acuerdo?"}:::decision
  E -->|"No"| E1["Recontar con SUP presente"]:::pin
  E1 --> F
  E -->|"Sí"| F["Cierra la sesión del saliente"]:::sistema
  F --> G["Abre la sesión del entrante<br/>con ese fondo"]:::sistema
  G --> OK(["Relevo hecho<br/>sin contar dos veces"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## B5 · Caja olvidada del día anterior

```mermaid
flowchart TD
  S(["Inicia sesión"]):::persona --> A{"¿Queda una sesión<br/>abierta de un día anterior?"}:::decision
  A -->|"No"| OK0(["Sigue normal B1"]):::ok
  A -->|"Sí"| B{"¿La sesión es<br/>de esta persona?"}:::decision
  B -->|"No"| B1["Solo SUP puede forzar el cierre"]:::pin
  B1 --> D
  B -->|"Sí"| C["Pantalla bloqueante:<br/>cerrar antes de vender"]:::error
  C --> D("Cierre tardío:<br/>cuenta el efectivo actual"):::persona
  D --> E("Observación obligatoria"):::persona
  E --> F["clave del supervisor"]:::pin
  F --> G["Cierra con la fecha real"]:::sistema
  G --> OK(["Ahora abre la caja de hoy B1"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## B6 · Correcciones de caja

```mermaid
flowchart TD
  S(["¿Qué se corrige?"]):::decision
  S -->|"Movimiento equivocado"| A["Crear movimiento contrario<br/>con motivo y enlace al original"]:::pin
  A --> A1{"¿Deja el efectivo negativo?"}:::decision
  A1 -->|"Sí"| A2["Bloqueado con explicación"]:::error
  A1 -->|"No"| OKA(["Corregido sin editar el original"]):::ok
  S -->|"Error en el dinero de apertura"| B["Movimiento Ajuste de apertura<br/>con observación"]:::pin
  B --> OKA
  S -->|"Cerré por error"| C{"¿Mismo día y la caja<br/>no tiene otra sesión?"}:::decision
  C -->|"No"| C1["Bloqueado: corregir con<br/>ajuste en la sesión actual"]:::error
  C -->|"Sí"| C2["Reabrir con motivo<br/>SUP o ADM"]:::pin
  C2 --> OKC(["Caja ABIERTA de nuevo"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## C1 · Crear un producto con tallas y colores

```mermaid
flowchart TD
  S(["Nuevo producto"]):::persona --> A("Datos: nombre, código base,<br/>categoría"):::persona
  A --> B{"¿código base repetido?"}:::decision
  B -->|"Sí"| B1["Sugiere el siguiente"]:::error
  B1 --> A
  B -->|"No"| C("Elige tallas y colores"):::persona
  C --> D{"¿Existen la talla<br/>o el color?"}:::decision
  D -->|"No"| D1["Crear en línea sin salir"]:::sistema
  D1 --> E
  D -->|"Sí"| E["Genera la tabla de tallas y colores"]:::sistema
  E --> F("Precio, costo, stock inicial<br/>y stock mínimo"):::persona
  F --> G{"¿Precio o costo en 0?"}:::decision
  G -->|"Sí"| G1["Bloquea el guardado"]:::error
  G1 --> F
  G -->|"No"| H{"¿Precio menor que el costo?"}:::decision
  H -->|"Sí"| H1["Aviso de margen negativo<br/>requiere confirmar"]:::sistema
  H1 --> I
  H -->|"No"| I["Revisión: tallas y colores, stock total, margen"]:::sistema
  I --> J{"¿Hay conexión?"}:::decision
  J -->|"No"| J1["Conserva el borrador"]:::error
  J -->|"Sí"| K["Crea producto, tallas y colores,<br/>stock y historial de movimientos inicial"]:::sistema
  K --> OK(["Imprimir etiquetas,<br/>crear otro igual o ir al inventario"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## C6 · Ajuste de stock

```mermaid
flowchart TD
  S(["Ajustar stock"]):::persona --> A("Busca o escanea la talla y color"):::persona
  A --> B{"¿Talla y color habilitada<br/>en la sede?"}:::decision
  B -->|"No"| B1["Pide Habilitar primero"]:::error
  B1 --> C
  B -->|"Sí"| C("Elige Entrada o Salida<br/>cantidad y motivo"):::persona
  C --> D{"¿El motivo es<br/>ingreso de proveedor?"}:::decision
  D -->|"Sí"| D1["Redirige a Compras D1"]:::sistema
  D -->|"No"| E{"¿Salida mayor al stock?"}:::decision
  E -->|"Sí"| E1["Bloqueada: solo hay N<br/>SUP puede forzar"]:::pin
  E1 --> F
  E -->|"No"| F["Muestra: pasará de 5 a 8"]:::sistema
  F --> G{"¿El stock cambió<br/>mientras ajustaba?"}:::decision
  G -->|"Sí"| G1["Recalcular con el valor actual"]:::sistema
  G1 --> F
  G -->|"No"| H["Actualiza stock y<br/>crea el registro en el historial"]:::sistema
  H --> OK(["Ajuste guardado"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## C7 · Toma de inventario físico

```mermaid
flowchart TD
  S(["Contar"]):::persona --> A("Elige el alcance:<br/>tienda, categoría o zona"):::persona
  A --> B("Escanea o busca cada prenda"):::persona
  B --> C{"¿El código existe?"}:::decision
  C -->|"No"| C1["Buscar por nombre<br/>o crear con permiso"]:::sistema
  C1 --> B
  C -->|"Sí"| D["Suma 1 por escaneo<br/>guarda el progreso en el equipo"]:::sistema
  D --> E{"¿Terminó?"}:::decision
  E -->|"No, pausa"| E1["Continúa después<br/>Continuar conteo del día"]:::sistema
  E1 --> B
  E -->|"Sí"| F["Compara con el sistema<br/>y descuenta ventas durante el conteo"]:::sistema
  F --> G{"¿Hay tallas y colores<br/>sin contar?"}:::decision
  G -->|"Sí"| G1["Contarlas como 0 o excluirlas"]:::sistema
  G1 --> H
  G -->|"No"| H["Lista de diferencias"]:::sistema
  H --> I{"¿Más del 40 por ciento<br/>no coincide?"}:::decision
  I -->|"Sí"| I1["Aviso: revisar antes de aplicar"]:::error
  I1 --> J
  I -->|"No"| J("Confirma las diferencias"):::persona
  J --> OK(["Crea los ajustes<br/>Corrección de conteo"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## C9 · Alertas de stock mínimo y reposición

```mermaid
flowchart TD
  S(["Bandeja Por reponer"]):::persona --> A["Tallas y colores con stock<br/>menor o igual al mínimo<br/>agotados primero"]:::sistema
  A --> B{"¿Qué decide?"}:::decision
  B -->|"Reponer"| C("Selecciona varias"):::persona
  C --> D["Crea una compra prellenada<br/>con cantidad sugerida"]:::sistema
  D --> OK1(["Sigue en Compras D1"]):::ok
  B -->|"Posponer"| E["No avisar por 7 días"]:::sistema
  B -->|"Descontinuar"| F["No volver a avisar"]:::sistema
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## D1 · Registrar una compra

```mermaid
flowchart TD
  S(["Nueva compra"]):::persona --> A("RUC del proveedor"):::persona
  A --> B{"¿RUC válido?"}:::decision
  B -->|"No"| B1["Error junto al campo"]:::error
  B1 --> A
  B -->|"Sí"| C["Completa el nombre<br/>desde el historial"]:::sistema
  C --> D("Tipo, serie, número y fecha"):::persona
  D --> E{"¿Ya existe esa combinación?"}:::decision
  E -->|"Sí"| E1["Bloquea con enlace<br/>a la compra existente"]:::error
  E -->|"No"| F{"¿Fecha futura?"}:::decision
  F -->|"Sí"| F1["Bloqueada"]:::error
  F1 --> D
  F -->|"No"| G("Agrega ítems: escanea,<br/>busca o modo tabla de tallas y colores"):::persona
  G --> H{"¿El producto existe?"}:::decision
  H -->|"No"| H1["Alta rápida D3"]:::sistema
  H1 --> I
  H -->|"Sí"| I("Cantidad y costo unitario<br/>prellenado con el último"):::persona
  I --> J["Calcula subtotal, IGV y total"]:::sistema
  J --> K{"¿Coincide con el total<br/>del documento?"}:::decision
  K -->|"No"| K1["Muestra la diferencia<br/>no deja registrar"]:::error
  K1 --> I
  K -->|"Sí"| L["Suma stock y crea<br/>registro en el historial Compra"]:::sistema
  L --> M{"¿Cambió algún costo?"}:::decision
  M -->|"Sí"| M1["Preguntar si actualizar costo<br/>y revisar precios de venta"]:::sistema
  M1 --> OK
  M -->|"No"| OK(["Compra registrada<br/>opción de imprimir etiquetas"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## D2 · Corregir o anular una compra

```mermaid
flowchart TD
  S(["Corregir compra"]):::persona --> A{"¿Mismo día y sin ventas<br/>de esa mercadería?"}:::decision
  A -->|"Sí"| B("Edita cantidades y costos"):::persona
  B --> C["Genera movimientos contrarios<br/>y nuevos"]:::sistema
  C --> OK1(["Compra corregida"]):::ok
  A -->|"No"| D["Muestra por talla y color:<br/>ingresaron N, ya se vendieron M"]:::sistema
  D --> E("Ajuste de salida<br/>solo por lo que queda"):::persona
  E --> F{"¿Dejaría stock negativo?"}:::decision
  F -->|"Sí"| F1["Bloquea esa talla y color"]:::error
  F -->|"No"| OK2(["Ajuste registrado con motivo"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## E1 · Consultar el historial de movimientos de una talla y color

```mermaid
flowchart TD
  S(["Historial de movimientos"]):::persona --> A("Elige la talla y color<br/>y los filtros"):::persona
  A --> B{"¿Tiene movimientos?"}:::decision
  B -->|"No"| B1["Aún no tiene movimientos"]:::error
  B -->|"Sí"| C["Línea de tiempo:<br/>fecha, tipo, documento,<br/>entrada, salida y saldo"]:::sistema
  C --> D{"¿El saldo del historial de movimientos<br/>es igual al stock actual?"}:::decision
  D -->|"Sí"| D1["Chip verde: coincide"]:::ok
  D -->|"No"| D2["Chip de alerta:<br/>diferencia de N unidades"]:::error
  D2 --> D3["Guía hacia un ajuste<br/>de corrección con motivo"]:::pin
  C --> E("Clic en un documento"):::persona
  E --> E1{"¿El documento se puede abrir?"}:::decision
  E1 -->|"Sí"| E2(["Abre la venta o la compra"]):::ok
  E1 -->|"No"| E3["Etiqueta Documento no disponible"]:::error
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## F2 · Registrar un cliente

```mermaid
flowchart TD
  S(["Nuevo cliente"]):::persona --> A("Elige tipo de documento<br/>y escribe el número"):::persona
  A --> B{"¿Formato válido?"}:::decision
  B -->|"No"| B1["Error junto al campo"]:::error
  B1 --> A
  B -->|"Sí"| C{"¿Ya existe el documento?"}:::decision
  C -->|"Sí"| C1["Ya está registrado:<br/>usar este cliente"]:::sistema
  C1 --> C2{"¿Pertenece a otra sede?"}:::decision
  C2 -->|"Sí"| C3["Aviso: registrado en otra sede<br/>se puede usar"]:::sistema
  C2 -->|"No"| OK0
  C3 --> OK0(["Cliente listo para la venta"]):::ok
  C -->|"No"| D("Pulsa Validar"):::persona
  D --> E{"¿El servicio responde?"}:::decision
  E -->|"No"| E1["Completar a mano<br/>marca Sin validar"]:::error
  E1 --> G
  E -->|"Sí"| F{"¿Encontró el documento?"}:::decision
  F -->|"No"| F1["Revisa el número<br/>o completa a mano"]:::error
  F1 --> G
  F -->|"Sí"| F2["Autocompleta nombre y dirección"]:::sistema
  F2 --> F3{"¿RUC de baja o no habido?"}:::decision
  F3 -->|"Sí"| F4["Aviso fuerte<br/>se desaconseja factura"]:::error
  F4 --> G
  F3 -->|"No"| G("Teléfono y correo opcionales"):::persona
  G --> H["Guarda el cliente"]:::sistema
  H --> OK0
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## G1 · Venta rápida en mostrador (flujo principal)

```mermaid
flowchart TD
  S(["Entra al punto de venta"]):::persona --> A{"¿La caja está abierta?"}:::decision
  A -->|"No"| A1["Lleva a Abrir caja B1"]:::error
  A -->|"Sí"| B("Agrega prendas G2<br/>escáner, búsqueda o grilla"):::persona
  B --> C["Carrito siempre visible con total G3"]:::sistema
  C --> D("Opcional: cliente y tipo<br/>de comprobante G4"):::persona
  D --> E("Opcional: descuento G3"):::persona
  E --> F("Pulsa Cobrar F9"):::persona
  F --> G("Elige el medio de pago<br/>y confirma G5"):::persona
  G --> H["Revalida stock y precios"]:::sistema
  H --> I{"¿Cambió algo?"}:::decision
  I -->|"Sí"| I1["Avisa y pide decidir"]:::error
  I1 --> C
  I -->|"No"| J["En una sola operación:<br/>reserva número, registra venta y pagos,<br/>descuenta stock y anota historial de movimientos"]:::sistema
  J --> K["Crea el comprobante y lo envía G6"]:::sistema
  K --> L{"¿Respuesta de SUNAT?"}:::decision
  L -->|"Aceptado"| L1(["Ticket: imprimir, WhatsApp o correo"]):::ok
  L -->|"Pendiente"| L2(["Venta registrada<br/>envío en segundo plano"]):::ok
  L -->|"Rechazado"| L3["Bandeja de errores H3"]:::error
  L1 --> Z(["Nueva venta<br/>el cursor vuelve al buscador"]):::ok
  L2 --> Z
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## G2 · Agregar productos

```mermaid
flowchart TD
  S(["Agregar prenda"]):::persona --> Q{"¿Cómo la busca?"}:::decision
  Q -->|"Escáner"| A("Lee el código y Enter"):::persona
  Q -->|"Búsqueda"| B("Nombre o código"):::persona
  Q -->|"Grilla o Packs"| C("Toca una tarjeta"):::persona
  A --> D{"¿El código existe?"}:::decision
  D -->|"No"| D1["No existe el código<br/>buscar por nombre"]:::error
  D -->|"Sí"| F
  B --> F
  C --> F{"¿El producto<br/>está activo?"}:::decision
  F -->|"No"| F1["Producto desactivado"]:::error
  F -->|"Sí"| G{"¿Tiene varias tallas y colores?"}:::decision
  G -->|"Sí"| G1["Selector en tabla de tallas y colores<br/>con el stock por celda"]:::sistema
  G1 --> H
  G -->|"No"| H{"¿Hay stock?"}:::decision
  H -->|"No"| H1["Agotado en esta sede"]:::error
  H1 --> H2{"¿La prenda está físicamente?"}:::decision
  H2 -->|"Sí"| H3["Vender sin stock:<br/>clave del supervisor y motivo"]:::pin
  H3 --> I
  H2 -->|"No"| H4["Ver otras sedes<br/>solo informativo"]:::sistema
  H -->|"Sí"| I{"¿La cantidad supera el stock?"}:::decision
  I -->|"Sí"| I1["Solo quedan N<br/>agrega lo disponible"]:::sistema
  I1 --> OK
  I -->|"No"| OK(["Agregado al carrito"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## G3 · Carrito, descuentos y packs

```mermaid
flowchart TD
  S(["Carrito"]):::persona --> Q{"¿Qué hace?"}:::decision
  Q -->|"Cambiar cantidad"| A{"¿Supera el stock?"}:::decision
  A -->|"Sí"| A1["Límite visible: solo quedan N"]:::error
  A -->|"No"| A2(["Cantidad actualizada"]):::ok
  Q -->|"Quitar prenda"| B["Se quita<br/>Deshacer por 6 segundos"]:::sistema
  Q -->|"Vaciar"| C["Pide confirmación"]:::sistema
  Q -->|"Cambiar precio de una línea"| D["clave del supervisor y motivo"]:::pin
  Q -->|"Aplicar descuento"| E{"¿Supera el límite del rol?"}:::decision
  E -->|"Sí"| E1["clave del supervisor o administrador"]:::pin
  E1 --> F
  E -->|"No"| F{"¿Es el 100 por ciento?"}:::decision
  F -->|"Sí"| F1["Bloqueado: la cortesía<br/>la registra SUP con motivo"]:::error
  F -->|"No"| G["Recalcula<br/>Subtotal, Descuento y Total"]:::sistema
  G --> H{"¿Hay packs en el carrito?"}:::decision
  H -->|"Sí"| H1["El descuento no se acumula<br/>con el precio del pack"]:::sistema
  H1 --> OK
  H -->|"No"| OK(["Total a cobrar actualizado<br/>incluye IGV"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## G4 · Cliente y tipo de comprobante

```mermaid
flowchart TD
  S(["¿Boleta o factura?"]):::decision
  S -->|"Boleta"| A{"¿El monto exige identificar<br/>al comprador?"}:::decision
  A -->|"No"| A1(["Clientes varios<br/>o cliente opcional"]):::ok
  A -->|"Sí"| A2("Pide el documento<br/>antes de cobrar"):::persona
  A2 --> OK2(["Boleta con cliente identificado"]):::ok
  S -->|"Factura"| B("Busca el cliente por RUC"):::persona
  B --> C{"¿Tiene RUC?"}:::decision
  C -->|"No"| C1["Factura necesita un RUC:<br/>buscar otra empresa o cambiar a boleta"]:::error
  C -->|"Sí"| D{"¿El RUC está habido?"}:::decision
  D -->|"No"| D1["Aviso: figura como no habido<br/>¿continuar?"]:::error
  D1 --> E
  D -->|"Sí"| E{"¿Responde la validación?"}:::decision
  E -->|"No"| E1["Continúa con RUC marcado Sin validar"]:::sistema
  E1 --> OK
  E -->|"Sí"| OK(["Factura lista para cobrar"]):::ok
  Z(["La clienta pide factura<br/>después de pagar"]):::persona -.-> Y["No se edita:<br/>ver anulación H5"]:::error
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## G5 · Cobro (incluye pago mixto)

```mermaid
flowchart TD
  S(["Pulsa Cobrar"]):::persona --> A{"¿Hay medios de pago activos?"}:::decision
  A -->|"No"| A1["Avisa a tu administrador"]:::error
  A -->|"Sí"| B("Elige el medio de pago"):::persona
  B --> Q{"¿Qué medio?"}:::decision
  Q -->|"Efectivo"| E("Monto recibido<br/>Exacto o billetes sugeridos"):::persona
  E --> E1{"¿Cubre el total?"}:::decision
  E1 -->|"No"| E2["Faltan S/ X<br/>Confirmar bloqueado"]:::error
  E1 -->|"Sí"| E3{"¿Hay efectivo en caja<br/>para el vuelto?"}:::decision
  E3 -->|"No"| E4["Pide un billete menor<br/>o cobrar por otro medio"]:::error
  E3 -->|"Sí"| V["Muestra el vuelto grande"]:::sistema
  Q -->|"Digital"| D("Instrucciones del medio<br/>y N° de operación"):::persona
  D --> D1{"¿El número ya se usó?"}:::decision
  D1 -->|"Sí"| D2["Aviso con el comprobante anterior"]:::error
  D1 -->|"No"| D3{"¿Llegó la notificación?"}:::decision
  D3 -->|"No"| D4["Esperar o cambiar de medio"]:::sistema
  D3 -->|"Sí"| M
  Q -->|"Tarjeta"| T("Referencia del voucher"):::persona
  T --> T1{"¿Fue rechazada?"}:::decision
  T1 -->|"Sí"| T2["Otra tarjeta o cambiar de medio<br/>sin perder lo ingresado"]:::error
  T1 -->|"No"| M
  V --> M{"¿Quiere agregar<br/>otro medio?"}:::decision
  M -->|"Sí"| M1["Pago mixto: prellena el resto<br/>máximo 3 medios"]:::sistema
  M1 --> B
  M -->|"No"| N{"¿La suma cubre el total?"}:::decision
  N -->|"No"| N1["Falta un monto"]:::error
  N -->|"Sí"| OK(["Confirmar<br/>el botón se bloquea contra doble clic"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## G6 · Emisión y post-venta

```mermaid
flowchart TD
  S(["Confirma el cobro"]):::persona --> A["Barra de progreso:<br/>Firmando, Enviando, Listo"]:::sistema
  A --> B{"¿Resultado?"}:::decision
  B -->|"Aceptado"| C(["Pantalla de éxito:<br/>número, total y vuelto grande"]):::ok
  B -->|"Tarda más de 10 s"| D(["Venta registrada<br/>se envía en segundo plano"]):::ok
  B -->|"Rechazado"| E["Aviso: no fue aceptado<br/>ver motivo en la bandeja H3"]:::error
  B -->|"Sin conexión"| F["Modo sin conexión H6"]:::error
  C --> G{"¿Qué elige?"}:::decision
  D --> G
  G -->|"Imprimir"| H{"¿Imprime?"}:::decision
  H -->|"No"| H1["Reintentar, ver PDF<br/>o enviar por WhatsApp"]:::error
  H -->|"Sí"| OK
  G -->|"WhatsApp"| W{"¿Tiene teléfono<br/>y el PDF está listo?"}:::decision
  W -->|"No"| W1["Pide el número o espera Generando"]:::sistema
  W1 --> OK
  W -->|"Sí"| OK
  G -->|"Correo"| OK
  OK(["Nueva venta"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## G7 · Venta en espera

```mermaid
flowchart TD
  S(["Pulsa En espera F4"]):::persona --> A{"¿Ya hay 5 en espera?"}:::decision
  A -->|"Sí"| A1["Límite alcanzado:<br/>cobrar o descartar una"]:::error
  A -->|"No"| B["Guarda el carrito con hora y cliente"]:::sistema
  B --> C("Atiende a otra persona"):::persona
  C --> D("Abre Ventas en espera<br/>y elige una"):::persona
  D --> E["Revalida stock y precios"]:::sistema
  E --> F{"¿Alguna prenda<br/>ya no está disponible?"}:::decision
  F -->|"Sí"| F1["Marca Ya no disponible"]:::error
  F1 --> OK
  F -->|"No"| OK(["Continúa la venta"]):::ok
  X(["El cliente se fue"]):::persona -.-> Y["Descartar con confirmación"]:::sistema
  Z(["Cierre de caja con esperas"]):::persona -.-> W["Bloqueado hasta resolverlas B3"]:::error
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## G8 · Falla de red al confirmar (respuesta incierta)

```mermaid
flowchart TD
  S(["Confirma el cobro"]):::persona --> A{"¿Llegó la respuesta?"}:::decision
  A -->|"Sí"| OK(["Flujo normal G6"]):::ok
  A -->|"No, se cayó la red"| B["Consulta la última venta<br/>antes de permitir reintentar"]:::sistema
  B --> C{"¿Se guardó la venta?"}:::decision
  C -->|"Sí"| D(["Va a la pantalla de éxito<br/>sin duplicar"]):::ok
  C -->|"No"| E["No se registró la venta<br/>el cliente no ha pagado en el sistema"]:::error
  E --> F{"¿Ya se cobró en efectivo?"}:::decision
  F -->|"Sí"| G["Guía: no entregues la prenda<br/>reintenta o devuelve el efectivo"]:::error
  G --> H
  F -->|"No"| H("Reintentar"):::persona
  H --> A
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## H2 · Bandeja de pendientes y errores

```mermaid
flowchart TD
  S(["Bandeja de comprobantes"]):::persona --> A["Lista con estado, cliente,<br/>total y días transcurridos"]:::sistema
  A --> B{"¿Se acerca el plazo<br/>de envío?"}:::decision
  B -->|"Sí"| B1["Se resalta en rojo"]:::error
  B -->|"No"| C
  B1 --> C("Reenviar uno<br/>o todos los pendientes"):::persona
  C --> D["Progreso y resultado por fila"]:::sistema
  D --> E{"¿Fue aceptado?"}:::decision
  E -->|"Sí"| OK(["Sale de la bandeja"]):::ok
  E -->|"No"| F["Conserva el motivo más reciente"]:::error
  F --> G{"¿Rechazado?"}:::decision
  G -->|"Sí"| G1["Corregir y reenviar H3"]:::sistema
  G -->|"No"| G2["Sigue en reintento automático<br/>Último intento hace N min"]:::sistema
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## H3 · Comprobante rechazado u observado

```mermaid
flowchart TD
  S(["Abre un comprobante<br/>No aceptado"]):::persona --> A["Muestra el motivo<br/>en lenguaje claro"]:::sistema
  A --> B{"¿Se puede corregir<br/>en pantalla?"}:::decision
  B -->|"Sí"| C("Corrige solo lo permitido,<br/>ejemplo datos del cliente"):::persona
  C --> D["Reenvía con el mismo número"]:::sistema
  D --> E{"¿Fue aceptado?"}:::decision
  E -->|"Sí"| OK(["Comprobante aceptado"]):::ok
  E -->|"No"| F["Muestra el nuevo motivo"]:::error
  F --> B
  B -->|"No, es el monto"| G["Anular y reemitir H5"]:::pin
  S2(["Observado"]):::persona -.-> O["Aviso para revisar,<br/>sin reenviar"]:::sistema
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## H5 · Anular o emitir nota de crédito (asistente)

```mermaid
flowchart TD
  S(["Elige el comprobante"]):::persona --> A{"¿Estado del comprobante?"}:::decision
  A -->|"Ya anulado o con nota"| A1["Bloqueado con el estado actual"]:::error
  A -->|"Pendiente"| A2["Primero debe aceptarse o corregirse"]:::error
  A -->|"Aceptado"| B{"¿Hay conexión?"}:::decision
  B -->|"No"| B1["Necesitas conexión"]:::error
  B -->|"Sí"| Q{"¿Qué pasó?"}:::decision
  Q -->|"Devolvió todo"| I1(["Devolución total I1"]):::ok
  Q -->|"Devolvió una parte"| I2(["Devolución parcial I2"]):::ok
  Q -->|"Se cambió de prenda"| I3(["Cambio I3"]):::ok
  Q -->|"Error en datos del cliente"| N1["Nota de crédito de corrección<br/>y nueva emisión"]:::sistema
  Q -->|"Error en monto o prendas"| N2["Anular y emitir de nuevo"]:::sistema
  Q -->|"Pidió factura después<br/>de la boleta"| F1["Anula la boleta"]:::sistema
  F1 --> F2["Crea venta nueva<br/>con las mismas prendas"]:::sistema
  F2 --> F3("Elige el cliente con RUC"):::persona
  F3 --> F4["Traslada el pago sin mover dinero<br/>y emite la factura"]:::sistema
  N1 --> M("Motivo obligatorio"):::persona
  N2 --> M
  M --> P["clave del supervisor"]:::pin
  P --> R["Resumen del efecto:<br/>stock, caja y comprobante"]:::sistema
  R --> T{"¿La venta es de un turno cerrado?"}:::decision
  T -->|"Sí"| T1["El reembolso cae en la sesión actual"]:::sistema
  T1 --> U
  T -->|"No"| U{"¿Hay efectivo para reembolsar?"}:::decision
  U -->|"No"| U1["Otro medio o esperar"]:::error
  U -->|"Sí"| OK(["Se actualizan comprobante,<br/>venta, historial de movimientos y caja"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## H6 · Modo sin conexión (SUNAT caído o sin internet)

```mermaid
flowchart TD
  S(["Se detecta una falla"]):::persona --> A{"¿Qué falla?"}:::decision
  A -->|"SUNAT no responde<br/>el sistema sí"| B["Aviso ámbar:<br/>sigues vendiendo"]:::sistema
  B --> B1["Los comprobantes quedan En proceso"]:::sistema
  B1 --> B2(["Reenvío automático al volver"]):::ok
  A -->|"Sin internet"| C["Aviso rojo"]:::error
  C --> D{"¿El negocio habilitó<br/>el modo local?"}:::decision
  D -->|"No"| D1["Bloquea las ventas<br/>hasta reconectar"]:::error
  D -->|"Sí"| E["Vende con límite:<br/>hasta 20 ventas o 2 horas"]:::sistema
  E --> F["Aviso: el stock puede<br/>no estar actualizado"]:::sistema
  F --> G["Al reconectar: sincroniza<br/>18 enviadas, 2 con problemas"]:::sistema
  G --> H{"¿Quedó stock negativo?"}:::decision
  H -->|"Sí"| H1["Lista para que SUP regularice"]:::pin
  H -->|"No"| OK(["Todo sincronizado"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## I1 · Devolución con comprobante

```mermaid
flowchart TD
  S(["Devoluciones"]):::persona --> A("Busca la venta:<br/>número, QR, documento o fecha"):::persona
  A --> B{"¿La encontró?"}:::decision
  B -->|"No"| B1["Buscar por cliente,<br/>fecha y monto"]:::sistema
  B1 --> A
  B -->|"Sí"| C["Muestra líneas, pagos<br/>y días transcurridos"]:::sistema
  C --> D{"¿Dentro del plazo?"}:::decision
  D -->|"No"| D1["Solo SUP con motivo"]:::pin
  D1 --> E
  D -->|"Sí"| E("Elige líneas y cantidades<br/>y el motivo"):::persona
  E --> F{"¿Cantidad mayor<br/>a la comprada o ya devuelta?"}:::decision
  F -->|"Sí"| F1["No se permite"]:::error
  F1 --> E
  F -->|"No"| G("Condición de cada prenda:<br/>reingresa, dañada o en revisión"):::persona
  G --> H["Calcula el monto con el descuento repartido"]:::sistema
  H --> I("Elige el medio de reembolso"):::persona
  I --> J{"¿Reembolso en efectivo<br/>mayor al efectivo de caja?"}:::decision
  J -->|"Sí"| J1["Elegir otro medio"]:::error
  J1 --> I
  J -->|"No"| K["clave del supervisor si corresponde"]:::pin
  K --> L["Emite la nota de crédito,<br/>mueve el stock, registra caja<br/>y actualiza la venta"]:::sistema
  L --> OK(["Imprime la nota<br/>y el comprobante de devolución"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## I3 · Cambio de talla o color

```mermaid
flowchart TD
  S(["Busca la venta y pulsa<br/>Cambiar en la prenda"]):::persona --> A{"¿Dentro del plazo?"}:::decision
  A -->|"No"| A1["Solo SUP"]:::pin
  A1 --> B
  A -->|"Sí"| B("Elige la prenda nueva<br/>escanea o busca"):::persona
  B --> C["Muestra stock por talla y color"]:::sistema
  C --> D{"¿Hay stock de la nueva?"}:::decision
  D -->|"No"| D1["Otras tallas y colores, otras sedes<br/>o convertir en devolución simple"]:::sistema
  D1 --> B
  D -->|"Sí"| E{"¿El precio actual<br/>de la original bajó?"}:::decision
  E -->|"Sí"| E1["Se cambia por el valor pagado<br/>con aviso"]:::sistema
  E1 --> F
  E -->|"No"| F["Calcula la diferencia"]:::sistema
  F --> G{"¿Diferencia?"}:::decision
  G -->|"Mismo precio"| H
  G -->|"Debe pagar"| G1("Cobra la diferencia G5"):::persona
  G1 --> H
  G -->|"Se devuelve"| G2{"¿Hay efectivo u otro medio?"}:::decision
  G2 -->|"No"| G3["Elegir otra prenda para igualar"]:::error
  G2 -->|"Sí"| H
  H["clave del supervisor si aplica"]:::pin
  H --> I["Por debajo: devuelve la original,<br/>crea la venta nueva,<br/>ajusta stock y caja"]:::sistema
  I --> OK(["Imprime los comprobantes"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## I4 · Devolución o cambio sin comprobante

```mermaid
flowchart TD
  S(["Clienta sin ticket"]):::persona --> A{"¿La compra está en el sistema?"}:::decision
  A -->|"Sí, se encuentra"| A1(["Sigue como I1 o I3"]):::ok
  A -->|"No"| B["Solo SUP o ADM"]:::pin
  B --> C("Pide documento de la clienta,<br/>motivo y condición de la prenda"):::persona
  C --> D{"¿Qué quiere?"}:::decision
  D -->|"Reembolso en dinero"| D1["No permitido sin comprobante"]:::error
  D -->|"Cambio por otra prenda"| E{"¿De igual o menor valor?"}:::decision
  E -->|"No"| E1["No hay diferencia a favor:<br/>elegir otra prenda"]:::error
  E1 --> D
  E -->|"Sí"| F["Registra el movimiento de stock con nota"]:::sistema
  F --> OK(["Cambio hecho y anotado"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## J1 · Crear una venta con envío

```mermaid
flowchart TD
  S(["Activa Envío en el carrito"]):::persona --> A("Elige o registra al cliente"):::persona
  A --> B{"¿Tiene teléfono?"}:::decision
  B -->|"No"| B1["Obligatorio: pide el número"]:::error
  B1 --> C
  B -->|"Sí"| C("Dirección, referencia y distrito"):::persona
  C --> D{"¿Dirección completa?"}:::decision
  D -->|"No"| D1["Indica qué falta"]:::error
  D1 --> C
  D -->|"Sí"| E("Costo de envío o Envío gratis"):::persona
  E --> F{"¿Costo vacío?"}:::decision
  F -->|"Sí"| F1["¿El envío es gratis?"]:::sistema
  F1 --> G
  F -->|"No"| G("Courier y fecha estimada"):::persona
  G --> H{"¿Fecha en domingo<br/>o feriado?"}:::decision
  H -->|"Sí"| H1["Aviso, no bloquea"]:::sistema
  H1 --> I
  H -->|"No"| I["Resumen:<br/>Productos + Envío = Total a cobrar"]:::sistema
  I --> J{"¿Pagar ahora<br/>o contra entrega?"}:::decision
  J -->|"Ahora"| K("Cobra G5"):::persona
  J -->|"Contra entrega"| L["Venta en pago pendiente J8"]:::sistema
  K --> OK(["Crea la venta y el envío<br/>en el estado inicial"]):::ok
  L --> OK
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## J2 · Estados y avance del pedido

```mermaid
flowchart TD
  S(["Abre el pedido"]):::persona --> Q{"¿Qué hace?"}:::decision
  Q -->|"Avanzar al siguiente estado"| A{"¿Pasa a En camino<br/>sin courier ni guía?"}:::decision
  A -->|"Sí"| A1["Pide courier y guía antes"]:::error
  A1 --> B
  A -->|"No"| B["Cambia el estado y guarda<br/>persona, hora y observación"]:::sistema
  B --> C{"¿Es un estado clave?"}:::decision
  C -->|"Sí"| C1["Ofrece mensaje de WhatsApp<br/>ya redactado para revisar"]:::sistema
  C1 --> OK
  C -->|"No"| OK(["Pedido actualizado"]):::ok
  Q -->|"Retroceder o saltar"| D["Motivo y clave del supervisor"]:::pin
  D --> B
  Q -->|"Deshacer un cambio"| E{"¿Pasaron menos de 10 min?"}:::decision
  E -->|"Sí"| E1["Deshace con motivo<br/>queda en el historial"]:::sistema
  E -->|"No"| E2["Solo con clave del supervisor"]:::pin
  X(["Dos personas cambian a la vez"]):::persona -.-> Y["La segunda ve:<br/>ya está En camino, actualizar"]:::error
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## J3 · Preparar, asignar courier y guía

```mermaid
flowchart TD
  S(["Abre el pedido en Preparando"]):::persona --> A["Checklist con las prendas del pedido"]:::sistema
  A --> B("Escanea cada prenda"):::persona
  B --> C{"¿Es una prenda del pedido?"}:::decision
  C -->|"No"| C1["Alerta: no pertenece al pedido"]:::error
  C1 --> B
  C -->|"Sí"| D{"¿Falta alguna prenda?"}:::decision
  D -->|"Sí"| D1["Cambiar prenda I3<br/>o quitar del pedido"]:::sistema
  D1 --> E
  D -->|"No"| E["Pasa a Listo para envío"]:::sistema
  E --> F["Imprime etiqueta y hoja de pedido"]:::sistema
  F --> G("Asigna courier y número de guía"):::persona
  G --> H{"¿La guía ya se usó<br/>en otro pedido?"}:::decision
  H -->|"Sí"| H1["Aviso con el pedido original"]:::error
  H1 --> G
  H -->|"No"| OK(["Marca En camino<br/>y notifica al cliente"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## J5 · Entrega fallida y reprogramación

```mermaid
flowchart TD
  S(["Marca Fallido y elige el motivo"]):::persona --> A["Guarda el intento en el historial"]:::sistema
  A --> B{"¿Cuántos intentos fallidos?"}:::decision
  B -->|"Dos o más"| B1["Sugiere devolver a tienda"]:::sistema
  B1 --> C
  B -->|"Uno"| C{"¿Qué decide?"}:::decision
  C -->|"Reprogramar"| D("Nueva fecha y,<br/>si hace falta, edita la dirección"):::persona
  D --> E["Notifica al cliente<br/>y anota el costo extra"]:::sistema
  E --> OK1(["Vuelve a En camino"]):::ok
  C -->|"Devolver a tienda"| F["Estado Devuelto a tienda"]:::sistema
  F --> G{"¿Reponer o devolver el dinero?"}:::decision
  G -->|"Reponer"| OK2(["La prenda vuelve al stock"]):::ok
  G -->|"Devolver"| OK3(["Devolución I1"]):::ok
  X(["El cliente no responde en 3 días"]):::persona -.-> Y["Aviso a SUP y opción de cancelar J6"]:::error
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## J6 · Cancelar un pedido

```mermaid
flowchart TD
  S(["Cancelar pedido"]):::persona --> A("Motivo obligatorio"):::persona
  A --> B{"¿En qué estado está?"}:::decision
  B -->|"Antes de preparar<br/>o preparando"| C{"¿Está pagado?"}:::decision
  C -->|"Sí"| C1["clave del supervisor"]:::pin
  C1 --> D
  C -->|"No"| D["Cancela y el stock vuelve"]:::sistema
  D --> E["Anula o emite nota de crédito<br/>y reembolsa H5 I5"]:::sistema
  E --> OK1(["Pedido cancelado"]):::ok
  B -->|"En camino"| F["No se cancela:<br/>se espera el retorno"]:::error
  F --> G["Marca Devuelto a tienda<br/>al regresar"]:::sistema
  G --> E
  B -->|"Entregado"| H(["Es una devolución I1"]):::ok
  X(["El courier perdió el paquete"]):::persona -.-> Y["Estado Extraviado<br/>nota de crédito o reposición"]:::pin
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

## J8 · Pago contra entrega

```mermaid
flowchart TD
  S(["Crea pedido Contra entrega"]):::persona --> A{"¿Supera el límite<br/>o la zona no aplica?"}:::decision
  A -->|"Sí"| A1["No disponible:<br/>pagar ahora"]:::error
  A -->|"No"| B["Venta en pago pendiente<br/>no entra dinero a la caja"]:::sistema
  B --> C["El repartidor entrega"]:::sistema
  C --> D{"¿El cliente acepta<br/>y paga?"}:::decision
  D -->|"Rechaza"| D1["Entrega fallida J5<br/>o cancelación J6"]:::error
  D -->|"Paga una parte"| D2["Pago mixto G5"]:::sistema
  D2 --> E
  D -->|"Paga todo"| E("El repartidor rinde<br/>el dinero a caja"):::persona
  E --> F{"¿Rinde el mismo día?"}:::decision
  F -->|"No"| F1["Aparece como Efectivo por rendir<br/>y en el cierre de caja"]:::error
  F1 --> G
  F -->|"Sí"| G("Registra el pago con el medio"):::persona
  G --> H{"¿Rindió menos de lo cobrado?"}:::decision
  H -->|"Sí"| H1["Diferencia con observación<br/>y aviso a SUP"]:::pin
  H1 --> OK
  H -->|"No"| OK(["Venta completada<br/>el efectivo entra a la caja que recibe"]):::ok
classDef persona fill:#e0e7ff,stroke:#4f46e5,color:#1e1b4b,stroke-width:1.5px;
classDef sistema fill:#ffffff,stroke:#78716c,color:#292524,stroke-width:1.5px;
classDef decision fill:#fef3c7,stroke:#d97706,color:#78350f,stroke-width:1.5px;
classDef error fill:#fee2e2,stroke:#dc2626,color:#7f1d1d,stroke-width:1.5px;
classDef ok fill:#dcfce7,stroke:#16a34a,color:#14532d,stroke-width:1.5px;
classDef pin fill:#f3e8ff,stroke:#9333ea,color:#581c87,stroke-width:1.5px;
```

