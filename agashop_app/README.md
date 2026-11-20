# AgaShop (Flutter)

Una sola app con **tres diseños** que cambian solos según el ancho de la pantalla:

| Ancho | Diseño | Navegación |
|---|---|---|
| menos de 700 px | Móvil | Barra inferior de 5 secciones + «Más», ventanas desde abajo |
| 700 a 1099 px | Tablet | Riel lateral con las 10 secciones, ventanas centradas, punto de venta dividido desde 800 px |
| 1100 px o más | Escritorio | Menú lateral completo (272 px) y panel de venta siempre visible |

Los datos son de ejemplo y viven en memoria (se reinician al recargar). No usa internet, base de datos ni GitHub: las tipografías están dentro de `assets/fonts` (Roboto y Roboto Condensed, tomadas del propio SDK de Flutter).

## Ejecutar en tu equipo

```powershell
cd agashop_app
flutter pub get
flutter run -d windows     # ventana de escritorio (se puede redimensionar para ver los 3 diseños)
flutter run -d chrome      # navegador
flutter test               # pruebas de pantallas (3 tamaños) y de reglas de negocio
```


## Estructura

- `lib/core`: colores, radios (máximo 10 % del lado menor), tipografías y formatos.
- `lib/data/models.dart`: modelos que siguen la estructura de la base.
- `lib/state/app_state.dart`: datos de ejemplo y reglas (venta, cobro mixto, caja, pedidos, devoluciones, stock).
- `lib/widgets`: botones, campos, selector, calendario, pestañas, ventanas (hoja inferior en móvil, diálogo en tablet y escritorio).
- `lib/layouts/shell.dart`: los tres marcos de navegación y el titular de cada pantalla.
- `lib/screens`: inicio, vender, pedidos, inventario, caja, comprobantes, clientes, compras, historial y tienda.
