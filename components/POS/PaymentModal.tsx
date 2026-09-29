'use client';

import React, { useState } from 'react';
import { useApp } from '@/context/AppContext';
import { Voucher } from '@/mock/mockData';
import confetti from 'canvas-confetti';
import {
  X,
  CreditCard,
  Banknote,
  QrCode,
  ShieldCheck,
  CheckCircle2,
  Loader2,
  ArrowRight,
  Coins,
  Sparkles
} from 'lucide-react';

interface PaymentModalProps {
  isOpen: boolean;
  onClose: () => void;
  voucherType: 'BOLETA' | 'FACTURA';
  customerName: string;
  customerDocType: 'DNI' | 'RUC';
  customerDocNumber: string;
  customerAddress?: string;
  onSuccess: (voucher: Voucher) => void;
}

export const PaymentModal: React.FC<PaymentModalProps> = ({
  isOpen,
  onClose,
  voucherType,
  customerName,
  customerDocType,
  customerDocNumber,
  customerAddress,
  onSuccess,
}) => {
  const { cartTotals, createVoucher, notify } = useApp();

  const [paymentMethod, setPaymentMethod] = useState<'EFECTIVO' | 'TARJETA' | 'YAPE' | 'PLIN'>('EFECTIVO');
  const [cashAmount, setCashAmount] = useState<string>(cartTotals.total.toString());
  const [cardReference, setCardReference] = useState<string>('4589 **** **** 1024');
  const [yapeOperationNumber, setYapeOperationNumber] = useState<string>('849102');

  const [processingState, setProcessingState] = useState<'idle' | 'signing' | 'transmitting' | 'accepted'>('idle');

  if (!isOpen) return null;

  const total = cartTotals.total;
  const cashNum = parseFloat(cashAmount) || 0;
  const changeAmount = Math.max(0, cashNum - total);
  const isCashSufficient = cashNum >= total;

  const handleQuickCash = (amount: number) => {
    setCashAmount(amount.toString());
  };

  const handleProcessPayment = async () => {
    if (paymentMethod === 'EFECTIVO' && !isCashSufficient) {
      notify('Monto Insuficiente', 'El monto recibido en efectivo no puede ser menor al total.', 'warning');
      return;
    }

    try {
      // Step 1: Sign XML
      setProcessingState('signing');
      await new Promise(r => setTimeout(r, 600));

      // Step 2: Transmit to SUNAT
      setProcessingState('transmitting');
      await new Promise(r => setTimeout(r, 800));

      // Step 3: Success CDR
      setProcessingState('accepted');
      try {
        confetti({
          particleCount: 60,
          spread: 70,
          origin: { y: 0.6 },
          colors: ['#c26d60', '#10b981', '#f59e0b', '#3b82f6'],
        });
      } catch (err) {}

      await new Promise(r => setTimeout(r, 500));

      // Create voucher in context
      const newVoucher = await createVoucher({
        type: voucherType,
        customerName,
        customerDocType,
        customerDocNumber,
        customerAddress,
        paymentMethod,
      });

      setProcessingState('idle');
      onSuccess(newVoucher);
    } catch (err) {
      setProcessingState('idle');
      notify('Error en Emisión', 'No se pudo comunicar con el servicio SUNAT.', 'error');
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-stone-900/60 backdrop-blur-xs">
      <div className="bg-white rounded-3xl shadow-2xl max-w-lg w-full border border-[#ebe1d5] overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        {/* Header */}
        <div className="bg-[#faf6f2] border-b border-[#ebe1d5] px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-9 h-9 rounded-xl bg-[#c26d60] text-white flex items-center justify-center shadow-xs">
              <Coins className="w-5 h-5" />
            </div>
            <div>
              <h3 className="font-serif font-bold text-base text-stone-900">Cobro & Emisión SUNAT</h3>
              <p className="text-xs text-stone-500">
                {voucherType === 'BOLETA' ? 'Boleta Electrónica' : 'Factura Electrónica'} • {customerName}
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            disabled={processingState !== 'idle'}
            className="p-1.5 rounded-lg text-stone-400 hover:text-stone-700 hover:bg-stone-200/50 transition-colors disabled:opacity-50"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Body */}
        <div className="p-6 space-y-5">
          {/* Total to pay banner */}
          <div className="p-4 rounded-2xl bg-[#faf6f2] border border-[#ebe1d5] flex items-center justify-between">
            <div>
              <span className="text-xs text-stone-500 uppercase font-semibold">Total a Cobrar</span>
              <div className="text-3xl font-serif font-bold text-stone-900 tracking-tight">
                S/ {total.toFixed(2)}
              </div>
            </div>
            <div className="text-right text-xs text-stone-500 space-y-0.5">
              <div>Subtotal: S/ {cartTotals.subtotal.toFixed(2)}</div>
              <div>IGV (18%): S/ {cartTotals.igv.toFixed(2)}</div>
              {cartTotals.discount > 0 && (
                <div className="text-emerald-700 font-medium">Desc: -S/ {cartTotals.discount.toFixed(2)}</div>
              )}
            </div>
          </div>

          {/* Payment Method Selector */}
          <div>
            <label className="block text-xs font-semibold text-stone-700 mb-2">Selecciona Método de Pago</label>
            <div className="grid grid-cols-3 gap-2.5">
              <button
                type="button"
                onClick={() => setPaymentMethod('EFECTIVO')}
                className={`flex flex-col items-center justify-center p-3 rounded-2xl border text-xs font-medium transition-all cursor-pointer ${
                  paymentMethod === 'EFECTIVO'
                    ? 'border-[#c26d60] bg-[#fcedea] text-[#c26d60] shadow-xs'
                    : 'border-stone-200 hover:bg-stone-50 text-stone-700'
                }`}
              >
                <Banknote className="w-6 h-6 mb-1.5" />
                <span>Efectivo</span>
              </button>

              <button
                type="button"
                onClick={() => setPaymentMethod('YAPE')}
                className={`flex flex-col items-center justify-center p-3 rounded-2xl border text-xs font-medium transition-all cursor-pointer ${
                  paymentMethod === 'YAPE' || paymentMethod === 'PLIN'
                    ? 'border-[#7b1fa2] bg-[#f3e5f5] text-[#7b1fa2] shadow-xs'
                    : 'border-stone-200 hover:bg-stone-50 text-stone-700'
                }`}
              >
                <QrCode className="w-6 h-6 mb-1.5 text-[#7b1fa2]" />
                <span>Yape / Plin</span>
              </button>

              <button
                type="button"
                onClick={() => setPaymentMethod('TARJETA')}
                className={`flex flex-col items-center justify-center p-3 rounded-2xl border text-xs font-medium transition-all cursor-pointer ${
                  paymentMethod === 'TARJETA'
                    ? 'border-[#1976d2] bg-[#e3f2fd] text-[#1976d2] shadow-xs'
                    : 'border-stone-200 hover:bg-stone-50 text-stone-700'
                }`}
              >
                <CreditCard className="w-6 h-6 mb-1.5 text-[#1976d2]" />
                <span>Tarjeta (POS)</span>
              </button>
            </div>
          </div>

          {/* Method Details */}
          {paymentMethod === 'EFECTIVO' && (
            <div className="space-y-3 p-4 rounded-2xl bg-stone-50 border border-stone-200">
              <div className="flex items-center justify-between">
                <label className="text-xs font-semibold text-stone-700">Monto recibido (S/):</label>
                <div className="flex gap-1.5">
                  {[50, 100, 200].map(bill => (
                    <button
                      key={bill}
                      type="button"
                      onClick={() => handleQuickCash(bill)}
                      className="px-2 py-0.5 text-[11px] font-semibold rounded-lg bg-white border border-stone-200 hover:border-[#c26d60] hover:text-[#c26d60] text-stone-700 transition-colors shadow-2xs"
                    >
                      S/ {bill}
                    </button>
                  ))}
                  <button
                    type="button"
                    onClick={() => handleQuickCash(total)}
                    className="px-2 py-0.5 text-[11px] font-semibold rounded-lg bg-white border border-stone-200 hover:border-[#c26d60] hover:text-[#c26d60] text-stone-700 transition-colors shadow-2xs"
                  >
                    Exacto
                  </button>
                </div>
              </div>

              <div className="relative">
                <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-stone-400 font-bold text-sm">S/</span>
                <input
                  type="number"
                  step="0.1"
                  value={cashAmount}
                  onChange={e => setCashAmount(e.target.value)}
                  className="w-full pl-9 pr-4 py-2.5 rounded-xl border border-stone-300 text-lg font-bold text-stone-900 focus:outline-none focus:border-[#c26d60] bg-white"
                />
              </div>

              {/* Vuelto / Change calculation */}
              <div className="flex items-center justify-between pt-2 border-t border-stone-200">
                <span className="text-xs text-stone-600 font-medium">Vuelto a entregar:</span>
                <span className={`text-base font-bold ${changeAmount > 0 ? 'text-emerald-600 font-mono' : 'text-stone-400'}`}>
                  S/ {changeAmount.toFixed(2)}
                </span>
              </div>
            </div>
          )}

          {(paymentMethod === 'YAPE' || paymentMethod === 'PLIN') && (
            <div className="p-4 rounded-2xl bg-purple-50/60 border border-purple-100 flex items-center gap-4">
              <div className="w-20 h-20 bg-white rounded-xl p-1.5 border border-purple-200 flex flex-col items-center justify-center shrink-0">
                <QrCode className="w-14 h-14 text-purple-700" />
                <span className="text-[8px] font-bold text-purple-700">QR TIENDA</span>
              </div>
              <div className="space-y-1 text-xs">
                <div className="font-semibold text-purple-900">Yape a: Estilo & Moda Boutique</div>
                <div className="text-purple-700 font-mono font-medium">Número: 987 654 321</div>
                <div className="text-[11px] text-stone-500 pt-1">
                  N° de Operación (demo):
                </div>
                <input
                  type="text"
                  value={yapeOperationNumber}
                  onChange={e => setYapeOperationNumber(e.target.value)}
                  className="w-full px-2.5 py-1 text-xs font-mono rounded-lg border border-purple-200 bg-white"
                  placeholder="ej: 849102"
                />
              </div>
            </div>
          )}

          {paymentMethod === 'TARJETA' && (
            <div className="p-4 rounded-2xl bg-blue-50/60 border border-blue-100 space-y-2 text-xs">
              <div className="flex items-center justify-between">
                <span className="font-semibold text-blue-900">Terminal IziPay / Niubiz</span>
                <span className="text-blue-700 font-medium">Conectado Bluetooth 🟢</span>
              </div>
              <div className="text-stone-600 text-[11px]">
                Referencia voucher físico (opcional):
              </div>
              <input
                type="text"
                value={cardReference}
                onChange={e => setCardReference(e.target.value)}
                className="w-full px-3 py-2 text-xs font-mono rounded-xl border border-blue-200 bg-white"
                placeholder="4589 **** **** 1024"
              />
            </div>
          )}

          {/* SUNAT Live transmission status during processing */}
          {processingState !== 'idle' && (
            <div className="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-900 space-y-2 animate-in fade-in duration-300">
              <div className="flex items-center gap-2 font-medium text-xs">
                {processingState === 'accepted' ? (
                  <CheckCircle2 className="w-4 h-4 text-emerald-600 animate-bounce" />
                ) : (
                  <Loader2 className="w-4 h-4 text-emerald-600 animate-spin" />
                )}
                <span>
                  {processingState === 'signing' && 'Firmando comprobante con certificado digital RSA...'}
                  {processingState === 'transmitting' && 'Transmitiendo XML al servidor OSE / SUNAT...'}
                  {processingState === 'accepted' && '¡Constancia de Recepción (CDR) Aceptada por SUNAT!'}
                </span>
              </div>
              <div className="w-full bg-emerald-200/60 h-1.5 rounded-full overflow-hidden">
                <div
                  className={`h-full bg-emerald-600 transition-all duration-500 ${
                    processingState === 'signing' ? 'w-1/3' : processingState === 'transmitting' ? 'w-3/4' : 'w-full'
                  }`}
                />
              </div>
            </div>
          )}
        </div>

        {/* Action Button */}
        <div className="bg-[#faf6f2] border-t border-[#ebe1d5] p-4 px-6 flex items-center justify-between">
          <div className="flex items-center gap-1.5 text-xs text-stone-500">
            <ShieldCheck className="w-4 h-4 text-emerald-600" />
            <span>Facturación Electrónica Segura</span>
          </div>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={onClose}
              disabled={processingState !== 'idle'}
              className="px-4 py-2 rounded-xl text-stone-600 hover:text-stone-900 text-xs font-medium cursor-pointer"
            >
              Cancelar
            </button>

            <button
              type="button"
              onClick={handleProcessPayment}
              disabled={processingState !== 'idle' || (paymentMethod === 'EFECTIVO' && !isCashSufficient)}
              className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-[#c26d60] hover:bg-[#b05c50] text-white font-semibold text-xs transition-all shadow-md shadow-[#c26d60]/25 cursor-pointer disabled:opacity-50"
            >
              <span>{processingState === 'idle' ? 'Confirmar y Emitir a SUNAT' : 'Procesando...'}</span>
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
