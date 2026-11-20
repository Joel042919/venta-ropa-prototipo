import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/product_art.dart';
import '../widgets/ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String rol = 'CAJ';
  bool ver = false, recordar = true;

  InputDecoration _dec(String hint, IconData icono, {Widget? fin}) => InputDecoration(
        hintText: hint,
        hintStyle: tx(14, c: C.gris),
        prefixIcon: Icon(icono, size: 19, color: C.suave),
        suffixIcon: fin,
        filled: true,
        fillColor: C.cremaOsc,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.card), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.card), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.card), borderSide: const BorderSide(color: C.acento, width: 1.4)),
      );

  @override
  Widget build(BuildContext context) {
    final st = AppScope.of(context);
    final ff = ffOf(context);
    final u = st.usuarios.firstWhere((x) => x.rol == rol);
    final form = Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(ff == FF.phone ? 22 : 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bienvenido de nuevo', style: tx(28, w: FontWeight.w700, ls: -0.6)),
            const SizedBox(height: 6),
            Text('Ingresa tus credenciales para continuar', style: tx(14.5, c: C.suave)),
            const SizedBox(height: 22),
            Text('Entrar como', style: tx(12.5, w: FontWeight.w600, c: C.suave)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final p in st.usuarios) AppChip('${p.nombre.split(' ').first} · ${roles[p.rol]}', rol == p.rol, () => setState(() => rol = p.rol)),
            ]),
            const SizedBox(height: 18),
            TextField(
              key: ValueKey('mail$rol'),
              controller: TextEditingController(text: '${u.user}@correo.com'),
              readOnly: true,
              style: tx(14.5),
              decoration: _dec('Correo electrónico', Icons.mail_outline),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: TextEditingController(text: 'demo1234'),
              obscureText: !ver,
              readOnly: true,
              style: tx(14.5),
              decoration: _dec('Contraseña', Icons.lock_outline, fin: IconBtn(ver ? Icons.visibility_off_outlined : Icons.visibility_outlined, () => setState(() => ver = !ver), color: C.suave)),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: CheckBox2(recordar, 'Recordarme', (v) => setState(() => recordar = v))),
              LinkBtn('¿Olvidaste tu contraseña?', () => st.toast('En el demo no hace falta: pulsa Iniciar sesión'), color: C.acento),
            ]),
            const SizedBox(height: 12),
            AppButton('Iniciar sesión', full: true, onTap: () => st.login(rol)),
            const SizedBox(height: 16),
            Center(
              child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text('¿Problemas para ingresar? ', style: tx(12.5, c: C.gris)),
                LinkBtn('Contacta al administrador', () => st.toast('Pide ayuda a la persona que administra tu tienda'), color: C.acento),
              ]),
            ),
          ]),
        ),
      ),
    );

    final items = ['Ventas y cobros en un solo lugar', 'Inventario por talla y color', 'Pedidos y envíos al día', 'Comprobantes electrónicos sin errores'];
    final panel = ClipRect(
      child: Container(
        color: C.lila,
        child: Stack(children: [
          // percha con prendas de fondo
          Positioned.fill(
            child: Opacity(
              opacity: 0.30,
              child: LayoutBuilder(builder: (context, b) {
                final w = b.maxWidth;
                final n = w > 560 ? 4 : 3;
                final tam = (w - 80) / n;
                return Stack(children: [
                  Positioned(left: 20, right: 20, top: b.maxHeight * 0.18, child: Container(height: 3, color: Colors.white.withValues(alpha: 0.9))),
                  for (var i = 0; i < n; i++)
                    Positioned(
                      left: 30 + i * ((w - 60) / n),
                      top: b.maxHeight * 0.18 + 3,
                      child: Column(children: [
                        Container(width: 2, height: 22, color: Colors.white),
                        Container(width: tam * 0.7, height: 3, color: Colors.white),
                        const SizedBox(height: 4),
                        ProductArt(st.prod[[0, 1, 2, 6][i]], size: tam * 0.9),
                      ]),
                    ),
                ]);
              }),
            ),
          ),
          Positioned.fill(child: Container(color: C.lila.withValues(alpha: 0.55))),
          Padding(
            padding: const EdgeInsets.all(44),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.turquesa, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Text('Sistema de gestión para tiendas de ropa', style: tx(14, w: FontWeight.w500, c: Colors.white)),
              ]),
              const Spacer(),
              Text('Tu tienda de ropa,', style: tx(ff == FF.desktop ? 38 : 30, w: FontWeight.w700, c: Colors.white, ls: -1, h: 1.15)),
              Text('ordenada.', style: tx(ff == FF.desktop ? 38 : 30, w: FontWeight.w700, c: C.turquesa, ls: -1, h: 1.15)),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Text('Vende, controla tu stock por talla y color y entrega tus pedidos a tiempo, todo desde un solo lugar.', style: tx(15, c: Colors.white.withValues(alpha: 0.85), h: 1.6)),
              ),
              const SizedBox(height: 26),
              for (final i in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: C.turquesa, width: 1.4)),
                      child: const Icon(Icons.check, size: 12, color: C.turquesa),
                    ),
                    const SizedBox(width: 12),
                    Text(i, style: tx(14, c: Colors.white.withValues(alpha: 0.92))),
                  ]),
                ),
              const SizedBox(height: 56),
              Text('© 2026 Todos los derechos reservados.', style: tx(12, c: Colors.white.withValues(alpha: 0.6))),
            ]),
          ),
        ]),
      ),
    );

    return Scaffold(
      backgroundColor: C.blanco,
      body: ff == FF.phone
          ? SafeArea(child: form)
          : Row(children: [Expanded(flex: 5, child: form), Expanded(flex: ff == FF.desktop ? 6 : 5, child: SizedBox.expand(child: panel))]),
    );
  }
}
