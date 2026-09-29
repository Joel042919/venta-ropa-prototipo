'use client';

import React, { useState } from 'react';
import { useApp } from '@/context/AppContext';
import { Sparkles, ShieldCheck, ArrowRight, Store, KeyRound, User } from 'lucide-react';

export const LoginScreen: React.FC = () => {
  const { login, storeInfo } = useApp();
  const [email, setEmail] = useState('cajera.valeria@estiloymoda.pe');
  const [password, setPassword] = useState('demo2026');
  const [loading, setLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      login();
      setLoading(false);
    }, 600);
  };

  return (
    <div className="min-h-screen w-full flex bg-[#faf8f5] text-stone-800">
      {/* Left visual banner (Fashion boutique aesthetic) */}
      <div className="hidden lg:flex lg:w-1/2 relative overflow-hidden bg-stone-900">
        <img
          src="https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&w=1400&q=85"
          alt="Boutique Fashion"
          className="absolute inset-0 w-full h-full object-cover opacity-60 mix-blend-overlay"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-stone-950 via-stone-900/60 to-transparent" />
        
        <div className="relative z-10 p-12 flex flex-col justify-between h-full text-white">
          <div className="flex items-center gap-2.5">
            <div className="w-10 h-10 rounded-xl bg-[#c26d60] flex items-center justify-center text-white shadow-lg">
              <Sparkles className="w-5 h-5" />
            </div>
            <div>
              <span className="font-serif text-2xl font-bold tracking-tight">Estilo & Moda</span>
              <p className="text-xs text-stone-300">Software POS & Facturación SUNAT</p>
            </div>
          </div>

          <div className="space-y-4 max-w-md">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/10 backdrop-blur-md text-xs text-emerald-300 border border-white/10">
              <ShieldCheck className="w-3.5 h-3.5" />
              <span>Conexión OSE / SUNAT Homologada 2026</span>
            </div>
            <h1 className="font-serif text-4xl font-bold leading-tight text-white">
              Agilidad en cada venta, control total de tu inventario.
            </h1>
            <p className="text-stone-300 text-sm leading-relaxed">
              Diseñado exclusivamente para boutiques de moda: gestión por tallas y colores, emisión instantánea de boletas y facturas electrónicas, y reportes en tiempo real.
            </p>
          </div>

          <div className="text-xs text-stone-400 flex items-center justify-between border-t border-white/10 pt-4">
            <span>RUC: {storeInfo.ruc}</span>
            <span>Versión Demo Comercial</span>
          </div>
        </div>
      </div>

      {/* Right Login Form */}
      <div className="flex-1 flex items-center justify-center p-6 md:p-12">
        <div className="w-full max-w-md space-y-8 bg-white p-8 md:p-10 rounded-3xl border border-[#ebe1d5] shadow-xl shadow-stone-200/50">
          <div className="space-y-2 text-center lg:text-left">
            <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-[#fcedea] text-[#c26d60] text-xs font-semibold">
              <Store className="w-3.5 h-3.5" />
              <span>Acceso Rápido al Prototipo</span>
            </div>
            <h2 className="text-2xl font-serif font-bold text-stone-900">Iniciar Turno de Caja</h2>
            <p className="text-xs text-stone-500">
              Ingresa con las credenciales demo predeterminadas para ver el software en acción.
            </p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-medium text-stone-700 mb-1.5">Usuario / Correo</label>
              <div className="relative">
                <User className="w-4 h-4 text-stone-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="email"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  className="w-full pl-10 pr-3.5 py-2.5 rounded-xl border border-stone-200 focus:border-[#c26d60] focus:ring-2 focus:ring-[#c26d60]/20 text-sm outline-none bg-stone-50/50"
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-medium text-stone-700 mb-1.5">Contraseña</label>
              <div className="relative">
                <KeyRound className="w-4 h-4 text-stone-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="password"
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  className="w-full pl-10 pr-3.5 py-2.5 rounded-xl border border-stone-200 focus:border-[#c26d60] focus:ring-2 focus:ring-[#c26d60]/20 text-sm outline-none bg-stone-50/50"
                  required
                />
              </div>
            </div>

            <div className="p-3 rounded-xl bg-[#faf6f2] border border-[#ebe1d5] text-xs text-stone-600 flex items-center justify-between">
              <div>
                <span className="font-semibold text-stone-800">Caja asignada:</span> Caja 01 - San Isidro
              </div>
              <span className="text-emerald-700 font-medium">Turno Mañana</span>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 px-4 rounded-xl bg-[#c26d60] hover:bg-[#b05c50] text-white font-medium text-sm transition-all shadow-md shadow-[#c26d60]/25 flex items-center justify-center gap-2 group cursor-pointer disabled:opacity-75"
            >
              <span>{loading ? 'Accediendo al POS...' : 'Ingresar al Punto de Venta'}</span>
              <ArrowRight className="w-4 h-4 transition-transform group-hover:translate-x-1" />
            </button>
          </form>

          <div className="pt-2 text-center text-xs text-stone-400 border-t border-stone-100">
            Demostración comercial para tienda de moda & accesorios
          </div>
        </div>
      </div>
    </div>
  );
};
