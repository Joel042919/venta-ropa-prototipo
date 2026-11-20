import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../layouts/shell.dart';
import '../state/app_state.dart';
import '../widgets/grid.dart';
import '../widgets/ui.dart';

class MasScreen extends StatelessWidget {
  const MasScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final a = st.alerts();
    const subs = [
      ('caja', 'Caja', 'Abre, cierra y mira tus movimientos', Icons.payments_outlined),
      ('comprobantes', 'Comprobantes', 'Boletas, facturas y devoluciones', Icons.receipt_long_outlined),
      ('clientes', 'Clientes', 'Tus clientes y sus datos', Icons.people_outline),
      ('compras', 'Compras', 'Recibe mercadería y sube el stock', Icons.move_to_inbox_outlined),
      ('kardex', 'Historial de movimientos', 'Qué pasó con el stock de cada talla', Icons.history),
      ('config', 'Tienda', 'Datos, series y conexión con SUNAT', Icons.settings_outlined),
    ];
    return ScreenPage('mas',
        child: FlowGrid(minWidth: 320, children: [
          for (final (k, t, s, i) in subs)
            Item2(
              onTap: () => st.go(k),
              lead: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: C.acentoSuave, borderRadius: BorderRadius.circular(4.6)),
                child: Icon(i, color: C.acento),
              ),
              trail: k == 'comprobantes' && a.pend > 0 ? Badge2('${a.pend}', fg: C.err, bg: C.errBg) : const Icon(Icons.chevron_right),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t, style: tx(16, w: FontWeight.w700)),
                Text(s, style: tx(13, c: C.suave)),
              ]),
            ),
        ]));
  }
}
