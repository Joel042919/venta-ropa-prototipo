import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/models.dart';

/// Foto de la prenda. Si existe `assets/products/<id>.jpg` se usa esa foto;
/// si no, se dibuja una ilustración de la prenda con su color.
class ProductArt extends StatelessWidget {
  final Producto p;
  final double? size;
  final double? height;
  const ProductArt(this.p, {super.key, this.size, this.height});

  @override
  Widget build(BuildContext context) {
    final h = height ?? size ?? 64;
    final r = (size ?? (h < 140 ? h : 140)) * 0.24;
    return ClipRRect(
      borderRadius: BorderRadius.circular(r.clamp(8, 20)),
      child: SizedBox(
        width: size ?? double.infinity,
        height: h,
        child: Image.asset(
          'assets/products/${p.id}.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => CustomPaint(painter: _Painter(p), size: Size.infinite),
        ),
      ),
    );
  }
}

Color _mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

class _Painter extends CustomPainter {
  final Producto p;
  _Painter(this.p);

  @override
  void paint(Canvas canvas, Size size) {
    final c = p.color;
    final fondo = _mix(const Color(0xFFEDEAE0), c, 0.14);
    canvas.drawRect(Offset.zero & size, Paint()..color = fondo);
    final s = size.shortestSide;
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);
    canvas.scale(s / 100);
    // suelo suave
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 93), width: 54, height: 5), Paint()..color = _mix(fondo, Colors.black, 0.10));
    final base = Paint()..color = c;
    final oscuro = Paint()..color = _mix(c, Colors.black, 0.2);
    final claro = Paint()..color = _mix(c, Colors.white, 0.22);
    Path poly(List<double> v) {
      final path = Path()..moveTo(v[0], v[1]);
      for (var i = 2; i < v.length; i += 2) {
        path.lineTo(v[i], v[i + 1]);
      }
      return path..close();
    }

    final line = Paint()
      ..color = oscuro.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    switch (p.base.substring(0, 3)) {
      case 'VES':
        canvas.drawPath(poly([36, 12, 42, 12, 50, 25, 58, 12, 64, 12, 62, 40, 74, 88, 26, 88, 38, 40]), base);
        canvas.drawPath(poly([50, 25, 62, 40, 74, 88, 50, 88]), claro);
        canvas.drawPath(poly([38, 40, 62, 40, 63, 45, 37, 45]), oscuro);
        for (final x in [38.0, 46.0, 54.0, 62.0]) {
          canvas.drawLine(Offset(50 + (x - 50) * 0.45, 46), Offset(50 + (x - 50) * 1.6, 87), line);
        }
      case 'BLU':
        final corta = p.id == 'p7';
        final y = corta ? 70.0 : 86.0;
        canvas.drawPath(poly([30, 18, 42, 12, 50, 23, 58, 12, 70, 18, 90, 42, 80, 50, 70, 40, 70, y, 30, y, 30, 40, 20, 50, 10, 42]), base);
        canvas.drawPath(poly([50, 23, 70, 18, 90, 42, 80, 50, 70, 40, 70, y, 50, y]), claro);
        canvas.drawPath(poly([42, 12, 50, 23, 58, 12, 55, 11, 50, 15, 45, 11]), oscuro);
        if (corta) {
          for (var i = 0; i < 4; i++) {
            canvas.drawLine(Offset(34, 46 + i * 6.0), Offset(66, 46 + i * 6.0), line);
          }
        } else {
          canvas.drawLine(const Offset(50, 24), const Offset(50, 86), line);
        }
      case 'JEA':
        canvas.drawPath(poly([30, 10, 70, 10, 75, 90, 55, 90, 50, 42, 45, 90, 25, 90]), base);
        canvas.drawPath(poly([50, 10, 70, 10, 75, 90, 55, 90, 50, 42]), claro);
        canvas.drawRect(const Rect.fromLTWH(30, 10, 40, 6), oscuro);
        canvas.drawLine(const Offset(50, 16), const Offset(50, 42), line);
        canvas.drawLine(const Offset(36, 22), const Offset(44, 22), line);
        canvas.drawLine(const Offset(56, 22), const Offset(64, 22), line);
      case 'ACC':
        if (p.id == 'p4') {
          final perla = Paint()..color = const Color(0xFFF7F4EC);
          final borde = Paint()
            ..color = _mix(c, Colors.black, 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8;
          for (var i = 0; i <= 14; i++) {
            final a = 3.4 + (i / 14) * 2.55;
            final o = Offset(50 + 32 * math.cos(a), 22 + 44 * (-math.sin(a)) * 0.9 + 6);
            canvas.drawCircle(o, 4.4, perla);
            canvas.drawCircle(o, 4.4, borde);
          }
        } else {
          final cinto = Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(10, 42, 80, 14), const Radius.circular(3)));
          canvas.drawPath(cinto, base);
          for (var x = 14.0; x < 86; x += 8) {
            canvas.drawLine(Offset(x, 43), Offset(x + 6, 55), line);
            canvas.drawLine(Offset(x + 6, 43), Offset(x, 55), line);
          }
          canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(40, 38, 20, 22), const Radius.circular(2)), Paint()..color = const Color(0xFFB8B3A0));
          canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(44, 43, 12, 12), const Radius.circular(1)), Paint()..color = fondo);
        }
      case 'CAL':
        final suela = Paint()..color = _mix(c, Colors.black, 0.32);
        canvas.drawPath(Path()..moveTo(14, 66)..quadraticBezierTo(14, 56, 28, 56)..lineTo(70, 56)..quadraticBezierTo(90, 58, 88, 70)..quadraticBezierTo(86, 76, 74, 76)..lineTo(24, 76)..quadraticBezierTo(14, 76, 14, 66)..close(), suela);
        canvas.drawPath(Path()..moveTo(16, 64)..quadraticBezierTo(16, 54, 28, 54)..lineTo(70, 54)..quadraticBezierTo(88, 56, 86, 66)..lineTo(16, 68)..close(), base);
        canvas.drawPath(poly([38, 54, 48, 34, 58, 36, 54, 54]), claro);
        canvas.drawPath(poly([60, 54, 66, 40, 74, 44, 72, 54]), oscuro);
        canvas.drawCircle(const Offset(50, 36), 2, oscuro);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _Painter old) => old.p != p;
}
