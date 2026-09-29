'use client';

import React from 'react';
import { useApp, NavTab } from '@/context/AppContext';
import {
  LayoutDashboard,
  ShoppingBag,
  Package,
  FileText,
  Users,
  BarChart3,
  Sparkles,
  CheckCircle2,
  Building2
} from 'lucide-react';

interface SidebarItem {
  id: NavTab;
  label: string;
  icon: React.ElementType;
  badge?: string | number;
  highlight?: boolean;
}

export const Sidebar: React.FC = () => {
  const { activeTab, setActiveTab, products, vouchers, storeInfo } = useApp();

  const lowStockCount = products.filter(p => p.stock <= p.minStock).length;
  const todayVouchersCount = vouchers.length;

  const navItems: SidebarItem[] = [
    {
      id: 'dashboard',
      label: 'Dashboard',
      icon: LayoutDashboard,
    },
    {
      id: 'pos',
      label: 'Punto de Venta',
      icon: ShoppingBag,
      badge: 'F2',
      highlight: true,
    },
    {
      id: 'inventory',
      label: 'Inventario',
      icon: Package,
      badge: lowStockCount > 0 ? `${lowStockCount} alertas` : undefined,
    },
    {
      id: 'vouchers',
      label: 'Comprobantes SUNAT',
      icon: FileText,
      badge: todayVouchersCount > 0 ? todayVouchersCount : undefined,
    },
    {
      id: 'customers',
      label: 'Clientes',
      icon: Users,
    },
    {
      id: 'reports',
      label: 'Reportes y Métricas',
      icon: BarChart3,
    },
  ];

  return (
    <aside className="w-64 bg-white border-r border-[#eae3db] flex flex-col justify-between shrink-0 h-[calc(100vh-4rem)]">
      {/* Navigation list */}
      <div className="p-4 space-y-6 overflow-y-auto">
        <div>
          <div className="text-[11px] font-semibold text-stone-400 tracking-wider uppercase px-3 mb-2">
            Módulos del Sistema
          </div>
          <nav className="space-y-1.5">
            {navItems.map(item => {
              const Icon = item.icon;
              const isActive = activeTab === item.id;

              return (
                <button
                  key={item.id}
                  onClick={() => setActiveTab(item.id)}
                  className={`w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl text-sm font-medium transition-all group ${
                    isActive
                      ? item.highlight
                        ? 'bg-[#c26d60] text-white shadow-md shadow-[#c26d60]/25'
                        : 'bg-stone-900 text-white shadow-sm'
                      : item.highlight
                      ? 'text-[#c26d60] bg-[#fcedea]/60 hover:bg-[#fcedea] font-semibold'
                      : 'text-stone-600 hover:text-stone-900 hover:bg-stone-100/80'
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <Icon
                      className={`w-5 h-5 transition-transform group-hover:scale-110 ${
                        isActive
                          ? 'text-white'
                          : item.highlight
                          ? 'text-[#c26d60]'
                          : 'text-stone-400 group-hover:text-stone-700'
                      }`}
                    />
                    <span>{item.label}</span>
                  </div>

                  {item.badge && (
                    <span
                      className={`text-[11px] px-2 py-0.5 rounded-full font-bold transition-colors ${
                        isActive
                          ? 'bg-white/20 text-white'
                          : item.id === 'inventory' && lowStockCount > 0
                          ? 'bg-amber-100 text-amber-800'
                          : item.highlight
                          ? 'bg-[#c26d60] text-white text-[10px]'
                          : 'bg-stone-200 text-stone-700'
                      }`}
                    >
                      {item.badge}
                    </span>
                  )}
                </button>
              );
            })}
          </nav>
        </div>

        {/* Feature Highlights Card for client confidence */}
        <div className="p-3.5 rounded-2xl bg-[#faf6f2] border border-[#ebe1d5] space-y-2.5">
          <div className="flex items-center gap-2 text-xs font-semibold text-stone-800">
            <Building2 className="w-4 h-4 text-[#c26d60]" />
            <span>Datos Fiscales Tienda</span>
          </div>
          <div className="text-xs text-stone-600 space-y-1">
            <div className="flex justify-between">
              <span className="text-stone-400">RUC:</span>
              <span className="font-mono font-medium text-stone-800">{storeInfo.ruc}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-stone-400">Series:</span>
              <span className="font-mono text-stone-700 font-medium">B001 / F001</span>
            </div>
            <div className="flex justify-between">
              <span className="text-stone-400">PSE/OSE:</span>
              <span className="text-emerald-700 font-medium flex items-center gap-1">
                <CheckCircle2 className="w-3 h-3 text-emerald-600" /> Activo
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Footer Info */}
      <div className="p-4 border-t border-[#eae3db] bg-stone-50/50">
        <div className="flex items-center justify-between text-[11px] text-stone-400">
          <span>Versión 2.4.0 (Enterprise)</span>
          <span className="flex items-center gap-1 text-[#c26d60] font-medium">
            <Sparkles className="w-3 h-3" /> Demo Pro
          </span>
        </div>
      </div>
    </aside>
  );
};
