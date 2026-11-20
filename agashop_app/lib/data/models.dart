import 'package:flutter/material.dart';
import '../core/format.dart';

const roles = {'CAJ': 'Cajero/a', 'SUP': 'Supervisor/a', 'ADM': 'Administrador/a'};

const colorHex = {
  'Terracota': Color(0xFFC26D60),
  'Crudo': Color(0xFFB9A98A),
  'Azul': Color(0xFF3F5F93),
  'Perla': Color(0xFF8F8A99),
  'Nude': Color(0xFFB98C70),
  'Verde': Color(0xFF2F6B57),
  'Mostaza': Color(0xFFB8861B),
  'Café': Color(0xFF7A5340),
};

class Usuario {
  final String id, user, nombre, rol;
  Usuario(this.id, this.user, this.nombre, this.rol);
}

class Variante {
  final String id, sku, talla, color;
  double precio, costo;
  int min, stock;
  Variante(this.id, this.sku, this.talla, this.color, this.precio, this.costo, this.min, this.stock);
}

class Producto {
  final String id, nombre, cat, marca, base;
  bool activo = true;
  final List<Variante> v;
  Producto(this.id, this.nombre, this.cat, this.marca, this.base, this.v);
  int get stock => v.fold(0, (a, x) => a + x.stock);
  String get estado {
    final s = stock;
    if (s <= 0) return 'out';
    if (v.any((x) => x.stock > 0 && x.stock <= x.min) || s <= v.first.min) return 'low';
    return 'ok';
  }

  Color get color => colorHex[v.first.color] ?? const Color(0xFF4B4D73);
  String get iniciales => nombre.split(' ').take(2).map((w) => w[0]).join();
}

class Cliente {
  final String id;
  String tipo, doc, nombre, tel, dir;
  final bool fijo;
  Cliente(this.id, this.tipo, this.doc, this.nombre, {this.tel = '', this.dir = '', this.fijo = false});
}

class Item {
  final String vid;
  int q;
  Item(this.vid, this.q);
}

class Pago {
  String medio;
  double monto;
  String ref;
  String? turnoId;
  double? recibido;
  Pago(this.medio, this.monto, {this.ref = '', this.turnoId, this.recibido});
}

class Venta {
  final String id;
  final DateTime fecha;
  String? turnoId;
  final String cli, user, canal;
  final List<Item> items;
  final double subtotal, desc, igv, envio, total;
  String estado;
  final List<Pago> pagos;
  Venta(this.id, this.fecha, this.turnoId, this.cli, this.user, this.canal, this.items, this.subtotal,
      this.desc, this.igv, this.envio, this.total, this.estado, this.pagos);
}

class Comprobante {
  final String id, ventaId, tipo, serie, num, cli;
  final DateTime fecha;
  final double total;
  String estado;
  String? motivo;
  Comprobante(this.id, this.ventaId, this.tipo, this.serie, this.num, this.fecha, this.total, this.estado, this.cli,
      {this.motivo});
  String get numero => '$serie-$num';
  String get nombre => switch (tipo) {
        '03' => 'Boleta',
        '01' => 'Factura',
        _ => 'Nota de crédito',
      };
}

class Hist {
  final String e, u, n;
  final DateTime f;
  Hist(this.e, this.u, this.n, this.f);
}

const estadosPedido = ['Pendiente', 'Preparando', 'Listo para enviar', 'En camino', 'Entregado'];

class Delivery {
  final String id, ventaId;
  String estado, dir, ref, courier, guia;
  double costo;
  DateTime estimada;
  bool contra;
  final List<Hist> hist;
  final Set<int> chk = {};
  Delivery(this.id, this.ventaId, this.estado, this.dir, this.ref, this.costo, this.courier, this.guia,
      this.estimada, this.contra, this.hist);
  bool get cerrado => const ['Entregado', 'Cancelado', 'Devuelto a tienda'].contains(estado);
  bool get atrasado => !cerrado && estimada.isBefore(sod(DateTime.now()));
}

class Kardex {
  final String vid, tipo, doc, motivo, user;
  final int cant, saldo;
  final DateTime fecha;
  Kardex(this.vid, this.tipo, this.cant, this.saldo, this.doc, this.motivo, this.user, this.fecha);
}

class MovCaja {
  final String tipo, motivo;
  final double monto;
  MovCaja(this.tipo, this.monto, this.motivo);
}

class Turno {
  final String id, caja, user, turno;
  final double apertura;
  final DateTime fechaA;
  DateTime? fechaC;
  final List<MovCaja> movs = [];
  String estado;
  double? real, esperado;
  Turno(this.id, this.caja, this.user, this.turno, this.apertura, this.fechaA, {this.estado = 'Abierta'});
}

class CompraItem {
  final String vid;
  final int q;
  final double costo;
  CompraItem(this.vid, this.q, this.costo);
}

class Compra {
  final String id, prov, doc;
  final DateTime fecha;
  final List<CompraItem> items;
  Compra(this.id, this.prov, this.doc, this.fecha, this.items);
  double get total => items.fold(0, (a, i) => a + i.q * i.costo);
}

class EnvioDatos {
  String dir, ref, courier;
  double costo;
  bool contra;
  DateTime estimada;
  EnvioDatos(this.dir, this.ref, this.costo, this.courier, this.contra, this.estimada);
}

class Medio {
  final String id, n;
  const Medio(this.id, this.n);
}

const medios = [Medio('efectivo', 'Efectivo'), Medio('yape', 'Yape'), Medio('plin', 'Plin'), Medio('tarjeta', 'Tarjeta')];
String medioN(String id) => medios.firstWhere((m) => m.id == id, orElse: () => Medio(id, id)).n;

const categorias = ['Vestidos', 'Blusas y tops', 'Pantalones y jeans', 'Accesorios', 'Calzado'];
const motivosAjuste = {
  'Entrada': ['Devolución de cliente', 'Hallazgo en conteo', 'Corrección de error'],
  'Salida': ['Prenda dañada o perdida', 'Robo o pérdida', 'Muestra o regalo', 'Corrección de conteo'],
};
