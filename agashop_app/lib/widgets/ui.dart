import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../state/app_state.dart';

// ───────────── botones ─────────────
enum BV { p, s, g, d }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final BV v;
  final bool full, sm;
  final IconData? icon;
  final double? size;
  const AppButton(this.label, {super.key, this.onTap, this.v = BV.p, this.full = false, this.sm = false, this.icon, this.size});
  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool hov = false, down = false;
  @override
  Widget build(BuildContext context) {
    final on = widget.onTap != null;
    Color bg, fg;
    Color? bd;
    switch (widget.v) {
      case BV.p:
        bg = hov || down ? const Color(0xFF3F8209) : C.acento;
        fg = Colors.white;
      case BV.s:
        bg = hov || down ? const Color(0xFF3F8209) : C.acento;
        fg = Colors.white;
      case BV.g:
        bg = hov || down ? C.cremaOsc : C.blanco;
        fg = C.negro;
        bd = C.borde;
      case BV.d:
        bg = hov || down ? C.errBg : Colors.transparent;
        fg = C.err;
        bd = C.err;
    }
    if (!on) {
      bg = C.cremaOsc;
      fg = C.gris;
      bd = null;
    }
    final h = widget.sm ? 32.0 : 38.0;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[Icon(widget.icon, size: 18, color: fg), const SizedBox(width: 8)],
        Flexible(
          child: Text(widget.label,
              overflow: TextOverflow.ellipsis,
              style: tx(widget.size ?? (widget.sm ? 12.5 : 14), w: FontWeight.w700, c: fg)),
        ),
      ],
    );
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      heightFactor: 1,
      child: MouseRegion(
      onEnter: (_) => setState(() => hov = true),
      onExit: (_) => setState(() => hov = false),
      cursor: on ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: on ? (_) => setState(() => down = true) : null,
        onTapCancel: () => setState(() => down = false),
        onTapUp: (_) => setState(() => down = false),
        onTap: widget.onTap,
        child: Semantics(
          button: true,
          enabled: on,
          label: widget.label,
          child: Container(
            height: h,
            constraints: const BoxConstraints(minWidth: 44),
            padding: EdgeInsets.symmetric(horizontal: widget.sm ? 14 : 22),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(R.btn),
              border: bd == null ? null : Border.all(color: bd, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    ));
  }
}

class IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final String tip;
  const IconBtn(this.icon, this.onTap, {super.key, this.color = C.negro, this.tip = ''});
  @override
  Widget build(BuildContext context) => Tooltip(
        message: tip,
        child: InkResponse(
          onTap: onTap,
          radius: 22,
          hoverColor: color.withValues(alpha: 0.12),
          child: SizedBox(width: 44, height: 44, child: Icon(icon, color: color, size: 22)),
        ),
      );
}

class LinkBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  const LinkBtn(this.label, this.onTap, {super.key, this.color = C.negro});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(R.chip),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(label, style: tx(14, w: FontWeight.w700, c: color).copyWith(decoration: TextDecoration.underline)),
        ),
      );
}

// ───────────── piezas visuales ─────────────
class Badge2 extends StatelessWidget {
  final String text;
  final Color fg, bg;
  const Badge2(this.text, {super.key, this.fg = C.warn, this.bg = C.warnBg});
  factory Badge2.estado(String e) {
    final c = estadoColor(e);
    final bg = c == C.ok ? C.okBg : c == C.err ? C.errBg : c == C.info ? C.infoBg : C.warnBg;
    return Badge2(e, fg: c, bg: bg);
  }
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(R.badge)),
        child: Text(text, style: tx(12, w: FontWeight.w700, c: fg)),
      );
}

enum BK { info, ok, warn, err }

class Aviso extends StatelessWidget {
  final String text;
  final BK k;
  final Widget? trailing;
  const Aviso(this.text, {super.key, this.k = BK.info, this.trailing});
  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (k) {
      BK.ok => (C.ok, C.okBg),
      BK.warn => (C.warn, C.warnBg),
      BK.err => (C.err, C.errBg),
      BK.info => (C.info, C.infoBg),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(R.card)),
      child: Row(children: [
        Expanded(child: Text(text, style: tx(14, w: FontWeight.w500, c: fg, h: 1.3))),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets pad;
  final bool border;
  final VoidCallback? onTap;
  const Panel({super.key, required this.child, this.color, this.pad = const EdgeInsets.all(16), this.border = true, this.onTap});
  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: pad,
      decoration: BoxDecoration(
        color: color ?? C.cremaOsc,
        borderRadius: BorderRadius.circular(R.card),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: box));
  }
}

class EmptyBox extends StatelessWidget {
  final String title, sub;
  const EmptyBox(this.title, this.sub, {super.key});
  @override
  Widget build(BuildContext context) => Panel(
        pad: const EdgeInsets.all(28),
        child: Column(children: [
          Text(title, style: tx(16, w: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(sub, style: tx(14, c: C.suave), textAlign: TextAlign.center),
        ]),
      );
}

class Swatch extends StatelessWidget {
  final Color color;
  final String text;
  final double size;
  const Swatch(this.color, this.text, {super.key, this.size = 52});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size * 0.28)),
        child: Text(text, style: tx(size * 0.4, w: FontWeight.w700, c: onColor(color))),
      );
}

class Sec extends StatelessWidget {
  final String text;
  const Sec(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 10),
        child: Text(text, style: tx(16, w: FontWeight.w700)),
      );
}

class Lbl extends StatelessWidget {
  final String text;
  const Lbl(this.text, {super.key});
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: tx(13, w: FontWeight.w700, c: C.suave)));
}

class Row2 extends StatelessWidget {
  final String a, b;
  final bool bold, sub;
  final Color? color;
  const Row2(this.a, this.b, {super.key, this.bold = false, this.sub = false, this.color});
  @override
  Widget build(BuildContext context) {
    final s = tx(sub ? 13 : 15, w: bold ? FontWeight.w700 : FontWeight.w400, c: color ?? (sub ? C.suave : C.negro));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: Text(a, style: s)), const SizedBox(width: 12), Expanded(flex: 3, child: Text(b, style: s, textAlign: TextAlign.right))]),
    );
  }
}

/// Fila de lista pulsable.
class Item2 extends StatelessWidget {
  final Widget child;
  final Widget? lead;
  final Widget? trail;
  final VoidCallback? onTap;
  const Item2({super.key, required this.child, this.lead, this.trail, this.onTap});
  @override
  Widget build(BuildContext context) => Panel(
        onTap: onTap,
        pad: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          if (lead != null) ...[lead!, const SizedBox(width: 14)],
          Expanded(child: child),
          if (trail != null) ...[const SizedBox(width: 10), trail!],
        ]),
      );
}

class StepperQ extends StatelessWidget {
  final int q;
  final VoidCallback minus, plus;
  const StepperQ(this.q, this.minus, this.plus, {super.key});
  @override
  Widget build(BuildContext context) {
    Widget b(String t, VoidCallback f, String l) => Semantics(
          label: l,
          button: true,
          child: InkWell(
            onTap: f,
            borderRadius: BorderRadius.circular(R.chip),
            child: SizedBox(width: 40, height: 40, child: Center(child: Text(t, style: tx(20, w: FontWeight.w700)))),
          ),
        );
    return Container(
      decoration: BoxDecoration(border: Border.all(color: C.borde), borderRadius: BorderRadius.circular(R.campo), color: C.blanco),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        b('−', minus, 'Quitar uno'),
        SizedBox(width: 26, child: Center(child: Text('$q', style: tx(15, w: FontWeight.w700)))),
        b('+', plus, 'Agregar uno'),
      ]),
    );
  }
}

// ───────────── pestañas de texto y chips ─────────────
class TextTabs extends StatelessWidget {
  final List<String> items;
  final String value;
  final ValueChanged<String> onChanged;
  final Map<String, int>? counts;
  const TextTabs({super.key, required this.items, required this.value, required this.onChanged, this.counts});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final t in items)
            Semantics(
              button: true,
              selected: t == value,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(t),
                child: Container(
                  height: 34,
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: t == value ? C.acento : Colors.transparent, borderRadius: BorderRadius.circular(R.btn)),
                  child: Text(counts == null ? t : '$t (${counts![t] ?? 0})',
                      style: tx(13.5, w: t == value ? FontWeight.w600 : FontWeight.w500, c: t == value ? Colors.white : C.suave)),
                ),
              ),
            ),
        ]),
      );
}

class AppChip extends StatelessWidget {
  final String label;
  final bool on;
  final VoidCallback onTap;
  const AppChip(this.label, this.on, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(R.chip),
        child: Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: on ? C.acentoSuave : C.blanco,
            borderRadius: BorderRadius.circular(R.chip),
            border: Border.all(color: on ? C.acento : C.borde),
          ),
          child: Center(widthFactor: 1, child: Text(label, style: tx(13.5, w: FontWeight.w600, c: on ? C.acento : C.negro))),
        ),
      );
}

class Seg extends StatelessWidget {
  final List<(String, String)> items;
  final String value;
  final ValueChanged<String> onChanged;
  const Seg({super.key, required this.items, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: C.cremaOsc, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          for (final (k, l) in items)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(k),
                child: Container(
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: k == value ? C.blanco : Colors.transparent, borderRadius: BorderRadius.circular(999), boxShadow: k == value ? sombra : null),
                  child: Text(l, style: tx(14, w: FontWeight.w700, c: k == value ? C.acento : C.suave)),
                ),
              ),
            ),
        ]),
      );
}

class CheckBox2 extends StatelessWidget {
  final bool on;
  final String label;
  final ValueChanged<bool> onChanged;
  const CheckBox2(this.on, this.label, this.onChanged, {super.key});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onChanged(!on),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: on ? C.acento : C.blanco,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: on ? C.acento : C.gris, width: 1.4),
              ),
              child: on ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: tx(15))),
          ]),
        ),
      );
}

// ───────────── campos ─────────────
InputDecoration _dec(String? hint, {Widget? suffix, Widget? prefix}) => InputDecoration(
      hintText: hint,
      hintStyle: tx(15, c: C.gris),
      isDense: true,
      filled: true,
      fillColor: C.blanco,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      suffixIcon: suffix,
      prefixIcon: prefix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.campo), borderSide: const BorderSide(color: C.borde)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.campo), borderSide: const BorderSide(color: C.borde)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.campo), borderSide: const BorderSide(color: C.acento, width: 1.6)),
    );

class AppField extends StatelessWidget {
  final String? label, hint, hintBelow;
  final TextEditingController? ctrl;
  final ValueChanged<String>? onChanged;
  final bool number, obscure, readOnly;
  final int? maxLen;
  final String? error;
  const AppField({super.key, this.label, this.hint, this.ctrl, this.onChanged, this.number = false, this.obscure = false, this.maxLen, this.error, this.hintBelow, this.readOnly = false});
  @override
  Widget build(BuildContext context) => ConstrainedBox(constraints: const BoxConstraints(maxWidth: 360), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (label != null) Lbl(label!),
        TextField(
          controller: ctrl,
          onChanged: onChanged,
          obscureText: obscure,
          readOnly: readOnly,
          maxLength: maxLen,
          keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
          inputFormatters: number ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : null,
          style: tx(14),
          cursorColor: C.negro,
          decoration: _dec(hint).copyWith(counterText: ''),
        ),
        if (error != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(error!, style: tx(13, c: C.err, w: FontWeight.w500))),
        if (hintBelow != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(hintBelow!, style: tx(13, c: C.suave))),
      ]));
}

class SearchBox extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmit;
  final TextEditingController? ctrl;
  const SearchBox({super.key, required this.hint, required this.onChanged, this.onSubmit, this.ctrl});
  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late final TextEditingController c = widget.ctrl ?? TextEditingController();
  @override
  Widget build(BuildContext context) => ConstrainedBox(constraints: const BoxConstraints(maxWidth: 380), child: TextField(
        controller: c,
        onChanged: (v) {
          widget.onChanged(v);
          setState(() {});
        },
        onSubmitted: widget.onSubmit,
        style: tx(15),
        cursorColor: C.negro,
        decoration: _dec(widget.hint,
            prefix: const Icon(Icons.search, size: 20, color: C.suave),
            suffix: c.text.isEmpty
                ? null
                : IconBtn(Icons.close, () {
                    c.clear();
                    widget.onChanged('');
                    setState(() {});
                  }, tip: 'Borrar búsqueda')),
      ));
}

// ───────────── ventanitas ancladas (selector y calendario) ─────────────
Future<T?> showAnchored<T>(BuildContext context, {required double width, required Widget child}) {
  final box = context.findRenderObject() as RenderBox;
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final tl = box.localToGlobal(Offset(0, box.size.height + 6), ancestor: overlay);
  var left = tl.dx;
  if (left + width > overlay.size.width - 8) left = overlay.size.width - width - 8;
  final pos = RelativeRect.fromLTRB(left, tl.dy, overlay.size.width - left - width, 0);
  return showMenu<T>(
    context: context,
    position: pos,
    color: C.blanco,
    elevation: 10,
    shadowColor: C.negro.withValues(alpha: 0.25),
    surfaceTintColor: Colors.transparent,
    constraints: BoxConstraints(minWidth: width, maxWidth: width),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.card), side: const BorderSide(color: C.borde)),
    items: [PopupMenuItem<T>(enabled: false, padding: EdgeInsets.zero, child: child)],
  );
}

class _Opt<T> extends StatefulWidget {
  final T v;
  final String label;
  final bool sel;
  const _Opt(this.v, this.label, this.sel);
  @override
  State<_Opt<T>> createState() => _OptState<T>();
}

class _OptState<T> extends State<_Opt<T>> {
  bool hov = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => hov = true),
        onExit: (_) => setState(() => hov = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(widget.v),
          child: Container(
            height: 38,
            margin: const EdgeInsets.symmetric(vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: widget.sel ? C.acentoSuave : hov ? C.cremaOsc : Colors.transparent,
              borderRadius: BorderRadius.circular(R.chip),
            ),
            child: Row(children: [
              Expanded(child: Text(widget.label, overflow: TextOverflow.ellipsis, style: tx(14.5, w: widget.sel ? FontWeight.w700 : FontWeight.w500, c: widget.sel ? C.acento : C.negro))),
              if (widget.sel) const Icon(Icons.check, size: 18, color: C.acento),
            ]),
          ),
        ),
      );
}

class AppSelect<T> extends StatelessWidget {
  final String? label;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;
  const AppSelect({super.key, this.label, required this.value, required this.options, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final cur = options.firstWhere((o) => o.$1 == value, orElse: () => options.first).$2;
    return ConstrainedBox(constraints: const BoxConstraints(maxWidth: 360), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label != null) Lbl(label!),
      Builder(
        builder: (ctx) => InkWell(
          borderRadius: BorderRadius.circular(R.campo),
          onTap: () async {
            final w = (ctx.findRenderObject() as RenderBox).size.width;
            final r = await showAnchored<T>(
              ctx,
              width: w,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: Scrollbar(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(6),
                    children: [for (final (v, l) in options) _Opt<T>(v, l, v == value)],
                  ),
                ),
              ),
            );
            if (r != null) onChanged(r);
          },
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: C.blanco, borderRadius: BorderRadius.circular(R.campo), border: Border.all(color: C.borde)),
            child: Row(children: [
              Expanded(child: Text(cur, overflow: TextOverflow.ellipsis, style: tx(14))),
              const Icon(Icons.keyboard_arrow_down, size: 22),
            ]),
          ),
        ),
      ),
    ]));
  }
}

class DateBox extends StatelessWidget {
  final String? label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? first;
  const DateBox({super.key, this.label, required this.value, required this.onChanged, this.first});
  @override
  Widget build(BuildContext context) => ConstrainedBox(constraints: const BoxConstraints(maxWidth: 360), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (label != null) Lbl(label!),
        Builder(
          builder: (ctx) => InkWell(
            borderRadius: BorderRadius.circular(R.campo),
            onTap: () async {
              final r = await showAnchored<DateTime>(ctx, width: 312, child: _Calendario(value, first ?? DateTime.now().subtract(const Duration(days: 365))));
              if (r != null) onChanged(r);
            },
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: C.blanco, borderRadius: BorderRadius.circular(R.campo), border: Border.all(color: C.borde)),
              child: Row(children: [
                Expanded(child: Text('${dm(value)}/${value.year}', style: tx(14))),
                const Icon(Icons.calendar_today_outlined, size: 18),
              ]),
            ),
          ),
        ),
      ]));
}

class _Calendario extends StatefulWidget {
  final DateTime sel, first;
  const _Calendario(this.sel, this.first);
  @override
  State<_Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<_Calendario> {
  late DateTime mes = DateTime(widget.sel.year, widget.sel.month);
  @override
  Widget build(BuildContext context) {
    final hoy = sod(DateTime.now());
    final offset = DateTime(mes.year, mes.month).weekday - 1;
    final dias = DateUtils.getDaysInMonth(mes.year, mes.month);
    final celdas = <Widget>[
      for (final l in const ['L', 'M', 'X', 'J', 'V', 'S', 'D']) Center(child: Text(l, style: tx(12, w: FontWeight.w700, c: C.suave))),
      for (var i = 0; i < offset; i++) const SizedBox(),
      for (var d = 1; d <= dias; d++)
        Builder(builder: (_) {
          final f = DateTime(mes.year, mes.month, d);
          final sel = DateUtils.isSameDay(f, widget.sel);
          final off = sod(f).isBefore(sod(widget.first));
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: off ? null : () => Navigator.of(context).pop(f),
            child: Container(
              margin: const EdgeInsets.all(2),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? C.acento : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: DateUtils.isSameDay(f, hoy) && !sel ? Border.all(color: C.acento) : null,
              ),
              child: Text('$d', style: tx(14, w: sel ? FontWeight.w700 : FontWeight.w500, c: sel ? Colors.white : off ? C.gris : C.negro)),
            ),
          );
        }),
    ];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          Expanded(child: Text('${mesesES[mes.month - 1]} ${mes.year}'.toUpperCase(), style: disp(20))),
          IconBtn(Icons.chevron_left, () => setState(() => mes = DateTime(mes.year, mes.month - 1))),
          IconBtn(Icons.chevron_right, () => setState(() => mes = DateTime(mes.year, mes.month + 1))),
        ]),
        SizedBox(
          width: 288,
          height: 36.0 * ((offset + dias + 6) ~/ 7 + 1),
          child: GridView.count(crossAxisCount: 7, physics: const NeverScrollableScrollPhysics(), padding: EdgeInsets.zero, childAspectRatio: 288 / 7 / 36, children: celdas),
        ),
        Align(alignment: Alignment.centerRight, child: LinkBtn('Hoy', () => Navigator.of(context).pop(hoy))),
      ]),
    );
  }
}

// ───────────── ventanas ─────────────
Future<T?> showAppSheet<T>(BuildContext context, String title, WidgetBuilder builder, {bool tall = false}) {
  final ff = ffOf(context);
  Widget frame(BuildContext c, double maxH) => _SheetFrame(title: title, tall: tall, maxH: maxH, child: Builder(builder: builder));
  if (ff == FF.phone) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.crema,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(R.big))),
      builder: (c) => frame(c, MediaQuery.sizeOf(c).height * 0.92),
    );
  }
  return showDialog<T>(
    context: context,
    barrierColor: C.negro.withValues(alpha: 0.55),
    builder: (c) => Dialog(
      backgroundColor: C.crema,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.big)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: ff == FF.desktop ? 560 : 520),
        child: frame(c, MediaQuery.sizeOf(c).height * 0.86),
      ),
    ),
  );
}

class _SheetFrame extends StatelessWidget {
  final String title;
  final bool tall;
  final double maxH;
  final Widget child;
  const _SheetFrame({required this.title, required this.tall, required this.maxH, required this.child});
  @override
  Widget build(BuildContext context) {
    final header = Container(
      decoration: const BoxDecoration(color: C.blanco, border: Border(bottom: BorderSide(color: C.borde))),
      padding: const EdgeInsets.only(left: 20, right: 6),
      height: 60,
      child: Row(children: [
        Expanded(child: Text(title, style: tx(18, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
        IconBtn(Icons.close, () => Navigator.of(context).pop(), color: C.suave, tip: 'Cerrar'),
      ]),
    );
    final body = tall
        ? Expanded(child: child)
        : Flexible(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
                child: child,
              ),
            ),
          );
    return SizedBox(
      height: tall ? maxH : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(mainAxisSize: tall ? MainAxisSize.max : MainAxisSize.min, children: [header, body]),
      ),
    );
  }
}

/// Antes pedía la clave de un supervisor; ahora cualquier usuario puede hacer estas acciones.
void requireSup(BuildContext context, String motivo, VoidCallback fn) => fn();
