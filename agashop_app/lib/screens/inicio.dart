import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../layouts/shell.dart';
import '../state/app_state.dart';
import '../widgets/ui.dart';
import 'caja.dart';

const _rangos = ['Día', 'Semana', 'Mes', 'Año'];

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});
  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  String rango = 'Semana';
  bool aviso = true;

  bool _vale(Venta v) => v.estado == 'Completada' || v.estado == 'Devuelta en parte';

  double _suma(AppState st, DateTime a, DateTime b) =>
      st.ventas.where((v) => _vale(v) && !v.fecha.isBefore(a) && v.fecha.isBefore(b)).fold(0.0, (x, v) => x + v.total);
  int _cuenta(AppState st, DateTime a, DateTime b) => st.ventas.where((v) => _vale(v) && !v.fecha.isBefore(a) && v.fecha.isBefore(b)).length;

  /// Ventana actual y anterior según el rango elegido.
  (DateTime, DateTime, DateTime, DateTime) _ventanas() {
    final hoy = sod(DateTime.now());
    final fin = hoy.add(const Duration(days: 1));
    final dias = switch (rango) { 'Día' => 1, 'Semana' => 7, 'Mes' => 30, _ => 365 };
    final ini = fin.subtract(Duration(days: dias));
    return (ini, fin, ini.subtract(Duration(days: dias)), ini);
  }

  /// Valores y etiquetas del gráfico.
  (List<double>, List<String>) _serie(AppState st) {
    final hoy = sod(DateTime.now());
    double dia(DateTime d) => _suma(st, d, d.add(const Duration(days: 1)));
    switch (rango) {
      case 'Día':
        return ([for (var h = 0; h < 24; h++) st.ventas.where((v) => _vale(v) && isToday(v.fecha) && v.fecha.hour == h).fold(0.0, (x, v) => x + v.total)], [for (var h = 0; h < 24; h++) h % 4 == 0 ? '${h}h' : '']);
      case 'Semana':
        final ds = [for (var i = 6; i >= 0; i--) hoy.subtract(Duration(days: i))];
        return ([for (final d in ds) dia(d)], [for (final d in ds) const ['L', 'M', 'X', 'J', 'V', 'S', 'D'][d.weekday - 1]]);
      case 'Mes':
        final ds = [for (var i = 29; i >= 0; i--) hoy.subtract(Duration(days: i))];
        return ([for (final d in ds) dia(d)], [for (var i = 0; i < ds.length; i++) i % 5 == 0 ? dm(ds[i]) : '']);
      default:
        final ms = [for (var i = 11; i >= 0; i--) DateTime(hoy.year, hoy.month - i)];
        return ([for (final m in ms) _suma(st, m, DateTime(m.year, m.month + 1))], [for (final m in ms) mesesES[m.month - 1].substring(0, 3)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final ff = ffOf(context);
    final a = st.alerts();
    final (ini, fin, pIni, pFin) = _ventanas();
    final ing = _suma(st, ini, fin), ingP = _suma(st, pIni, pFin);
    final n = _cuenta(st, ini, fin), nP = _cuenta(st, pIni, pFin);
    final prom = n == 0 ? 0.0 : ing / n, promP = nP == 0 ? 0.0 : ingP / nP;
    final porCobrar = st.ventas.where((v) => v.estado == 'Pago pendiente').fold(0.0, (x, v) => x + v.total);
    final (valores, etiquetas) = _serie(st);
    final hoyTotal = _suma(st, sod(DateTime.now()), sod(DateTime.now()).add(const Duration(days: 1)));
    final t = st.turnoAbierto;

    Widget titulo(String s, {Widget? der}) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [Expanded(child: Text(s, style: tx(20, w: FontWeight.w700, ls: -0.4))), if (der != null) der]),
        );

    BoxDecoration tarjeta() => BoxDecoration(color: C.cremaOsc, borderRadius: BorderRadius.circular(R.card));

    // ── aviso superior ──
    final banner = !aviso
        ? const SizedBox.shrink()
        : Container(
            margin: const EdgeInsets.only(bottom: 22),
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            decoration: BoxDecoration(color: C.cremaOsc, borderRadius: BorderRadius.circular(R.card)),
            child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 10, runSpacing: 6, children: [
              Icon(t == null ? Icons.lock_outline : Icons.storefront_outlined, size: 20),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: ff == FF.phone ? 250 : 520),
                child: Text(
                  t == null ? 'Tu caja está cerrada. Ábrela para empezar a vender.' : 'Caja abierta desde ${hm(t.fechaA)} · ${st.ventasTurno(t).length} ventas en tu turno',
                  style: tx(14, w: FontWeight.w500),
                ),
              ),
              if (t == null)
                AppButton('Abrir caja', sm: true, onTap: () => abrirCajaSheet(context))
              else ...[
                AppButton('Movimiento', sm: true, v: BV.g, onTap: () => movimientoSheet(context)),
                AppButton('Cerrar caja', sm: true, v: BV.g, onTap: () => cerrarCajaSheet(context)),
              ],
              IconBtn(Icons.close, () => setState(() => aviso = false), color: C.suave, tip: 'Ocultar'),
            ]),
          );

    // ── rango ──
    final selector = Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: C.cremaOsc, borderRadius: BorderRadius.circular(R.btn + 2)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final r in _rangos)
          GestureDetector(
            onTap: () => setState(() => rango = r),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: r == rango ? C.acento : Colors.transparent, borderRadius: BorderRadius.circular(R.btn)),
              child: Text(r, style: tx(13, w: r == rango ? FontWeight.w700 : FontWeight.w500, c: r == rango ? Colors.white : C.suave)),
            ),
          ),
      ]),
    );

    Widget metrica(String t, String v, double ahora, double antes, {bool conDelta = true}) {
      var delta = '';
      if (conDelta) {
        if (antes == 0) {
          delta = ahora == 0 ? 'Sin cambios' : 'Nuevo en este periodo';
        } else {
          final p = ((ahora - antes) / antes * 100).round();
          delta = '${p >= 0 ? '+' : '−'}${p.abs()} % vs periodo anterior';
        }
      }
      final sube = conDelta && ahora > antes;
      return Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t, style: tx(14, c: C.suave)),
          const SizedBox(height: 8),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(v, style: tx(30, w: FontWeight.w700, ls: -0.8))),
          const SizedBox(height: 8),
          Text(conDelta ? delta : 'pedidos contra entrega', maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(12, c: sube ? C.ok : C.suave, w: sube ? FontWeight.w600 : FontWeight.w400)),
        ]),
      );
    }

    final metricas = Container(
      decoration: tarjeta(),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: metrica('Ventas', money(ing), ing, ingP)),
          Container(width: 1, height: 112, color: C.borde),
          Expanded(child: metrica('Comprobantes', '$n', n.toDouble(), nP.toDouble())),
        ]),
        Container(height: 1, color: C.borde),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: metrica('Ticket promedio', money(prom), prom, promP)),
          Container(width: 1, height: 112, color: C.borde),
          Expanded(child: metrica('Por cobrar', money(porCobrar), 0, 0, conDelta: false)),
        ]),
      ]),
    );

    // ── ingresos ──
    final ingresos = Container(
      padding: const EdgeInsets.all(18),
      decoration: tarjeta(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Ingresos totales', style: tx(14, c: C.suave)),
        const SizedBox(height: 6),
        Text(money(ing), style: tx(32, w: FontWeight.w700, ls: -1)),
        const SizedBox(height: 4),
        Text.rich(TextSpan(style: tx(13, c: C.suave), children: [
          const TextSpan(text: 'Hoy vendiste '),
          TextSpan(text: money(hoyTotal), style: tx(13, w: FontWeight.w700)),
        ])),
        const SizedBox(height: 14),
        SizedBox(height: ff == FF.phone ? 190 : 230, child: _Grafico(valores, etiquetas, key: ValueKey(rango))),
      ]),
    );

    // ── columna derecha ──
    Widget filaAviso(IconData i, String t, String s, VoidCallback f) => InkWell(
          onTap: f,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Container(width: 38, height: 38, decoration: const BoxDecoration(color: C.blanco, shape: BoxShape.circle), child: Icon(i, size: 19)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t, style: tx(14, w: FontWeight.w600)),
                  Text(s, style: tx(12.5, c: C.suave)),
                ]),
              ),
              const Icon(Icons.chevron_right, size: 20, color: C.gris),
            ]),
          ),
        );
    final avisos = <Widget>[
      if (a.pend > 0) filaAviso(Icons.receipt_long_outlined, '${a.pend} comprobantes por revisar', 'En proceso o no aceptados por SUNAT', () => st.go('comprobantes', f: 'pend')),
      if (a.atr > 0) filaAviso(Icons.local_shipping_outlined, '${a.atr} pedidos atrasados', 'Pasó la fecha estimada de entrega', () => st.go('pedidos', f: 'atrasados')),
      if (a.bajo > 0) filaAviso(Icons.checkroom_outlined, '${a.bajo} tallas por reponer', 'Con poco stock o agotadas', () => st.go('inventario', f: 'bajo')),
    ];
    final cardAvisos = Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
      decoration: tarjeta(),
      child: avisos.isEmpty
          ? Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text('Todo en orden. No hay nada pendiente.', style: tx(14, c: C.suave)))
          : Column(children: [for (var i = 0; i < avisos.length; i++) ...[avisos[i], if (i < avisos.length - 1) const Divider(height: 1, color: C.borde)]]),
    );

    final activas = st.prod.where((p) => p.activo).length;
    final bajas = st.prod.where((p) => p.estado == 'low').length;
    final agot = st.prod.where((p) => p.estado == 'out').length;
    Widget fila(String t, int v, VoidCallback f) => InkWell(
          onTap: f,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(children: [Expanded(child: Text(t, style: tx(15))), Text('$v', style: tx(22, w: FontWeight.w500))]),
          ),
        );
    final cardProductos = Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: tarjeta(),
      child: Column(children: [
        fila('Prendas activas', activas, () => st.go('inventario')),
        const Divider(height: 1, color: C.borde),
        fila('Con stock bajo', bajas, () => st.go('inventario', f: 'bajo')),
        const Divider(height: 1, color: C.borde),
        fila('Agotadas', agot, () => st.go('inventario')),
      ]),
    );

    // actividad reciente
    final eventos = <(DateTime, String, String, String)>[
      for (final v in st.ventas)
        if (st.compDe(v.id) != null) (v.fecha, v.user, 'cobró', st.compDe(v.id)!.numero),
      for (final d in st.deliveries)
        for (final h in d.hist) (h.f, h.u, 'pasó un pedido a', h.e.toLowerCase()),
      for (final k in st.kardex.where((k) => k.tipo == 'COMPRA' || k.tipo.startsWith('AJUSTE')).take(4)) (k.fecha, k.user, k.tipo == 'COMPRA' ? 'registró una compra' : 'ajustó el stock', ''),
    ]..sort((x, y) => y.$1.compareTo(x.$1));
    final recientes = eventos.take(6).toList();
    String hace(DateTime f) {
      final m = DateTime.now().difference(f).inMinutes;
      if (m < 1) return 'ahora';
      if (m < 60) return 'hace $m min';
      if (m < 60 * 24) return 'hace ${m ~/ 60} h';
      return dayDiff(f) == 1 ? 'ayer' : 'el ${dm(f)}';
    }

    final cardActividad = Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
      decoration: tarjeta(),
      child: Column(children: [
        for (var i = 0; i < recientes.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Stack(clipBehavior: Clip.none, children: [
                Avatar(recientes[i].$2[0], 38),
                Positioned(right: -2, bottom: -2, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: C.turquesa, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
              ]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text.rich(TextSpan(style: tx(13.5), children: [
                    TextSpan(text: recientes[i].$2.split(' ').first, style: tx(13.5, w: FontWeight.w700)),
                    TextSpan(text: ' ${recientes[i].$3} '),
                    TextSpan(text: recientes[i].$4, style: tx(13.5, w: FontWeight.w600)),
                  ])),
                  Text(hace(recientes[i].$1), style: tx(12, c: C.gris)),
                ]),
              ),
            ]),
          ),
          if (i < recientes.length - 1) const Divider(height: 1, color: C.borde),
        ],
      ]),
    );

    final izq = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      titulo('Resumen de ventas', der: selector),
      metricas,
      const SizedBox(height: 26),
      titulo('Ingresos'),
      ingresos,
    ]);
    final der = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      titulo('Avisos'),
      cardAvisos,
      const SizedBox(height: 26),
      titulo('Prendas', der: LinkBtn('Ver todo →', () => st.go('inventario'))),
      cardProductos,
      const SizedBox(height: 26),
      titulo('Actividad reciente'),
      cardActividad,
    ]);

    return ScreenPage('inicio',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          banner,
          ff == FF.phone
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [izq, const SizedBox(height: 26), der])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: izq),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: der),
                ]),
        ]));
  }
}

/// Gráfico de ingresos: línea azul noche con relleno rayado y marcador al pasar el mouse o tocar.
class _Grafico extends StatefulWidget {
  final List<double> v;
  final List<String> etq;
  const _Grafico(this.v, this.etq, {super.key});
  @override
  State<_Grafico> createState() => _GraficoState();
}

class _GraficoState extends State<_Grafico> {
  int? sel;
  static const izq = 40.0, abajo = 22.0, arriba = 10.0;

  void _mover(Offset p, double w) {
    final n = widget.v.length;
    if (n < 2) return;
    final i = ((p.dx - izq) / ((w - izq) / (n - 1))).round().clamp(0, n - 1);
    if (i != sel) setState(() => sel = i);
  }

  double _tope(double m) {
    if (m <= 0) return 100;
    const pasos = [100, 200, 300, 400, 500, 1000, 2000, 3000, 5000, 10000, 20000, 50000, 100000];
    return pasos.firstWhere((p) => p >= m, orElse: () => m.ceil()).toDouble();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, b) {
        final maxV = widget.v.fold<double>(0, (m, x) => x > m ? x : m);
        final tope = _tope(maxV);
        final n = widget.v.length;
        final alto = b.maxHeight - abajo - arriba;
        double px(int i) => izq + i * (b.maxWidth - izq) / (n - 1);
        double py(double val) => arriba + alto - (val / tope) * alto;
        return MouseRegion(
          onHover: (e) => _mover(e.localPosition, b.maxWidth),
          onExit: (_) => setState(() => sel = null),
          child: GestureDetector(
            onPanUpdate: (d) => _mover(d.localPosition, b.maxWidth),
            onTapDown: (d) => _mover(d.localPosition, b.maxWidth),
            child: Stack(children: [
              CustomPaint(size: Size(b.maxWidth, b.maxHeight), painter: _Pintor(widget.v, widget.etq, tope, sel)),
              if (sel != null)
                Positioned(
                  left: (px(sel!) - 58).clamp(0.0, b.maxWidth - 116),
                  top: (py(widget.v[sel!]) - 62).clamp(0.0, b.maxHeight),
                  child: Container(
                    width: 116,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(color: C.blanco, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.borde), boxShadow: sombra),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text(widget.etq[sel!].isEmpty ? 'Punto ${sel! + 1}' : widget.etq[sel!], style: tx(11.5, c: C.suave)),
                      Text(money(widget.v[sel!]), style: tx(15, w: FontWeight.w700)),
                    ]),
                  ),
                ),
            ]),
          ),
        );
      });
}

class _Pintor extends CustomPainter {
  final List<double> v;
  final List<String> etq;
  final double tope;
  final int? sel;
  _Pintor(this.v, this.etq, this.tope, this.sel);

  @override
  void paint(Canvas c, Size s) {
    const izq = _GraficoState.izq, abajo = _GraficoState.abajo, arriba = _GraficoState.arriba;
    final alto = s.height - abajo - arriba, ancho = s.width - izq;
    final n = v.length;
    double x(int i) => izq + i * ancho / (n - 1);
    double y(double val) => arriba + alto - (val / tope) * alto;
    for (var k = 0; k <= 4; k++) {
      final yy = arriba + alto * k / 4;
      c.drawLine(Offset(izq, yy), Offset(s.width, yy), Paint()..color = C.borde..strokeWidth = 1);
      final tp = TextPainter(text: TextSpan(text: (tope * (4 - k) / 4).round().toString(), style: tx(11, c: C.gris)), textDirection: TextDirection.ltr)..layout();
      tp.paint(c, Offset(izq - 8 - tp.width, yy - tp.height / 2));
    }
    final raya = Paint()..color = C.turquesa.withValues(alpha: 0.55)..strokeWidth = 1.2;
    for (var px = izq; px <= s.width; px += 3.5) {
      final f = ((px - izq) / ancho * (n - 1)).clamp(0, n - 1).toDouble();
      final i = f.floor().clamp(0, n - 2);
      final val = v[i] + (v[i + 1] - v[i]) * (f - i);
      c.drawLine(Offset(px, y(val)), Offset(px, arriba + alto), raya);
    }
    final path = Path()..moveTo(x(0), y(v[0]));
    for (var i = 1; i < n; i++) {
      path.lineTo(x(i), y(v[i]));
    }
    c.drawPath(path, Paint()..color = C.negro..style = PaintingStyle.stroke..strokeWidth = 2..strokeJoin = StrokeJoin.round);
    for (var i = 0; i < n; i++) {
      if (etq[i].isEmpty) continue;
      final tp = TextPainter(text: TextSpan(text: etq[i], style: tx(11, c: C.gris)), textDirection: TextDirection.ltr)..layout();
      tp.paint(c, Offset(x(i) - tp.width / 2, s.height - abajo + 6));
    }
    if (sel != null) {
      c.drawLine(Offset(x(sel!), arriba), Offset(x(sel!), arriba + alto), Paint()..color = C.negro..strokeWidth = 1.5);
      c.drawCircle(Offset(x(sel!), y(v[sel!])), 5, Paint()..color = C.blanco);
      c.drawCircle(Offset(x(sel!), y(v[sel!])), 5, Paint()..color = C.negro..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant _Pintor o) => o.sel != sel || o.v != v || o.tope != tope;
}
