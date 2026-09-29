'use client';

import React, { useState } from 'react';
import { useApp } from '@/context/AppContext';
import { MOCK_SALES_CHART, MOCK_CATEGORY_SHARE } from '@/mock/mockData';
import { VoucherModal } from '../Vouchers/VoucherModal';
import { Voucher } from '@/mock/mockData';
import {
  TrendingUp,
  CreditCard,
  ShoppingBag,
  AlertTriangle,
  FileText,
  Calendar,
  ArrowUpRight,
  ArrowRight,
  Sparkles,
  Package,
  CheckCircle2,
  RefreshCw
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

export const DashboardView: React.FC = () => {
  const { vouchers, products, setActiveTab, updateProductStock, notify } = useApp();
  const [selectedVoucherForDetail, setSelectedVoucherForDetail] = useState<Voucher | null>(null);

  // Calculate day totals
  const todayTotal = vouchers.reduce((acc, v) => acc + v.total, 0);
  const lowStockItems = products.filter(p => p.stock <= p.minStock);

  const handleQuickRestock = (productId: string, productName: string) => {
    updateProductStock(productId, 12, 'Reabastecimiento rápido desde Dashboard');
    notify('Stock Repuesto', `Se añadieron 12 unidades a "${productName}".`, 'success');
  };

  return (
    <div className="flex-1 overflow-y-auto p-4 md:p-6 lg:p-8 space-y-6 bg-[#faf8f5]">
      {/* Top Welcome & Quick Actions */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-[#fcedea] text-[#c26d60] text-xs font-semibold mb-1">
            <Sparkles className="w-3.5 h-3.5" />
            <span>Resumen Ejecutivo en Tiempo Real</span>
          </div>
          <h1 className="font-serif text-2xl md:text-3xl font-bold text-stone-900">
            Panel de Control de Boutique
          </h1>
          <p className="text-xs text-stone-500">
            Monitoreo comercial, emisión electrónica y salud de inventario en vivo.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={() => setActiveTab('pos')}
            className="flex items-center gap-2 px-5 py-2.5 rounded-2xl bg-[#c26d60] hover:bg-[#b05c50] text-white font-semibold text-xs transition-all shadow-md shadow-[#c26d60]/25 cursor-pointer"
          >
            <ShoppingBag className="w-4 h-4" />
            <span>Ir al Punto de Venta (POS)</span>
            <ArrowRight className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* KPI 1: Ventas del Día */}
        <div className="bg-white p-5 rounded-3xl border border-[#eae3db] shadow-xs relative overflow-hidden">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-stone-500 uppercase tracking-wide">
              Ventas del Día
            </span>
            <div className="w-9 h-9 rounded-2xl bg-[#fcedea] text-[#c26d60] flex items-center justify-center">
              <TrendingUp className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-3">
            <div className="text-2xl font-serif font-bold text-stone-900">
              S/ {todayTotal.toFixed(2)}
            </div>
            <div className="flex items-center gap-1 mt-1 text-xs text-emerald-600 font-semibold">
              <ArrowUpRight className="w-3.5 h-3.5" />
              <span>+18.4% vs ayer</span>
            </div>
          </div>
        </div>

        {/* KPI 2: Ventas del Mes */}
        <div className="bg-white p-5 rounded-3xl border border-[#eae3db] shadow-xs relative overflow-hidden">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-stone-500 uppercase tracking-wide">
              Ventas del Mes
            </span>
            <div className="w-9 h-9 rounded-2xl bg-amber-50 text-amber-600 flex items-center justify-center">
              <Calendar className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-3">
            <div className="text-2xl font-serif font-bold text-stone-900">
              S/ 38,920.00
            </div>
            <div className="flex items-center gap-1 mt-1 text-xs text-emerald-600 font-semibold">
              <ArrowUpRight className="w-3.5 h-3.5" />
              <span>+24.2% vs mes anterior</span>
            </div>
          </div>
        </div>

        {/* KPI 3: Comprobantes SUNAT */}
        <div className="bg-white p-5 rounded-3xl border border-[#eae3db] shadow-xs relative overflow-hidden">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-stone-500 uppercase tracking-wide">
              Comprobantes Hoy
            </span>
            <div className="w-9 h-9 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <FileText className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-3">
            <div className="text-2xl font-serif font-bold text-stone-900">
              {vouchers.length} Emitidos
            </div>
            <div className="flex items-center gap-1 mt-1 text-xs text-stone-500">
              <span className="font-semibold text-emerald-600">100% CDR SUNAT</span>
              <span>Aceptados</span>
            </div>
          </div>
        </div>

        {/* KPI 4: Stock Bajo */}
        <div className="bg-white p-5 rounded-3xl border border-[#eae3db] shadow-xs relative overflow-hidden">
          <div className="flex items-center justify-between">
            <span className="text-xs font-semibold text-stone-500 uppercase tracking-wide">
              Alertas de Stock
            </span>
            <div className="w-9 h-9 rounded-2xl bg-rose-50 text-rose-600 flex items-center justify-center">
              <AlertTriangle className="w-5 h-5" />
            </div>
          </div>
          <div className="mt-3">
            <div className="text-2xl font-serif font-bold text-stone-900">
              {lowStockItems.length} Prendas
            </div>
            <div className="flex items-center gap-1 mt-1 text-xs text-rose-600 font-semibold">
              <span>Requieren reposición</span>
            </div>
          </div>
        </div>
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Weekly sales bar chart */}
        <div className="lg:col-span-2 bg-white p-5 md:p-6 rounded-3xl border border-[#eae3db] shadow-xs">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="font-serif font-bold text-base text-stone-900">
                Tendencia de Ventas Semanales (S/)
              </h3>
              <p className="text-xs text-stone-400">Flujo diario de ingresos de la boutique</p>
            </div>
            <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-stone-100 text-stone-600">
              Últimos 7 días
            </span>
          </div>

          <div className="h-64 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={MOCK_SALES_CHART} margin={{ top: 10, right: 10, left: -10, bottom: 0 }}>
                <XAxis dataKey="day" stroke="#a8a29e" fontSize={11} tickLine={false} />
                <YAxis stroke="#a8a29e" fontSize={11} tickLine={false} tickFormatter={v => `S/${v}`} />
                <Tooltip
                  formatter={(val: any) => [`S/ ${Number(val).toFixed(2)}`, 'Ventas']}
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
        <div className="bg-white p-5 md:p-6 rounded-3xl border border-[#eae3db] shadow-xs flex flex-col justify-between">
          <div>
            <h3 className="font-serif font-bold text-base text-stone-900">
              Ventas por Categoría
            </h3>
            <p className="text-xs text-stone-400 mb-2">Prendas con mayor demanda</p>
            <div className="h-52 w-full flex items-center justify-center">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={MOCK_CATEGORY_SHARE}
                    cx="50%"
                    cy="50%"
                    innerRadius={50}
                    outerRadius={75}
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

          <div className="grid grid-cols-2 gap-2 text-xs pt-2 border-t border-stone-100">
            {MOCK_CATEGORY_SHARE.map(c => (
              <div key={c.name} className="flex items-center gap-1.5">
                <span className="w-2.5 h-2.5 rounded-full shrink-0" style={{ backgroundColor: c.color }} />
                <span className="text-stone-600 truncate text-[11px]">{c.name}</span>
                <span className="font-semibold text-stone-900 text-[11px] ml-auto">{c.value}%</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Two columns: Recent Sales & Low Stock Alerts */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent sales table */}
        <div className="lg:col-span-2 bg-white rounded-3xl border border-[#eae3db] p-5 md:p-6 shadow-xs">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="font-serif font-bold text-base text-stone-900">
                Últimos Comprobantes Emitidos
              </h3>
              <p className="text-xs text-stone-400">Boletas y facturas sincronizadas con SUNAT</p>
            </div>
            <button
              onClick={() => setActiveTab('vouchers')}
              className="text-xs font-semibold text-[#c26d60] hover:text-[#b05c50] flex items-center gap-1 cursor-pointer"
            >
              <span>Ver todos</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </button>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead>
                <tr className="border-b border-stone-200 text-stone-400 font-semibold uppercase text-[10px]">
                  <th className="pb-2">Comprobante</th>
                  <th className="pb-2">Cliente</th>
                  <th className="pb-2">Método</th>
                  <th className="pb-2 text-right">Total</th>
                  <th className="pb-2 text-center">SUNAT</th>
                  <th className="pb-2 text-right">Acción</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-stone-100">
                {vouchers.slice(0, 5).map(v => (
                  <tr key={v.id} className="hover:bg-stone-50/70 transition-colors">
                    <td className="py-3 font-mono font-medium text-stone-800">
                      <div className="flex items-center gap-1.5">
                        <span
                          className={`px-1.5 py-0.5 rounded text-[10px] font-bold ${
                            v.type === 'BOLETA' ? 'bg-[#fcedea] text-[#c26d60]' : 'bg-blue-50 text-blue-700'
                          }`}
                        >
                          {v.type}
                        </span>
                        <span>{v.seriesNumber}</span>
                      </div>
                    </td>
                    <td className="py-3 max-w-[140px] truncate text-stone-700 font-medium">
                      {v.customerName}
                    </td>
                    <td className="py-3 text-stone-500">{v.paymentMethod}</td>
                    <td className="py-3 text-right font-serif font-bold text-stone-900">
                      S/ {v.total.toFixed(2)}
                    </td>
                    <td className="py-3 text-center">
                      <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 text-[10px] font-semibold">
                        <CheckCircle2 className="w-3 h-3 text-emerald-600" />
                        CDR Aceptado
                      </span>
                    </td>
                    <td className="py-3 text-right">
                      <button
                        onClick={() => setSelectedVoucherForDetail(v)}
                        className="px-2.5 py-1 rounded-lg bg-stone-100 hover:bg-stone-200 text-stone-700 font-medium text-[11px] transition-colors cursor-pointer"
                      >
                        Ver Detalle
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Low Stock Alerts */}
        <div className="bg-white rounded-3xl border border-[#eae3db] p-5 md:p-6 shadow-xs flex flex-col justify-between">
          <div>
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="font-serif font-bold text-base text-stone-900">
                  Alertas de Reposición
                </h3>
                <p className="text-xs text-stone-400">Prendas con stock mínimo o agotado</p>
              </div>
              <span className="w-6 h-6 rounded-full bg-rose-100 text-rose-700 flex items-center justify-center text-xs font-bold">
                {lowStockItems.length}
              </span>
            </div>

            <div className="space-y-3">
              {lowStockItems.slice(0, 4).map(prod => (
                <div
                  key={prod.id}
                  className="p-3 rounded-2xl border border-stone-200 bg-stone-50/50 flex items-center justify-between gap-2"
                >
                  <img
                    src={prod.image}
                    alt={prod.name}
                    className="w-10 h-10 rounded-xl object-cover border border-stone-200 shrink-0"
                  />
                  <div className="flex-1 min-w-0 text-xs">
                    <h5 className="font-semibold text-stone-800 truncate">{prod.name}</h5>
                    <div className="flex items-center gap-2 text-[10px] mt-0.5">
                      <span className="font-mono text-stone-400">{prod.sku}</span>
                      <span className={`font-bold ${prod.stock === 0 ? 'text-rose-600' : 'text-amber-600'}`}>
                        {prod.stock === 0 ? 'Agotado (0)' : `Quedan ${prod.stock} un.`}
                      </span>
                    </div>
                  </div>

                  <button
                    onClick={() => handleQuickRestock(prod.id, prod.name)}
                    title="Reponer 12 unidades inmediatamente"
                    className="px-2.5 py-1.5 rounded-xl bg-stone-900 hover:bg-[#c26d60] text-white text-[11px] font-semibold transition-colors flex items-center gap-1 shrink-0 cursor-pointer"
                  >
                    <RefreshCw className="w-3 h-3" />
                    <span>Reponer</span>
                  </button>
                </div>
              ))}

              {lowStockItems.length === 0 && (
                <div className="p-6 text-center text-stone-400">
                  <CheckCircle2 className="w-8 h-8 text-emerald-500 mx-auto mb-2" />
                  <p className="text-xs font-medium text-stone-600">¡Inventario óptimo!</p>
                  <p className="text-[11px] text-stone-400">Todas las prendas tienen stock suficiente.</p>
                </div>
              )}
            </div>
          </div>

          <div className="pt-4 border-t border-stone-100">
            <button
              onClick={() => setActiveTab('inventory')}
              className="w-full py-2 px-3 rounded-xl bg-stone-100 hover:bg-stone-200 text-stone-700 text-xs font-semibold transition-colors text-center cursor-pointer"
            >
              Gestionar Inventario Completo
            </button>
          </div>
        </div>
      </div>

      {/* Voucher detail modal if clicked */}
      <VoucherModal
        voucher={selectedVoucherForDetail}
        onClose={() => setSelectedVoucherForDetail(null)}
      />
    </div>
  );
};
