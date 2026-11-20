import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agashop_app/main.dart';
import 'package:agashop_app/state/app_state.dart';

Future<void> cargarFuentes() async {
  Future<ByteData> f(String p) async => ByteData.view(Uint8List.fromList(await File(p).readAsBytes()).buffer);
  final texto = FontLoader('Texto')
    ..addFont(f('assets/fonts/Poppins_400Regular.ttf'))
    ..addFont(f('assets/fonts/Poppins_500Medium.ttf'))
    ..addFont(f('assets/fonts/Poppins_600SemiBold.ttf'))
    ..addFont(f('assets/fonts/Poppins_700Bold.ttf'));
  await texto.load();
}

void main() {
  setUpAll(cargarFuentes);
  for (final (nombre, w, h) in [('móvil', 390.0, 844.0), ('tablet', 820.0, 1180.0), ('escritorio', 1440.0, 900.0)]) {
    testWidgets('Entrar, abrir caja y recorrer pantallas en $nombre', (t) async {
      t.view.physicalSize = Size(w, h);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(const AgaShopApp());
      await t.pumpAndSettle();
      expect(find.text('Iniciar sesión'), findsOneWidget);
      final st = AppScope.read(t.element(find.byType(MaterialApp)));
      st.login('SUP');
      await t.pumpAndSettle();
      expect(st.logged, isTrue);
      final fallos = <String>[];
      for (final v in kViews) {
        st.go(v);
        await t.pumpAndSettle();
        final e = t.takeException();
        if (e != null) fallos.add('$v: ${e.toString().split('\n').first}');
      }
      st.abrirCaja('k1', 't1', 150);
      st.go('vender');
      await t.pumpAndSettle();
      expect(st.addCart('p2-M'), isNull);
      await t.pumpAndSettle();
      final e = t.takeException();
      if (e != null) fallos.add('vender con prenda: ${e.toString().split('\n').first}');
      expect(st.totals().pagar, 79);
      expect(fallos, isEmpty);
    });
  }
}
