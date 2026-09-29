'use client';

import React, { useState, useMemo } from 'react';
import { useApp } from '@/context/AppContext';
import { Voucher } from '@/mock/mockData';
import { VoucherModal } from './VoucherModal';
import {
  FileText,
  Search,
  Filter,
  CheckCircle2,
  Printer,
  Download,
  Share2,
  Calendar,
  Smartphone,
  ShieldCheck,
  Sparkles,
  ArrowRight
} from 'lucide-react';

export const VouchersView: React.FC = () => {
  const { vouchers, storeInfo, notify } = useApp();

  const [searchTerm, setSearchTerm] = useState('');
  const [selectedType, setSelectedType] = useState<string>('TODOS');
  const [selectedVoucherForModal, setSelectedVoucherForModal] = useState<Voucher | null>(null);

  // Statistics
  const totalBilled = vouchers.reduce((acc, v) => acc + v.total, 0);
  const boletasCount = vouchers.filter(v => v.type === 'BOLETA').length;
  const facturasCount = vouchers.filter(v => v.type === 'FACTURA').length;

  const filteredVouchers = useMemo(() => {
    return vouchers.filter(v => {
      const matchesSearch =
        v.seriesNumber.toLowerCase().includes(searchTerm.toLowerCase()) ||
        v.customerName.toLowerCase().includes(searchTerm.toLowerCase()) ||
        v.customerDocNumber.includes(searchTerm);
      const matchesType = selectedType === 'TODOS' || v.type === selectedType;
      return matchesSearch && matchesType;
    });
  }, [vouchers, searchTerm, selectedType]);

  const handleSendWhatsApp = (v: Voucher) => {
    const text = encodeURIComponent(
      `¡Hola ${v.customerName}! 🛍️ Te compartimos tu comprobante electrónico *${v.seriesNumber}* de *${storeInfo.commercialName}* por S/ ${v.total.toFixed(2)}. Estado: Aceptado por SUNAT ✅.`
    );
    window.open(`https://wa.me/?text=${text}`, '_blank');
  };

  return (
    <div className="flex-1 overflow-y-auto p-4 md:p-6 lg:p-8 space-y-6 bg-[#faf8f5]">
      {/* Top Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-700 text-xs font-semibold mb-1 border border-emerald-200">
            <ShieldCheck className="w-3.5 h-3.5 text-emerald-600" />
            <span>Facturación Electrónica SUNAT / OSE Homologada</span>
          </div>
          <h1 className="font-serif text-2xl md:text-3xl font-bold text-stone-900">
            Comprobantes de Pago Electrónicos
          </h1>
          <p className="text-xs text-stone-500">
            Historial de Boletas (B001) y Facturas (F001) con firma digital y CDR de constancia.
          </p>
        </div>
      </div>

      {/* KPI Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div className="bg-white p-5 rounded-3xl border border-[#eae3db] shadow-xs">
          <div className="text-xs font-semibold text-stone-500 uppercase">Total Facturado</div>
          <div className="text-2xl font-serif font-bold text-stone-900 mt-1">
            S/ {totalBilled.toFixed(2)}
          </div>
          <div className="text-xs text-stone-400 mt-0.5">{vouchers.length} comprobantes emitidos</div>
        </div>

        <div className="bg-white p-5 rounded-3xl border border-[#eae3db] shadow-xs">
          <div className="text-xs font-semibold text-stone-500 uppercase">Boletas de Venta (B001)</div>
          <div className="text-2xl font-serif font-bold text-[#c26d60] mt-1">
            {boletasCount} emitidas
          </div>
          <div className="text-xs text-stone-400 mt-0.5">Personas naturales con DNI</div>
        </div>

        <div className="bg-white p-5 rounded-3xl border border-[#eae3db] shadow-xs">
          <div className="text-xs font-semibold text-stone-500 uppercase">Facturas con RUC (F001)</div>
          <div className="text-2xl font-serif font-bold text-blue-700 mt-1">
            {facturasCount} emitidas
          </div>
          <div className="text-xs text-stone-400 mt-0.5">Empresas con crédito fiscal</div>
        </div>
      </div>

      {/* Search & Filters */}
      <div className="bg-white p-4 rounded-3xl border border-[#eae3db] shadow-xs flex flex-col sm:flex-row gap-3 items-center justify-between">
        <div className="relative w-full sm:w-80">
          <Search className="w-4 h-4 text-stone-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchTerm}
            onChange={e => setSearchTerm(e.target.value)}
            placeholder="Buscar por serie (B001/F001) o cliente..."
            className="w-full pl-10 pr-4 py-2 rounded-xl border border-stone-200 focus:border-[#c26d60] text-xs bg-stone-50/50 outline-none"
          />
        </div>

        <div className="flex items-center gap-2">
          <span className="text-xs text-stone-400 font-medium">Tipo:</span>
          {[
            { id: 'TODOS', label: 'Todos' },
            { id: 'BOLETA', label: 'Boletas (B001)' },
            { id: 'FACTURA', label: 'Facturas (F001)' },
          ].map(t => (
            <button
              key={t.id}
              onClick={() => setSelectedType(t.id)}
              className={`px-3 py-1.5 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
                selectedType === t.id
                  ? 'bg-stone-900 text-white shadow-2xs'
                  : 'bg-stone-100 hover:bg-stone-200 text-stone-600'
              }`}
            >
              {t.label}
            </button>
          ))}
        </div>
      </div>

      {/* Vouchers Table */}
      <div className="bg-white rounded-3xl border border-[#eae3db] shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="bg-[#faf6f2] border-b border-[#eae3db] text-stone-500 font-semibold uppercase text-[10px]">
                <th className="py-3 px-4">Comprobante</th>
                <th className="py-3 px-3">Fecha y Hora</th>
                <th className="py-3 px-3">Cliente / Receptor</th>
                <th className="py-3 px-3">Documento</th>
                <th className="py-3 px-3">Pago</th>
                <th className="py-3 px-3 text-right">Importe Total</th>
                <th className="py-3 px-3 text-center">Estado SUNAT</th>
                <th className="py-3 px-4 text-right">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stone-100">
              {filteredVouchers.map(v => (
                <tr key={v.id} className="hover:bg-stone-50/70 transition-colors">
                  <td className="py-3 px-4 font-mono font-medium text-stone-900">
                    <div className="flex items-center gap-2">
                      <span
                        className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                          v.type === 'BOLETA'
                            ? 'bg-[#fcedea] text-[#c26d60] border border-[#f5d0ca]'
                            : 'bg-blue-50 text-blue-700 border border-blue-200'
                        }`}
                      >
                        {v.type}
                      </span>
                      <span className="font-bold">{v.seriesNumber}</span>
                    </div>
                  </td>

                  <td className="py-3 px-3 text-stone-500">
                    <div>{v.date}</div>
                    <div className="text-[10px] text-stone-400">{v.time}</div>
                  </td>

                  <td className="py-3 px-3 max-w-[180px] truncate font-medium text-stone-800">
                    {v.customerName}
                  </td>

                  <td className="py-3 px-3 font-mono text-stone-600">
                    <span className="text-[10px] text-stone-400 mr-1">{v.customerDocType}:</span>
                    {v.customerDocNumber}
                  </td>

                  <td className="py-3 px-3">
                    <span className="px-2 py-0.5 rounded-full bg-stone-100 text-stone-700 text-[10px] font-medium">
                      {v.paymentMethod}
                    </span>
                  </td>

                  <td className="py-3 px-3 text-right font-serif font-bold text-stone-900 text-sm">
                    S/ {v.total.toFixed(2)}
                  </td>

                  <td className="py-3 px-3 text-center">
                    <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200 text-[10px] font-semibold">
                      <CheckCircle2 className="w-3 h-3 text-emerald-600" />
                      CDR Aceptado
                    </span>
                  </td>

                  <td className="py-3 px-4 text-right">
                    <div className="flex items-center justify-end gap-1.5">
                      <button
                        onClick={() => setSelectedVoucherForModal(v)}
                        title="Ver Comprobante / Imprimir"
                        className="p-1.5 rounded-lg bg-stone-100 hover:bg-stone-200 text-stone-700 transition-colors cursor-pointer"
                      >
                        <FileText className="w-4 h-4" />
                      </button>

                      <button
                        onClick={() => handleSendWhatsApp(v)}
                        title="Enviar por WhatsApp"
                        className="p-1.5 rounded-lg bg-emerald-50 hover:bg-emerald-100 text-emerald-700 transition-colors cursor-pointer"
                      >
                        <Smartphone className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Voucher detail modal */}
      <VoucherModal
        voucher={selectedVoucherForModal}
        onClose={() => setSelectedVoucherForModal(null)}
      />
    </div>
  );
};
