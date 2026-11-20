import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../layouts/shell.dart';
import '../state/app_state.dart';
import '../widgets/grid.dart';
import '../widgets/ui.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final s = st.sede;
    return ScreenPage('config',
        child: FlowGrid(minWidth: 360, gap: 16, children: [
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Datos de la tienda', style: tx(16, w: FontWeight.w700)),
              const SizedBox(height: 10),
              Row2('Empresa', s.empresa),
              Row2('RUC', s.ruc),
              Row2('Sede', s.nombre),
              Row2('Dirección', s.dir),
              Row2('IGV', '${s.igv} %'),
            ]),
          ),
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Conexión con sunat', style: tx(16, w: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Con la conexión activa, cada comprobante se envía a SUNAT al vender. Apágala para probar qué pasa sin internet.', style: tx(14, c: C.suave)),
              const SizedBox(height: 10),
              CheckBox2(st.sunat, 'Conexión con SUNAT activa', (v) {
                st.setSunat(v);
                st.toast(v ? 'SUNAT conectado' : 'Sin conexión con SUNAT');
              }),
            ]),
          ),
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Series de comprobantes', style: tx(16, w: FontWeight.w700)),
              const SizedBox(height: 10),
              for (final x in st.series)
                Row2('${x.serie} · ${x.tipo == '03' ? 'Boleta' : x.tipo == '01' ? 'Factura' : 'Nota de crédito'}', 'Siguiente ${x.next.toString().padLeft(8, '0')}'),
            ]),
          ),
          Panel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Equipo', style: tx(16, w: FontWeight.w700)),
              const SizedBox(height: 10),
              for (final u in st.usuarios) Row2(u.nombre, roles[u.rol]!),
            ]),
          ),
        ]));
  }
}
