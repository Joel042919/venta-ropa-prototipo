# Demo mejorado (guía para implementar)

Archivo: [`index.html`](index.html). Se abre con doble clic, sin instalar nada. Es un **boceto funcional** de las mejoras de [`../evaluacion-ux.md`](../evaluacion-ux.md), no la app final. Los datos son de ejemplo y se guardan en el navegador (botón **Reiniciar demo** para empezar de cero).

El botón **Ver mejoras aplicadas** (abajo) muestra etiquetas azules con el código de cada mejora.

## Qué incluye

| Pantalla | Mejoras que muestra |
|---|---|
| Login | E1 (se ve al abrir) |
| Punto de venta | P1 totales ordenados · P2 sin avisos al agregar · P3 deshacer al borrar · P4 stock por talla · P5 Enter con código de barras · P6 buscar clienta · P8 "Venta actual" · carrito en cajón en pantallas pequeñas |
| Cobro | C1 total exacto por defecto · C2 billetes sugeridos · C3 Yape y Plin separados · C4 sin datos precargados · C5 modo sin conexión · C6 factura exige RUC |
| Inventario | I1/I2 entrada o salida por talla con motivo · I3 tallas elegibles · I4 stock por talla visible · D5 estado vacío |
| Comprobantes | D4 anular con motivo |
| Global | A1 letra de 14 px · A2/A3 contraste (terracota original, letra en negrita) · A5 botones de 40 px o más · A6 Escape y foco · E2 estado guardado · E3 sin imágenes externas · sin emojis |

## Dónde aplicarlo en la app real

| Mejora | Archivo de la app |
|---|---|
| P1, P2, P3, P5, P6, P8 | `components/POS/PosView.tsx`, `context/AppContext.tsx` |
| P4 | `components/POS/PosView.tsx` (modal de tallas y colores), `context/AppContext.tsx` (`addToCart`) |
| C1 a C6 | `components/POS/PaymentModal.tsx` |
| I1 a I4 | `components/Inventory/InventoryView.tsx` |
| D1, D4, D5 | `components/Dashboard/DashboardView.tsx`, `components/Vouchers/VouchersView.tsx` |
| A1 a A3 | `app/globals.css` y clases de color de los componentes. El terracota `#c26d60` **no cambia**; solo se pone la letra de los botones en negrita y se usa `#9a4a40` para texto de marca pequeño |
| E1 | `context/AppContext.tsx` (`isLoggedIn` inicia en `true`) |
| E2 | `context/AppContext.tsx` (guardar en `localStorage`) |
| E3 | Mover imágenes a `public/` y usar `mockData.ts` |

## Orden sugerido

1. **Antes de presentar:** C1, P1, E1, E3, A1 a A3.
2. **Pulido:** P2, P3, P6, C5, C6, D1, D4, I1 a I3, E2.
3. **Producto real:** el resto.

## Decisiones de diseño

- **Terracota original `#c26d60` (se mantiene):** blanco sobre este tono da 3.72:1. Se compensa con letra en negrita de 16 px o más (el botón de cobro, a 19 px) y con un tono más oscuro de la misma familia, `#9a4a40` (6.1:1 sobre blanco), solo para texto de marca sobre fondo claro. El hover es `#b05c50` (4.67:1).
- **Si quieres cumplir 4.5:1 en todos los botones:** usar `#b05c50` como relleno base. Es un tono que ya existe en el sistema.
- **Texto secundario `#57534e`:** antes se usaba un gris con 2.5:1.
- **Sin imágenes externas:** las prendas son bloques de color con iniciales, así la demo funciona sin internet. En la app real, usar fotos locales.
