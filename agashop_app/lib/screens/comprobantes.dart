import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../layouts/shell.dart';
import '../state/app_state.dart';
import '../widgets/grid.dart';
import '../widgets/product_art.dart';
import '../widgets/ui.dart';
import '../widgets/pastel_card.dart';

class ComprobantesScreen extends StatefulWidget {
  const ComprobantesScreen({super.key});
  @override
  State<ComprobantesScreen> createState() => _ComprobantesScreenState();
}

class _ComprobantesScreenState extends State<ComprobantesScreen> {
  late String f;
  String q = '';
  @override
  void initState() {
    super.initState();
    f = AppScope.read(context).filtro == 'pend' ? 'Por revisar' : 'Todos';
  }

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final ql = q.toLowerCase();
    final l = st.comprobantes.where((c) {
      final okF = f == 'Todos' ||
          (f == 'Por revisar' && (c.estado == 'En proceso' || c.estado == 'No aceptado')) ||
          (f == 'Aceptados' && c.estado == 'Aceptado') ||
          (f == 'Notas de crédito' && c.tipo.startsWith('07'));
      return okF && (ql.isEmpty || c.numero.toLowerCase().contains(ql) || st.cli(c.cli).nombre.toLowerCase().contains(ql));
    }).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return ScreenPage('comprobantes',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Align(alignment: Alignment.centerLeft, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 320), child: SearchBox(hint: 'Busca por número o cliente', onChanged: (v) => setState(() => q = v)))),
          const SizedBox(height: 12),
          TextTabs(items: const ['Todos', 'Por revisar', 'Aceptados', 'Notas de crédito'], value: f, onChanged: (v) => setState(() => f = v)),
          const SizedBox(height: 14),
          if (l.isEmpty)
            const EmptyBox('No hay comprobantes aquí', 'Prueba con otro filtro.')
          else
            FlowGrid(minWidth: 340, children: [
              for (final c in l)
                Builder(builder: (_) {
                  final v = st.venta(c.ventaId);
                  final x = st.vById(v.items.first.vid);
                  final tono = switch (c.estado) {
                    'Aceptado' => Pastel.menta,
                    'En proceso' => Pastel.cielo,
                    'No aceptado' => Pastel.rosa,
                    _ => Pastel.gris,
                  };
                  return PastelCard(
                    tono: tono,
                    pill: fdt(c.fecha),
                    esquina: Icons.receipt_long_outlined,
                    label: st.cli(c.cli).nombre,
                    title: '${c.nombre} ${c.numero}',
                    logo: ProductArt(x.p, size: 46),
                    tags: [c.estado, if (v.pagos.isNotEmpty) medioN(v.pagos.first.medio), '${v.items.fold(0, (a, i) => a + i.q)} prendas'],
                    big: money(c.total),
                    small: '${st.cli(c.cli).tipo} ${st.cli(c.cli).doc}',
                    onTap: () => _detalle(context, c),
                  );
                }),
            ]),
        ]));
  }

  void _detalle(BuildContext context, Comprobante c) {
    showAppSheet(context, '${c.nombre} ${c.numero}', (ctx) {
      final st = AppScope.of(ctx);
      final v = st.venta(c.ventaId);
      final esNC = c.tipo.startsWith('07');
      final pend = c.estado == 'En proceso' || c.estado == 'No aceptado';
      final puedeDevolver = !esNC && c.estado == 'Aceptado' && v.estado != 'Anulada';
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (c.estado == 'No aceptado' && c.motivo != null) ...[Aviso('SUNAT no lo aceptó: ${c.motivo}', k: BK.err), const SizedBox(height: 12)],
        _Papel(c: c, v: v, st: st),
        const SizedBox(height: 14),
        if (pend) ...[
          if (c.estado == 'No aceptado')
            AppButton('Corregir el documento y reenviar', full: true, icon: Icons.edit_outlined, onTap: () {
              Navigator.of(ctx).pop();
              _corregir(context, c);
            })
          else
            AppButton('Reenviar a SUNAT', full: true, icon: Icons.send_outlined, onTap: () => st.reenviar(c)),
          const SizedBox(height: 10),
        ],
        Row(children: [
          Expanded(child: AppButton('Imprimir', v: BV.s, sm: true, icon: Icons.print_outlined, onTap: () => st.toast('Enviado a la impresora (demo)'))),
          const SizedBox(width: 10),
          Expanded(child: AppButton('WhatsApp', v: BV.s, sm: true, icon: Icons.chat_bubble_outline, onTap: () => st.toast('Comprobante enviado por WhatsApp (demo)'))),
        ]),
        if (puedeDevolver) ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: AppButton('Devolver', v: BV.g, sm: true, icon: Icons.undo, onTap: () => requireSup(ctx, 'Una devolución necesita autorización', () {
                  Navigator.of(ctx).pop();
                  _devolver(context, v, false);
                }))),
            const SizedBox(width: 10),
            Expanded(child: AppButton('Cambiar prenda', v: BV.g, sm: true, icon: Icons.swap_horiz, onTap: () => requireSup(ctx, 'Un cambio necesita autorización', () {
                  Navigator.of(ctx).pop();
                  _devolver(context, v, true);
                }))),
          ]),
        ],
        if (!esNC && c.estado != 'Anulado') ...[
          const SizedBox(height: 10),
          AppButton('Anular comprobante', v: BV.d, sm: true, full: true, icon: Icons.block, onTap: () => requireSup(ctx, 'Anular un comprobante necesita autorización', () {
                Navigator.of(ctx).pop();
                st.anular(c);
                st.toast('Comprobante anulado y stock devuelto');
              })),
        ],
      ]);
    });
  }

  void _corregir(BuildContext context, Comprobante c) {
    final st = AppScope.read(context);
    final cl = st.cli(c.cli);
    final doc = TextEditingController(text: cl.doc);
    showAppSheet(
      context,
      'Corregir documento',
      (ctx) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(cl.nombre, style: tx(16, w: FontWeight.w700)),
        const SizedBox(height: 12),
        AppField(label: cl.tipo == 'RUC' ? 'RUC (11 dígitos)' : 'DNI (8 dígitos)', ctrl: doc, number: true, maxLen: 11),
        const SizedBox(height: 16),
        AppButton('Guardar y reenviar', full: true, onTap: () {
          final n = cl.tipo == 'RUC' ? 11 : 8;
          if (doc.text.length != n) {
            st.toast('El documento debe tener $n dígitos');
            return;
          }
          cl.doc = doc.text;
          Navigator.of(ctx).pop();
          st.reenviar(c);
        }),
      ]),
    );
  }

  void _devolver(BuildContext context, Venta v, bool cambiar) {
    final st = AppScope.read(context);
    final cant = {for (final i in v.items) i.vid: 0};
    var motivo = 'Talla equivocada';
    showAppSheet(
      context,
      cambiar ? 'Cambiar prenda' : 'Devolver prendas',
      (ctx) => StatefulBuilder(
        builder: (ctx, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Lbl('Elige qué prendas vuelven'),
          for (final i in v.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Builder(builder: (_) {
                final x = st.vById(i.vid);
                return Item2(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(x.p.nombre, style: tx(15, w: FontWeight.w700)),
                    Text('Talla ${x.v.talla} · compraste ${i.q}', style: tx(13, c: C.suave)),
                  ]),
                  trail: StepperQ(cant[i.vid]!, () => set(() => cant[i.vid] = (cant[i.vid]! - 1).clamp(0, i.q)), () => set(() => cant[i.vid] = (cant[i.vid]! + 1).clamp(0, i.q))),
                );
              }),
            ),
          const SizedBox(height: 8),
          AppSelect<String>(label: 'Motivo', value: motivo, options: const [('Talla equivocada', 'Talla equivocada'), ('No le gustó', 'No le gustó'), ('Prenda con falla', 'Prenda con falla'), ('Otro', 'Otro')], onChanged: (x) => set(() => motivo = x)),
          const SizedBox(height: 18),
          AppButton(cambiar ? 'Registrar y elegir otra prenda' : 'Registrar devolución', full: true, onTap: cant.values.every((q) => q == 0) ? null : () {
            Navigator.of(ctx).pop();
            final m = st.devolver(v, cant, motivo);
            st.toast('Devolución registrada: devuelve ${money(m)} al cliente');
            if (cambiar) st.go('vender');
          }),
        ]),
      ),
    );
  }
}

class _Papel extends StatelessWidget {
  final Comprobante c;
  final Venta v;
  final AppState st;
  const _Papel({required this.c, required this.v, required this.st});

  Widget _sep(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          const Expanded(child: Divider(height: 1, color: C.borde)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(t, style: tx(11, w: FontWeight.w600, c: C.suave, ls: 1.4))),
          const Expanded(child: Divider(height: 1, color: C.borde)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final cl = st.cli(c.cli);
    final s = st.sede;
    final pagado = c.estado == 'Aceptado' || c.estado == 'En proceso';
    final etiqueta = c.estado == 'Anulado' ? 'ANULADO' : v.pagos.isEmpty ? 'PAGO PENDIENTE' : c.estado == 'No aceptado' ? 'RECHAZADO' : pagado ? 'PAGADO · ${c.numero.split('-').last.replaceFirst(RegExp(r'^0+'), '#')}' : c.estado.toUpperCase();
    final prendas = v.items.fold(0, (a, i) => a + i.q);
    final tu = st.turnoById(v.turnoId ?? '');
    final caja = tu == null ? '' : st.cajas.firstWhere((k) => k.id == tu.caja).n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: C.blanco, borderRadius: BorderRadius.circular(R.card), border: Border.all(color: C.borde)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // cabecera
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: C.negro, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.checkroom_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.empresa, style: tx(15, w: FontWeight.w700, ls: -0.2)),
              Text('RUC ${s.ruc}', style: tx(12, c: C.suave)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: c.estado == 'No aceptado' || c.estado == 'Anulado' ? C.negro : C.acento, borderRadius: BorderRadius.circular(6)),
            child: Text(etiqueta, style: tx(11, w: FontWeight.w700, c: Colors.white, ls: 0.6)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(s.dir, style: tx(12.5, c: C.suave)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(color: C.cremaOsc, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Expanded(child: Text(caja.isEmpty ? s.nombre : '$caja · ${s.nombre}', maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(12, w: FontWeight.w500))),
            Text(v.user, style: tx(12, w: FontWeight.w500)),
          ]),
        ),
        _sep('DETALLE'),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${c.nombre.toUpperCase()} N.°', style: tx(10.5, c: C.gris, ls: 0.8)),
              const SizedBox(height: 2),
              Text(c.numero, style: tx(13.5, w: FontWeight.w600)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('FECHA Y HORA', style: tx(10.5, c: C.gris, ls: 0.8)),
            const SizedBox(height: 2),
            Text('${dm(c.fecha)}/${c.fecha.year} · ${hm(c.fecha)}', style: tx(13.5, w: FontWeight.w600)),
          ]),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Text('CLIENTE', style: tx(10.5, c: C.gris, ls: 0.8)),
          const SizedBox(width: 10),
          Expanded(child: Text('${cl.nombre} · ${cl.tipo} ${cl.doc}', maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(13, w: FontWeight.w500))),
        ]),
        const SizedBox(height: 16),
        for (final it in v.items)
          Builder(builder: (_) {
            final x = st.vById(it.vid);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ProductArt(x.p, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${it.q}× ${x.p.nombre}', style: tx(14, w: FontWeight.w600, h: 1.25)),
                    const SizedBox(height: 2),
                    Text('Talla ${x.v.talla} · ${x.v.color} · ${money(x.v.precio)} c/u', style: tx(12, c: C.suave)),
                  ]),
                ),
                const SizedBox(width: 10),
                Text(money(x.v.precio * it.q), style: tx(14, w: FontWeight.w700)),
              ]),
            );
          }),
        // totales
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: C.cremaOsc, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Row2('Subtotal ($prendas ${prendas == 1 ? 'prenda' : 'prendas'})', money(v.subtotal), sub: true),
            Row2('IGV (${s.igv} %)', money(v.igv), sub: true),
            if (v.desc > 0) Row2('Descuento', '− ${money(v.desc)}', color: C.ok, sub: true),
            if (v.envio > 0) Row2('Envío', money(v.envio), sub: true),
            const Divider(height: 18, color: C.borde),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('TOTAL', style: tx(15, w: FontWeight.w700, ls: 0.4)),
              Text(money(c.total), style: tx(26, w: FontWeight.w700, ls: -0.8)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        // pagos
        if (v.pagos.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: C.cremaOsc, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.local_shipping_outlined, size: 20, color: C.suave),
              const SizedBox(width: 12),
              Expanded(child: Text('Pago contra entrega: se cobra al entregar el pedido', style: tx(13, w: FontWeight.w500))),
              Text('PENDIENTE', style: tx(11.5, w: FontWeight.w700, c: C.suave, ls: 0.6)),
            ]),
          )
        else
          for (final p in v.pagos)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: C.cremaOsc, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: C.blanco, borderRadius: BorderRadius.circular(8)),
                    child: Icon(switch (p.medio) { 'efectivo' => Icons.payments_outlined, 'tarjeta' => Icons.credit_card_outlined, _ => Icons.phone_iphone_outlined }, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(medioN(p.medio), style: tx(13.5, w: FontWeight.w600)),
                      Text(p.ref.isNotEmpty ? 'Operación ${p.ref}' : money(p.monto), style: tx(12, c: C.suave)),
                    ]),
                  ),
                  Text(c.estado == 'Anulado' ? 'ANULADO' : 'APROBADO', style: tx(11.5, w: FontWeight.w700, c: c.estado == 'Anulado' ? C.suave : C.acento, ls: 0.6)),
                ]),
              ),
            ),
      ]),
    );
  }
}
