import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../layouts/shell.dart';
import '../state/app_state.dart';
import '../widgets/grid.dart';
import '../widgets/ui.dart';

class KardexScreen extends StatefulWidget {
  const KardexScreen({super.key});
  @override
  State<KardexScreen> createState() => _KardexScreenState();
}

class _KardexScreenState extends State<KardexScreen> {
  String pid = 'todas';
  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final l = st.kardex.where((k) => pid == 'todas' || st.vById(k.vid).p.id == pid).take(80).toList();
    return ScreenPage('kardex',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 420,
            child: AppSelect<String>(label: 'Prenda', value: pid, options: [('todas', 'Todas las prendas'), for (final p in st.prod) (p.id, p.nombre)], onChanged: (v) => setState(() => pid = v)),
          ),
          const SizedBox(height: 14),
          FlowGrid(minWidth: 340, children: [
            for (final k in l)
              Builder(builder: (_) {
                final x = st.vById(k.vid);
                final sube = k.cant > 0;
                return Item2(
                  lead: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: sube ? C.okBg : C.errBg, borderRadius: BorderRadius.circular(4.4)),
                    child: Text('${sube ? '+' : ''}${k.cant}', style: disp(20, c: sube ? C.ok : C.err)),
                  ),
                  trail: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('${k.saldo}', style: disp(24)),
                    Text('queda', style: tx(11.5, c: C.suave)),
                  ]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${x.p.nombre} · ${x.v.talla}', style: tx(14.5, w: FontWeight.w700)),
                    Text('${_tipo(k.tipo)} · ${k.doc}${k.motivo.isNotEmpty ? ' · ${k.motivo}' : ''}', style: tx(12.5, c: C.suave)),
                    Text('${fdt(k.fecha)} · ${k.user}', style: tx(12, c: C.suave)),
                  ]),
                );
              }),
          ]),
        ]));
  }

  String _tipo(String t) => switch (t) {
        'INICIAL' => 'Stock inicial',
        'VENTA' => 'Venta',
        'COMPRA' => 'Compra',
        'DEVOLUCION' => 'Devolución',
        'ANULACION' => 'Anulación',
        'AJUSTE+' => 'Ajuste (sube)',
        'AJUSTE-' => 'Ajuste (baja)',
        _ => t,
      };
}
