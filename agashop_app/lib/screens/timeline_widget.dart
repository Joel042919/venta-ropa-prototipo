import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../widgets/ui.dart';

/// Seguimiento del pedido: tira de días arriba y lista de pasos con barra de color,
/// hora y etiqueta a la derecha. Todo entra con animación escalonada.
class TimelinePedido extends StatefulWidget {
  final Delivery d;
  const TimelinePedido(this.d, {super.key});
  @override
  State<TimelinePedido> createState() => _TimelineState();
}

class _TimelineState extends State<TimelinePedido> with TickerProviderStateMixin {
  late final AnimationController entra = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  late final AnimationController pulso = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);

  @override
  void dispose() {
    entra.dispose();
    pulso.dispose();
    super.dispose();
  }

  // avance 0 a 1 de la pieza i con retraso escalonado
  double _p(int i, int n, [double ini = 0, double fin = 1]) {
    final a = i / (n + 1) * 0.7, b = a + 0.35;
    final t = ((entra.value - a) / (b - a)).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(((t - ini) / (fin - ini)).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    final hechos = d.hist;
    final idx = estadosPedido.indexOf(d.estado);
    final futuros = (idx >= 0 && !d.cerrado) ? estadosPedido.sublist(idx + 1) : <String>[];
    // tipo: 0 hecho, 1 actual, 2 por hacer
    final filas = <(String, String, DateTime?, int)>[
      for (var i = 0; i < hechos.length; i++)
        (hechos[i].e, '${hechos[i].u}${hechos[i].n.isNotEmpty ? ' · ${hechos[i].n}' : ''}', hechos[i].f, i == hechos.length - 1 ? 1 : 0),
      for (final f in futuros) (f, f == 'Entregado' ? 'Entrega estimada ${dm(d.estimada)}' : 'Pendiente', null, 2),
    ];
    final n = filas.length;
    final hoy = sod(DateTime.now());
    final ini = sod(hechos.first.f);
    final dias = [for (var i = 0; i < 7; i++) ini.add(Duration(days: i))];
    final nombres = const ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Panel(
      pad: EdgeInsets.zero,
      child: AnimatedBuilder(
        animation: Listenable.merge([entra, pulso]),
        builder: (_, __) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(children: [
              Expanded(child: Text(fechaLarga(hoy)[0].toUpperCase() + fechaLarga(hoy).substring(1), style: tx(15, w: FontWeight.w700))),
              Text('${hechos.length} de ${hechos.length + futuros.length} pasos', style: tx(12.5, c: C.suave)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
            child: Row(children: [
              for (var i = 0; i < dias.length; i++)
                Expanded(
                  child: Opacity(
                    opacity: _p(i, 7),
                    child: Transform.scale(
                      scale: 0.85 + 0.15 * _p(i, 7),
                      child: _dia(dias[i], nombres[dias[i].weekday - 1], hoy, d, hechos),
                    ),
                  ),
                ),
            ]),
          ),
          const Divider(height: 1, color: C.borde),
          for (var i = 0; i < n; i++)
            Opacity(
              opacity: _p(i, n, 0.1, 0.8),
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - _p(i, n, 0.1, 0.8))),
                child: _fila(filas[i], _p(i, n, 0.2, 1)),
              ),
            ),
          const SizedBox(height: 6),
        ]),
      ),
    );
  }

  Widget _dia(DateTime f, String letra, DateTime hoy, Delivery d, List<Hist> hechos) {
    final sel = f == hoy;
    final entrega = sod(d.estimada) == f;
    final eventos = hechos.where((h) => sod(h.f) == f).length;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(letra, style: tx(11, w: FontWeight.w700, c: C.gris)),
      const SizedBox(height: 4),
      Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sel ? C.acento : entrega ? C.acentoSuave : Colors.transparent,
          borderRadius: BorderRadius.circular(R.chip),
        ),
        child: Text('${f.day}', style: tx(14, w: sel ? FontWeight.w700 : FontWeight.w500, c: sel ? Colors.white : C.negro)),
      ),
      const SizedBox(height: 4),
      SizedBox(
        height: 6,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (var k = 0; k < eventos.clamp(0, 3); k++)
            Container(width: 5, height: 5, margin: const EdgeInsets.symmetric(horizontal: 1), decoration: BoxDecoration(color: [C.ok, C.info, C.warn][k], shape: BoxShape.circle)),
          if (entrega) Container(width: 5, height: 5, margin: const EdgeInsets.symmetric(horizontal: 1), decoration: const BoxDecoration(color: C.acento, shape: BoxShape.circle)),
        ]),
      ),
    ]);
  }

  Widget _fila((String, String, DateTime?, int) f, double barra) {
    final (nombre, sub, fecha, tipo) = f;
    final color = tipo == 0 ? C.ok : tipo == 1 ? C.info : C.borde;
    final etiqueta = tipo == 0 ? 'Hecho' : tipo == 1 ? 'Ahora' : 'Por hacer';
    final ebg = tipo == 0 ? C.okBg : tipo == 1 ? C.infoBg : C.cremaOsc;
    final efg = tipo == 0 ? C.ok : tipo == 1 ? C.info : C.suave;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.borde, width: 0.6))),
      child: Stack(children: [
        Positioned(
          right: 78,
          top: 0,
          bottom: 0,
          width: 3,
          child: Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(heightFactor: barra.clamp(0.0, 1.0), widthFactor: 1, child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(1.5)))),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 92),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(nombre, style: tx(15, w: FontWeight.w700, c: tipo == 2 ? C.suave : C.negro)),
            const SizedBox(height: 6),
            Row(children: [
              Icon(tipo == 2 ? Icons.schedule : Icons.event_available_outlined, size: 14, color: C.gris),
              const SizedBox(width: 6),
              Expanded(child: Text(fecha != null ? '${_dia2(fecha)} · $sub' : sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(12.5, c: C.suave))),
            ]),
          ]),
        ),
        Positioned(
          right: 0,
          top: 0,
          width: 64,
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(fecha != null ? hm(fecha) : '—', style: tx(15, w: FontWeight.w700, c: tipo == 2 ? C.gris : C.negro)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: ebg, borderRadius: BorderRadius.circular(R.badge + 1)),
              child: Text(etiqueta, style: tx(11.5, w: FontWeight.w700, c: efg)),
            ),
          ]),
        ),
      ]),
    );
  }

  String _dia2(DateTime f) {
    final p = fdt(f).split(' ').first;
    return (p == 'Hoy' || p == 'Ayer') ? p : dm(f);
  }
}

