import 'dart:math';
import 'package:flutter/material.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);
  static AppState of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
  static AppState read(BuildContext c) => c.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

class Totales {
  final double raw, d, total, envio, pagar, base, igv;
  final int n;
  Totales(this.raw, this.d, this.total, this.envio, this.pagar, this.base, this.igv, this.n);
}

class Alertas {
  final int pend, bajo, atr;
  Alertas(this.pend, this.bajo, this.atr);
}

class Serie {
  final String serie, tipo, caja;
  int next;
  Serie(this.serie, this.tipo, this.caja, this.next);
}

class Caja {
  final String id, n;
  Caja(this.id, this.n);
}

class TurnoDef {
  final String id, n;
  TurnoDef(this.id, this.n);
}

const kViews = ['inicio', 'vender', 'pedidos', 'inventario', 'mas', 'caja', 'comprobantes', 'clientes', 'compras', 'kardex', 'config'];
const kSubs = ['clientes', 'compras', 'kardex', 'comprobantes', 'caja', 'config'];

class AppState extends ChangeNotifier {
  final messengerKey = GlobalKey<ScaffoldMessengerState>();
  final _rnd = Random();
  String uid() => _rnd.nextInt(1 << 30).toRadixString(36);

  // sesión y navegación
  bool logged = false;
  String rol = 'CAJ';
  String view = 'inicio';
  String? filtro; // filtro que llega desde un aviso del inicio

  // datos
  final sede = (nombre: 'Boutique San Isidro', dir: 'Av. Conquistadores 450, San Isidro', igv: 18, ruc: '20601234567', empresa: 'Estilo & Moda S.A.C.');
  final usuarios = [
    Usuario('u1', 'valeria.m', 'Valeria Mendoza', 'CAJ'),
    Usuario('u2', 'rosa.q', 'Rosa Quispe', 'SUP'),
    Usuario('u3', 'marcos.d', 'Marcos Díaz', 'ADM'),
  ];
  final cajas = [Caja('k1', 'Caja 01'), Caja('k2', 'Caja 02')];
  final turnosDef = [TurnoDef('t1', 'Mañana'), TurnoDef('t2', 'Tarde')];
  final series = [Serie('B001', '03', 'k1', 433), Serie('F001', '01', 'k1', 213), Serie('BC01', '07b', 'k1', 5), Serie('FC01', '07f', 'k1', 2)];
  late final List<Producto> prod;
  late final List<Cliente> clientes;
  final ventas = <Venta>[];
  final comprobantes = <Comprobante>[];
  final deliveries = <Delivery>[];
  final kardex = <Kardex>[];
  final compras = <Compra>[];
  final turnosHist = <Turno>[];
  Turno? turno;
  bool sunat = true;

  // venta en curso
  final cart = <Item>[];
  String cust = 'c0';
  String vt = '03';
  int disc = 0;
  EnvioDatos? envio;
  final espera = <List<Item>>[];

  AppState() {
    _seed();
  }

  Usuario get user => usuarios.firstWhere((u) => u.rol == rol);
  bool get isSup => rol != 'CAJ';
  Turno? get turnoAbierto => (turno != null && turno!.estado == 'Abierta') ? turno : null;

  void refresh() => notifyListeners();

  // ---------- semilla ----------
  void _seed() {
    DateTime d(int n, [int h = 10, int m = 0]) {
      final x = DateTime.now().subtract(Duration(days: n));
      return DateTime(x.year, x.month, x.day, h, m);
    }

    const col = {'p1': 'Terracota', 'p2': 'Crudo', 'p3': 'Azul', 'p4': 'Perla', 'p5': 'Nude', 'p6': 'Verde', 'p7': 'Mostaza', 'p8': 'Café'};
    const code = {'p1': 'TER', 'p2': 'CRU', 'p3': 'AZU', 'p4': 'PER', 'p5': 'NUD', 'p6': 'VER', 'p7': 'MOS', 'p8': 'CAF'};
    final raw = <List<Object>>[
      ['p1', 'Vestido Midi Terracota', 'Vestidos', 'Línea Propia', 'VES-001', 149.0, 62.0, 3, {'S': 3, 'M': 5, 'L': 0}],
      ['p2', 'Blusa Lino Crudo', 'Blusas y tops', 'Línea Propia', 'BLU-004', 79.0, 31.0, 4, {'S': 6, 'M': 8, 'L': 4}],
      ['p3', 'Jean Mom Azul', 'Pantalones y jeans', 'Boho Lima', 'JEA-002', 129.0, 55.0, 4, {'28': 2, '30': 1, '32': 0}],
      ['p4', 'Collar Perlas', 'Accesorios', 'Boho Lima', 'ACC-010', 45.0, 14.0, 5, {'Único': 14}],
      ['p5', 'Sandalia Cuero Nude', 'Calzado', 'Línea Propia', 'CAL-003', 119.0, 52.0, 3, {'36': 2, '37': 3, '38': 0}],
      ['p6', 'Vestido Satín Verde', 'Vestidos', 'Boho Lima', 'VES-007', 189.0, 80.0, 4, {'S': 0, 'M': 0, 'L': 0}],
      ['p7', 'Top Crochet Mostaza', 'Blusas y tops', 'Línea Propia', 'BLU-011', 59.0, 22.0, 4, {'S': 5, 'M': 7}],
      ['p8', 'Cinturón Trenzado', 'Accesorios', 'Boho Lima', 'ACC-014', 39.0, 12.0, 5, {'Único': 9}],
    ];
    prod = raw.map((r) {
      final id = r[0] as String, base = r[4] as String;
      final vs = (r[8] as Map<String, int>).entries
          .map((e) => Variante('$id-${e.key}', '$base-${code[id]}-${e.key}', e.key, col[id]!, r[5] as double, r[6] as double, r[7] as int, e.value))
          .toList();
      return Producto(id, r[1] as String, r[2] as String, r[3] as String, base, vs);
    }).toList();
    clientes = [
      Cliente('c0', 'DNI', '00000000', 'Clientes varios', fijo: true),
      Cliente('c1', 'DNI', '72345678', 'Mariana Silva Delgado', tel: '987654321', dir: 'Av. Pardo 650, Miraflores'),
      Cliente('c2', 'DNI', '45678912', 'Sofía Castillo Morales', tel: '955443322', dir: 'Jr. Los Pinos 120, Surco'),
      Cliente('c3', 'RUC', '20554433221', 'Glam Models S.A.C.', tel: '014445566', dir: 'Av. Javier Prado Este 3200, San Borja'),
    ];
    final hist1 = Turno('hist1', 'k1', 'Valeria Mendoza', 't2', 150, d(1, 14, 5), estado: 'Cerrada')
      ..fechaC = d(1, 20, 10)
      ..real = 150
      ..esperado = 150;
    turnosHist.add(hist1);

    final sold = <String, int>{};
    double price(String vid) => prod.expand((p) => p.v).firstWhere((v) => v.id == vid).precio;
    Venta mk(String id, DateTime fecha, String cli, List<Item> items, List<Pago> pagos, String estado, String serie,
        int num, String cEstado, {double envio = 0, String? motivo}) {
      final tot = items.fold<double>(0, (a, i) => a + price(i.vid) * i.q) + envio;
      final base = double.parse((tot / 1.18).toStringAsFixed(2));
      final v = Venta(id, fecha, 'hist1', cli, 'Valeria Mendoza', envio > 0 ? 'WhatsApp' : 'Físico', items, base, 0,
          double.parse((tot - base).toStringAsFixed(2)), envio, tot, estado, pagos..forEach((p) => p.turnoId = 'hist1'));
      ventas.add(v);
      comprobantes.add(Comprobante('c-$id', id, serie.startsWith('F') ? '01' : '03', serie, pad(num), fecha, tot, cEstado, cli, motivo: motivo));
      for (final i in items) {
        sold[i.vid] = (sold[i.vid] ?? 0) + i.q;
      }
      return v;
    }

    mk('s3', d(10, 12, 30), 'c1', [Item('p5-37', 1)], [Pago('efectivo', 119)], 'Completada', 'B001', 398, 'Aceptado');
    mk('s1', d(1, 16, 20), 'c0', [Item('p2-M', 1)], [Pago('yape', 79, ref: '849102')], 'Completada', 'B001', 430, 'Aceptado');
    mk('s2', d(1, 18, 5), 'c3', [Item('p3-30', 1), Item('p1-S', 1)], [Pago('tarjeta', 278, ref: '4589')], 'Completada', 'F001', 212,
        'No aceptado', motivo: 'El RUC del cliente no es válido');
    mk('s4', d(1, 19, 30), 'c2', [Item('p7-M', 1)], [Pago('yape', 69, ref: '773310')], 'Completada', 'B001', 431, 'En proceso', envio: 10);
    deliveries.add(Delivery('d1', 's4', 'En camino', 'Jr. Los Pinos 120, Surco', 'Casa verde, portón negro', 10, 'Olva', 'OL-48211', d(1, 12), false, [
      Hist('Pendiente', 'Valeria Mendoza', 'Pedido creado', d(1, 19, 30)),
      Hist('Preparando', 'Rosa Quispe', '', d(1, 19, 50)),
      Hist('Listo para enviar', 'Rosa Quispe', '', d(1, 20, 0)),
      Hist('En camino', 'Rosa Quispe', 'Guía OL-48211', d(0, 9, 10)),
    ]));
    final s5 = mk('s5', d(0, 8, 30), 'c1', [Item('p4-Único', 2)], [], 'Pago pendiente', 'B001', 432, 'Aceptado', envio: 8);
    s5.turnoId = null;
    deliveries.add(Delivery('d2', 's5', 'Pendiente', 'Av. Pardo 650, Miraflores', 'Edificio azul, piso 4', 8, '', '', d(-1, 12), true,
        [Hist('Pendiente', 'Rosa Quispe', 'Pedido creado, pago contra entrega', d(0, 8, 30))]));

    for (final v in prod.expand((p) => p.v)) {
      final ini = v.stock + (sold[v.id] ?? 0);
      kardex.add(Kardex(v.id, 'INICIAL', ini, ini, 'Stock inicial', '', 'Marcos Díaz', d(30, 9)));
    }
    final ord = [...ventas]..sort((a, b) => a.fecha.compareTo(b.fecha));
    for (final v in ord) {
      for (final i in v.items) {
        final last = kardex.lastWhere((k) => k.vid == i.vid);
        final c = comprobantes.firstWhere((c) => c.ventaId == v.id);
        kardex.add(Kardex(i.vid, 'VENTA', -i.q, last.saldo - i.q, c.numero, '', v.user, v.fecha));
      }
    }
    kardex.sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  // ---------- consultas ----------
  ({Producto p, Variante v}) vById(String id) {
    for (final p in prod) {
      for (final v in p.v) {
        if (v.id == id) return (p: p, v: v);
      }
    }
    throw StateError('Variante $id');
  }

  Cliente cli(String id) => clientes.firstWhere((c) => c.id == id, orElse: () => clientes.first);
  Comprobante? compDe(String ventaId) {
    for (final c in comprobantes) {
      if (c.ventaId == ventaId && (c.tipo == '01' || c.tipo == '03')) return c;
    }
    return null;
  }

  Venta venta(String id) => ventas.firstWhere((v) => v.id == id);
  Turno? turnoById(String id) => (turno?.id == id) ? turno : turnosHist.where((t) => t.id == id).firstOrNull;

  Totales totals() {
    final raw = cart.fold<double>(0, (a, i) => a + vById(i.vid).v.precio * i.q);
    final d = double.parse((raw * disc / 100).toStringAsFixed(2));
    final total = double.parse((raw - d).toStringAsFixed(2));
    final env = envio?.costo ?? 0;
    final pagar = double.parse((total + env).toStringAsFixed(2));
    final base = double.parse((pagar / (1 + sede.igv / 100)).toStringAsFixed(2));
    return Totales(raw, d, total, env, pagar, base, double.parse((pagar - base).toStringAsFixed(2)), cart.fold(0, (a, i) => a + i.q));
  }

  double efectivoEsperado(Turno t) {
    final ef = ventas.expand((v) => v.pagos).where((p) => p.turnoId == t.id && p.medio == 'efectivo').fold<double>(0, (a, p) => a + p.monto);
    final mv = t.movs.fold<double>(0, (a, m) => a + (m.tipo == 'Ingreso' ? m.monto : -m.monto));
    return double.parse((t.apertura + ef + mv).toStringAsFixed(2));
  }

  List<Venta> ventasTurno(Turno t) => ventas.where((v) => v.pagos.any((p) => p.turnoId == t.id)).toList();

  Alertas alerts() => Alertas(
        comprobantes.where((c) => c.estado == 'En proceso' || c.estado == 'No aceptado').length,
        prod.expand((p) => p.v).where((v) => v.stock <= v.min).length,
        deliveries.where((d) => d.atrasado).length,
      );

  // ---------- navegación ----------
  void login(String r) {
    rol = r;
    logged = true;
    view = 'inicio';
    notifyListeners();
  }

  void logout() {
    logged = false;
    cart.clear();
    notifyListeners();
  }

  void go(String v, {String? f}) {
    view = v;
    filtro = f;
    notifyListeners();
  }

  // ---------- avisos ----------
  void toast(String msg, {VoidCallback? undo}) {
    final m = messengerKey.currentState;
    if (m == null) return;
    m.hideCurrentSnackBar();
    m.showSnackBar(SnackBar(
      content: Text(msg),
      duration: Duration(seconds: undo != null ? 6 : 3),
      action: undo == null ? null : SnackBarAction(label: 'Deshacer', onPressed: undo),
    ));
  }

  // ---------- stock ----------
  void mov(String vid, String tipo, int cant, String doc, [String motivo = '']) {
    final v = vById(vid).v;
    v.stock += cant;
    kardex.insert(0, Kardex(vid, tipo, cant, v.stock, doc, motivo, user.nombre, DateTime.now()));
  }

  void ajustar(String vid, String tipo, int cant, String motivo) {
    mov(vid, tipo == 'Entrada' ? 'AJUSTE+' : 'AJUSTE-', tipo == 'Entrada' ? cant : -cant, 'Ajuste manual', motivo);
    notifyListeners();
  }

  // ---------- venta ----------
  String? addCart(String vid) {
    final x = vById(vid);
    final ex = cart.where((i) => i.vid == vid).firstOrNull;
    final q = (ex?.q ?? 0) + 1;
    if (x.v.stock <= 0) return 'Agotado en esta sede';
    if (q > x.v.stock) return 'Solo quedan ${x.v.stock} en talla ${x.v.talla}';
    if (ex != null) {
      ex.q = q;
    } else {
      cart.add(Item(vid, 1));
    }
    notifyListeners();
    return null;
  }

  void setQty(int i, int d) {
    final it = cart[i];
    final v = vById(it.vid).v;
    final q = it.q + d;
    if (q <= 0) {
      cart.removeAt(i);
    } else if (q > v.stock) {
      toast('Solo quedan ${v.stock} en talla ${v.talla}');
      return;
    } else {
      it.q = q;
    }
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    disc = 0;
    envio = null;
    cust = 'c0';
    vt = '03';
    notifyListeners();
  }

  void ponerEnEspera() {
    espera.add(cart.map((i) => Item(i.vid, i.q)).toList());
    clearCart();
    toast('Venta puesta en espera');
  }

  void recuperar(int i) {
    cart
      ..clear()
      ..addAll(espera.removeAt(i));
    notifyListeners();
  }

  void setSunat(bool v) {
    sunat = v;
    notifyListeners();
  }

  String? scan(String code) {
    final c = code.trim().toLowerCase();
    if (c.isEmpty) return null;
    final v = prod.expand((p) => p.v).where((v) => v.sku.toLowerCase() == c).firstOrNull;
    if (v == null) return 'No existe el código ${code.trim()}';
    return addCart(v.id) ?? 'ok:${vById(v.id).p.nombre} ${v.talla}';
  }

  /// Registra la venta ya cobrada. Devuelve (comprobante, vuelto).
  (Comprobante, double) registrarVenta(List<Pago> pagosIn, bool contra) {
    final t = totals();
    final tu = turnoAbierto!;
    final serie = series.firstWhere((s) => s.tipo == vt && s.caja == tu.caja);
    final num = pad(serie.next++);
    final vid = 's${uid()}';
    final pagos = contra
        ? <Pago>[]
        : pagosIn.map((p) => Pago(p.medio, p.monto, ref: p.ref, turnoId: tu.id, recibido: p.recibido ?? p.monto)).toList();
    final vuelto = contra ? 0.0 : pagos.where((p) => p.medio == 'efectivo').fold<double>(0, (a, p) => a + max(0, p.recibido! - p.monto));
    final venta = Venta(vid, DateTime.now(), contra ? null : tu.id, cust, user.nombre, envio != null ? 'WhatsApp' : 'Físico',
        cart.map((i) => Item(i.vid, i.q)).toList(), t.base, t.d, t.igv, t.envio, t.pagar, contra ? 'Pago pendiente' : 'Completada', pagos);
    final c = Comprobante('c-$vid', vid, vt, serie.serie, num, DateTime.now(), t.pagar, sunat ? 'Aceptado' : 'En proceso', cust);
    ventas.insert(0, venta);
    comprobantes.insert(0, c);
    for (final i in cart) {
      mov(i.vid, 'VENTA', -i.q, c.numero);
    }
    if (envio != null) {
      final e = envio!;
      deliveries.insert(0, Delivery('d${uid()}', vid, 'Pendiente', e.dir, e.ref, e.costo, e.courier, '', e.estimada, e.contra,
          [Hist('Pendiente', user.nombre, 'Pedido creado', DateTime.now())]));
    }
    clearCart();
    return (c, vuelto);
  }

  // ---------- pedidos ----------
  void avanzar(Delivery d, String estado, [String nota = '']) {
    d.estado = estado;
    d.hist.add(Hist(estado, user.nombre, nota, DateTime.now()));
    if (estado == 'Entregado' && d.contra) {
      final v = venta(d.ventaId);
      final tu = turnoAbierto;
      if (tu != null && v.pagos.isEmpty) {
        v.pagos.add(Pago('efectivo', v.total, turnoId: tu.id, recibido: v.total));
        v.turnoId = tu.id;
        v.estado = 'Completada';
      }
    }
    notifyListeners();
  }

  // ---------- caja ----------
  void abrirCaja(String cajaId, String turnoId, double monto) {
    turno = Turno('t${uid()}', cajaId, user.nombre, turnoId, monto, DateTime.now());
    notifyListeners();
  }

  void cerrarCaja(double real) {
    final t = turno!;
    t.estado = 'Cerrada';
    t.fechaC = DateTime.now();
    t.real = real;
    t.esperado = efectivoEsperado(t);
    turnosHist.insert(0, t);
    turno = null;
    notifyListeners();
  }

  void movimientoCaja(String tipo, double monto, String motivo) {
    turno!.movs.add(MovCaja(tipo, monto, motivo));
    notifyListeners();
  }

  // ---------- comprobantes ----------
  void reenviar(Comprobante c) {
    if (!sunat) {
      toast('Sin conexión con SUNAT. Intenta más tarde.');
      return;
    }
    c.estado = 'Aceptado';
    c.motivo = null;
    notifyListeners();
    toast('Comprobante aceptado por SUNAT');
  }

  void anular(Comprobante c) {
    final v = venta(c.ventaId);
    for (final i in v.items) {
      mov(i.vid, 'ANULACION', i.q, c.numero, 'Comprobante anulado');
    }
    v.estado = 'Anulada';
    c.estado = 'Anulado';
    notifyListeners();
  }

  /// Devuelve las prendas elegidas y genera la nota de crédito.
  double devolver(Venta v, Map<String, int> cant, String motivo) {
    final ratio = () {
      final raw = v.total - v.envio + v.desc;
      return raw > 0 ? v.desc / raw : 0.0;
    }();
    var monto = 0.0;
    final cDe = compDe(v.id)!;
    cant.forEach((vid, q) {
      if (q > 0) {
        final p = vById(vid).v.precio;
        monto += p * q * (1 - ratio);
        mov(vid, 'DEVOLUCION', q, cDe.numero, motivo);
      }
    });
    monto = double.parse(monto.toStringAsFixed(2));
    final s = series.firstWhere((s) => s.tipo == (cDe.tipo == '01' ? '07f' : '07b'));
    comprobantes.insert(0, Comprobante('c-nc${uid()}', v.id, s.tipo, s.serie, pad(s.next++), DateTime.now(), monto, sunat ? 'Aceptado' : 'En proceso', v.cli));
    v.estado = 'Devuelta en parte';
    notifyListeners();
    return monto;
  }

  // ---------- compras y clientes ----------
  void registrarCompra(String prov, String doc, DateTime fecha, List<CompraItem> items) {
    final c = Compra('co${uid()}', prov, doc, fecha, items);
    compras.insert(0, c);
    for (final i in items) {
      mov(i.vid, 'COMPRA', i.q, doc.isEmpty ? 'Compra' : doc);
      vById(i.vid).v.costo = i.costo;
    }
    notifyListeners();
  }

  void agregarCliente(Cliente c) {
    clientes.add(c);
    notifyListeners();
  }

  void agregarProducto(Producto p) {
    prod.add(p);
    for (final v in p.v) {
      kardex.insert(0, Kardex(v.id, 'INICIAL', v.stock, v.stock, 'Stock inicial', '', user.nombre, DateTime.now()));
    }
    notifyListeners();
  }
}

Color estadoColor(String e) => switch (e) {
      'Aceptado' || 'Entregado' || 'Completada' => C.ok,
      'En proceso' || 'En camino' => C.info,
      'No aceptado' || 'Anulado' || 'Fallido' || 'Cancelado' || 'Anulada' => C.err,
      _ => C.warn,
    };
