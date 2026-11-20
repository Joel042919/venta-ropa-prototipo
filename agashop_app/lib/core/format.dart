import 'package:flutter/material.dart';

String money(num n) {
  final s = n.toStringAsFixed(2);
  final p = s.split('.');
  final ent = p[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return 'S/ $ent.${p[1]}';
}

String pad(int n, [int l = 8]) => n.toString().padLeft(l, '0');

DateTime sod(DateTime d) => DateTime(d.year, d.month, d.day);
int dayDiff(DateTime d) => sod(DateTime.now()).difference(sod(d)).inDays;
bool isToday(DateTime d) => dayDiff(d) == 0;

String hm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
String dm(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
String fdt(DateTime d) {
  final n = dayDiff(d);
  return '${n == 0 ? 'Hoy' : n == 1 ? 'Ayer' : dm(d)} ${hm(d)}';
}

const _dias = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
const mesesES = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio',
  'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
];
String fechaLarga(DateTime d) => '${_dias[d.weekday - 1]} ${d.day} de ${mesesES[d.month - 1]}';

/// Color de texto legible sobre un fondo dado.
Color onColor(Color c) => c.computeLuminance() > 0.45 ? const Color(0xFF0B0C09) : Colors.white;

/// Tamaño de pantalla: móvil, tablet o escritorio.
enum FF { phone, tablet, desktop }

FF formFactor(double w) => w < 700 ? FF.phone : (w < 1100 ? FF.tablet : FF.desktop);
FF ffOf(BuildContext c) => formFactor(MediaQuery.sizeOf(c).width);
