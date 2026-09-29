'use client';

import React, { useState, useMemo } from 'react';
import { useApp } from '@/context/AppContext';
import { Product, ProductVariant } from '@/mock/mockData';
import {
  Package,
  Plus,
  Search,
  Filter,
  ArrowUpDown,
  AlertTriangle,
  CheckCircle2,
  XCircle,
  Edit3,
  RefreshCw,
  X,
  Layers,
  Sparkles,
  TrendingUp,
  Tag
} from 'lucide-react';

export const InventoryView: React.FC = () => {
  const { products, addProduct, updateProductStock, notify } = useApp();

  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('Todos');
  const [selectedStatus, setSelectedStatus] = useState<string>('Todos');

  // Modals
  const [isNewProductModalOpen, setIsNewProductModalOpen] = useState(false);
  const [adjustStockProduct, setAdjustStockProduct] = useState<Product | null>(null);
  const [newStockInput, setNewStockInput] = useState<number>(0);
  const [adjustReason, setAdjustReason] = useState<string>('Ingreso de mercadería nuevo lote');

  // Form state for New Product Modal
  const [newSku, setNewSku] = useState('VES-016');
  const [newName, setNewName] = useState('');
  const [newCategory, setNewCategory] = useState<Product['category']>('Vestidos');
  const [newDescription, setNewDescription] = useState('');
  const [newCostPrice, setNewCostPrice] = useState<number>(45);
  const [newSalePrice, setNewSalePrice] = useState<number>(129);
  const [newStock, setNewStock] = useState<number>(10);
  const [newMinStock, setNewMinStock] = useState<number>(4);
  const [newImage, setNewImage] = useState('https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=600&q=80');

  const categories = ['Todos', 'Vestidos', 'Blusas & Tops', 'Pantalones & Jeans', 'Accesorios', 'Calzado'];

  // Filtered list
  const filteredProducts = useMemo(() => {
    return products.filter(p => {
      const matchesSearch =
        p.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        p.sku.toLowerCase().includes(searchTerm.toLowerCase()) ||
        p.barcode.includes(searchTerm);
      const matchesCategory = selectedCategory === 'Todos' || p.category === selectedCategory;
      const matchesStatus =
        selectedStatus === 'Todos' ||
        (selectedStatus === 'low' && p.stock > 0 && p.stock <= p.minStock) ||
        (selectedStatus === 'out' && p.stock === 0) ||
        (selectedStatus === 'active' && p.stock > p.minStock);

      return matchesSearch && matchesCategory && matchesStatus;
    });
  }, [products, searchTerm, selectedCategory, selectedStatus]);

  // Handle open adjust stock modal
  const handleOpenAdjustStock = (prod: Product) => {
    setAdjustStockProduct(prod);
    setNewStockInput(prod.stock);
    setAdjustReason('Ingreso de mercadería por factura proveedor');
  };

  // Confirm stock adjustment
  const handleConfirmStockAdjust = () => {
    if (adjustStockProduct) {
      updateProductStock(adjustStockProduct.id, Number(newStockInput), adjustReason);
      setAdjustStockProduct(null);
    }
  };

  // Submit New Product
  const handleCreateProduct = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newName) {
      notify('Campo requerido', 'Por favor ingresa el nombre de la prenda.', 'warning');
      return;
    }

    const variants: ProductVariant[] = [
      { size: 'S', color: 'Palo Rosa', colorHex: '#DDA7A5', stock: Math.floor(newStock / 2) },
      { size: 'M', color: 'Terracota', colorHex: '#C26D60', stock: Math.ceil(newStock / 2) },
    ];

    addProduct({
      sku: newSku,
      name: newName,
      category: newCategory,
      description: newDescription || `${newName} de temporada confeccionado con alta calidad.`,
      costPrice: Number(newCostPrice),
      salePrice: Number(newSalePrice),
      stock: Number(newStock),
      minStock: Number(newMinStock),
      image: newImage,
      barcode: `775123400${Math.floor(100 + Math.random() * 900)}`,
      variants,
      status: Number(newStock) <= 0 ? 'out_of_stock' : Number(newStock) <= Number(newMinStock) ? 'low_stock' : 'active',
    });

    setIsNewProductModalOpen(false);
    setNewName('');
    setNewSku(`MOD-${Math.floor(100 + Math.random() * 900)}`);
  };

  return (
    <div className="flex-1 overflow-y-auto p-4 md:p-6 lg:p-8 space-y-6 bg-[#faf8f5]">
      {/* Top Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-[#fcedea] text-[#c26d60] text-xs font-semibold mb-1">
            <Package className="w-3.5 h-3.5" />
            <span>Kardex & Control de Existencias</span>
          </div>
          <h1 className="font-serif text-2xl md:text-3xl font-bold text-stone-900">
            Control de Inventario y Stock
          </h1>
          <p className="text-xs text-stone-500">
            Monitoreo en tiempo real de tallas, colores, precios de compra, margen y rotación.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={() => setIsNewProductModalOpen(true)}
            className="flex items-center gap-2 px-5 py-2.5 rounded-2xl bg-[#c26d60] hover:bg-[#b05c50] text-white font-semibold text-xs transition-all shadow-md shadow-[#c26d60]/25 cursor-pointer"
          >
            <Plus className="w-4 h-4" />
            <span>Nuevo Producto</span>
          </button>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-3xl border border-[#eae3db] shadow-xs space-y-3">
        <div className="flex flex-col sm:flex-row gap-3 items-center justify-between">
          {/* Search bar */}
          <div className="relative w-full sm:w-80">
            <Search className="w-4 h-4 text-stone-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              value={searchTerm}
              onChange={e => setSearchTerm(e.target.value)}
              placeholder="Buscar por nombre o código SKU..."
              className="w-full pl-10 pr-4 py-2 rounded-xl border border-stone-200 focus:border-[#c26d60] text-xs bg-stone-50/50 outline-none"
            />
          </div>

          {/* Status Quick Filter */}
          <div className="flex items-center gap-2 w-full sm:w-auto overflow-x-auto pb-1">
            <span className="text-xs text-stone-400 font-medium">Estado:</span>
            {[
              { id: 'Todos', label: 'Todos' },
              { id: 'active', label: 'Disponible' },
              { id: 'low', label: 'Stock Bajo' },
              { id: 'out', label: 'Agotados' },
            ].map(st => (
              <button
                key={st.id}
                onClick={() => setSelectedStatus(st.id)}
                className={`px-3 py-1 rounded-lg text-xs font-semibold transition-all cursor-pointer ${
                  selectedStatus === st.id
                    ? 'bg-stone-900 text-white'
                    : 'bg-stone-100 hover:bg-stone-200 text-stone-600'
                }`}
              >
                {st.label}
              </button>
            ))}
          </div>
        </div>

        {/* Category Pills */}
        <div className="flex items-center gap-2 overflow-x-auto pt-2 border-t border-stone-100 no-scrollbar">
          {categories.map(cat => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-3.5 py-1 rounded-full text-xs font-medium whitespace-nowrap transition-all cursor-pointer ${
                selectedCategory === cat
                  ? 'bg-[#c26d60] text-white shadow-2xs'
                  : 'bg-stone-100 text-stone-600 hover:bg-stone-200'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* Main Table */}
      <div className="bg-white rounded-3xl border border-[#eae3db] shadow-xs overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead>
              <tr className="bg-[#faf6f2] border-b border-[#eae3db] text-stone-500 font-semibold uppercase text-[10px]">
                <th className="py-3 px-4">Prenda / SKU</th>
                <th className="py-3 px-3">Categoría</th>
                <th className="py-3 px-3">Tallas / Variantes</th>
                <th className="py-3 px-3 text-right">Costo (S/)</th>
                <th className="py-3 px-3 text-right">P. Venta (S/)</th>
                <th className="py-3 px-3 text-right">Margen</th>
                <th className="py-3 px-3 text-center">Stock Actual</th>
                <th className="py-3 px-3 text-center">Estado</th>
                <th className="py-3 px-4 text-right">Acción</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-stone-100">
              {filteredProducts.map(p => {
                const margin = p.salePrice > 0 ? (((p.salePrice - p.costPrice) / p.salePrice) * 100).toFixed(0) : '0';
                const isOutOfStock = p.stock <= 0;
                const isLowStock = p.stock > 0 && p.stock <= p.minStock;

                return (
                  <tr key={p.id} className="hover:bg-stone-50/70 transition-colors">
                    <td className="py-3 px-4">
                      <div className="flex items-center gap-3">
                        <img
                          src={p.image}
                          alt={p.name}
                          className="w-10 h-10 rounded-xl object-cover border border-stone-200 shrink-0"
                        />
                        <div>
                          <div className="font-semibold text-stone-900 leading-tight">{p.name}</div>
                          <div className="text-[10px] text-stone-400 font-mono mt-0.5">
                            SKU: {p.sku} • Barra: {p.barcode}
                          </div>
                        </div>
                      </div>
                    </td>

                    <td className="py-3 px-3 text-stone-600 font-medium">
                      {p.category}
                    </td>

                    <td className="py-3 px-3">
                      <div className="flex flex-wrap gap-1">
                        {p.variants.map((v, i) => (
                          <span
                            key={i}
                            className="px-1.5 py-0.5 rounded bg-stone-100 text-stone-700 text-[10px] font-semibold"
                            title={`Color: ${v.color} - Stock: ${v.stock}`}
                          >
                            {v.size}
                          </span>
                        ))}
                      </div>
                    </td>

                    <td className="py-3 px-3 text-right font-mono text-stone-500">
                      S/ {p.costPrice.toFixed(2)}
                    </td>

                    <td className="py-3 px-3 text-right font-serif font-bold text-stone-900">
                      S/ {p.salePrice.toFixed(2)}
                    </td>

                    <td className="py-3 px-3 text-right font-medium text-emerald-600">
                      +{margin}%
                    </td>

                    <td className="py-3 px-3 text-center">
                      <span className="font-bold font-mono text-sm text-stone-900">{p.stock}</span>
                      <span className="text-[10px] text-stone-400 block">Mín: {p.minStock}</span>
                    </td>

                    <td className="py-3 px-3 text-center">
                      {isOutOfStock ? (
                        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-rose-50 text-rose-700 border border-rose-200">
                          <XCircle className="w-3 h-3 text-rose-500" />
                          Agotado
                        </span>
                      ) : isLowStock ? (
                        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-amber-50 text-amber-800 border border-amber-200">
                          <AlertTriangle className="w-3 h-3 text-amber-500" />
                          Bajo Stock
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                          <CheckCircle2 className="w-3 h-3 text-emerald-500" />
                          Disponible
                        </span>
                      )}
                    </td>

                    <td className="py-3 px-4 text-right">
                      <button
                        onClick={() => handleOpenAdjustStock(p)}
                        className="px-2.5 py-1.5 rounded-xl bg-stone-100 hover:bg-[#c26d60] hover:text-white text-stone-700 font-semibold text-[11px] transition-colors flex items-center gap-1 ml-auto cursor-pointer"
                      >
                        <RefreshCw className="w-3 h-3" />
                        <span>Ajustar</span>
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* MODAL: Ajustar Stock */}
      {adjustStockProduct && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-stone-900/60 backdrop-blur-xs">
          <div className="bg-white rounded-3xl shadow-2xl max-w-md w-full border border-stone-200 p-6 space-y-4 animate-in fade-in zoom-in-95">
            <div className="flex items-start justify-between">
              <div>
                <h4 className="font-serif font-bold text-stone-900 text-base">Ajuste de Stock en Kardex</h4>
                <p className="text-xs text-stone-500">{adjustStockProduct.name}</p>
              </div>
              <button onClick={() => setAdjustStockProduct(null)} className="text-stone-400 hover:text-stone-700">
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-3 bg-stone-50 rounded-xl border border-stone-200 text-xs flex justify-between">
              <span>Stock actual en sistema:</span>
              <span className="font-bold text-stone-900">{adjustStockProduct.stock} unidades</span>
            </div>

            <div>
              <label className="block text-xs font-semibold text-stone-700 mb-1">Nuevo Stock Físico:</label>
              <input
                type="number"
                min="0"
                value={newStockInput}
                onChange={e => setNewStockInput(parseInt(e.target.value) || 0)}
                className="w-full px-3 py-2 rounded-xl border border-stone-300 font-bold text-base focus:border-[#c26d60] outline-none"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-stone-700 mb-1">Motivo del Ajuste:</label>
              <select
                value={adjustReason}
                onChange={e => setAdjustReason(e.target.value)}
                className="w-full px-3 py-2 rounded-xl border border-stone-300 text-xs bg-white focus:border-[#c26d60] outline-none"
              >
                <option value="Ingreso de mercadería por proveedor">Ingreso de mercadería por proveedor</option>
                <option value="Conteo físico / Auditoría de inventario">Conteo físico / Auditoría de inventario</option>
                <option value="Devolución de clienta">Devolución de clienta</option>
                <option value="Merma o prenda dañada">Merma o prenda dañada</option>
              </select>
            </div>

            <div className="flex justify-end gap-2 pt-2">
              <button
                type="button"
                onClick={() => setAdjustStockProduct(null)}
                className="px-4 py-2 rounded-xl text-stone-600 hover:text-stone-900 text-xs font-medium cursor-pointer"
              >
                Cancelar
              </button>
              <button
                type="button"
                onClick={handleConfirmStockAdjust}
                className="px-5 py-2 rounded-xl bg-[#c26d60] hover:bg-[#b05c50] text-white text-xs font-semibold transition-all cursor-pointer shadow-xs"
              >
                Guardar Ajuste
              </button>
            </div>
          </div>
        </div>
      )}

      {/* MODAL: Nuevo Producto */}
      {isNewProductModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-stone-900/60 backdrop-blur-xs">
          <div className="bg-white rounded-3xl shadow-2xl max-w-lg w-full border border-stone-200 p-6 space-y-4 animate-in fade-in zoom-in-95">
            <div className="flex items-start justify-between">
              <div>
                <h4 className="font-serif font-bold text-stone-900 text-base">Registrar Nueva Prenda</h4>
                <p className="text-xs text-stone-500">Agrega un nuevo producto al catálogo de la boutique</p>
              </div>
              <button onClick={() => setIsNewProductModalOpen(false)} className="text-stone-400 hover:text-stone-700">
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateProduct} className="space-y-3.5 text-xs">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-stone-700 mb-1">Código SKU</label>
                  <input
                    type="text"
                    value={newSku}
                    onChange={e => setNewSku(e.target.value)}
                    className="w-full px-3 py-2 rounded-xl border border-stone-300 font-mono uppercase bg-stone-50"
                    required
                  />
                </div>
                <div>
                  <label className="block font-semibold text-stone-700 mb-1">Categoría</label>
                  <select
                    value={newCategory}
                    onChange={e => setNewCategory(e.target.value as any)}
                    className="w-full px-3 py-2 rounded-xl border border-stone-300 bg-white"
                  >
                    <option value="Vestidos">Vestidos</option>
                    <option value="Blusas & Tops">Blusas & Tops</option>
                    <option value="Pantalones & Jeans">Pantalones & Jeans</option>
                    <option value="Accesorios">Accesorios</option>
                    <option value="Calzado">Calzado</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block font-semibold text-stone-700 mb-1">Nombre de la Prenda</label>
                <input
                  type="text"
                  placeholder="ej: Vestido Boho Escote Cuadrado"
                  value={newName}
                  onChange={e => setNewName(e.target.value)}
                  className="w-full px-3 py-2 rounded-xl border border-stone-300 focus:border-[#c26d60]"
                  required
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-stone-700 mb-1">Precio Compra Costo (S/)</label>
                  <input
                    type="number"
                    step="0.1"
                    value={newCostPrice}
                    onChange={e => setNewCostPrice(parseFloat(e.target.value) || 0)}
                    className="w-full px-3 py-2 rounded-xl border border-stone-300"
                    required
                  />
                </div>
                <div>
                  <label className="block font-semibold text-stone-700 mb-1">Precio Venta Público (S/)</label>
                  <input
                    type="number"
                    step="0.1"
                    value={newSalePrice}
                    onChange={e => setNewSalePrice(parseFloat(e.target.value) || 0)}
                    className="w-full px-3 py-2 rounded-xl border border-stone-300 font-bold"
                    required
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block font-semibold text-stone-700 mb-1">Stock Inicial</label>
                  <input
                    type="number"
                    value={newStock}
                    onChange={e => setNewStock(parseInt(e.target.value) || 0)}
                    className="w-full px-3 py-2 rounded-xl border border-stone-300 font-bold"
                    required
                  />
                </div>
                <div>
                  <label className="block font-semibold text-stone-700 mb-1">Stock Mínimo (Alerta)</label>
                  <input
                    type="number"
                    value={newMinStock}
                    onChange={e => setNewMinStock(parseInt(e.target.value) || 0)}
                    className="w-full px-3 py-2 rounded-xl border border-stone-300"
                    required
                  />
                </div>
              </div>

              <div className="flex justify-end gap-2 pt-3 border-t border-stone-100">
                <button
                  type="button"
                  onClick={() => setIsNewProductModalOpen(false)}
                  className="px-4 py-2 rounded-xl text-stone-600 hover:text-stone-900 font-medium cursor-pointer"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 rounded-xl bg-[#c26d60] hover:bg-[#b05c50] text-white font-semibold shadow-xs cursor-pointer"
                >
                  Guardar Prenda
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
