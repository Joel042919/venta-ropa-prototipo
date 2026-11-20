import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../layouts/shell.dart';
import '../state/app_state.dart';
import '../widgets/grid.dart';
import '../widgets/ui.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});
  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final ql = q.toLowerCase();
    final l = st.clientes.where((c) => ql.isEmpty || c.nombre.toLowerCase().contains(ql) || c.doc.contains(ql)).toList();
    return ScreenPage('clientes',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 320), child: SearchBox(hint: 'Busca por nombre o documento', onChanged: (v) => setState(() => q = v)))),
            const SizedBox(width: 10),
            AppButton('Nuevo', sm: true, icon: Icons.add, onTap: () => _nuevo(context)),
          ]),
          const SizedBox(height: 14),
          FlowGrid(minWidth: 320, children: [
            for (final c in l)
              Item2(
                lead: Swatch(c.fijo ? C.gris : C.negro, c.nombre[0], size: 46),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.nombre, style: tx(15, w: FontWeight.w700)),
                  Text('${c.tipo} ${c.doc}', style: tx(13, c: C.suave)),
                  if (c.tel.isNotEmpty) Text(c.tel, style: tx(13, c: C.suave)),
                  if (c.dir.isNotEmpty) Text(c.dir, style: tx(13, c: C.suave)),
                ]),
                trail: Text('${st.ventas.where((v) => v.cli == c.id).length} compras', style: tx(12.5, c: C.suave)),
              ),
          ]),
        ]));
  }

  void _nuevo(BuildContext context) {
    final st = AppScope.read(context);
    var tipo = 'DNI';
    final doc = TextEditingController(), nom = TextEditingController(), tel = TextEditingController(), dir = TextEditingController();
    showAppSheet(
      context,
      'Nuevo cliente',
      (c) => StatefulBuilder(
        builder: (c, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Seg(items: const [('DNI', 'Persona (DNI)'), ('RUC', 'Empresa (RUC)')], value: tipo, onChanged: (v) => set(() => tipo = v)),
          const SizedBox(height: 14),
          AppField(label: tipo == 'DNI' ? 'DNI (8 dígitos)' : 'RUC (11 dígitos)', ctrl: doc, number: true, maxLen: tipo == 'DNI' ? 8 : 11),
          const SizedBox(height: 12),
          AppField(label: tipo == 'DNI' ? 'Nombre completo' : 'Razón social', ctrl: nom),
          const SizedBox(height: 12),
          AppField(label: 'Teléfono (opcional)', ctrl: tel, number: true),
          const SizedBox(height: 12),
          AppField(label: 'Dirección (opcional)', ctrl: dir),
          const SizedBox(height: 18),
          AppButton('Guardar cliente', full: true, onTap: () {
            final n = tipo == 'DNI' ? 8 : 11;
            if (doc.text.length != n || nom.text.trim().isEmpty) {
              st.toast('Revisa el documento ($n dígitos) y el nombre');
              return;
            }
            if (st.clientes.any((x) => x.doc == doc.text)) {
              st.toast('Ya existe un cliente con ese documento');
              return;
            }
            st.agregarCliente(Cliente('c${st.uid()}', tipo, doc.text, nom.text.trim(), tel: tel.text, dir: dir.text.trim()));
            Navigator.of(c).pop();
            st.toast('Cliente guardado');
          }),
        ]),
      ),
    );
  }
}
