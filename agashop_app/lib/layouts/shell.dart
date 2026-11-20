import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../screens/caja.dart';
import '../screens/clientes.dart';
import '../screens/comprobantes.dart';
import '../screens/compras.dart';
import '../screens/config.dart';
import '../screens/inicio.dart';
import '../screens/inventario.dart';
import '../screens/kardex.dart';
import '../screens/mas.dart';
import '../screens/pedidos.dart';
import '../screens/vender.dart';
import '../state/app_state.dart';
import '../widgets/ui.dart';

typedef NavDef = (String key, String label, IconData icon);

const navMobile = <NavDef>[
  ('inicio', 'Inicio', Icons.home_outlined),
  ('vender', 'Vender', Icons.shopping_bag_outlined),
  ('pedidos', 'Pedidos', Icons.local_shipping_outlined),
  ('inventario', 'Inventario', Icons.checkroom_outlined),
  ('mas', 'Más', Icons.menu),
];
const navPrincipal = <NavDef>[
  ('inicio', 'Inicio', Icons.home_outlined),
  ('vender', 'Vender', Icons.shopping_bag_outlined),
  ('pedidos', 'Pedidos', Icons.local_shipping_outlined),
  ('inventario', 'Inventario', Icons.checkroom_outlined),
];
const navAdmin = <NavDef>[
  ('caja', 'Caja', Icons.payments_outlined),
  ('comprobantes', 'Comprobantes', Icons.receipt_long_outlined),
  ('clientes', 'Clientes', Icons.people_outline),
  ('compras', 'Compras', Icons.move_to_inbox_outlined),
  ('kardex', 'Historial', Icons.history),
  ('config', 'Tienda', Icons.settings_outlined),
];
const navFull = <NavDef>[...navPrincipal, ...navAdmin];

const tituloVista = {
  'vender': 'Vender',
  'pedidos': 'Pedidos',
  'inventario': 'Inventario',
  'mas': 'Más opciones',
  'caja': 'Caja',
  'comprobantes': 'Comprobantes',
  'clientes': 'Clientes',
  'compras': 'Compras',
  'kardex': 'Historial de movimientos',
  'config': 'Tienda',
};

Widget screenFor(String v) => switch (v) {
      'inicio' => const InicioScreen(),
      'vender' => const VenderScreen(),
      'pedidos' => const PedidosScreen(),
      'inventario' => const InventarioScreen(),
      'mas' => const MasScreen(),
      'caja' => const CajaScreen(),
      'comprobantes' => const ComprobantesScreen(),
      'clientes' => const ClientesScreen(),
      'compras' => const ComprasScreen(),
      'kardex' => const KardexScreen(),
      _ => const ConfigScreen(),
    };

// ───────────── encabezado de cada pantalla ─────────────
class Band extends StatelessWidget {
  final String view;
  final bool compact;
  const Band(this.view, {super.key, this.compact = false});
  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final ff = ffOf(context);
    final a = st.alerts();
    final nom = st.user.nombre.split(' ').first;
    final enCurso = st.deliveries.where((d) => !d.cerrado).length;
    final t = st.turnoAbierto;
    final tn = t == null ? null : st.turnosDef.firstWhere((x) => x.id == t.turno);
    final sub = switch (view) {
      'inicio' => '${fechaLarga(DateTime.now())}${tn != null ? ' · Turno ${tn.n.toLowerCase()}' : ''}',
      'vender' => 'Busca o escanea una prenda y cobra',
      'pedidos' => '$enCurso en curso · ${a.atr} atrasados',
      'inventario' => '${st.prod.length} prendas · ${a.bajo} tallas por reponer',
      'mas' => 'Lo demás de tu tienda',
      'caja' => t != null ? 'Tu turno está abierto' : 'Tu caja está cerrada',
      'comprobantes' => a.pend > 0 ? '${a.pend} por revisar' : 'Todo al día',
      'clientes' => '${st.clientes.length} registrados',
      'compras' => 'Recibe mercadería y sube el stock',
      'kardex' => 'Qué pasó con el stock de cada talla',
      _ => 'Lo que necesita tu tienda para vender',
    };
    final titulo = view == 'inicio' ? 'Hola, $nom' : (tituloVista[view] ?? '');
    final size = compact ? 22.0 : switch (ff) { FF.phone => 28.0, FF.tablet => 34.0, FF.desktop => 40.0 };
    final pad = ff == FF.phone ? 12.0 : 24.0;
    final seccion = view == 'inicio' ? 'Inicio' : (tituloVista[view] ?? '');
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, compact ? 10 : 14, pad, compact ? 4 : 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ff == FF.phone ? 22 : 28),
            child: Container(
              width: double.infinity,
              color: C.lila,
              padding: EdgeInsets.fromLTRB(ff == FF.phone ? 20 : 30, compact ? 16 : (ff == FF.desktop ? 30 : 22), 20, compact ? 16 : (ff == FF.desktop ? 30 : 22)),
              child: Stack(children: [
                Positioned(right: -40, top: -60, child: Container(width: 210, height: 210, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.10)))),
                Positioned(right: 70, bottom: -50, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.10)))),
                if (!compact) const Positioned(right: 24, top: 4, child: Icon(Icons.auto_awesome, color: Colors.white70, size: 22)),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (!compact) ...[
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.auto_awesome, size: 13, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(seccion, style: tx(12.5, w: FontWeight.w600, c: Colors.white)),
                    ]),
                    const SizedBox(height: 8),
                  ],
                  Text(titulo, style: TextStyle(fontFamily: 'Texto', fontSize: size, fontWeight: FontWeight.w800, color: Colors.white, height: 1.05, letterSpacing: -1)),
                  if (!compact) ...[
                    const SizedBox(height: 8),
                    Text(sub, style: tx(14, c: const Color(0xFFE9F7FF))),
                  ],
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Página con scroll vertical: encabezado + contenido centrado sobre fondo suave.
class ScreenPage extends StatelessWidget {
  final String view;
  final Widget child;
  const ScreenPage(this.view, {super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final ff = ffOf(context);
    final pad = ff == FF.phone ? 12.0 : 24.0;
    return Scrollbar(
      child: SingleChildScrollView(
        child: Column(children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: SizedBox(width: double.infinity, child: Padding(padding: EdgeInsets.all(pad), child: child)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ───────────── barra superior ─────────────
class TopBar extends StatelessWidget {
  final bool brand;
  const TopBar({super.key, this.brand = true});
  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final ff = ffOf(context);
    final sub = ff == FF.phone && kSubs.contains(st.view);
    final u = st.user;
    final seccion = st.view == 'inicio' ? 'Inicio' : (tituloVista[st.view] ?? '');
    return Container(
      height: 56,
      decoration: const BoxDecoration(color: C.blanco, border: Border(bottom: BorderSide(color: C.borde))),
      padding: EdgeInsets.symmetric(horizontal: ff == FF.phone ? 6 : 18),
      child: Row(children: [
        if (sub) IconBtn(Icons.arrow_back, () => st.go('mas'), tip: 'Volver'),
        if (brand) ...[
          if (!sub) const SizedBox(width: 10),
          const Brand(),
        ] else ...[
          Text('AgaShop', style: tx(13, c: C.gris)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.chevron_right, size: 16, color: C.gris)),
          Text(seccion, style: tx(13, w: FontWeight.w500)),
        ],
        const Spacer(),
        if (ff == FF.phone) Flexible(child: _Sunat(st.sunat, true)) else _Sunat(st.sunat, false),
        const SizedBox(width: 12),
        InkWell(
          onTap: () => _cuenta(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(children: [
              Avatar(u.nombre[0], 32),
              if (ff != FF.phone) ...[
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(u.nombre.split(' ').first, style: tx(13, w: FontWeight.w700)),
                  Text(roles[u.rol]!, style: tx(11, c: C.gris)),
                ]),
                const SizedBox(width: 6),
              ],
            ]),
          ),
        ),
      ]),
    );
  }

  void _cuenta(BuildContext context) {
    final st = AppScope.read(context);
    showAppSheet(context, 'Tu cuenta', (c) {
      final u = st.user;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Item2(
          lead: Avatar(u.nombre[0], 48),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(u.nombre, style: tx(16, w: FontWeight.w700)),
            Text('${roles[u.rol]} · ${u.user}', style: tx(13, c: C.suave)),
          ]),
        ),
        const SizedBox(height: 16),
        AppButton('Cerrar sesión', v: BV.g, full: true, onTap: () {
          Navigator.of(c).pop();
          st.logout();
        }),
      ]);
    });
  }
}

class Avatar extends StatelessWidget {
  final String letra;
  final double size;
  const Avatar(this.letra, this.size, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: C.acento, shape: BoxShape.circle),
        child: Text(letra, style: tx(size * 0.42, w: FontWeight.w700, c: Colors.white)),
      );
}

class Brand extends StatelessWidget {
  final Color color;
  final bool claro;
  const Brand({super.key, this.color = C.negro, this.claro = false});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: claro ? Colors.white : C.acento, borderRadius: BorderRadius.circular(6)),
          child: Text('A', style: tx(17, w: FontWeight.w700, c: claro ? C.acento : Colors.white)),
        ),
        const SizedBox(width: 10),
        Text('AgaShop', style: tx(18, w: FontWeight.w700, c: color, ls: -0.3)),
      ]);
}

class _Sunat extends StatelessWidget {
  final bool on, corto;
  const _Sunat(this.on, this.corto);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: on ? C.okBg : C.warnBg, borderRadius: BorderRadius.circular(R.chip)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: on ? C.ok : C.warn, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(corto ? (on ? 'SUNAT' : 'Sin SUNAT') : (on ? 'SUNAT conectado' : 'Sin conexión con SUNAT'),
                overflow: TextOverflow.ellipsis, style: tx(12, w: FontWeight.w600, c: on ? C.ok : C.warn)),
          ),
        ]),
      );
}

// ───────────── menú ─────────────
class _NavBadge extends StatelessWidget {
  final int n;
  const _NavBadge(this.n);
  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 18),
        height: 18,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: C.err, borderRadius: BorderRadius.circular(9)),
        child: Text('$n', style: tx(11, w: FontWeight.w700, c: Colors.white)),
      );
}

class Shell extends StatelessWidget {
  const Shell({super.key});
  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final ff = ffOf(context);
    final body = KeyedSubtree(key: ValueKey(st.view), child: screenFor(st.view));
    switch (ff) {
      case FF.phone:
        final act = kSubs.contains(st.view) ? 'mas' : st.view;
        return Scaffold(
          backgroundColor: C.fondo,
          body: SafeArea(bottom: false, child: Column(children: [const TopBar(), Expanded(child: body)])),
          bottomNavigationBar: _BottomNav(act),
        );
      case FF.tablet:
        return Scaffold(
          backgroundColor: C.fondo,
          body: Row(children: [
            _Rail(st.view),
            Expanded(child: Column(children: [const TopBar(brand: false), Expanded(child: body)])),
          ]),
        );
      case FF.desktop:
        return Scaffold(
          backgroundColor: C.fondo,
          body: Row(children: [
            _Sidebar(st.view),
            Expanded(child: Column(children: [const TopBar(brand: false), Expanded(child: body)])),
          ]),
        );
    }
  }
}

class _BottomNav extends StatelessWidget {
  final String act;
  const _BottomNav(this.act);
  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final a = st.alerts();
    return Container(
      decoration: const BoxDecoration(color: C.blanco, border: Border(top: BorderSide(color: C.borde))),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(children: [
            for (final (k, l, i) in navMobile)
              Expanded(
                child: InkWell(
                  onTap: () => st.go(k),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Stack(clipBehavior: Clip.none, children: [
                      Container(
                        width: 52,
                        height: 30,
                        decoration: BoxDecoration(color: act == k ? C.acentoSuave : Colors.transparent, borderRadius: BorderRadius.circular(15)),
                        child: Icon(i, size: 22, color: act == k ? C.acento : C.gris),
                      ),
                      if (k == 'mas' && a.pend > 0) Positioned(right: -2, top: -4, child: _NavBadge(a.pend)),
                    ]),
                    const SizedBox(height: 3),
                    Text(l, style: tx(11.5, w: act == k ? FontWeight.w700 : FontWeight.w500, c: act == k ? C.acento : C.suave)),
                  ]),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  final String act;
  const _Rail(this.act);
  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final a = st.alerts();
    return Container(
      width: 84,
      decoration: const BoxDecoration(color: C.blanco, border: Border(right: BorderSide(color: C.borde))),
      child: SafeArea(
        child: Column(children: [
          const SizedBox(height: 14),
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: C.acento, borderRadius: BorderRadius.circular(7)),
            child: Text('A', style: tx(20, w: FontWeight.w700, c: Colors.white)),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: ListView(children: [
                for (final (k, l, i) in navFull)
                  InkWell(
                    onTap: () => st.go(k),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Column(children: [
                        Stack(clipBehavior: Clip.none, children: [
                          Container(
                            width: 48,
                            height: 32,
                            decoration: BoxDecoration(color: act == k ? C.acentoSuave : Colors.transparent, borderRadius: BorderRadius.circular(16)),
                            child: Icon(i, size: 22, color: act == k ? C.acento : C.gris),
                          ),
                          if (k == 'comprobantes' && a.pend > 0) Positioned(right: -4, top: -4, child: _NavBadge(a.pend)),
                        ]),
                        const SizedBox(height: 4),
                        Text(l, style: tx(11, w: act == k ? FontWeight.w700 : FontWeight.w500, c: act == k ? C.acento : C.suave)),
                      ]),
                    ),
                  ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String act;
  const _Sidebar(this.act);

  Widget _item(BuildContext context, AppState st, NavDef n, int pend) {
    final (k, l, i) = n;
    final on = act == k;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: () => st.go(k),
        borderRadius: BorderRadius.circular(R.btn),
        hoverColor: C.fondo,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: on ? C.cremaOsc : Colors.transparent, borderRadius: BorderRadius.circular(R.btn)),
          child: Row(children: [
            Icon(i, size: 19, color: on ? C.negro : C.suave),
            const SizedBox(width: 12),
            Expanded(child: Text(l, style: tx(14, w: on ? FontWeight.w700 : FontWeight.w500, c: on ? C.negro : C.suave))),
            if (k == 'comprobantes' && pend > 0) _NavBadge(pend),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final a = st.alerts();
    return Container(
      width: 248,
      decoration: const BoxDecoration(color: C.blanco, border: Border(right: BorderSide(color: C.borde))),
      child: Column(children: [
        const Padding(padding: EdgeInsets.fromLTRB(18, 18, 18, 14), child: Align(alignment: Alignment.centerLeft, child: Brand())),
        const Divider(height: 1, color: C.borde),
        const SizedBox(height: 12),
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView(padding: const EdgeInsets.symmetric(horizontal: 12), children: [
              for (final n in navPrincipal) _item(context, st, n, a.pend),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 22, 12, 8),
                child: Text('ADMINISTRACIÓN', style: tx(11, w: FontWeight.w700, c: C.gris, ls: 1)),
              ),
              for (final n in navAdmin) _item(context, st, n, a.pend),
            ]),
          ),
        ),
        const Divider(height: 1, color: C.borde),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Avatar(st.user.nombre[0], 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(st.sede.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(13, w: FontWeight.w700)),
                Text(st.sede.empresa, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(11.5, c: C.gris)),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}
