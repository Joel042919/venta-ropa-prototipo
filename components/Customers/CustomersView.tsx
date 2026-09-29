'use client';

import React, { useState, useMemo } from 'react';
import { useApp } from '@/context/AppContext';
import { Customer } from '@/mock/mockData';
import {
  Users,
  UserPlus,
  Search,
  Phone,
  Mail,
  MapPin,
  Calendar,
  CreditCard,
  Building,
  CheckCircle2,
  X,
  Sparkles
} from 'lucide-react';

export const CustomersView: React.FC = () => {
  const { customers, addCustomer, notify } = useApp();

  const [searchTerm, setSearchTerm] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);

  // New Customer Form State
  const [docType, setDocType] = useState<'DNI' | 'RUC'>('DNI');
  const [docNumber, setDocNumber] = useState('');
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [address, setAddress] = useState('');
  const [isValidating, setIsValidating] = useState(false);

  const filteredCustomers = useMemo(() => {
    return customers.filter(c => {
      return (
        c.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        c.docNumber.includes(searchTerm) ||
        (c.phone && c.phone.includes(searchTerm))
      );
    });
  }, [customers, searchTerm]);

  // Simulate RENIEC / SUNAT Query
  const handleValidateDoc = () => {
    if (!docNumber || docNumber.length < 8) {
      notify('Documento Inválido', 'Ingresa un DNI de 8 dígitos o RUC de 11 dígitos.', 'warning');
      return;
    }

    setIsValidating(true);
    setTimeout(() => {
      setIsValidating(false);
      if (docType === 'RUC') {
        setName('TEXTILES & BOUTIQUE PERUANA S.A.C.');
        setAddress('Calle Las Begonias 441, San Isidro, Lima');
        setEmail('contacto@textilesperu.com');
        notify('SUNAT en línea ✅', 'RUC encontrado: TEXTILES & BOUTIQUE PERUANA S.A.C.', 'success');
      } else {
        setName('Sofia Elena Castillo Morales');
        setAddress('Av. Pardo 650, Miraflores, Lima');
        setEmail('sofia.castillo@gmail.com');
        notify('RENIEC en línea ✅', 'DNI encontrado: Sofia Elena Castillo Morales', 'success');
      }
    }, 600);
  };

  const handleCreateCustomer = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name || !docNumber) {
      notify('Campos requeridos', 'Por favor ingresa número de documento y nombre.', 'warning');
      return;
    }

    addCustomer({
      docType,
      docNumber,
      name,
      phone: phone || '987 111 222',
      email: email || `${name.toLowerCase().replace(/\s+/g, '.')}@email.com`,
      address: address || 'Lima, Perú',
    });

    setIsModalOpen(false);
    setDocNumber('');
    setName('');
    setPhone('');
    setEmail('');
    setAddress('');
  };

  return (
    <div className="flex-1 overflow-y-auto p-4 md:p-6 lg:p-8 space-y-6 bg-[#faf8f5]">
      {/* Top Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-[#fcedea] text-[#c26d60] text-xs font-semibold mb-1">
            <Users className="w-3.5 h-3.5" />
            <span>Fidelización & Cartera de Clientes</span>
          </div>
          <h1 className="font-serif text-2xl md:text-3xl font-bold text-stone-900">
            Directorio de Clientes
          </h1>
          <p className="text-xs text-stone-500">
            Registro de clientas habituales, historial de compras y datos para emisión electrónica.
          </p>
        </div>

        <button
          onClick={() => setIsModalOpen(true)}
          className="flex items-center gap-2 px-5 py-2.5 rounded-2xl bg-[#c26d60] hover:bg-[#b05c50] text-white font-semibold text-xs transition-all shadow-md shadow-[#c26d60]/25 cursor-pointer"
        >
          <UserPlus className="w-4 h-4" />
          <span>Nuevo Cliente</span>
        </button>
      </div>

      {/* Search Bar */}
      <div className="bg-white p-4 rounded-3xl border border-[#eae3db] shadow-xs flex items-center justify-between">
        <div className="relative w-full sm:w-80">
          <Search className="w-4 h-4 text-stone-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchTerm}
            onChange={e => setSearchTerm(e.target.value)}
            placeholder="Buscar por nombre, DNI o RUC..."
            className="w-full pl-10 pr-4 py-2 rounded-xl border border-stone-200 focus:border-[#c26d60] text-xs bg-stone-50/50 outline-none"
          />
        </div>

        <div className="text-xs text-stone-500 font-medium">
          Total: <span className="font-bold text-stone-900">{customers.length} clientas registradas</span>
        </div>
      </div>

      {/* Customers Table */}
      <div className="bg-white rounded-3xl border border-[#eae3db] shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="bg-[#faf6f2] border-b border-[#eae3db] text-stone-500 font-semibold uppercase text-[10px]">
                <th className="py-3 px-4">Cliente / Razón Social</th>
                <th className="py-3 px-3">Documento</th>
                <th className="py-3 px-3">Contacto</th>
                <th className="py-3 px-3">Dirección</th>
                <th className="py-3 px-3 text-right">Compras Acumuladas</th>
                <th className="py-3 px-4 text-center">Última Visita</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stone-100">
              {filteredCustomers.map(c => (
                <tr key={c.id} className="hover:bg-stone-50/70 transition-colors">
                  <td className="py-3.5 px-4 font-semibold text-stone-900">
                    <div className="flex items-center gap-2.5">
                      <div className="w-8 h-8 rounded-full bg-[#fcedea] text-[#c26d60] flex items-center justify-center font-bold text-xs shrink-0">
                        {c.name.charAt(0)}
                      </div>
                      <div>
                        <div>{c.name}</div>
                        <div className="text-[10px] text-stone-400 font-normal">
                          {c.docType === 'RUC' ? 'Persona Jurídica' : 'Persona Natural'}
                        </div>
                      </div>
                    </div>
                  </td>

                  <td className="py-3.5 px-3 font-mono font-medium text-stone-800">
                    <span
                      className={`px-1.5 py-0.5 rounded text-[10px] mr-1 font-bold ${
                        c.docType === 'RUC' ? 'bg-blue-50 text-blue-700' : 'bg-stone-100 text-stone-700'
                      }`}
                    >
                      {c.docType}
                    </span>
                    {c.docNumber}
                  </td>

                  <td className="py-3.5 px-3 text-stone-600">
                    {c.phone && <div className="text-[11px]">{c.phone}</div>}
                    {c.email && <div className="text-[10px] text-stone-400 truncate max-w-[140px]">{c.email}</div>}
                  </td>

                  <td className="py-3.5 px-3 text-stone-500 max-w-[180px] truncate text-[11px]">
                    {c.address || 'San Isidro, Lima'}
                  </td>

                  <td className="py-3.5 px-3 text-right font-serif font-bold text-stone-900 text-sm">
                    S/ {c.totalPurchases.toFixed(2)}
                  </td>

                  <td className="py-3.5 px-4 text-center text-stone-500 text-[11px]">
                    {c.lastPurchaseDate}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* MODAL: Nuevo Cliente */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-stone-900/60 backdrop-blur-xs">
          <div className="bg-white rounded-3xl shadow-2xl max-w-md w-full border border-stone-200 p-6 space-y-4 animate-in fade-in zoom-in-95">
            <div className="flex items-start justify-between">
              <div>
                <h4 className="font-serif font-bold text-stone-900 text-base">Registrar Nuevo Cliente</h4>
                <p className="text-xs text-stone-500">Valida automáticamente con RENIEC o SUNAT</p>
              </div>
              <button onClick={() => setIsModalOpen(false)} className="text-stone-400 hover:text-stone-700">
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateCustomer} className="space-y-3.5 text-xs">
              <div className="grid grid-cols-3 gap-2">
                <div>
                  <label className="block font-semibold text-stone-700 mb-1">Tipo Doc.</label>
                  <select
                    value={docType}
                    onChange={e => setDocType(e.target.value as any)}
                    className="w-full px-2.5 py-2 rounded-xl border border-stone-300 bg-white"
                  >
                    <option value="DNI">DNI</option>
                    <option value="RUC">RUC</option>
                  </select>
                </div>
                <div className="col-span-2">
                  <label className="block font-semibold text-stone-700 mb-1">
                    Número {docType === 'DNI' ? '(8 dígitos)' : '(11 dígitos)'}
                  </label>
                  <div className="flex gap-1.5">
                    <input
                      type="text"
                      placeholder={docType === 'DNI' ? '72345678' : '20601234567'}
                      value={docNumber}
                      onChange={e => setDocNumber(e.target.value)}
                      className="w-full px-3 py-2 rounded-xl border border-stone-300 font-mono"
                      required
                    />
                    <button
                      type="button"
                      onClick={handleValidateDoc}
                      disabled={isValidating}
                      className="px-2.5 py-2 rounded-xl bg-stone-900 hover:bg-stone-800 text-white font-semibold text-[11px] whitespace-nowrap cursor-pointer"
                    >
                      {isValidating ? '...' : '🔍 Validar'}
                    </button>
                  </div>
                </div>
              </div>

              <div>
                <label className="block font-semibold text-stone-700 mb-1">
                  Nombre Completo / Razón Social
                </label>
                <input
                  type="text"
                  placeholder="ej: Valeria Rossi Morales"
                  value={name}
                  onChange={e => setName(e.target.value)}
                  className="w-full px-3 py-2 rounded-xl border border-stone-300 focus:border-[#c26d60]"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-stone-700 mb-1">Teléfono / WhatsApp</label>
                  <input
                    type="text"
                    placeholder="987 654 321"
                    value={phone}
                    onChange={e => setPhone(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl border border-stone-300"
                  />
                </div>
                <div>
                  <label className="block font-semibold text-stone-700 mb-1">Correo Electrónico</label>
                  <input
                    type="email"
                    placeholder="cliente@email.com"
                    value={email}
                    onChange={e => setEmail(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl border border-stone-300"
                  />
                </div>
              </div>

              <div>
                <label className="block font-semibold text-stone-700 mb-1">Dirección Fiscal / Entrega</label>
                <input
                  type="text"
                  placeholder="Av. Los Conquistadores 450, San Isidro"
                  value={address}
                  onChange={e => setAddress(e.target.value)}
                  className="w-full px-3 py-2 rounded-xl border border-stone-300"
                />
              </div>

              <div className="flex justify-end gap-2 pt-3 border-t border-stone-100">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 rounded-xl text-stone-600 hover:text-stone-900 font-medium cursor-pointer"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 rounded-xl bg-[#c26d60] hover:bg-[#b05c50] text-white font-semibold shadow-xs cursor-pointer"
                >
                  Guardar Cliente
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
