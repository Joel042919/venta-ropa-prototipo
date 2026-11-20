import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../layouts/shell.dart';
import '../state/app_state.dart';
import '../widgets/grid.dart';
import '../widgets/ui.dart';

void abrirCajaSheet(BuildContext context) {
  final st = AppScope.read(context);
  final libres = st.cajas.where((c) => c.id == 'k1').toList();
  var caja = libres.first.id;
  var turno = DateTime.now().hour < 14 ? 't1' : 't2';
  final monto = TextEditingController(text: '150');
  showAppSheet(
    context,
    'Abrir caja',
    (c) => StatefulBuilder(
      builder: (c, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppSelect<String>(label: 'Caja', value: caja, options: [for (final k in st.cajas) (k.id, k.id == 'k2' ? '${k.n} · en uso (Rosa)' : k.n)], onChanged: (v) {
          if (v == 'k2') {
            st.toast('La Caja 02 está en uso');
          } else {
            set(() => caja = v);
          }
        }),
        const SizedBox(height: 14),
        AppSelect<String>(label: 'Turno', value: turno, options: [for (final t in st.turnosDef) (t.id, t.n)], onChanged: (v) => set(() => turno = v)),
        const SizedBox(height: 14),
        AppField(label: 'Dinero para vuelto', ctrl: monto, number: true, hintBelow: 'Es el efectivo con el que empiezas el turno para dar vuelto.'),
        const SizedBox(height: 18),
        AppButton('Abrir caja', full: true, onTap: () {
          final m = double.tryParse(monto.text);
          if (m == null || m < 0) {
            st.toast('Escribe el dinero para vuelto');
            return;
          }
          Navigator.of(c).pop();
          st.abrirCaja(caja, turno, m);
          st.toast('Caja abierta');
        }),
      ]),
    ),
  );
}

class CajaCard extends StatelessWidget {
  const CajaCard({super.key});
  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final t = st.turnoAbierto;
    if (t == null) {
      return Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Badge2('Caja cerrada', fg: C.suave, bg: C.cremaOsc),
          const SizedBox(height: 12),
          Text('Aún no abres tu caja', style: tx(18, w: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Para vender necesitas abrirla con el dinero para vuelto.', style: tx(14, c: C.suave)),
          const SizedBox(height: 14),
          AppButton('Abrir caja', full: true, onTap: () => abrirCajaSheet(context)),
        ]),
      );
    }
    final vs = st.ventasTurno(t);
    final tot = vs.fold<double>(0, (a, v) => a + v.pagos.where((p) => p.turnoId == t.id).fold<double>(0, (x, p) => x + p.monto));
    final caja = st.cajas.firstWhere((c) => c.id == t.caja);
    final tn = st.turnosDef.firstWhere((x) => x.id == t.turno);
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Badge2('● Caja abierta', fg: C.ok, bg: C.okBg),
          Text('desde ${hm(t.fechaA)}', style: tx(13, c: C.suave)),
        ]),
        const SizedBox(height: 12),
        Text('${caja.n} · Turno ${tn.n.toLowerCase()}', style: tx(18, w: FontWeight.w700)),
        const SizedBox(height: 2),
        Text('${vs.length} ${vs.length == 1 ? 'venta' : 'ventas'} · ${money(tot)}', style: tx(14, c: C.suave)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: AppButton('Movimiento', v: BV.s, sm: true, onTap: () => movimientoSheet(context))),
          const SizedBox(width: 10),
          Expanded(child: AppButton('Cerrar caja', v: BV.g, sm: true, onTap: () => cerrarCajaSheet(context))),
        ]),
      ]),
    );
  }
}

void movimientoSheet(BuildContext context) {
  final st = AppScope.read(context);
  var tipo = 'Ingreso';
  final monto = TextEditingController(), motivo = TextEditingController();
  showAppSheet(
    context,
    'Movimiento de caja',
    (c) => StatefulBuilder(
      builder: (c, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Seg(items: const [('Ingreso', 'Entra dinero'), ('Egreso', 'Sale dinero')], value: tipo, onChanged: (v) => set(() => tipo = v)),
        const SizedBox(height: 14),
        AppField(label: 'Monto', ctrl: monto, number: true, hint: '0.00'),
        const SizedBox(height: 14),
        AppField(label: 'Motivo', ctrl: motivo, hint: 'Ej: Pago de delivery'),
        const SizedBox(height: 18),
        AppButton('Guardar movimiento', full: true, onTap: () {
          final m = double.tryParse(monto.text);
          if (m == null || m <= 0 || motivo.text.trim().isEmpty) {
            st.toast('Completa el monto y el motivo');
            return;
          }
          Navigator.of(c).pop();
          st.movimientoCaja(tipo, m, motivo.text.trim());
          st.toast('Movimiento guardado');
        }),
      ]),
    ),
  );
}

void cerrarCajaSheet(BuildContext context) {
  final st = AppScope.read(context);
  final t = st.turnoAbierto!;
  final esperado = st.efectivoEsperado(t);
  final real = TextEditingController();
  showAppSheet(
    context,
    'Cerrar caja',
    (c) => StatefulBuilder(builder: (c, set) {
      final r = double.tryParse(real.text);
      final dif = r == null ? null : double.parse((r - esperado).toStringAsFixed(2));
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Panel(
          child: Column(children: [
            Row2('Dinero para vuelto inicial', money(t.apertura)),
            Row2('Efectivo esperado en caja', money(esperado), bold: true),
          ]),
        ),
        const SizedBox(height: 14),
        AppField(label: 'Efectivo contado', ctrl: real, number: true, hint: '0.00', onChanged: (_) => set(() {})),
        if (dif != null) ...[
          const SizedBox(height: 12),
          Aviso(dif == 0 ? 'La caja cuadra' : dif > 0 ? 'Sobran ${money(dif)}' : 'Faltan ${money(-dif)}', k: dif == 0 ? BK.ok : BK.warn),
        ],
        const SizedBox(height: 18),
        AppButton('Cerrar caja', full: true, onTap: r == null ? null : () {
          Navigator.of(c).pop();
          st.cerrarCaja(r);
          st.toast('Caja cerrada');
        }),
      ]);
    }),
  );
}

class CajaScreen extends StatelessWidget {
  const CajaScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final t = st.turnoAbierto;
    final hist = st.turnosHist;
    return ScreenPage('caja',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CajaCard(),
          if (t != null && t.movs.isNotEmpty) ...[
            const Sec('Movimientos del turno'),
            FlowGrid(minWidth: 300, children: [
              for (final m in t.movs)
                Item2(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.motivo, style: tx(15, w: FontWeight.w700)),
                    Text(m.tipo, style: tx(13, c: C.suave)),
                  ]),
                  trail: Text('${m.tipo == 'Ingreso' ? '+' : '−'} ${money(m.monto)}',
                      style: tx(15, w: FontWeight.w700, c: m.tipo == 'Ingreso' ? C.ok : C.err)),
                ),
            ]),
          ],
          const Sec('Turnos anteriores'),
          if (hist.isEmpty)
            const EmptyBox('Sin turnos cerrados', 'Cuando cierres tu caja aparecerá aquí.')
          else
            FlowGrid(minWidth: 320, children: [
              for (final h in hist)
                Item2(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${st.cajas.firstWhere((c) => c.id == h.caja).n} · ${st.turnosDef.firstWhere((x) => x.id == h.turno).n}', style: tx(15, w: FontWeight.w700)),
                    Text('${fdt(h.fechaA)} · ${h.user}', style: tx(13, c: C.suave)),
                    const SizedBox(height: 6),
                    Text('${st.ventasTurno(h).length} ventas · contado ${money(h.real ?? 0)}', style: tx(13)),
                  ]),
                  trail: (h.real ?? 0) == (h.esperado ?? 0) ? const Badge2('Cuadró', fg: C.ok, bg: C.okBg) : Badge2('Dif. ${money((h.real ?? 0) - (h.esperado ?? 0))}'),
                ),
            ]),
        ]));
  }
}
