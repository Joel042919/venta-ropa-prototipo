import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../layouts/shell.dart';
import '../state/app_state.dart';
import '../widgets/grid.dart';
import '../widgets/product_art.dart';
import '../widgets/ui.dart';
import 'caja.dart';

class VenderScreen extends StatefulWidget {
  const VenderScreen({super.key});
  @override
  State<VenderScreen> createState() => _VenderScreenState();
}

class _VenderScreenState extends State<VenderScreen> {
  String cat = 'Todas', q = '';
  final qc = TextEditingController();

  List<Widget> _cards(AppState st) {
    final ql = q.toLowerCase().trim();
    final l = st.prod.where((p) =>
        p.activo && (cat == 'Todas' || p.cat == cat) && (ql.isEmpty || p.nombre.toLowerCase().contains(ql) || p.v.any((v) => v.sku.toLowerCase().contains(ql)))).toList();
    return [for (final p in l) _ProdCard(p, () => _pick(st, p))];
  }

  void _pick(AppState st, Producto p) {
    if (p.v.length == 1) {
      final e = st.addCart(p.v.first.id);
      if (e != null) st.toast(e);
      return;
    }
    String? sel = p.v.where((v) => v.stock > 0).firstOrNull?.id;
    showAppSheet(
      context,
      p.nombre,
      (c) => StatefulBuilder(
        builder: (c, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(p.cat, style: tx(14, c: C.suave)),
            Text(money(p.v.first.precio), style: disp(26)),
          ]),
          const SizedBox(height: 16),
          const Lbl('Elige talla y color'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final v in p.v)
              InkWell(
                onTap: v.stock <= 0 ? null : () => set(() => sel = v.id),
                borderRadius: BorderRadius.circular(R.btn),
                child: Container(
                  width: 104,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: v.stock <= 0 ? C.cremaOsc : sel == v.id ? C.acento : C.blanco,
                    borderRadius: BorderRadius.circular(R.btn),
                    border: Border.all(color: sel == v.id ? C.negro : C.borde),
                  ),
                  child: Column(children: [
                    Text(v.talla, style: tx(18, w: FontWeight.w700, c: v.stock <= 0 ? C.gris : sel == v.id ? Colors.white : C.negro)),
                    Text('${v.color} · ${v.stock > 0 ? '${v.stock} disp.' : 'agotado'}',
                        textAlign: TextAlign.center, style: tx(11.5, c: sel == v.id ? const Color(0xFFE9F7FF) : C.suave)),
                  ]),
                ),
              ),
          ]),
          const SizedBox(height: 20),
          AppButton('Agregar a la venta', full: true, onTap: sel == null ? null : () {
            Navigator.of(c).pop();
            final e = st.addCart(sel!);
            if (e != null) st.toast(e);
          }),
        ]),
      ),
    );
  }

  void _openCart() => showAppSheet(context, 'Venta actual', (c) => CartView(onCobrar: () {
        Navigator.of(c).pop();
        openCobro(context);
      }), tall: true);

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final w = MediaQuery.sizeOf(context).width;
    final split = w >= 800;
    final t = st.turnoAbierto;
    if (t == null) {
      return ScreenPage('vender',
          child: Panel(
            pad: const EdgeInsets.all(24),
            child: Column(children: [
              Text('Abre tu caja para vender', style: tx(18, w: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Así cada venta queda registrada en tu turno.', style: tx(14, c: C.suave)),
              const SizedBox(height: 16),
              AppButton('Abrir caja', full: true, onTap: () => abrirCajaSheet(context)),
            ]),
          ));
    }
    final tot = st.totals();
    final catalog = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: SearchBox(
            hint: 'Busca o escanea el código',
            ctrl: qc,
            onChanged: (v) => setState(() => q = v),
            onSubmit: (v) {
              final r = st.scan(v);
              if (r != null) {
                st.toast(r.startsWith('ok:') ? 'Escaneado: ${r.substring(3)}' : r);
                if (r.startsWith('ok:')) {
                  qc.clear();
                  setState(() => q = '');
                }
              }
            },
          ),
          ),
        ),
        if (st.espera.isNotEmpty) ...[

          const SizedBox(width: 10),
          AppButton('En espera (${st.espera.length})', v: BV.s, sm: true, onTap: () => _espera(st)),
        ],
      ]),
      const SizedBox(height: 12),
      TextTabs(items: const ['Todas', ...categorias], value: cat, onChanged: (v) => setState(() => cat = v)),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text('Escribe un código y pulsa Enter. Ejemplo: ', style: tx(12.5, c: C.suave)),
          LinkBtn('VES-001-TER-M', () {
            final r = st.scan('VES-001-TER-M');
            if (r != null) st.toast(r.startsWith('ok:') ? 'Escaneado: ${r.substring(3)}' : r);
          }),
        ]),
      ),
      Builder(builder: (_) {
        final cs = _cards(st);
        return cs.isEmpty ? const EmptyBox('No encontramos prendas', 'Prueba con otra categoría o limpia la búsqueda.') : FlowGrid(minWidth: 158, gap: 12, children: cs);
      }),
    ]);
    if (split) {
      final pw = w >= 1100 ? 400.0 : 340.0;
      return Column(children: [
        Expanded(
          child: Row(children: [
            Expanded(child: Scrollbar(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: catalog))),
            Container(
              width: pw,
              decoration: const BoxDecoration(color: C.blanco, border: Border(left: BorderSide(color: C.borde))),
              child: CartView(onCobrar: () => openCobro(context), panel: true),
            ),
          ]),
        ),
      ]);
    }
    return Stack(children: [
      ScreenPage('vender', child: Padding(padding: EdgeInsets.only(bottom: tot.n > 0 ? 76 : 0), child: catalog)),
      if (tot.n > 0)
        Positioned(
          left: 16,
          right: 16,
          bottom: 12,
          child: GestureDetector(
            onTap: _openCart,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(color: C.acento, borderRadius: BorderRadius.circular(R.big)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Ver venta · ${tot.n} ${tot.n == 1 ? 'prenda' : 'prendas'}', style: tx(15, w: FontWeight.w700, c: Colors.white)),
                Text(money(tot.pagar), style: disp(26, c: Colors.white)),
              ]),
            ),
          ),
        ),
    ]);
  }

  void _espera(AppState st) => showAppSheet(
        context,
        'Ventas en espera',
        (c) => Column(children: [
          for (var i = 0; i < st.espera.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Item2(
                onTap: () {
                  Navigator.of(c).pop();
                  if (st.cart.isNotEmpty) st.ponerEnEspera();
                  st.recuperar(i);
                },
                trail: const Text('Retomar', style: TextStyle(fontFamily: 'Texto', fontWeight: FontWeight.w700, decoration: TextDecoration.underline)),
                child: Text('${st.espera[i].fold(0, (a, x) => a + x.q)} prendas', style: tx(15, w: FontWeight.w700)),
              ),
            ),
        ]),
      );
}

class _ProdCard extends StatelessWidget {
  final Producto p;
  final VoidCallback onTap;
  const _ProdCard(this.p, this.onTap);
  @override
  Widget build(BuildContext context) {
    final e = p.stock <= 0 ? 'out' : p.stock <= p.v.first.min ? 'low' : 'ok';
    return Opacity(
      opacity: e == 'out' ? 0.55 : 1,
      child: Panel(
        pad: const EdgeInsets.all(10),
        onTap: e == 'out' ? null : onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ProductArt(p, height: 118),
            if (e != 'ok') Positioned(left: 6, top: 6, child: Badge2(e == 'out' ? 'Agotado' : 'Stock bajo', fg: e == 'out' ? C.err : C.warn, bg: e == 'out' ? C.errBg : C.warnBg)),
          ]),
          const SizedBox(height: 10),
          Text(p.nombre, maxLines: 2, overflow: TextOverflow.ellipsis, style: tx(14.5, w: FontWeight.w700, h: 1.2)),
          const SizedBox(height: 2),
          Text('${p.cat} · ${p.v.length > 1 ? p.v.map((v) => v.talla).join(' ') : 'Talla única'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(12, c: C.suave)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(money(p.v.first.precio), style: disp(22)))),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: C.acento, borderRadius: BorderRadius.circular(3)),
              child: const Icon(Icons.add, size: 20, color: Colors.white),
            ),
          ]),
          const SizedBox(height: 2),
          Text('${p.stock} en stock', style: tx(11.5, c: C.suave)),
        ]),
      ),
    );
  }
}

// ───────────── venta actual ─────────────
class CartView extends StatelessWidget {
  final VoidCallback onCobrar;
  final bool panel;
  const CartView({super.key, required this.onCobrar, this.panel = false});
  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final t = st.totals();
    final c = st.cli(st.cust);
    final factura = st.vt == '01';
    final faltaRuc = factura && c.tipo != 'RUC';
    final lines = st.cart.isEmpty
        ? const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: EmptyBox('La venta está vacía', 'Elige una prenda para empezar.'))
        : Column(children: [
            for (var ix = 0; ix < st.cart.length; ix++)
              Builder(builder: (_) {
                final i = st.cart[ix];
                final x = st.vById(i.vid);
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.borde))),
                  child: Row(children: [
                    ProductArt(x.p, size: 54),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(x.p.nombre, style: tx(14, w: FontWeight.w700)),
                        Text('Talla ${x.v.talla} · ${money(x.v.precio)}', style: tx(12.5, c: C.suave)),
                      ]),
                    ),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      StepperQ(i.q, () => st.setQty(ix, -1), () => st.setQty(ix, 1)),
                      const SizedBox(height: 6),
                      Text(money(x.v.precio * i.q), style: tx(14, w: FontWeight.w700)),
                    ]),
                  ]),
                );
              }),
          ]);
    final body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (panel) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('Venta actual', style: tx(16, w: FontWeight.w700))),
      lines,
      const SizedBox(height: 14),
      Panel(
        onTap: () => _cliente(context),
        pad: const EdgeInsets.all(12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Cliente', style: tx(12, c: C.suave)),
              Text(c.nombre, style: tx(15, w: FontWeight.w700)),
              Text('${c.tipo} ${c.doc}', style: tx(12.5, c: C.suave)),
            ]),
          ),
          Text('Cambiar', style: tx(14, w: FontWeight.w700).copyWith(decoration: TextDecoration.underline)),
        ]),
      ),
      const SizedBox(height: 14),
      const Lbl('Comprobante'),
      Seg(items: const [('03', 'Boleta'), ('01', 'Factura')], value: st.vt, onChanged: (v) {
        st.vt = v;
        st.refresh();
      }),
      if (faltaRuc) Padding(padding: const EdgeInsets.only(top: 6), child: Text('La factura necesita un RUC. Elige una empresa o cambia a boleta.', style: tx(13, c: C.err))),
      const SizedBox(height: 14),
      const Lbl('Descuento'),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final d in [0, 5, 10, 15, 20, 30])
          AppChip(d == 0 ? 'Sin descuento' : '$d %', st.disc == d, () {
            if (d > 10 && !st.isSup) {
              requireSup(context, 'Un descuento mayor a 10 % necesita autorización', () {
                st.disc = d;
                st.refresh();
              });
            } else {
              st.disc = d;
              st.refresh();
            }
          }),
      ]),
      const SizedBox(height: 14),
      if (st.envio != null)
        Aviso('Envío a ${st.envio!.dir} · ${money(st.envio!.costo)}${st.envio!.contra ? ' · contra entrega' : ''}', trailing: LinkBtn('Editar', () => envioSheet(context)))
      else
        AppButton('Agregar envío', v: BV.g, sm: true, full: true, onTap: st.cart.isEmpty ? null : () => envioSheet(context)),
      const SizedBox(height: 14),
      Panel(
        color: C.cremaOsc,
        child: Column(children: [
          Row2('Subtotal', money(t.raw)),
          if (t.d > 0) Row2('Descuento (${st.disc} %)', '− ${money(t.d)}', color: C.ok),
          if (t.envio > 0) Row2('Envío', money(t.envio)),
          const Divider(color: C.borde, height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total a cobrar', style: tx(15, w: FontWeight.w700)),
            Text(money(t.pagar), style: disp(32)),
          ]),
          Row2('Incluye Op. Gravada', money(t.base), sub: true),
          Row2('Incluye IGV (${st.sede.igv} %)', money(t.igv), sub: true),
        ]),
      ),
    ]);
    final foot = Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(color: C.blanco, border: Border(top: BorderSide(color: C.borde))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AppButton('Cobrar ${money(t.pagar)}', full: true, size: 18, onTap: st.cart.isNotEmpty && !faltaRuc ? onCobrar : null),
        if (st.cart.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: AppButton('Poner en espera', v: BV.g, sm: true, onTap: st.ponerEnEspera)),
            const SizedBox(width: 8),
            Expanded(child: AppButton('Vaciar', v: BV.g, sm: true, onTap: () {
              final copia = st.cart.map((i) => Item(i.vid, i.q)).toList();
              st.clearCart();
              st.toast('Venta vaciada', undo: () {
                st.cart.addAll(copia);
                st.refresh();
              });
            })),
          ]),
        ],
      ]),
    );
    return Column(children: [
      Expanded(
        child: Scrollbar(
          child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: body),
        ),
      ),
      foot,
    ]);
  }

  void _cliente(BuildContext context) {
    final st = AppScope.read(context);
    var q = '';
    showAppSheet(
      context,
      'Elige un cliente',
      (c) => StatefulBuilder(builder: (c, set) {
        final l = st.clientes.where((x) => q.isEmpty || x.nombre.toLowerCase().contains(q.toLowerCase()) || x.doc.contains(q)).toList();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SearchBox(hint: 'Busca por nombre o documento', onChanged: (v) => set(() => q = v)),
          const SizedBox(height: 12),
          for (final x in l)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Item2(
                onTap: () {
                  st.cust = x.id;
                  st.refresh();
                  Navigator.of(c).pop();
                },
                trail: st.cust == x.id ? const Icon(Icons.check) : null,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(x.nombre, style: tx(15, w: FontWeight.w700)),
                  Text('${x.tipo} ${x.doc}', style: tx(13, c: C.suave)),
                ]),
              ),
            ),
        ]);
      }),
    );
  }
}

void envioSheet(BuildContext context) {
  final st = AppScope.read(context);
  final cl = st.cli(st.cust);
  final e = st.envio;
  final dir = TextEditingController(text: e?.dir ?? cl.dir);
  final ref = TextEditingController(text: e?.ref ?? '');
  final costo = TextEditingController(text: (e?.costo ?? 10).toString());
  var courier = e?.courier ?? 'Olva';
  var contra = e?.contra ?? false;
  var fecha = e?.estimada ?? DateTime.now().add(const Duration(days: 1));
  showAppSheet(
    context,
    'Envío',
    (c) => StatefulBuilder(
      builder: (c, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppField(label: 'Dirección de entrega', ctrl: dir, hint: 'Calle, número, distrito'),
        const SizedBox(height: 12),
        AppField(label: 'Referencia', ctrl: ref, hint: 'Ej: Casa verde, portón negro'),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: AppField(label: 'Costo del envío', ctrl: costo, number: true)),
          const SizedBox(width: 12),
          Expanded(child: DateBox(label: 'Entrega estimada', value: fecha, first: DateTime.now(), onChanged: (d) => set(() => fecha = d))),
        ]),
        const SizedBox(height: 12),
        AppSelect<String>(label: 'Courier', value: courier, options: const [('Olva', 'Olva'), ('Shalom', 'Shalom'), ('Moto propia', 'Moto propia'), ('Recojo', 'Sin courier')], onChanged: (v) => set(() => courier = v)),
        const SizedBox(height: 6),
        CheckBox2(contra, 'Pago contra entrega', (v) => set(() => contra = v)),
        const SizedBox(height: 14),
        AppButton('Guardar envío', full: true, onTap: () {
          if (dir.text.trim().isEmpty) {
            st.toast('Escribe la dirección de entrega');
            return;
          }
          st.envio = EnvioDatos(dir.text.trim(), ref.text.trim(), double.tryParse(costo.text) ?? 0, courier, contra, fecha);
          st.refresh();
          Navigator.of(c).pop();
        }),
        if (e != null) ...[
          const SizedBox(height: 8),
          AppButton('Quitar envío', v: BV.d, full: true, onTap: () {
            st.envio = null;
            st.refresh();
            Navigator.of(c).pop();
          }),
        ],
      ]),
    ),
  );
}

// ───────────── cobro ─────────────
void openCobro(BuildContext context) {
  final st = AppScope.read(context);
  final t = st.totals();
  final c = st.cli(st.cust);
  if (st.vt == '01' && c.tipo != 'RUC') {
    st.toast('La factura necesita un RUC');
    return;
  }
  if (st.vt == '03' && t.pagar >= 700 && c.id == 'c0') {
    st.toast('Desde S/ 700 la boleta debe llevar el documento del cliente');
    return;
  }
  showAppSheet(context, 'Cobrar', (_) => const CobroView());
}

class _PagoEd {
  final Pago p;
  final TextEditingController monto, rec, ref;
  _PagoEd(this.p)
      : monto = TextEditingController(text: p.monto.toString()),
        rec = TextEditingController(),
        ref = TextEditingController();
}

class CobroView extends StatefulWidget {
  const CobroView({super.key});
  @override
  State<CobroView> createState() => _CobroViewState();
}

class _CobroViewState extends State<CobroView> {
  late final List<_PagoEd> pagos;
  late final bool contra;
  int fase = 0; // 0 formulario, 1 emitiendo, 2 resultado
  double prog = 0.1;
  String msg = 'Firmando comprobante…';
  Comprobante? comp;
  double vuelto = 0, totalVenta = 0;
  bool init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!init) {
      init = true;
      final st = AppScope.read(context);
      contra = st.envio?.contra ?? false;
      pagos = [_PagoEd(Pago('efectivo', st.totals().pagar))];
    }
  }

  double _suma() => double.parse(pagos.fold<double>(0, (a, p) => a + (double.tryParse(p.monto.text) ?? 0)).toStringAsFixed(2));
  bool _ok(AppState st) {
    if (contra) return true;
    final f = double.parse((st.totals().pagar - _suma()).toStringAsFixed(2));
    if (f.abs() >= 0.005) return false;
    for (final p in pagos) {
      if (p.p.medio == 'efectivo' && p.rec.text.isNotEmpty && (double.tryParse(p.rec.text) ?? 0) < (double.tryParse(p.monto.text) ?? 0)) return false;
    }
    return true;
  }

  Future<void> _emitir(AppState st) async {
    final t = st.totals();
    for (final i in st.cart) {
      final x = st.vById(i.vid);
      if (i.q > x.v.stock) {
        st.toast('El stock cambió: de ${x.p.nombre} ${x.v.talla} quedan ${x.v.stock}');
        Navigator.of(context).pop();
        return;
      }
    }
    totalVenta = t.pagar;
    final lista = [
      for (final p in pagos)
        Pago(p.p.medio, double.tryParse(p.monto.text) ?? 0, ref: p.ref.text, recibido: p.rec.text.isEmpty ? null : double.tryParse(p.rec.text)),
    ];
    setState(() => fase = 1);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    if (st.sunat) {
      setState(() {
        prog = 0.55;
        msg = 'Enviando a SUNAT…';
      });
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
    }
    setState(() {
      prog = 1;
      msg = st.sunat ? '¡Listo!' : 'Comprobante guardado';
    });
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    final (c, v) = st.registrarVenta(lista, contra);
    setState(() {
      comp = c;
      vuelto = v;
      fase = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    if (fase == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: prog, minHeight: 8, color: C.acento, backgroundColor: C.cremaOsc),
          ),
          const SizedBox(height: 18),
          Text(msg, style: tx(16, w: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('No cierres esta pantalla.', style: tx(13, c: C.suave)),
        ]),
      );
    }
    if (fase == 2) return _resultado(st);
    final t = st.totals();
    final falta = double.parse((t.pagar - _suma()).toStringAsFixed(2));
    final usados = pagos.map((p) => p.p.medio).toSet();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: C.acento, borderRadius: BorderRadius.circular(R.card)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Total a cobrar', style: tx(13, c: const Color(0xFFE9F7FF))),
          Text(money(t.pagar), style: disp(52, c: Colors.white)),
        ]),
      ),
      const SizedBox(height: 14),
      if (contra)
        const Aviso('Pago contra entrega: el cobro se registra cuando se entregue el pedido.')
      else ...[
        for (var i = 0; i < pagos.length; i++) _pagoCard(st, i),
        Aviso(falta.abs() < 0.005 ? 'El pago está completo' : falta > 0 ? 'Faltan ${money(falta)}' : 'Sobran ${money(-falta)}', k: falta.abs() < 0.005 ? BK.ok : BK.warn),
        if (pagos.length < 3) ...[
          const SizedBox(height: 14),
          const Lbl('Agregar otro medio de pago'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final m in medios.where((m) => !usados.contains(m.id)))
              AppChip(m.n, false, () => setState(() {
                    final rest = falta > 0 ? falta : 0.0;
                    final p = _PagoEd(Pago(m.id, rest));
                    pagos.add(p);
                  })),
          ]),
        ],
      ],
      const SizedBox(height: 18),
      AppButton(contra ? 'Confirmar pedido' : 'Confirmar cobro', full: true, size: 18, onTap: _ok(st) ? () => _emitir(st) : null),
    ]);
  }

  Widget _pagoCard(AppState st, int i) {
    final p = pagos[i];
    final monto = double.tryParse(p.monto.text) ?? 0;
    final rec = p.rec.text.isEmpty ? monto : (double.tryParse(p.rec.text) ?? 0);
    final vuelto = p.p.medio == 'efectivo' ? (rec - monto).clamp(0, double.infinity) : 0.0;
    final sug = {(monto / 10).ceil() * 10, (monto / 50).ceil() * 50, (monto / 100).ceil() * 100}.where((x) => x >= monto && x > 0).take(3).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(medioN(p.p.medio), style: tx(16, w: FontWeight.w700)),
            if (pagos.length > 1) LinkBtn('Quitar', () => setState(() => pagos.removeAt(i)), color: C.err),
          ]),
          const SizedBox(height: 10),
          AppField(label: 'Monto', ctrl: p.monto, number: true, onChanged: (_) => setState(() {})),
          const SizedBox(height: 10),
          if (p.p.medio == 'efectivo') ...[
            AppField(label: 'Dinero recibido', ctrl: p.rec, number: true, hint: monto.toString(), onChanged: (_) => setState(() {})),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              AppChip('Exacto', false, () => setState(() => p.rec.text = monto.toString())),
              for (final s in sug) AppChip('S/ $s', false, () => setState(() => p.rec.text = s.toString())),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Vuelto a entregar', style: tx(14, c: C.suave)),
              Text(money(vuelto), style: disp(26)),
            ]),
          ] else
            AppField(label: 'N.º de operación (opcional)', ctrl: p.ref, hint: 'Ej: 849102'),
        ]),
      ),
    );
  }

  Widget _resultado(AppState st) {
    final c = comp!;
    final ok = c.estado == 'Aceptado';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Aviso(ok ? 'Aceptado por SUNAT' : 'Venta guardada. El comprobante se enviará a SUNAT cuando haya conexión', k: ok ? BK.ok : BK.warn),
      const SizedBox(height: 14),
      Center(child: Text(c.nombre, style: tx(14, c: C.suave))),
      Center(child: Text(c.numero, style: tx(22, w: FontWeight.w700))),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: C.acento, borderRadius: BorderRadius.circular(R.card)),
        child: Column(children: [
          Text('Total', style: tx(13, c: const Color(0xFFE9F7FF))),
          Text(money(totalVenta), style: disp(48, c: Colors.white)),
        ]),
      ),
      if (vuelto > 0) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: C.okBg, borderRadius: BorderRadius.circular(R.card)),
          child: Column(children: [
            Text('Vuelto a entregar', style: tx(13, w: FontWeight.w700, c: C.ok)),
            Text(money(vuelto), style: disp(44, c: C.ok)),
          ]),
        ),
      ],
      if (contra) ...[const SizedBox(height: 10), const Aviso('Pedido contra entrega: el cobro quedó pendiente.')],
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: AppButton('Imprimir', v: BV.s, sm: true, onTap: () => st.toast('Enviado a la impresora (demo)'))),
        const SizedBox(width: 10),
        Expanded(child: AppButton('WhatsApp', v: BV.s, sm: true, onTap: () => st.toast('Comprobante enviado por WhatsApp (demo)'))),
      ]),
      const SizedBox(height: 10),
      AppButton('Nueva venta', full: true, onTap: () => Navigator.of(context).pop()),
    ]);
  }
}
