import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../layouts/shell.dart';
import '../state/app_state.dart';
import '../widgets/grid.dart';
import '../widgets/product_art.dart';
import '../widgets/ui.dart';

class ComprasScreen extends StatelessWidget {
  const ComprasScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    return ScreenPage('compras',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppButton('Nueva compra', icon: Icons.add, full: ffOf(context) == FF.phone, onTap: () => requireSup(context, 'Registrar una compra necesita autorización', () => _nueva(context))),
          const SizedBox(height: 14),
          if (st.compras.isEmpty)
            const EmptyBox('Aún no registraste compras', 'Cuando recibas mercadería, regístrala aquí para subir el stock.')
          else
            FlowGrid(minWidth: 320, children: [
              for (final c in st.compras)
                Item2(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.prov, style: tx(15, w: FontWeight.w700)),
                    Text('${c.doc.isEmpty ? 'Sin documento' : c.doc} · ${dm(c.fecha)}', style: tx(13, c: C.suave)),
                    Text('${c.items.fold(0, (a, i) => a + i.q)} prendas', style: tx(13, c: C.suave)),
                  ]),
                  trail: Text(money(c.total), style: disp(24)),
                ),
            ]),
        ]));
  }

  void _nueva(BuildContext context) {
    final st = AppScope.read(context);
    final prov = TextEditingController(), doc = TextEditingController();
    var fecha = DateTime.now();
    final lineas = <CompraItem>[];
    var vid = st.prod.first.v.first.id;
    final cant = TextEditingController(text: '5'), costo = TextEditingController();
    final opts = [for (final p in st.prod) for (final v in p.v) (v.id, '${p.nombre} · ${v.talla}')];
    showAppSheet(
      context,
      'Nueva compra',
      (c) => StatefulBuilder(
        builder: (c, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppField(label: 'Proveedor', ctrl: prov, hint: 'Ej: Textiles Gamarra'),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: AppField(label: 'N.º de documento', ctrl: doc, hint: 'F001-123')),
            const SizedBox(width: 12),
            Expanded(child: DateBox(label: 'Fecha', value: fecha, onChanged: (d) => set(() => fecha = d))),
          ]),
          const SizedBox(height: 16),
          const Lbl('Agrega prendas'),
          AppSelect<String>(value: vid, options: opts, onChanged: (v) => set(() {
                vid = v;
                costo.text = st.vById(v).v.costo.toString();
              })),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: AppField(label: 'Cantidad', ctrl: cant, number: true)),
            const SizedBox(width: 12),
            Expanded(child: AppField(label: 'Costo unitario', ctrl: costo, number: true, hint: st.vById(vid).v.costo.toString())),
          ]),
          const SizedBox(height: 10),
          AppButton('Agregar a la compra', v: BV.g, sm: true, onTap: () {
            final q = int.tryParse(cant.text) ?? 0;
            final k = double.tryParse(costo.text) ?? st.vById(vid).v.costo;
            if (q <= 0) {
              st.toast('Escribe una cantidad válida');
              return;
            }
            set(() => lineas.add(CompraItem(vid, q, k)));
          }),
          if (lineas.isNotEmpty) ...[
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Prendas de la compra', style: tx(16, w: FontWeight.w700)),
              Text('${lineas.fold(0, (a, i) => a + i.q)} prendas', style: tx(13, c: C.suave)),
            ]),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: C.blanco, borderRadius: BorderRadius.circular(R.card), border: Border.all(color: C.borde)),
              child: Column(children: [
                for (var i = 0; i < lineas.length; i++)
                  Builder(builder: (_) {
                    final x = st.vById(lineas[i].vid);
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(border: Border(bottom: i < lineas.length - 1 ? const BorderSide(color: C.borde) : BorderSide.none)),
                      child: Row(children: [
                        ProductArt(x.p, size: 52),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(x.p.nombre, style: tx(14.5, w: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Wrap(spacing: 6, runSpacing: 4, children: [
                              Badge2('Talla ${x.v.talla}', fg: C.negro, bg: C.cremaOsc),
                              Badge2('${lineas[i].q} und.', fg: C.negro, bg: C.cremaOsc),
                            ]),
                            const SizedBox(height: 4),
                            Text('${money(lineas[i].costo)} c/u', style: tx(12.5, c: C.suave)),
                          ]),
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(money(lineas[i].q * lineas[i].costo), style: tx(15, w: FontWeight.w700)),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => set(() => lineas.removeAt(i)),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(padding: const EdgeInsets.all(4), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.delete_outline, size: 16, color: C.err), const SizedBox(width: 3), Text('Quitar', style: tx(12.5, w: FontWeight.w700, c: C.err))])),
                          ),
                        ]),
                      ]),
                    );
                  }),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: const BoxDecoration(color: C.acento, borderRadius: BorderRadius.vertical(bottom: Radius.circular(5))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('TOTAL DE LA COMPRA', style: tx(12, w: FontWeight.w700, c: const Color(0xFFE9F7FF), ls: 1.1)),
                    Text(money(lineas.fold<double>(0, (a, i) => a + i.q * i.costo)), style: disp(26, c: Colors.white)),
                  ]),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 14),
          AppButton('Registrar compra', full: true, onTap: lineas.isEmpty || prov.text.trim().isEmpty ? null : () {
            st.registrarCompra(prov.text.trim(), doc.text.trim(), fecha, lineas);
            Navigator.of(c).pop();
            st.toast('Compra registrada. El stock subió.');
          }),
        ]),
      ),
    );
  }
}
