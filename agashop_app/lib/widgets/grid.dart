import 'package:flutter/material.dart';

/// Reparte los hijos en columnas según el ancho disponible (sin recortar ni superponer).
class FlowGrid extends StatelessWidget {
  final List<Widget> children;
  final double minWidth;
  final double gap;
  const FlowGrid({super.key, required this.children, this.minWidth = 320, this.gap = 12});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final cols = ((box.maxWidth + gap) / (minWidth + gap)).floor().clamp(1, 6);
        final w = (box.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(spacing: gap, runSpacing: gap, children: [for (final c in children) SizedBox(width: w, child: c)]);
      });
}
