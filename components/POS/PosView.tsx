'use client';

import React, { useState, useMemo } from 'react';
import { useApp } from '@/context/AppContext';
import { Product, ProductVariant, Voucher } from '@/mock/mockData';
import { PaymentModal } from './PaymentModal';
import { VoucherModal } from '../Vouchers/VoucherModal';
import {
  Search,
  Barcode,
  ShoppingBag,
  Trash2,
  Plus,
  Minus,
  Check,
  Building,
  User,
  Percent,
  Sparkles,
  ArrowRight,
  Filter,
  CheckCircle2,
  X,
  CreditCard,
  Layers,
  AlertCircle
} from 'lucide-react';

export const PosView: React.FC = () => {
  const {
    products,
    cart,
    addToCart,
    removeFromCart,
    updateCartQuantity,
    clearCart,
    cartTotals,
    discountPercentage,
    setDiscountPercentage,
    customers,
    notify,
  } = useApp();

  // Search & Filters
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('Todos');

  // Variant selector modal state
  const [variantModalProduct, setVariantModalProduct] = useState<Product | null>(null);
  const [selectedSize, setSelectedSize] = useState<string>('');
  const [selectedColor, setSelectedColor] = useState<string>('');

  // Voucher configuration for checkout
  const [voucherType, setVoucherType] = useState<'BOLETA' | 'FACTURA'>('BOLETA');
  const [customerDocType, setCustomerDocType] = useState<'DNI' | 'RUC'>('DNI');
  const [customerDocNumber, setCustomerDocNumber] = useState('');
  const [customerName, setCustomerName] = useState('Clientes Varios');
  const [customerAddress, setCustomerAddress] = useState('');
  const [isConsultingSunat, setIsConsultingSunat] = useState(false);

  // Payment & Finished Voucher modals
  const [isPaymentModalOpen, setIsPaymentModalOpen] = useState(false);
  const [issuedVoucher, setIssuedVoucher] = useState<Voucher | null>(null);

  // Barcode scanner simulation feedback
  const [scanBeepActive, setScanBeepActive] = useState(false);

  // Categories list
  const categories = ['Todos', 'Vestidos', 'Blusas & Tops', 'Pantalones & Jeans', 'Accesorios', 'Calzado'];

  // Filtered products
  const filteredProducts = useMemo(() => {
    return products.filter(p => {
      const matchesSearch =
        p.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        p.sku.toLowerCase().includes(searchTerm.toLowerCase()) ||
        p.barcode.includes(searchTerm);
      const matchesCat = selectedCategory === 'Todos' || p.category === selectedCategory;
      return matchesSearch && matchesCat;
    });
  }, [products, searchTerm, selectedCategory]);

  // Click on product card
  const handleProductClick = (product: Product) => {
    if (product.stock <= 0) {
      notify('Stock Agotado', `El producto ${product.name} no tiene stock.`, 'warning');
      return;
    }

    if (product.variants.length > 1) {
      setVariantModalProduct(product);
      setSelectedSize(product.variants[0].size);
      setSelectedColor(product.variants[0].color);
    } else {
      addToCart(product);
    }
  };

  const handleConfirmVariantAdd = () => {
    if (variantModalProduct) {
      addToCart(variantModalProduct, selectedSize, selectedColor);
      setVariantModalProduct(null);
    }
  };

  // Barcode scanner simulation
  const handleSimulateScan = () => {
    setScanBeepActive(true);
    setTimeout(() => setScanBeepActive(false), 400);

    // Pick a random in-stock product
    const available = products.filter(p => p.stock > 0);
    if (available.length > 0) {
      const randomProd = available[Math.floor(Math.random() * available.length)];
      addToCart(randomProd);
      notify('Código Escaneado ⚡', `Beep! Código ${randomProd.barcode} detectado: ${randomProd.name}`, 'success');
    }
  };

  // Switch voucher type between Boleta and Factura
  const handleSwitchVoucherType = (type: 'BOLETA' | 'FACTURA') => {
    setVoucherType(type);
    if (type === 'FACTURA') {
      setCustomerDocType('RUC');
      setCustomerDocNumber('20554433221');
      setCustomerName('AGENCIA DE TALENTOS & MODELAJE GLAM S.A.C.');
      setCustomerAddress('Av. Javier Prado Este 3200, San Borja, Lima');
    } else {
      setCustomerDocType('DNI');
      setCustomerDocNumber('00000000');
      setCustomerName('Clientes Varios');
      setCustomerAddress('');
    }
  };

  // Simulate SUNAT / RENIEC online query
  const handleConsultSunatReniec = () => {
    if (!customerDocNumber || customerDocNumber.length < 8) {
      notify('Documento Inválido', 'Ingresa un DNI de 8 dígitos o RUC de 11 dígitos.', 'warning');
      return;
    }

    setIsConsultingSunat(true);
    setTimeout(() => {
      setIsConsultingSunat(false);

      // Check if matches existing customer
      const existing = customers.find(c => c.docNumber === customerDocNumber);
      if (existing) {
        setCustomerName(existing.name);
        setCustomerAddress(existing.address || 'Lima, Perú');
        notify('Consulta Exitosa', `Datos obtenidos desde la base de datos de SUNAT / RENIEC.`, 'success');
        return;
      }

      if (customerDocType === 'RUC') {
        if (customerDocNumber.length === 11) {
          const mockName = 'CORPORACIÓN DE MODA & RETAIL LIMA S.A.C.';
          const mockAddress = 'Av. República de Panamá 3500, San Isidro';
          setCustomerName(mockName);
          setCustomerAddress(mockAddress);
          notify('SUNAT en línea ✅', `RUC Activo y Habido: ${mockName}`, 'success');
        } else {
          notify('RUC Inválido', 'El RUC debe tener 11 dígitos.', 'warning');
        }
      } else {
        if (customerDocNumber.length === 8) {
          const mockName = 'Mariana Silva Delgado';
          setCustomerName(mockName);
          notify('RENIEC en línea ✅', `DNI validado: ${mockName}`, 'success');
        } else {
          notify('DNI Inválido', 'El DNI debe tener 8 dígitos.', 'warning');
        }
      }
    }, 700);
  };

  return (
    <div className="flex-1 flex flex-col lg:flex-row h-[calc(100vh-4rem)] overflow-hidden bg-[#faf8f5]">
      {/* LEFT: Catalog & Products grid */}
      <div className="flex-1 flex flex-col h-full overflow-hidden p-4 md:p-6 border-r border-[#eae3db]">
        {/* Top Bar: Search, Scanner Button, Category Pills */}
        <div className="space-y-3.5 mb-4 shrink-0">
          <div className="flex items-center gap-3">
            {/* Search Input */}
            <div className="relative flex-1">
              <Search className="w-4 h-4 text-stone-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                value={searchTerm}
                onChange={e => setSearchTerm(e.target.value)}
                placeholder="Buscar prenda por nombre, código SKU o escanear..."
                className="w-full pl-10 pr-4 py-2.5 rounded-2xl border border-stone-200 focus:border-[#c26d60] focus:ring-2 focus:ring-[#c26d60]/20 text-sm bg-white shadow-2xs outline-none"
              />
              {searchTerm && (
                <button
                  onClick={() => setSearchTerm('')}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-stone-400 hover:text-stone-600"
                >
                  <X className="w-4 h-4" />
                </button>
              )}
            </div>

            {/* Simular Lector de Código de Barras (High visual impact for client!) */}
            <button
              onClick={handleSimulateScan}
              title="Simular escaneo de lector físico con código de barras"
              className={`flex items-center gap-2 px-4 py-2.5 rounded-2xl text-xs font-semibold shadow-xs transition-all cursor-pointer ${
                scanBeepActive
                  ? 'bg-emerald-600 text-white scale-105 ring-4 ring-emerald-300'
                  : 'bg-stone-900 hover:bg-stone-800 text-white'
              }`}
            >
              <Barcode className="w-4 h-4" />
              <span>{scanBeepActive ? '¡BEEP! Escaneado' : 'Simular Escáner'}</span>
            </button>
          </div>

          {/* Category Chips */}
          <div className="flex items-center gap-2 overflow-x-auto pb-1 no-scrollbar">
            {categories.map(cat => (
              <button
                key={cat}
                onClick={() => setSelectedCategory(cat)}
                className={`px-3.5 py-1.5 rounded-full text-xs font-medium whitespace-nowrap transition-all cursor-pointer ${
                  selectedCategory === cat
                    ? 'bg-[#c26d60] text-white shadow-xs'
                    : 'bg-white border border-stone-200 text-stone-600 hover:border-stone-300 hover:bg-stone-50'
                }`}
              >
                {cat}
              </button>
            ))}
          </div>
        </div>

        {/* Products Grid */}
        <div className="flex-1 overflow-y-auto pr-1">
          <div className="grid grid-cols-2 sm:grid-cols-3 xl:grid-cols-4 gap-3.5">
            {filteredProducts.map(product => {
              const isOutOfStock = product.stock <= 0;
              const isLowStock = product.stock > 0 && product.stock <= product.minStock;

              return (
                <div
                  key={product.id}
                  onClick={() => handleProductClick(product)}
                  className={`group bg-white rounded-2xl border transition-all overflow-hidden flex flex-col justify-between cursor-pointer ${
                    isOutOfStock
                      ? 'opacity-60 border-stone-200 cursor-not-allowed'
                      : 'border-[#eae3db] hover:border-[#c26d60]/50 hover:shadow-md'
                  }`}
                >
                  <div className="relative aspect-4/3 w-full bg-stone-100 overflow-hidden">
                    <img
                      src={product.image}
                      alt={product.name}
                      className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
                      loading="lazy"
                    />

                    {/* Stock status badge */}
                    <div className="absolute top-2 left-2 flex gap-1">
                      {isOutOfStock ? (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-rose-500 text-white shadow-xs">
                          Agotado
                        </span>
                      ) : isLowStock ? (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-amber-500 text-white shadow-xs">
                          Quedan {product.stock}
                        </span>
                      ) : (
                        <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-600/90 text-white backdrop-blur-xs">
                          Stock: {product.stock}
                        </span>
                      )}
                    </div>

                    <div className="absolute top-2 right-2">
                      <span className="font-mono text-[9px] bg-black/60 text-white px-1.5 py-0.5 rounded backdrop-blur-xs">
                        {product.sku}
                      </span>
                    </div>
                  </div>

                  <div className="p-3 flex-1 flex flex-col justify-between">
                    <div>
                      <span className="text-[10px] font-medium text-stone-400 uppercase tracking-wide">
                        {product.category}
                      </span>
                      <h4 className="text-xs font-semibold text-stone-800 line-clamp-1 group-hover:text-[#c26d60] transition-colors">
                        {product.name}
                      </h4>

                      {/* Sizes indicator */}
                      <div className="flex items-center gap-1 mt-1 text-[10px] text-stone-500">
                        <span>Tallas:</span>
                        <div className="flex gap-1">
                          {product.variants.map((v, i) => (
                            <span key={i} className="font-semibold text-stone-700">
                              {v.size}
                            </span>
                          ))}
                        </div>
                      </div>
                    </div>

                    <div className="pt-2 mt-2 border-t border-stone-100 flex items-center justify-between">
                      <div className="font-serif font-bold text-sm text-stone-900">
                        S/ {product.salePrice.toFixed(2)}
                      </div>
                      <div className="w-7 h-7 rounded-xl bg-[#fcedea] text-[#c26d60] flex items-center justify-center group-hover:bg-[#c26d60] group-hover:text-white transition-all shadow-2xs">
                        <Plus className="w-4 h-4" />
                      </div>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>

          {filteredProducts.length === 0 && (
            <div className="h-64 flex flex-col items-center justify-center text-center p-6 text-stone-400">
              <ShoppingBag className="w-12 h-12 stroke-1 mb-2 text-stone-300" />
              <p className="text-sm font-medium text-stone-600">No encontramos prendas con esa búsqueda</p>
              <p className="text-xs text-stone-400 mt-0.5">Prueba con otra categoría o limpia el buscador</p>
            </div>
          )}
        </div>
      </div>

      {/* RIGHT: Modern Checkout Cart Panel */}
      <div className="w-full lg:w-[420px] bg-white flex flex-col h-full shadow-lg shrink-0">
        {/* Cart Header */}
        <div className="p-4 border-b border-[#eae3db] bg-[#faf6f2] flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-xl bg-[#c26d60] text-white flex items-center justify-center">
              <ShoppingBag className="w-4 h-4" />
            </div>
            <div>
              <h3 className="font-serif font-bold text-sm text-stone-900">Comanda / Venta Actual</h3>
              <p className="text-[11px] text-stone-500">
                {cartTotals.itemsCount} {cartTotals.itemsCount === 1 ? 'prenda' : 'prendas'} seleccionadas
              </p>
            </div>
          </div>

          {cart.length > 0 && (
            <button
              onClick={clearCart}
              title="Vaciar carrito"
              className="text-stone-400 hover:text-rose-600 p-1.5 rounded-lg hover:bg-rose-50 transition-colors text-xs flex items-center gap-1 cursor-pointer"
            >
              <Trash2 className="w-3.5 h-3.5" />
              <span>Vaciar</span>
            </button>
          )}
        </div>

        {/* Voucher Selector (Boleta vs Factura) */}
        <div className="p-3 border-b border-[#eae3db] bg-white space-y-2.5">
          <div className="flex items-center justify-between text-xs">
            <span className="font-semibold text-stone-700">Tipo de Comprobante:</span>
            <div className="flex rounded-xl bg-stone-100 p-0.5 font-medium text-xs">
              <button
                type="button"
                onClick={() => handleSwitchVoucherType('BOLETA')}
                className={`px-3 py-1 rounded-lg transition-all cursor-pointer ${
                  voucherType === 'BOLETA'
                    ? 'bg-[#c26d60] text-white font-semibold shadow-2xs'
                    : 'text-stone-600 hover:text-stone-900'
                }`}
              >
                Boleta (B001)
              </button>
              <button
                type="button"
                onClick={() => handleSwitchVoucherType('FACTURA')}
                className={`px-3 py-1 rounded-lg transition-all cursor-pointer ${
                  voucherType === 'FACTURA'
                    ? 'bg-[#c26d60] text-white font-semibold shadow-2xs'
                    : 'text-stone-600 hover:text-stone-900'
                }`}
              >
                Factura (F001)
              </button>
            </div>
          </div>

          {/* Customer input fields */}
          <div className="p-2.5 rounded-xl bg-stone-50 border border-stone-200 space-y-2 text-xs">
            <div className="flex items-center gap-2">
              <div className="w-16 shrink-0">
                <span className="text-[10px] uppercase font-bold text-stone-500">
                  {customerDocType}
                </span>
              </div>
              <div className="relative flex-1 flex gap-1.5">
                <input
                  type="text"
                  value={customerDocNumber}
                  onChange={e => setCustomerDocNumber(e.target.value)}
                  placeholder={customerDocType === 'RUC' ? '2060...' : '7234...'}
                  className="w-full px-2.5 py-1.5 rounded-lg border border-stone-300 font-mono text-xs bg-white outline-none focus:border-[#c26d60]"
                />
                <button
                  type="button"
                  onClick={handleConsultSunatReniec}
                  disabled={isConsultingSunat}
                  title="Consultar padrón en tiempo real"
                  className="px-2.5 py-1.5 rounded-lg bg-stone-800 hover:bg-stone-700 text-white font-semibold text-[11px] whitespace-nowrap cursor-pointer transition-colors"
                >
                  {isConsultingSunat ? 'Buscando...' : '🔍 Validar'}
                </button>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <div className="w-16 shrink-0">
                <span className="text-[10px] text-stone-500">Nombre / Razón:</span>
              </div>
              <input
                type="text"
                value={customerName}
                onChange={e => setCustomerName(e.target.value)}
                className="w-full px-2.5 py-1.5 rounded-lg border border-stone-300 text-xs bg-white outline-none focus:border-[#c26d60]"
              />
            </div>
          </div>
        </div>

        {/* Cart Items List */}
        <div className="flex-1 overflow-y-auto p-3 space-y-2">
          {cart.map((item, index) => (
            <div
              key={`${item.product.id}-${item.selectedSize}-${item.selectedColor}`}
              className="p-2.5 rounded-xl border border-stone-200 bg-stone-50/50 hover:bg-stone-50 flex items-center justify-between gap-2 transition-colors"
            >
              <img
                src={item.product.image}
                alt={item.product.name}
                className="w-11 h-11 rounded-lg object-cover border border-stone-200 shrink-0"
              />

              <div className="flex-1 min-w-0">
                <h5 className="text-xs font-semibold text-stone-800 truncate">{item.product.name}</h5>
                <div className="flex items-center gap-1.5 text-[10px] text-stone-500">
                  <span className="px-1.5 py-0.2 rounded bg-stone-200 text-stone-700 font-medium">
                    Talla {item.selectedSize}
                  </span>
                  <span>•</span>
                  <span>{item.selectedColor}</span>
                </div>
                <div className="text-[11px] font-medium text-stone-600 mt-0.5">
                  S/ {item.unitPrice.toFixed(2)} c/u
                </div>
              </div>

              {/* Quantity Controls */}
              <div className="flex flex-col items-end gap-1">
                <div className="flex items-center border border-stone-300 rounded-lg bg-white overflow-hidden shadow-2xs">
                  <button
                    onClick={() => updateCartQuantity(index, item.quantity - 1)}
                    className="p-1 text-stone-500 hover:text-stone-800 hover:bg-stone-100 transition-colors cursor-pointer"
                  >
                    <Minus className="w-3 h-3" />
                  </button>
                  <span className="w-7 text-center text-xs font-bold text-stone-800 font-mono">
                    {item.quantity}
                  </span>
                  <button
                    onClick={() => updateCartQuantity(index, item.quantity + 1)}
                    className="p-1 text-stone-500 hover:text-stone-800 hover:bg-stone-100 transition-colors cursor-pointer"
                  >
                    <Plus className="w-3 h-3" />
                  </button>
                </div>

                <div className="font-serif font-bold text-xs text-stone-900">
                  S/ {(item.unitPrice * item.quantity).toFixed(2)}
                </div>
              </div>

              <button
                onClick={() => removeFromCart(index)}
                className="text-stone-300 hover:text-rose-600 p-1 transition-colors cursor-pointer"
              >
                <Trash2 className="w-3.5 h-3.5" />
              </button>
            </div>
          ))}

          {cart.length === 0 && (
            <div className="h-44 flex flex-col items-center justify-center text-center p-6 text-stone-400">
              <ShoppingBag className="w-10 h-10 text-stone-300 mb-2 stroke-1" />
              <p className="text-xs font-medium text-stone-600">El carrito de venta está vacío</p>
              <p className="text-[11px] text-stone-400">Selecciona prendas de la lista para iniciar el cobro</p>
            </div>
          )}
        </div>

        {/* Cart Totals & Checkout Button */}
        <div className="p-4 border-t border-[#eae3db] bg-[#faf6f2] space-y-3">
          {/* Quick discount picker */}
          <div className="flex items-center justify-between text-xs">
            <span className="text-stone-500 flex items-center gap-1">
              <Percent className="w-3.5 h-3.5 text-[#c26d60]" />
              <span>Descuento Promocional:</span>
            </span>
            <div className="flex gap-1">
              {[0, 5, 10, 15].map(pct => (
                <button
                  key={pct}
                  type="button"
                  onClick={() => setDiscountPercentage(pct)}
                  className={`px-2 py-0.5 rounded-md text-[10px] font-semibold transition-all cursor-pointer ${
                    discountPercentage === pct
                      ? 'bg-[#c26d60] text-white'
                      : 'bg-white border border-stone-200 text-stone-600 hover:bg-stone-100'
                  }`}
                >
                  {pct === 0 ? 'Sin desc.' : `${pct}%`}
                </button>
              ))}
            </div>
          </div>

          {/* Breakdown summary */}
          <div className="space-y-1 text-xs text-stone-600 pt-1 border-t border-stone-200/80">
            <div className="flex justify-between">
              <span className="text-stone-500">Op. Gravada:</span>
              <span className="font-mono">S/ {cartTotals.subtotal.toFixed(2)}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-stone-500">I.G.V. (18%):</span>
              <span className="font-mono">S/ {cartTotals.igv.toFixed(2)}</span>
            </div>
            {cartTotals.discount > 0 && (
              <div className="flex justify-between text-emerald-700 font-medium">
                <span>Descuento ({discountPercentage}%):</span>
                <span className="font-mono">- S/ {cartTotals.discount.toFixed(2)}</span>
              </div>
            )}
            <div className="flex justify-between items-baseline pt-2 border-t border-stone-300 font-bold text-stone-900">
              <span className="text-sm">TOTAL A COBRAR:</span>
              <span className="text-2xl font-serif text-[#c26d60] font-bold">
                S/ {cartTotals.total.toFixed(2)}
              </span>
            </div>
          </div>

          {/* Checkout CTA */}
          <button
            type="button"
            disabled={cart.length === 0}
            onClick={() => setIsPaymentModalOpen(true)}
            className="w-full py-3.5 px-4 rounded-2xl bg-[#c26d60] hover:bg-[#b05c50] text-white font-semibold text-sm transition-all shadow-md shadow-[#c26d60]/25 flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed group"
          >
            <span>Cobrar y Emitir Comprobante</span>
            <ArrowRight className="w-4 h-4 transition-transform group-hover:translate-x-1" />
          </button>
        </div>
      </div>

      {/* MODAL: Variant Selector when clicking product with multiple sizes/colors */}
      {variantModalProduct && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-stone-900/60 backdrop-blur-xs">
          <div className="bg-white rounded-3xl shadow-2xl max-w-md w-full border border-stone-200 overflow-hidden p-6 space-y-5 animate-in fade-in zoom-in-95">
            <div className="flex items-start justify-between">
              <div className="flex gap-3">
                <img
                  src={variantModalProduct.image}
                  alt={variantModalProduct.name}
                  className="w-16 h-16 rounded-xl object-cover border border-stone-200"
                />
                <div>
                  <h4 className="font-serif font-bold text-stone-900 text-sm">{variantModalProduct.name}</h4>
                  <p className="text-xs text-stone-400 font-mono">{variantModalProduct.sku}</p>
                  <p className="font-serif font-bold text-[#c26d60] text-base mt-0.5">
                    S/ {variantModalProduct.salePrice.toFixed(2)}
                  </p>
                </div>
              </div>
              <button
                onClick={() => setVariantModalProduct(null)}
                className="text-stone-400 hover:text-stone-700 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Select Size */}
            <div>
              <label className="block text-xs font-semibold text-stone-700 mb-2">Selecciona Talla</label>
              <div className="flex flex-wrap gap-2">
                {Array.from(new Set(variantModalProduct.variants.map(v => v.size))).map(size => (
                  <button
                    key={size}
                    onClick={() => setSelectedSize(size)}
                    className={`w-11 h-10 rounded-xl border text-xs font-bold transition-all cursor-pointer ${
                      selectedSize === size
                        ? 'border-[#c26d60] bg-[#c26d60] text-white shadow-xs'
                        : 'border-stone-200 hover:border-stone-400 text-stone-800'
                    }`}
                  >
                    {size}
                  </button>
                ))}
              </div>
            </div>

            {/* Select Color */}
            <div>
              <label className="block text-xs font-semibold text-stone-700 mb-2">Selecciona Color</label>
              <div className="flex flex-wrap gap-2">
                {Array.from(new Set(variantModalProduct.variants.map(v => v.color))).map(color => {
                  const variant = variantModalProduct.variants.find(v => v.color === color);
                  return (
                    <button
                      key={color}
                      onClick={() => setSelectedColor(color)}
                      className={`flex items-center gap-2 px-3 py-1.5 rounded-xl border text-xs font-medium transition-all cursor-pointer ${
                        selectedColor === color
                          ? 'border-[#c26d60] bg-[#fcedea] text-[#c26d60]'
                          : 'border-stone-200 hover:border-stone-400 text-stone-700'
                      }`}
                    >
                      <span
                        className="w-3.5 h-3.5 rounded-full border border-stone-300"
                        style={{ backgroundColor: variant?.colorHex || '#ccc' }}
                      />
                      <span>{color}</span>
                    </button>
                  );
                })}
              </div>
            </div>

            <button
              onClick={handleConfirmVariantAdd}
              className="w-full py-3 px-4 rounded-xl bg-[#c26d60] hover:bg-[#b05c50] text-white font-semibold text-xs shadow-md transition-all cursor-pointer"
            >
              Agregar al Carrito (Talla {selectedSize} / {selectedColor})
            </button>
          </div>
        </div>
      )}

      {/* Payment Processing Modal */}
      <PaymentModal
        isOpen={isPaymentModalOpen}
        onClose={() => setIsPaymentModalOpen(false)}
        voucherType={voucherType}
        customerName={customerName}
        customerDocType={customerDocType}
        customerDocNumber={customerDocNumber}
        customerAddress={customerAddress}
        onSuccess={newVoucher => {
          setIsPaymentModalOpen(false);
          setIssuedVoucher(newVoucher);
        }}
      />

      {/* Post-sale Voucher Preview Modal (with print, PDF, WhatsApp) */}
      <VoucherModal
        voucher={issuedVoucher}
        onClose={() => setIssuedVoucher(null)}
        justEmitted={true}
      />
    </div>
  );
};
