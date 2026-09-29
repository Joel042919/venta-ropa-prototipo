# Prototipo Comercial de Alto Impacto: POS + Inventario + SUNAT
## Boutique de Moda Femenina "Estilo & Moda" (Perú)

Este prototipo interactivo ha sido diseñado específicamente para la reunión comercial de venta con la clienta dueña de una tienda de ropa y accesorios en Perú. Cuenta con datos realistas, estética premium de boutique de moda y simulación completa del ciclo de venta y facturación electrónica SUNAT.

---

## 🚀 Cómo Ejecutar el Prototipo

Ejecuta el proyecto con **pnpm**:

```bash
# Opción 1: Servidor de producción optimizado (ya compilado)
pnpm start

# Opción 2: Modo desarrollo
pnpm dev
```

Abre en tu navegador: [http://localhost:3000](http://localhost:3000)

> 💡 **Tip para la presentación**: Presiona la tecla **F11** en tu navegador o haz clic en el botón de pantalla completa en la esquina superior derecha del header para presentar en modo quiosco/caja profesional.

---

## 🌟 Guión Recomendado para la Reunión Comercial

### 1. Entrada y Bienvenida (Login de Boutique)
- Muestra la pantalla de acceso con estética cuidada de moda.
- Destaca que cada cajera o jefa de tienda tiene su turno y caja identificada (`Caja 01 - Boutique San Isidro`).
- Clic directo en **"Ingresar al Punto de Venta"**.

### 2. Header & Conexión SUNAT en Vivo (Genera Confianza Inmediata)
- Muestra el indicador permanente: `Conectado a SUNAT 🟢` con CDR en tiempo real.
- Explica que el sistema valida comprobantes al instante y cuenta con modo de contingencia si el servidor de SUNAT se cae.

### 3. Pantalla Estrella: Punto de Venta (POS)
- **Buscador & Categorías**: Muestra cómo filtrar entre *Vestidos*, *Blusas & Tops*, *Pantalones & Jeans*, *Accesorios* y *Calzado*.
- **Simulador de Escáner de Código de Barras**: Haz clic en el botón **"Simular Escáner"** para ver y escuchar el feedback sonoro/visual (*¡Beep!*).
- **Selector de Tallas y Colores**: Al hacer clic en un vestido (ej: *Vestido Midi Terracota Lino*), se abre el modal para elegir talla (**S, M, L**) y color.
- **Carrito Dinámico**: Modifica cantidades, aplica descuentos promocionales (5%, 10%, 15%) y observa el desglose automático de **Op. Gravada** e **IGV (18%)**.
- **Boleta vs Factura**:
  - Cambia a **Factura**: Se exige RUC (11 dígitos). Haz clic en **"🔍 Validar"** para mostrar la consulta automática a SUNAT con razón social y dirección.
  - Cambia a **Boleta**: Puedes usar *Clientes Varios* o validar DNI en RENIEC.
- **Cobro Multicanal**:
  - Haz clic en **"Cobrar y Emitir Comprobante"**.
  - **Efectivo**: Con botones rápidos de billetes peruanos (S/ 50, S/ 100, S/ 200) y cálculo instantáneo del vuelto.
  - **Yape / Plin**: Con código QR de la boutique y registro de operación.
  - **Tarjeta**: Terminal POS integrado.
- **Emisión & Efecto Wow**:
  - Al confirmar, se muestra la animación en 3 pasos: *Firmando XML con certificado digital* ➔ *Transmitiendo al OSE/SUNAT* ➔ *CDR Aceptado con lluvia de confeti*.
  - Se despliega el comprobante con formato **Ticket 80mm térmico** o **A4**, con Hash digital, Código QR y estado `CDR: ACEPTADO ✅`.
  - Botón **"Enviar por WhatsApp"** para compartir el recibo directamente a la clienta.

### 4. Control de Inventario & Kardex
- Muestra la tabla completa con precios de compra, precio de venta y **Margen de Ganancia %**.
- Alertas de **Bajo Stock** (naranja) y **Agotado** (rojo suave).
- Botón **"Ajustar"** para entradas/salidas de mercadería con motivo registrado.
- Botón **"Nuevo Producto"** con formulario funcional para agregar nuevas prendas en vivo.

### 5. Registro de Comprobantes Electrónicos
- Historial filtrable de Boletas (`B001-XXXXXX`) y Facturas (`F001-XXXXXX`).
- Reimpresión, descarga en PDF y reenvío por WhatsApp en un clic.

### 6. Fidelización de Clientes
- Directorio de clientas con historial acumulado de compras para premiar la recurrencia.
- Registro rápido con validación simulada en RENIEC / SUNAT.

### 7. Reportes & Analítica Comercial
- Gráficos interactivos de ventas semanales (Recharts).
- Participación por categoría (Vestidos 42%, Blusas 25%, etc.).
- Ranking **Top 5 prendas más vendidas**.
- Distribución de medios de pago (demostrando el impacto de Yape/Plin con el 48% de ventas).

---

## 📁 Estructura del Código

```
venta-prototipo/
├── app/
│   ├── globals.css           # Estilos globales, paleta boutique y reglas para impresión de tickets
│   ├── layout.tsx            # Metadata, tipografía Geist y viewport
│   └── page.tsx              # Página principal integradora y atajos de teclado (F2 POS)
├── components/
│   ├── Header.tsx            # Barra superior con reloj, estado SUNAT y perfil cajera
│   ├── Sidebar.tsx           # Menú lateral con badges reactivos de inventario
│   ├── LoginScreen.tsx       # Pantalla de inicio de turno estética para boutique
│   ├── NotificationToastContainer.tsx # Alertas y notificaciones flotantes
│   ├── POS/
│   │   ├── PosView.tsx       # Punto de Venta interactivo, escáner, carrito y desglose IGV
│   │   └── PaymentModal.tsx  # Pasarela de pagos peruanos, vuelto y animación SUNAT
│   ├── Inventory/
│   │   └── InventoryView.tsx # Tabla de existencias, márgenes, reposición y nuevo producto
│   ├── Vouchers/
│   │   ├── VouchersView.tsx  # Historial de boletas y facturas
│   │   └── VoucherModal.tsx  # Representación impresa oficial con QR, Hash y WhatsApp
│   ├── Customers/
│   │   └── CustomersView.tsx # Directorio y validación RENIEC/SUNAT
│   └── Reports/
│       └── ReportsView.tsx   # Gráficos de tendencias, top ventas y canales de cobro
├── context/
│   └── AppContext.tsx        # Estado global reactivo en memoria (POS, stock, ventas)
└── mock/
    └── mockData.ts           # Catálogo realista con fotos HD, clientela y ventas históricas
```
