'use client';

import React from 'react';
import { useApp } from '@/context/AppContext';
import {
  MOCK_SALES_CHART,
  MOCK_CATEGORY_SHARE,
  MOCK_PAYMENT_SHARE,
} from '@/mock/mockData';
import {
  BarChart3,
  TrendingUp,
  PieChart as PieIcon,
  Award,
  CreditCard,
  QrCode,
  Banknote,
  DollarSign,
  ArrowUpRight,
  Sparkles,
  ShoppingBag
} from 'lucide-react';
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  PieChart,
  Pie,
  Cell,
  Legend
} from 'recharts';

export const ReportsView: React.FC = () => {
  const { products, vouchers } = useApp();

  // Top 5 best selling products (mocked realistically based on product list)
  const topProducts = [
    {
      product: products[0], // Vestido Midi Terracota Lino
      salesCount: 48,
      revenue: 7632.00,
    },
    {
      product: products[1], // Blusa Floral Manga Abullonada
      salesCount: 39,
      revenue: 3471.00,
    },
    {
      product: products[3], // Vestido Camisero Safari Beige
      salesCount: 31,
      revenue: 5549.00,
    },
    {
      product: products[8], // Camisa Oversize Algodón Pima
      salesCount: 28,
      revenue: 3332.00,
    },
    {
      product: products[4], // Cartera Crossbody Cuero Caramelo
      salesCount: 22,
      revenue: 4818.00,
    },
  ];

  return (
    <div className="flex-1 overflow-y-auto p-4 md:p-6 lg:p-8 space-y-6 bg-[#faf8f5]">
      {/* Top Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-[#fcedea] text-[#c26d60] text-xs font-semibold mb-1">
            <BarChart3 className="w-3.5 h-3.5" />
            <span>Inteligencia de Negocio & Analítica</span>
          </div>
          <h1 className="font-serif text-2xl md:text-3xl font-bold text-stone-900">
            Reportes de Rendimiento y Ventas
          </h1>
          <p className="text-xs text-stone-500">
            Métricas estratégicas para toma de decisiones: productos estrella, canales de cobro y rentabilidad.
          </p>
        </div>
      </div>

      {/* KPI Highlights */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white p-5 rounded-3xl border border-[#eae3db] shadow-xs">
          <span className="text-xs font-semibold text-stone-500 uppercase">Ticket Promedio</span>
          <div className="text-2xl font-serif font-bold text-stone-900 mt-2">
            S/ 168.50
          </div>
          <div className="flex items-center gap-1 mt-1 text-xs text-emerald-600 font-semibold">
            <ArrowUpRight className="w-3.5 h-3.5" />
            <span>+12% vs mes anterior</span>
          </div>
        </div>

        <div className="bg-white p-5 rounded-3xl border border-[#eae3db] shadow-xs">
          <span className="text-xs font-semibold text-stone-500 uppercase">Prendas Vendidas (Mes)</span>
          <div className="text-2xl font-serif font-bold text-stone-900 mt-2">
            324 unidades
          </div>
          <div className="text-xs text-stone-400 mt-1">Alta rotación en vestidos</div>
        </div>

        <div className="bg-white p-5 rounded-3xl border border-[#eae3db] shadow-xs">
          <span className="text-xs font-semibold text-stone-500 uppercase">Margen Comercial Bruto</span>
          <div className="text-2xl font-serif font-bold text-emerald-700 mt-2">
            58.4%
          </div>
          <div className="text-xs text-stone-400 mt-1">Rentabilidad sobre costo</div>
        </div>

        <div className="bg-white p-5 rounded-3xl border border-[#eae3db] shadow-xs">
          <span className="text-xs font-semibold text-stone-500 uppercase">Método Preferido</span>
          <div className="text-2xl font-serif font-bold text-[#7b1fa2] mt-2">
            Yape / Plin
          </div>
          <div className="text-xs text-stone-400 mt-1">48% de todas las transacciones</div>
        </div>
      </div>

      {/* Graphs Row: Weekly Sales & Category Share */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Sales by day of week */}
        <div className="lg:col-span-2 bg-white p-6 rounded-3xl border border-[#eae3db] shadow-xs">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="font-serif font-bold text-base text-stone-900">
                Ventas por Día del Mes / Semana
              </h3>
              <p className="text-xs text-stone-400">Ingresos diarios registrados en soles</p>
            </div>
            <div className="flex items-center gap-2">
              <span className="w-3 h-3 rounded-full bg-[#c26d60]" />
              <span className="text-xs text-stone-600 font-medium">Venta Neta (S/)</span>
            </div>
          </div>

          <div className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={MOCK_SALES_CHART} margin={{ top: 10, right: 10, left: -10, bottom: 0 }}>
                <XAxis dataKey="day" stroke="#a8a29e" fontSize={11} tickLine={false} />
                <YAxis stroke="#a8a29e" fontSize={11} tickLine={false} tickFormatter={v => `S/${v}`} />
                <Tooltip
                  formatter={(val: any) => [`S/ ${Number(val).toFixed(2)}`, 'Venta total']}
                  contentStyle={{
                    backgroundColor: '#fff',
                    borderRadius: '16px',
                    borderColor: '#eae3db',
                    fontSize: '12px',
                    boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
                  }}
                />
                <Bar dataKey="ventas" fill="#c26d60" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Category Share Donut */}
        <div className="bg-white p-6 rounded-3xl border border-[#eae3db] shadow-xs flex flex-col justify-between">
          <div>
            <h3 className="font-serif font-bold text-base text-stone-900">
              Ventas por Categoría
            </h3>
            <p className="text-xs text-stone-400 mb-3">Distribución porcentual de demanda</p>
            <div className="h-56 w-full flex items-center justify-center">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={MOCK_CATEGORY_SHARE}
                    cx="50%"
                    cy="50%"
                    innerRadius={50}
                    outerRadius={80}
                    paddingAngle={3}
                    dataKey="value"
                  >
                    {MOCK_CATEGORY_SHARE.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip
                    formatter={(val: any) => [`${val}%`, 'Participación']}
                    contentStyle={{ borderRadius: '12px', fontSize: '11px' }}
                  />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="space-y-1.5 pt-3 border-t border-stone-100 text-xs">
            {MOCK_CATEGORY_SHARE.map(c => (
              <div key={c.name} className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <span className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: c.color }} />
                  <span className="text-stone-600">{c.name}</span>
                </div>
                <span className="font-bold text-stone-900">{c.value}%</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Row: Top 5 Best Sellers & Payment Methods */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Top 5 Products */}
        <div className="lg:col-span-2 bg-white p-6 rounded-3xl border border-[#eae3db] shadow-xs">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="font-serif font-bold text-base text-stone-900">
                Top 5 Prendas Más Vendidas
              </h3>
              <p className="text-xs text-stone-400">Prendas con mayor facturación en el período</p>
            </div>
            <Award className="w-5 h-5 text-amber-500" />
          </div>

          <div className="space-y-3">
            {topProducts.map((item, idx) => (
              <div
                key={idx}
                className="p-3 rounded-2xl border border-stone-100 bg-stone-50/50 flex items-center justify-between gap-3 hover:bg-stone-50 transition-colors"
              >
                <div className="flex items-center gap-3">
                  <span className="w-6 h-6 rounded-full bg-stone-900 text-white font-bold text-xs flex items-center justify-center shrink-0">
                    {idx + 1}
                  </span>
                  <img
                    src={item.product?.image}
                    alt={item.product?.name}
                    className="w-12 h-12 rounded-xl object-cover border border-stone-200 shrink-0"
                  />
                  <div>
                    <h5 className="font-semibold text-xs text-stone-900">{item.product?.name}</h5>
                    <div className="text-[10px] text-stone-400 font-mono">
                      {item.product?.category} • S/ {item.product?.salePrice.toFixed(2)}
                    </div>
                  </div>
                </div>

                <div className="text-right">
                  <div className="font-serif font-bold text-sm text-stone-900">
                    S/ {item.revenue.toFixed(2)}
                  </div>
                  <div className="text-[11px] text-stone-500 font-medium">
                    {item.salesCount} unidades vendidas
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Payment Methods Breakdown */}
        <div className="bg-white p-6 rounded-3xl border border-[#eae3db] shadow-xs flex flex-col justify-between">
          <div>
            <h3 className="font-serif font-bold text-base text-stone-900">
              Canales de Cobro
            </h3>
            <p className="text-xs text-stone-400 mb-4">Comportamiento de pago de las clientas</p>

            <div className="space-y-4">
              {MOCK_PAYMENT_SHARE.map(pm => (
                <div key={pm.name} className="space-y-1.5">
                  <div className="flex items-center justify-between text-xs">
                    <span className="font-semibold text-stone-800">{pm.name}</span>
                    <span className="font-bold text-stone-900">{pm.percentage}%</span>
                  </div>
                  <div className="w-full bg-stone-100 h-2.5 rounded-full overflow-hidden">
                    <div
                      className="h-full rounded-full transition-all duration-500"
                      style={{ width: `${pm.percentage}%`, backgroundColor: pm.color }}
                    />
                  </div>
                  <div className="text-[10px] text-stone-400 text-right">
                    {pm.count} transacciones registradas
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="p-3.5 rounded-2xl bg-[#faf6f2] border border-[#ebe1d5] text-xs text-stone-600 space-y-1 mt-4">
            <span className="font-semibold text-stone-800 block">💡 Tip comercial:</span>
            <span>
              Yape y Plin representan casi la mitad de los cobros en tienda. El checkout rápido por QR reduce filas en horas pico.
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};
