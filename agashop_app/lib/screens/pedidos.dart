import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../layouts/shell.dart';
import '../state/app_state.dart';
import '../widgets/ui.dart';
import '../widgets/product_art.dart';
import '../widgets/pastel_card.dart';
import '../widgets/mapa.dart';
import 'timeline_widget.dart';

const _pf = ['Todos', 'Atrasados', 'Con problemas'];
const _cols = ['Pendiente', 'Preparando', 'Listo para enviar', 'En camino', 'Entregado', 'Con problemas'];

bool _problema(Delivery d) => const ['Fallido', 'Devuelto a tienda', 'Cancelado'].contains(d.estado);
bool _match(Delivery d, String f) => f == 'Todos' || (f == 'Atrasados' && d.atrasado) || (f == 'Con problemas' && _problema(d));
String _col(Delivery d) => _problema(d) ? 'Con problemas' : d.estado;

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});
  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  late String f;
  @override
  void initState() {
    super.initState();
    final x = AppScope.read(context).filtro;
    f = x == 'atrasados' ? 'Atrasados' : 'Todos';
  }

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final ff = ffOf(context);
    final l = st.deliveries.where((d) => _match(d, f)).toList();
    final ancho = ff == FF.phone ? 288.0 : 296.0;
    return ScreenPage('pedidos',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextTabs(
            items: _pf,
            value: f,
            onChanged: (v) => setState(() => f = v),
            counts: {for (final k in _pf) k: st.deliveries.where((d) => _match(d, k)).length},
          ),
          const SizedBox(height: 16),
          Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                for (final c in _cols)
                  Container(
                    width: ancho,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
                        child: Row(children: [
                          Text(c.toUpperCase(), style: tx(11.5, w: FontWeight.w700, c: C.suave, ls: 0.8)),
                          const SizedBox(width: 8),
                          Text('${l.where((d) => _col(d) == c).length}', style: tx(11.5, c: C.gris)),
                        ]),
                      ),
                      if (l.where((d) => _col(d) == c).isEmpty)
                        Container(
                          height: 96,
                          decoration: BoxDecoration(color: C.cremaOsc.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(R.card), border: Border.all(color: C.borde)),
                        )
                      else
                        for (final d in l.where((d) => _col(d) == c))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Builder(builder: (_) {
                              final v = st.venta(d.ventaId);
                              final cl = st.cli(v.cli);
                              final x = st.vById(v.items.first.vid);
                              return PastelCard(
                                tono: switch (c) {
                                  'Pendiente' => Pastel.durazno,
                                  'Preparando' => Pastel.lavanda,
                                  'Listo para enviar' => Pastel.cielo,
                                  'En camino' => Pastel.menta,
                                  'Entregado' => Pastel.gris,
                                  _ => Pastel.rosa,
                                },
                                pill: 'Entrega ${dm(d.estimada)}',
                                label: '${v.items.fold(0, (a, i) => a + i.q)} prendas · ${d.courier.isNotEmpty ? d.courier : 'Sin courier'}',
                                title: cl.nombre,
                                logo: ProductArt(x.p, size: 30),
                                tags: [if (d.atrasado) 'Atrasado', if (d.contra) 'Contra entrega', if (_problema(d)) d.estado],
                                big: money(v.total),
                                small: d.dir,
                                onTap: () => detallePedido(context, d),
                              );
                            }),
                          ),
                    ]),
                  ),
              ]),
            ),
          ),
        ]));
  }
}

void detallePedido(BuildContext context, Delivery d) {
  showAppSheet(context, 'Pedido', (c) {
    final st = AppScope.of(c);
    final v = st.venta(d.ventaId);
    final cl = st.cli(v.cli);
    final i = estadosPedido.indexOf(d.estado);
    final next = i >= 0 && i < estadosPedido.length - 1 ? estadosPedido[i + 1] : null;
    final items = [
      for (final it in v.items) () {
        final x = st.vById(it.vid);
        return '${x.p.nombre} · talla ${x.v.talla} × ${it.q}';
      }()
    ];
    final prep = d.estado == 'Preparando';
    final todas = List.generate(items.length, (k) => d.chk.contains(k)).every((e) => e);
    Widget accion;
    if (d.estado == 'Entregado' || d.estado == 'Cancelado' || d.estado == 'Devuelto a tienda') {
      accion = Aviso(d.estado == 'Entregado' ? 'Pedido entregado' : 'Pedido cerrado', k: d.estado == 'Entregado' ? BK.ok : BK.warn);
    } else if (d.estado == 'Fallido') {
      accion = Row(children: [
        Expanded(child: AppButton('Reprogramar', onTap: () {
          st.avanzar(d, 'Listo para enviar', 'Reprogramado');
          d.estimada = DateTime.now().add(const Duration(days: 1));
        })),
        const SizedBox(width: 10),
        Expanded(child: AppButton('Devolver a tienda', v: BV.s, onTap: () {
          for (final it in v.items) {
            st.mov(it.vid, 'DEVOLUCION', it.q, 'Pedido devuelto', 'No se pudo entregar');
          }
          st.avanzar(d, 'Devuelto a tienda');
        })),
      ]);
    } else if (d.estado == 'En camino') {
      accion = Row(children: [
        Expanded(child: AppButton('Marcar entregado', onTap: () => st.avanzar(d, 'Entregado'))),
        const SizedBox(width: 10),
        Expanded(child: AppButton('No se pudo entregar', v: BV.s, onTap: () => st.avanzar(d, 'Fallido', 'No se pudo entregar'))),
      ]);
    } else {
      accion = AppButton('Marcar como ${next!.toLowerCase()}', full: true, onTap: prep && !todas ? null : () => st.avanzar(d, next, next == 'En camino' && d.guia.isNotEmpty ? 'Guía ${d.guia}' : ''));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Badge2.estado(d.estado),
        Text('${d.atrasado ? 'Atrasado · ' : ''}Entrega estimada ${dm(d.estimada)}', style: tx(13, c: d.atrasado ? C.err : C.suave, w: d.atrasado ? FontWeight.w700 : FontWeight.w400)),
      ]),
      const SizedBox(height: 14),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(cl.nombre, style: tx(16, w: FontWeight.w700)),
          Text(d.dir, style: tx(14, c: C.suave)),
          if (d.ref.isNotEmpty) Text('Referencia: ${d.ref}', style: tx(14, c: C.suave)),
          if (cl.tel.isNotEmpty) Text('Teléfono: ${cl.tel}', style: tx(14, w: FontWeight.w700)),
          if (d.courier.isNotEmpty) Text('Courier: ${d.courier}${d.guia.isNotEmpty ? ' · Guía ${d.guia}' : ''}', style: tx(14)),
          if (d.contra) Padding(padding: const EdgeInsets.only(top: 6), child: Row(children: [const Badge2('Contra entrega', fg: C.info, bg: C.infoBg), const SizedBox(width: 8), Text(money(v.total), style: tx(14, w: FontWeight.w700))])),
        ]),
      ),
      const SizedBox(height: 14),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _campo('Dirección', d.dir)),
        const SizedBox(width: 12),
        Expanded(child: _campo('Distrito', d.dir.contains(',') ? d.dir.split(',').last.trim() : 'Lima')),
      ]),
      const SizedBox(height: 12),
      MapaSeguimiento(d: d, barrio: d.dir.contains(',') ? d.dir.split(',').last.trim() : ''),
      if (prep) ...[
        const SizedBox(height: 14),
        const Lbl('Verifica las prendas del pedido'),
        for (var k = 0; k < items.length; k++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Item2(
              onTap: () {
                d.chk.contains(k) ? d.chk.remove(k) : d.chk.add(k);
                st.refresh();
              },
              lead: d.chk.contains(k) ? const Badge2('✓ Lista', fg: C.ok, bg: C.okBg) : const Badge2('Pendiente', fg: C.suave, bg: C.cremaOsc),
              child: Text(items[k], style: tx(14)),
            ),
          ),
      ],
      const SizedBox(height: 14),
      accion,
      if (!const ['Entregado', 'Cancelado', 'Devuelto a tienda', 'En camino'].contains(d.estado)) ...[
        const SizedBox(height: 8),
        AppButton('Cancelar pedido', v: BV.d, full: true, onTap: () => requireSup(c, 'Cancelar un pedido necesita autorización', () {
              for (final it in v.items) {
                st.mov(it.vid, 'DEVOLUCION', it.q, 'Pedido cancelado', 'Pedido cancelado');
              }
              st.avanzar(d, 'Cancelado');
            })),
      ],
      const SizedBox(height: 20),
      Text('Seguimiento', style: tx(16, w: FontWeight.w700)),
      const SizedBox(height: 10),
      TimelinePedido(d),
    ]);
  });
}


Widget _campo(String t, String v) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t, style: tx(12, c: C.suave)),
      const SizedBox(height: 3),
      Text(v, maxLines: 2, overflow: TextOverflow.ellipsis, style: tx(13.5, w: FontWeight.w600)),
    ]);
