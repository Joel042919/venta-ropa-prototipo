'use client';

import React, { useState } from 'react';
import { useApp } from '@/context/AppContext';
import { Voucher } from '@/mock/mockData';
import {
  X,
  Printer,
  Download,
  Share2,
  CheckCircle2,
  ShieldCheck,
  QrCode,
  Sparkles,
  FileCheck,
  Smartphone
} from 'lucide-react';

interface VoucherModalProps {
  voucher: Voucher | null;
  onClose: () => void;
  justEmitted?: boolean;
}

export const VoucherModal: React.FC<VoucherModalProps> = ({ voucher, onClose, justEmitted = false }) => {
  const { storeInfo, notify } = useApp();
  const [viewFormat, setViewFormat] = useState<'ticket' | 'a4'>('ticket');

  if (!voucher) return null;

  const handlePrint = () => {
    window.print();
  };

  const handleDownloadPdf = () => {
    notify('PDF Generado', `Descargando comprobante ${voucher.seriesNumber}.pdf`, 'success');
  };

  const handleSendWhatsApp = () => {
    const text = encodeURIComponent(
      `¡Hola ${voucher.customerName}! 🛍️ Gracias por tu compra en *${storeInfo.commercialName}*.\n\n` +
      `Tu comprobante electrónico *${voucher.seriesNumber}* por un total de *S/ ${voucher.total.toFixed(2)}* ya está disponible.\n` +
      `✅ Estado: Aceptado por SUNAT.\n` +
      `¡Esperamos que disfrutes tus prendas!`
    );
    window.open(`https://wa.me/?text=${text}`, '_blank');
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-stone-900/60 backdrop-blur-xs overflow-y-auto">
      <div className="bg-white rounded-3xl shadow-2xl max-w-2xl w-full border border-stone-200 overflow-hidden my-6 animate-in fade-in zoom-in-95 duration-200">
        {/* Header Bar */}
        <div className="bg-[#faf6f2] border-b border-[#ebe1d5] px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-2xl bg-emerald-100 text-emerald-700 flex items-center justify-center shadow-xs">
              <FileCheck className="w-5 h-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="font-serif font-bold text-lg text-stone-900">
                  {voucher.type === 'BOLETA' ? 'Boleta Electrónica' : 'Factura Electrónica'}
                </h3>
                <span className="font-mono text-xs px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-800 border border-emerald-200 font-semibold flex items-center gap-1">
                  <CheckCircle2 className="w-3 h-3 text-emerald-600" />
                  CDR SUNAT: Aceptado
                </span>
              </div>
              <p className="text-xs text-stone-500 font-mono">{voucher.seriesNumber}</p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            {/* Toggle format: Ticket 80mm vs A4 */}
            <div className="flex bg-stone-200/70 p-1 rounded-xl text-xs font-medium">
              <button
                onClick={() => setViewFormat('ticket')}
                className={`px-3 py-1 rounded-lg transition-all ${
                  viewFormat === 'ticket' ? 'bg-white text-stone-900 shadow-xs' : 'text-stone-600 hover:text-stone-900'
                }`}
              >
                Ticket 80mm
              </button>
              <button
                onClick={() => setViewFormat('a4')}
                className={`px-3 py-1 rounded-lg transition-all ${
                  viewFormat === 'a4' ? 'bg-white text-stone-900 shadow-xs' : 'text-stone-600 hover:text-stone-900'
                }`}
              >
                Formato A4
              </button>
            </div>

            <button
              onClick={onClose}
              className="p-2 rounded-xl text-stone-400 hover:text-stone-700 hover:bg-stone-200/50 transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Voucher Content (Printable) */}
        <div className="p-6 max-h-[68vh] overflow-y-auto bg-stone-50/50 flex justify-center">
          <div
            id="printable-voucher"
            className={`bg-white border border-stone-200 shadow-sm p-6 text-stone-900 transition-all ${
              viewFormat === 'ticket' ? 'w-full max-w-[340px] text-xs font-mono' : 'w-full text-xs font-sans rounded-xl'
            }`}
          >
            {/* Header info */}
            <div className="text-center pb-4 border-b border-dashed border-stone-300 space-y-1">
              <h2 className="font-bold text-sm tracking-wide uppercase text-stone-900">
                {storeInfo.commercialName}
              </h2>
              <p className="text-[11px] text-stone-600 font-medium">{storeInfo.name}</p>
              <p className="text-[11px] text-stone-600">RUC: {storeInfo.ruc}</p>
              <p className="text-[10px] text-stone-500 leading-tight">
                {storeInfo.address} - {storeInfo.district}, {storeInfo.city}
              </p>
              <p className="text-[10px] text-stone-500">Telf: {storeInfo.phone}</p>
            </div>

            {/* Document Box */}
            <div className="my-3 py-2 px-3 border border-stone-800 text-center rounded-sm bg-stone-50">
              <div className="font-bold text-xs uppercase tracking-wider">
                {voucher.type === 'BOLETA' ? 'BOLETA DE VENTA ELECTRÓNICA' : 'FACTURA ELECTRÓNICA'}
              </div>
              <div className="font-bold text-sm tracking-widest mt-0.5">{voucher.seriesNumber}</div>
            </div>

            {/* Metadata */}
            <div className="space-y-1 pb-3 border-b border-dashed border-stone-300 text-[11px]">
              <div className="flex justify-between">
                <span className="text-stone-500">Fecha Emisión:</span>
                <span className="font-medium">{voucher.date} {voucher.time}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-stone-500">Moneda:</span>
                <span className="font-medium">SOLES (S/)</span>
              </div>
              <div className="flex justify-between">
                <span className="text-stone-500">Forma de Pago:</span>
                <span className="font-semibold text-[#c26d60]">{voucher.paymentMethod}</span>
              </div>
              <div className="pt-1 border-t border-stone-200 mt-1">
                <div className="text-stone-500">Cliente:</div>
                <div className="font-bold text-stone-800 uppercase">{voucher.customerName}</div>
                <div className="text-stone-600">
                  {voucher.customerDocType}: {voucher.customerDocNumber}
                </div>
                {voucher.customerAddress && (
                  <div className="text-stone-500 text-[10px] truncate">{voucher.customerAddress}</div>
                )}
              </div>
            </div>

            {/* Items list */}
            <div className="py-3 border-b border-dashed border-stone-300">
              <table className="w-full text-[11px]">
                <thead>
                  <tr className="border-b border-stone-200 text-stone-500 text-[10px]">
                    <th className="text-left pb-1 font-semibold">CANT</th>
                    <th className="text-left pb-1 font-semibold">DESCRIPCIÓN</th>
                    <th className="text-right pb-1 font-semibold">TOTAL</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-stone-100">
                  {voucher.items.map((item, idx) => (
                    <tr key={idx} className="py-1">
                      <td className="align-top py-1.5 font-medium">{item.quantity}</td>
                      <td className="align-top py-1.5 pr-2">
                        <div className="font-medium text-stone-800 leading-tight">{item.productName}</div>
                        <div className="text-[10px] text-stone-500">
                          Talla: {item.size} | Color: {item.color}
                        </div>
                        <div className="text-[10px] text-stone-400">P.U: S/ {item.unitPrice.toFixed(2)}</div>
                      </td>
                      <td className="align-top py-1.5 text-right font-medium">
                        S/ {item.total.toFixed(2)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Tax totals */}
            <div className="py-2.5 space-y-1 text-[11px] border-b border-dashed border-stone-300">
              <div className="flex justify-between">
                <span className="text-stone-500">Op. Gravada:</span>
                <span>S/ {voucher.subtotal.toFixed(2)}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-stone-500">I.G.V. (18%):</span>
                <span>S/ {voucher.igv.toFixed(2)}</span>
              </div>
              {voucher.discount > 0 && (
                <div className="flex justify-between text-emerald-700">
                  <span>Descuento aplicado:</span>
                  <span>- S/ {voucher.discount.toFixed(2)}</span>
                </div>
              )}
              <div className="flex justify-between font-bold text-xs pt-1 border-t border-stone-200 text-stone-900">
                <span>IMPORTE TOTAL:</span>
                <span className="text-sm">S/ {voucher.total.toFixed(2)}</span>
              </div>
            </div>

            {/* Footer with SUNAT security info */}
            <div className="pt-3 text-center space-y-2">
              <div className="flex justify-center my-1">
                {/* Simulated QR Code */}
                <div className="p-1.5 bg-stone-100 border border-stone-300 rounded flex flex-col items-center">
                  <QrCode className="w-16 h-16 text-stone-800" />
                  <span className="text-[8px] text-stone-500 uppercase tracking-tight mt-0.5">
                    SUNAT CPE QR
                  </span>
                </div>
              </div>

              <div className="text-[9px] text-stone-500 space-y-0.5">
                <p className="font-semibold text-stone-700">
                  Representación impresa de la {voucher.type === 'BOLETA' ? 'Boleta de Venta' : 'Factura'} Electrónica
                </p>
                <p>Autorizado mediante {storeInfo.sunatResolution}</p>
                <p className="font-mono text-[8px] text-stone-400 truncate">
                  Hash CPE: {voucher.hashCpe}
                </p>
                <div className="inline-flex items-center gap-1 text-emerald-700 font-semibold bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200 text-[10px] mt-1">
                  <ShieldCheck className="w-3 h-3 text-emerald-600" />
                  <span>Constancia de Recepción (CDR) Aceptada</span>
                </div>
              </div>

              <p className="text-[10px] font-serif italic text-stone-600 pt-1">
                ¡Gracias por elegir Estilo & Moda!
              </p>
            </div>
          </div>
        </div>

        {/* Action Footer Buttons */}
        <div className="bg-[#faf6f2] border-t border-[#ebe1d5] p-4 px-6 flex flex-wrap items-center justify-between gap-3">
          <div className="flex items-center gap-2">
            <button
              onClick={handlePrint}
              className="flex items-center gap-2 px-4 py-2 rounded-xl bg-stone-900 hover:bg-stone-800 text-white text-xs font-semibold shadow-xs transition-colors cursor-pointer"
            >
              <Printer className="w-4 h-4" />
              <span>Imprimir Ticket</span>
            </button>

            <button
              onClick={handleDownloadPdf}
              className="flex items-center gap-2 px-3.5 py-2 rounded-xl bg-white border border-stone-300 hover:bg-stone-100 text-stone-700 text-xs font-semibold transition-colors cursor-pointer"
            >
              <Download className="w-4 h-4 text-stone-500" />
              <span>Descargar PDF</span>
            </button>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={handleSendWhatsApp}
              className="flex items-center gap-2 px-4 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold shadow-xs transition-colors cursor-pointer"
            >
              <Smartphone className="w-4 h-4" />
              <span>Enviar por WhatsApp</span>
            </button>

            <button
              onClick={onClose}
              className="px-4 py-2 rounded-xl text-stone-500 hover:text-stone-800 text-xs font-medium transition-colors"
            >
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
