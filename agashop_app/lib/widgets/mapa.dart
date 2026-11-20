import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/models.dart';

/// Mapa de seguimiento dibujado sin conexión: calles, parque, agua, ruta de la tienda al cliente.
class MapaSeguimiento extends StatefulWidget {
  final Delivery d;
  final String barrio;
  final double height;
  const MapaSeguimiento({super.key, required this.d, required this.barrio, this.height = 240});
  @override
  State<MapaSeguimiento> createState() => _MapaState();
}

class _MapaState extends State<MapaSeguimiento> {
  int zoom = 1;
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(R.card),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _MapaPintor(widget.d, widget.barrio, 1 + (zoom - 1) * 0.35))),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                decoration: BoxDecoration(color: C.blanco, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.borde)),
                child: Column(children: [
                  _btn(Icons.add, () => setState(() => zoom = (zoom + 1).clamp(0, 3))),
                  Container(width: 28, height: 1, color: C.borde),
                  _btn(Icons.remove, () => setState(() => zoom = (zoom - 1).clamp(0, 3))),
                ]),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: C.blanco, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.borde)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.negro, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('Tienda', style: tx(11.5, w: FontWeight.w500)),
                  const SizedBox(width: 12),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.acento, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('Entrega', style: tx(11.5, w: FontWeight.w500)),
                ]),
              ),
            ),
          ]),
        ),
      );

  Widget _btn(IconData i, VoidCallback f) => InkWell(onTap: f, child: SizedBox(width: 30, height: 30, child: Icon(i, size: 17)));
}

class _MapaPintor extends CustomPainter {
  final Delivery d;
  final String barrio;
  final double escala;
  _MapaPintor(this.d, this.barrio, this.escala);

  @override
  void paint(Canvas c, Size s) {
    final r = math.Random(d.id.hashCode);
    c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFF1F2EF));
    c.save();
    c.translate(s.width / 2, s.height / 2);
    c.scale(escala);
    c.translate(-s.width / 2, -s.height / 2);
    final w = s.width, h = s.height;

    // agua
    final agua = Path()
      ..moveTo(-40, h * 0.55)
      ..cubicTo(w * 0.15, h * 0.45, w * 0.2, h * 0.9, w * 0.05, h + 40)
      ..lineTo(-40, h + 40)
      ..close();
    c.drawPath(agua, Paint()..color = const Color(0xFFDCE6EA));
    // parques
    final parque = Paint()..color = const Color(0xFFE1EDD5);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.55, h * 0.08, w * 0.26, h * 0.3), const Radius.circular(18)), parque);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.18, h * 0.06, w * 0.18, h * 0.2), const Radius.circular(14)), parque);
    // manzanas y calles
    final borde = Paint()..color = const Color(0xFFD9DBD6)..strokeWidth = 11..strokeCap = StrokeCap.round;
    final calle = Paint()..color = Colors.white..strokeWidth = 8..strokeCap = StrokeCap.round;
    final fina = Paint()..color = Colors.white..strokeWidth = 4..strokeCap = StrokeCap.round;
    final ang = (r.nextDouble() - 0.5) * 0.5;
    void linea(Offset a, Offset b, Paint p, {bool contorno = false}) {
      if (contorno) c.drawLine(a, b, borde);
      c.drawLine(a, b, p);
    }

    for (var i = 0; i < 6; i++) {
      final x = w * (0.12 + i * 0.17) + r.nextDouble() * 12;
      linea(Offset(x - h * ang, -20), Offset(x + h * ang, h + 20), i % 2 == 0 ? calle : fina, contorno: i % 2 == 0);
    }
    for (var i = 0; i < 5; i++) {
      final y = h * (0.1 + i * 0.22) + r.nextDouble() * 10;
      linea(Offset(-20, y + w * ang * 0.4), Offset(w + 20, y - w * ang * 0.4), i % 2 == 1 ? calle : fina, contorno: i % 2 == 1);
    }
    // avenida diagonal
    final av = Path()..moveTo(-20, h * 0.8)..quadraticBezierTo(w * 0.5, h * 0.45, w + 20, h * 0.25);
    c.drawPath(av, Paint()..color = const Color(0xFFD9DBD6)..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round);
    c.drawPath(av, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round);

    // etiquetas
    void texto(String t, Offset o, {double sz = 10}) {
      final tp = TextPainter(text: TextSpan(text: t.toUpperCase(), style: tx(sz, c: const Color(0xFF9A9D96), w: FontWeight.w500, ls: 1.2)), textDirection: TextDirection.ltr)..layout();
      tp.paint(c, o);
    }

    texto(barrio.isEmpty ? 'Centro' : barrio, Offset(w * 0.56, h * 0.62));
    texto('Av. Principal', Offset(w * 0.22, h * 0.7), sz: 9);
    texto('Parque', Offset(w * 0.6, h * 0.2), sz: 9);

    // ruta
    final tienda = Offset(w * 0.2, h * 0.72);
    final destino = Offset(w * (0.62 + r.nextDouble() * 0.08), h * (0.34 + r.nextDouble() * 0.1));
    final ruta = Path()
      ..moveTo(tienda.dx, tienda.dy)
      ..cubicTo(w * 0.4, h * 0.78, w * 0.45, h * 0.45, destino.dx, destino.dy);
    final entregado = d.estado == 'Entregado';
    final enCamino = d.estado == 'En camino';
    final trazo = Paint()..color = C.acento..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    if (entregado) {
      c.drawPath(ruta, trazo);
    } else {
      for (final m in ruta.computeMetrics()) {
        for (var dist = 0.0; dist < m.length; dist += 14) {
          c.drawPath(m.extractPath(dist, math.min(dist + 7, m.length)), trazo..color = C.acento.withValues(alpha: 0.75));
        }
        if (enCamino) {
          final t = m.getTangentForOffset(m.length * 0.55)!;
          c.drawCircle(t.position, 9, Paint()..color = C.blanco);
          c.drawCircle(t.position, 9, Paint()..color = C.negro..style = PaintingStyle.stroke..strokeWidth = 2.5);
          c.drawCircle(t.position, 3.5, Paint()..color = C.negro);
        }
      }
    }
    // tienda
    c.drawCircle(tienda, 9, Paint()..color = C.blanco);
    c.drawCircle(tienda, 6, Paint()..color = C.negro);
    // destino con halo
    c.drawCircle(destino, 40, Paint()..color = C.acento.withValues(alpha: 0.16));
    c.drawCircle(destino, 40, Paint()..color = C.acento.withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 1);
    c.drawCircle(destino, 8, Paint()..color = C.blanco);
    c.drawCircle(destino, 6, Paint()..color = C.acento);
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _MapaPintor o) => o.escala != escala || o.d.estado != d.estado;
}
