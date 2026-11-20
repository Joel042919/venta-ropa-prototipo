import 'package:flutter_test/flutter_test.dart';
import 'package:agashop_app/data/models.dart';
import 'package:agashop_app/state/app_state.dart';

void main() {
  test('Venta con pago mixto descuenta stock, da vuelto y numera el comprobante', () {
    final st = AppState()..login('CAJ');
    st.abrirCaja('k1', 't1', 150);
    final antes = st.vById('p2-M').v.stock;
    final nextB = st.series.firstWhere((s) => s.tipo == '03').next;
    st.addCart('p2-M');
    st.addCart('p2-M');
    expect(st.totals().pagar, 158);
    final (c, vuelto) = st.registrarVenta([Pago('yape', 58), Pago('efectivo', 100, recibido: 120)], false);
    expect(vuelto, 20);
    expect(c.numero, 'B001-${nextB.toString().padLeft(8, '0')}');
    expect(st.vById('p2-M').v.stock, antes - 2);
    expect(st.cart, isEmpty);
    expect(st.efectivoEsperado(st.turnoAbierto!), 250);
  });

  test('No se vende más de lo que hay y la devolución reparte el descuento', () {
    final st = AppState()..login('SUP');
    st.abrirCaja('k1', 't1', 150);
    expect(st.addCart('p6-S'), 'Agotado en esta sede');
    for (var i = 0; i < 2; i++) {
      expect(st.addCart('p1-S'), isNull);
    }
    st.disc = 10;
    final (c, _) = st.registrarVenta([Pago('tarjeta', 268.2)], false);
    final v = st.venta(c.ventaId);
    final monto = st.devolver(v, {'p1-S': 1}, 'Talla equivocada');
    expect(monto, 134.1);
    expect(st.alerts().pend, greaterThanOrEqualTo(2));
  });

  test('Pedido contra entrega se cobra al entregar', () {
    final st = AppState()..login('SUP');
    st.abrirCaja('k1', 't1', 100);
    final d = st.deliveries.firstWhere((x) => x.contra);
    st.avanzar(d, 'Entregado');
    expect(st.venta(d.ventaId).estado, 'Completada');
    expect(st.efectivoEsperado(st.turnoAbierto!), 100 + st.venta(d.ventaId).total);
  });
}
