import 'package:flutter/material.dart';

/// Paleta: blanco, gris cálido muy claro, casi negro y verde como acento. Tipografía: Poppins.
class C {
  static const negro = Color(0xFF1A1C19); // texto y botón oscuro
  static const crema = Color(0xFFFFFFFF);
  static const fondo = Color(0xFFFFFFFF);
  static const cremaOsc = Color(0xFFF4F5F3); // paneles grises
  static const acento = Color(0xFF4C9A0F); // verde
  static const turquesa = Color(0xFF8FD14F);
  static const lila = Color(0xFF1F3A2B); // verde oscuro
  static const acentoSuave = Color(0xFFE7F3DB);
  static const gris = Color(0xFF8E918B);
  static const suave = Color(0xFF5F625C);
  static const borde = Color(0xFFE6E8E4);
  static const blanco = Colors.white;
  static const ok = Color(0xFF2F7D12);
  static const okBg = Color(0xFFDDF3CF);
  static const warn = Color(0xFF55584F);
  static const warnBg = Color(0xFFE9EBE6);
  static const err = Color(0xFF1A1C19);
  static const errBg = Color(0xFFDADDD6);
  static const info = Color(0xFF2F5D8A);
  static const infoBg = Color(0xFFE3EBF5);
}

/// Radios suaves (nunca más del 10 % del lado menor).
class R {
  static const btn = 8.0;
  static const campo = 8.0;
  static const chip = 8.0;
  static const card = 14.0;
  static const big = 18.0;
  static const badge = 6.0;
}

List<BoxShadow> get sombra => const [];

TextStyle tx(double size, {FontWeight w = FontWeight.w400, Color c = C.negro, double? h, double? ls}) =>
    TextStyle(fontFamily: 'Texto', fontSize: size, fontWeight: w, color: c, height: h, letterSpacing: ls);

/// Títulos y cifras grandes: misma tipografía, en negrita y con espaciado ajustado.
TextStyle disp(double size, {Color c = C.negro, double? h}) =>
    TextStyle(fontFamily: 'Texto', fontSize: size * 0.9, fontWeight: FontWeight.w700, color: c, height: h ?? 1.1, letterSpacing: -0.3);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: C.acento, brightness: Brightness.light).copyWith(
      primary: C.acento,
      onPrimary: Colors.white,
      secondary: C.acento,
      onSecondary: Colors.white,
      surface: C.blanco,
      onSurface: C.negro,
      error: C.err,
    ),
    scaffoldBackgroundColor: C.fondo,
    fontFamily: 'Texto',
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: C.cremaOsc,
    dividerColor: C.borde,
  );
  return base.copyWith(
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(Colors.transparent),
      trackColor: WidgetStateProperty.all(Colors.transparent),
      trackBorderColor: WidgetStateProperty.all(Colors.transparent),
      thickness: WidgetStateProperty.all(0),
      thumbVisibility: WidgetStateProperty.all(false),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: C.negro,
      contentTextStyle: tx(14, c: Colors.white),
      actionTextColor: C.turquesa,
      behavior: SnackBarBehavior.floating,
      width: 440,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.card)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: C.blanco,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.card), side: const BorderSide(color: C.borde)),
      textStyle: tx(15),
    ),
  );
}
