import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Tonos pastel para las etiquetas.
class Pastel {
  static const durazno = Color(0xFFE3EBF5);
  static const menta = Color(0xFFCFEFC0);
  static const lavanda = Color(0xFFE7F3DB);
  static const cielo = Color(0xFFDCE9F6);
  static const rosa = Color(0xFFDADDD6);
  static const gris = Color(0xFFE9EBE6);
  static Color deColor(Color c) => Color.lerp(Colors.white, c, 0.30)!;
}

/// Tarjeta limpia estilo tablero: título, detalle gris, etiquetas de color y pie con fecha, valor e imagen.
class PastelCard extends StatefulWidget {
  final Color tono;
  final String pill, label, title, big, small;
  final Widget? logo;
  final List<String> tags;
  final VoidCallback onTap;
  const PastelCard({
    super.key,
    required this.tono,
    required this.pill,
    required this.label,
    required this.title,
    required this.big,
    required this.small,
    required this.onTap,
    this.logo,
    this.tags = const [],
    String boton = '',
    IconData? esquina,
  });
  @override
  State<PastelCard> createState() => _PastelCardState();
}

class _PastelCardState extends State<PastelCard> {
  bool hov = false;
  static const _rot = [Pastel.lavanda, Pastel.menta, Pastel.cielo, Pastel.durazno, Pastel.menta];
  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => hov = true),
        onExit: (_) => setState(() => hov = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: C.cremaOsc,
              borderRadius: BorderRadius.circular(R.card),
              border: Border.all(color: hov ? C.acento.withValues(alpha: 0.6) : Colors.transparent),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: tx(15, w: FontWeight.w600, h: 1.25)),
              const SizedBox(height: 4),
              Text(widget.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(13, c: C.suave)),
              if (widget.small.isNotEmpty) Text(widget.small, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(12.5, c: C.gris)),
              if (widget.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (var i = 0; i < widget.tags.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: i == 0 ? widget.tono : _rot[i % _rot.length], borderRadius: BorderRadius.circular(R.badge + 1)),
                      child: Text(widget.tags[i], style: tx(11.5, w: FontWeight.w600)),
                    ),
                ]),
              ],
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.event_outlined, size: 14, color: C.gris),
                const SizedBox(width: 5),
                Expanded(child: Text(widget.pill, maxLines: 1, overflow: TextOverflow.ellipsis, style: tx(12, c: C.suave))),
                Text(widget.big, style: tx(14, w: FontWeight.w700)),
                if (widget.logo != null) ...[const SizedBox(width: 8), widget.logo!],
              ]),
            ]),
          ),
        ),
      );
}
