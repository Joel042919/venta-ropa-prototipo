'use client';

import React, { useState, useEffect } from 'react';
import { useApp } from '@/context/AppContext';
import {
  Sparkles,
  Wifi,
  WifiOff,
  Clock,
  Store,
  ChevronDown,
  Bell,
  LogOut,
  ShieldCheck,
  Maximize2
} from 'lucide-react';

export const Header: React.FC = () => {
  const { user, storeInfo, sunatConnected, toggleSunatConnection, logout, products } = useApp();
  const [time, setTime] = useState<string>('');

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setTime(
        now.toLocaleTimeString('es-PE', {
          hour: '2-digit',
          minute: '2-digit',
          second: '2-digit',
          hour12: true,
        })
      );
    };
    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  const lowStockCount = products.filter(p => p.stock <= p.minStock).length;

  const toggleFullscreen = () => {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen().catch(() => {});
    } else {
      document.exitFullscreen().catch(() => {});
    }
  };

  return (
    <header className="h-16 bg-white border-b border-[#eae3db] px-4 md:px-6 flex items-center justify-between shadow-xs sticky top-0 z-30">
      {/* Left: Store identity & Branch */}
      <div className="flex items-center gap-3">
        <div className="flex items-center gap-2">
          <div className="w-9 h-9 rounded-xl bg-[#c26d60] text-white flex items-center justify-center shadow-sm">
            <Sparkles className="w-5 h-5" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <span className="font-serif font-bold text-lg text-stone-900 tracking-tight">
                {storeInfo.commercialName}
              </span>
              <span className="text-[10px] font-medium tracking-wide uppercase px-2 py-0.5 rounded-full bg-[#fcedea] text-[#c26d60] border border-[#f5d0ca]">
                POS Boutique
              </span>
            </div>
            <div className="flex items-center gap-1.5 text-xs text-stone-500">
              <Store className="w-3.5 h-3.5 text-stone-400" />
              <span>{user.storeBranch}</span>
              <span className="text-stone-300">•</span>
              <span>{user.registerNumber}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Right: Live Indicators, SUNAT Status, Cashier */}
      <div className="flex items-center gap-3">
        {/* Real-time Clock */}
        <div className="hidden lg:flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-stone-50 border border-stone-200 text-stone-600 text-xs font-medium">
          <Clock className="w-3.5 h-3.5 text-[#c26d60]" />
          <span>{time || '10:45 AM'}</span>
        </div>

        {/* SUNAT Connection Pill (Crucial for client presentation) */}
        <button
          onClick={toggleSunatConnection}
          title="Click para alternar simulación de conexión con SUNAT"
          className={`flex items-center gap-2 px-3 py-1.5 rounded-full border text-xs font-semibold transition-all shadow-xs ${
            sunatConnected
              ? 'bg-emerald-50 border-emerald-300 text-emerald-800 hover:bg-emerald-100'
              : 'bg-amber-50 border-amber-300 text-amber-800 hover:bg-amber-100'
          }`}
        >
          <span className="relative flex h-2.5 w-2.5">
            <span
              className={`animate-ping absolute inline-flex h-full w-full rounded-full opacity-75 ${
                sunatConnected ? 'bg-emerald-400' : 'bg-amber-400'
              }`}
            ></span>
            <span
              className={`relative inline-flex rounded-full h-2.5 w-2.5 ${
                sunatConnected ? 'bg-emerald-500' : 'bg-amber-500'
              }`}
            ></span>
          </span>
          <div className="flex items-center gap-1">
            <ShieldCheck className="w-3.5 h-3.5 text-emerald-600" />
            <span>{sunatConnected ? 'Conectado a SUNAT' : 'SUNAT en Contingencia'}</span>
          </div>
          <span className="hidden sm:inline-block text-[10px] font-normal text-stone-500 border-l border-emerald-200 pl-1.5">
            CDR Automático
          </span>
        </button>

        {/* Fullscreen Button */}
        <button
          onClick={toggleFullscreen}
          title="Modo Pantalla Completa (Ideal para presentación)"
          className="p-2 rounded-lg text-stone-500 hover:text-stone-800 hover:bg-stone-100 transition-colors hidden sm:flex items-center justify-center"
        >
          <Maximize2 className="w-4 h-4" />
        </button>

        {/* Cashier Info & Logout */}
        <div className="flex items-center pl-2 border-l border-stone-200 gap-2">
          <img
            src={user.avatar}
            alt={user.name}
            className="w-8 h-8 rounded-full object-cover ring-2 ring-[#c26d60]/20"
          />
          <div className="hidden md:block text-left text-xs leading-tight">
            <div className="font-semibold text-stone-800">{user.name}</div>
            <div className="text-[11px] text-stone-400">{user.role}</div>
          </div>
          <button
            onClick={logout}
            title="Cerrar sesión demo"
            className="p-1.5 rounded-lg text-stone-400 hover:text-red-600 hover:bg-red-50 transition-colors ml-1"
          >
            <LogOut className="w-4 h-4" />
          </button>
        </div>
      </div>
    </header>
  );
};
