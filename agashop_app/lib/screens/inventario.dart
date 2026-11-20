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

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});
  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  late String f;
  String q = '';
  @override
  void initState() {
    super.initState();
    f = AppScope.read(context).filtro == 'bajo' ? 'Stock bajo' : 'Todos';
  }

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final ql = q.toLowerCase().trim();
    final l = st.prod.where((p) {
      final okQ = ql.isEmpty || p.nombre.toLowerCase().contains(ql) || p.v.any((v) => v.sku.toLowerCase().contains(ql));
      final okF = f == 'Todos' || (f == 'Disponible' && p.estado == 'ok') || (f == 'Stock bajo' && p.estado == 'low') || (f == 'Agotado' && p.estado == 'out');
      return okQ && okF;
    }).toList();
    return ScreenPage('inventario',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 320), child: SearchBox(hint: 'Busca por nombre o código', onChanged: (v) => setState(() => q = v)))),
            const SizedBox(width: 10),
            AppButton('Nuevo', sm: true, icon: Icons.add, onTap: () => requireSup(context, 'Crear un producto necesita autorización', () => _nuevo(context))),
          ]),
          const SizedBox(height: 12),
          TextTabs(items: const ['Todos', 'Disponible', 'Stock bajo', 'Agotado'], value: f, onChanged: (v) => setState(() => f = v)),
          const SizedBox(height: 14),
          if (l.isEmpty)
            const EmptyBox('No hay prendas con ese filtro', 'Prueba con otro estado o limpia la búsqueda.')
          else
            FlowGrid(minWidth: 340, children: [
              for (final p in l)
                PastelCard(
                  tono: Pastel.deColor(p.color),
                  pill: p.base,
                  esquina: p.estado == 'out' ? Icons.block : p.estado == 'low' ? Icons.warning_amber_rounded : Icons.check,
                  label: '${p.cat} · ${p.marca}',
                  title: p.nombre,
                  logo: ProductArt(p, size: 46),
                  tags: [p.estado == 'out' ? 'Agotado' : p.estado == 'low' ? 'Stock bajo' : 'Disponible', for (final v in p.v) '${v.talla}: ${v.stock}'],
                  big: money(p.v.first.precio),
                  small: '${p.stock} en stock',
                  onTap: () => _detalle(context, p),
                ),
            ]),
        ]));
  }

  void _detalle(BuildContext context, Producto p) {
    var sel = p.v.indexOf(p.v.firstWhere((v) => v.stock > 0, orElse: () => p.v.first));
    showAppSheet(context, p.nombre, (c) {
      AppScope.of(c); // se vuelve a dibujar cuando cambia el stock
      return StatefulBuilder(builder: (c, set) {
        final v = p.v[sel];
        final est = p.estado;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ProductArt(p, height: 210),
          const SizedBox(height: 14),
          Wrap(spacing: 6, runSpacing: 6, children: [
            Badge2(p.cat, fg: C.negro, bg: C.cremaOsc),
            Badge2(est == 'out' ? 'Agotado' : est == 'low' ? 'Stock bajo' : 'Disponible', fg: est == 'out' ? C.err : est == 'low' ? C.warn : C.ok, bg: est == 'out' ? C.errBg : est == 'low' ? C.warnBg : C.okBg),
          ]),
          const SizedBox(height: 10),
          Text(p.nombre, style: tx(22, w: FontWeight.w800, h: 1.15, ls: -0.5)),
          const SizedBox(height: 4),
          Text('${p.marca} · código ${p.base}', style: tx(13, c: C.suave)),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(money(v.precio), style: tx(26, w: FontWeight.w800, ls: -0.5)),
            const SizedBox(width: 10),
            Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('Costo ${money(v.costo)}', style: tx(13, c: C.gris))),
          ]),
          const Divider(height: 28, color: C.borde),
          Text('Color: ${v.color}', style: tx(13, w: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(children: [
            for (final col in {for (final x in p.v) x.color}.toList())
              Container(
                width: 34,
                height: 34,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: col == v.color ? C.negro : C.borde, width: 1.6)),
                child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: colorHex[col] ?? C.gris)),
              ),
          ]),
          const SizedBox(height: 16),
          Text('Talla: ${v.talla}', style: tx(13, w: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (var i = 0; i < p.v.length; i++)
              GestureDetector(
                onTap: () => set(() => sel = i),
                child: Container(
                  width: 54,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sel == i ? C.negro : C.blanco,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: sel == i ? C.negro : (p.v[i].stock <= 0 ? C.borde : C.gris)),
                  ),
                  child: Text(p.v[i].talla, style: tx(14, w: FontWeight.w600, c: sel == i ? Colors.white : (p.v[i].stock <= 0 ? C.gris : C.negro)).copyWith(decoration: p.v[i].stock <= 0 && sel != i ? TextDecoration.lineThrough : null)),
                ),
              ),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _dato('En stock', '${v.stock}', v.stock <= 0 ? C.err : v.stock <= v.min ? C.warn : C.negro)),
            const SizedBox(width: 10),
            Expanded(child: _dato('Aviso de reposición', '${v.min}', C.negro)),
            const SizedBox(width: 10),
            Expanded(child: _dato('Código', v.sku.split('-').skip(1).join('-'), C.negro, chico: true)),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: AppButton('Ajustar stock', full: true, icon: Icons.tune, onTap: () => requireSup(c, 'Ajustar el stock necesita autorización', () => _ajuste(c, p, v)))),
            const SizedBox(width: 10),
            AppButton('Vender', v: BV.g, icon: Icons.shopping_bag_outlined, onTap: () {
              Navigator.of(c).pop();
              AppScope.read(context).go('vender');
            }),
          ]),
        ]);
      });
    });
  }

  Widget _dato(String t, String v, Color col, {bool chico = false}) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: C.fondo, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(11.5, c: C.suave)),
          const SizedBox(height: 4),
          Text(v, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(chico ? 12.5 : 20, w: FontWeight.w800, c: col)),
        ]),
      );

  void _ajuste(BuildContext context, Producto p, Variante v) {
    final st = AppScope.read(context);
    var tipo = 'Entrada';
    var motivo = motivosAjuste['Entrada']!.first;
    final cant = TextEditingController(text: '1');
    showAppSheet(
      context,
      'Ajustar stock',
      (c) => StatefulBuilder(
        builder: (c, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${p.nombre} · talla ${v.talla}', style: tx(16, w: FontWeight.w700)),
          Text('Stock actual: ${v.stock}', style: tx(14, c: C.suave)),
          const SizedBox(height: 14),
          Seg(items: const [('Entrada', 'Sube el stock'), ('Salida', 'Baja el stock')], value: tipo, onChanged: (x) => set(() {
                tipo = x;
                motivo = motivosAjuste[x]!.first;
              })),
          const SizedBox(height: 14),
          AppField(label: 'Cantidad', ctrl: cant, number: true),
          const SizedBox(height: 14),
          AppSelect<String>(label: 'Motivo', value: motivo, options: [for (final m in motivosAjuste[tipo]!) (m, m)], onChanged: (x) => set(() => motivo = x)),
          const SizedBox(height: 18),
          AppButton('Guardar ajuste', full: true, onTap: () {
            final n = int.tryParse(cant.text) ?? 0;
            if (n <= 0) {
              st.toast('Escribe una cantidad válida');
              return;
            }
            if (tipo == 'Salida' && n > v.stock) {
              st.toast('No puedes sacar más de lo que hay (${v.stock})');
              return;
            }
            Navigator.of(c).pop();
            st.ajustar(v.id, tipo, n, motivo);
            st.toast('Stock ajustado');
          }),
        ]),
      ),
    );
  }

  void _nuevo(BuildContext context) {
    final st = AppScope.read(context);
    final nombre = TextEditingController(), precio = TextEditingController(), costo = TextEditingController(), stock = TextEditingController(text: '5');
    var cat = categorias.first;
    showAppSheet(
      context,
      'Nuevo producto',
      (c) => StatefulBuilder(
        builder: (c, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppField(label: 'Nombre de la prenda', ctrl: nombre, hint: 'Ej: Falda Plisada Negra'),
          const SizedBox(height: 12),
          AppSelect<String>(label: 'Categoría', value: cat, options: [for (final x in categorias) (x, x)], onChanged: (x) => set(() => cat = x)),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: AppField(label: 'Precio de venta', ctrl: precio, number: true, hint: '0.00')),
            const SizedBox(width: 12),
            Expanded(child: AppField(label: 'Costo', ctrl: costo, number: true, hint: '0.00')),
          ]),
          const SizedBox(height: 12),
          AppField(label: 'Stock inicial (talla única)', ctrl: stock, number: true),
          const SizedBox(height: 18),
          AppButton('Crear producto', full: true, onTap: () {
            final pr = double.tryParse(precio.text);
            if (nombre.text.trim().isEmpty || pr == null || pr <= 0) {
              st.toast('Completa el nombre y el precio');
              return;
            }
            final id = 'p${st.uid()}';
            final base = '${cat.substring(0, 3).toUpperCase()}-${(st.prod.length + 1).toString().padLeft(3, '0')}';
            st.agregarProducto(Producto(id, nombre.text.trim(), cat, 'Línea Propia', base,
                [Variante('$id-Único', '$base-UNI-Único', 'Único', 'Crudo', pr, double.tryParse(costo.text) ?? 0, 3, int.tryParse(stock.text) ?? 0)]));
            Navigator.of(c).pop();
            st.toast('Producto creado');
          }),
        ]),
      ),
    );
  }
}
