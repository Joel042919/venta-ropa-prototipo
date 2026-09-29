'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import {
  Product,
  CartItem,
  Customer,
  Voucher,
  StoreInfo,
  INITIAL_STORE_INFO,
  INITIAL_PRODUCTS,
  INITIAL_CUSTOMERS,
  INITIAL_VOUCHERS,
} from '@/mock/mockData';

export type NavTab = 'dashboard' | 'pos' | 'inventory' | 'vouchers' | 'customers' | 'reports';

export interface UserSession {
  name: string;
  role: string;
  avatar: string;
  storeBranch: string;
  registerNumber: string;
}

interface NotificationToast {
  id: string;
  title: string;
  message: string;
  type: 'success' | 'warning' | 'info' | 'error';
}

interface AppContextType {
  // Auth
  isLoggedIn: boolean;
  user: UserSession;
  login: () => void;
  logout: () => void;

  // Navigation
  activeTab: NavTab;
  setActiveTab: (tab: NavTab) => void;

  // Store
  storeInfo: StoreInfo;
  sunatConnected: boolean;
  toggleSunatConnection: () => void;

  // Products & Inventory
  products: Product[];
  addProduct: (product: Omit<Product, 'id'>) => void;
  updateProductStock: (productId: string, newStock: number, reason: string) => void;

  // Cart & POS
  cart: CartItem[];
  addToCart: (product: Product, size?: string, color?: string, quantity?: number) => void;
  removeFromCart: (index: number) => void;
  updateCartQuantity: (index: number, quantity: number) => void;
  clearCart: () => void;
  cartTotals: {
    subtotal: number;
    igv: number;
    discount: number;
    total: number;
    itemsCount: number;
  };
  discountPercentage: number;
  setDiscountPercentage: (pct: number) => void;

  // Checkout / Vouchers
  vouchers: Voucher[];
  createVoucher: (params: {
    type: 'BOLETA' | 'FACTURA';
    customerName: string;
    customerDocType: 'DNI' | 'RUC';
    customerDocNumber: string;
    customerAddress?: string;
    paymentMethod: 'EFECTIVO' | 'TARJETA' | 'YAPE' | 'PLIN';
  }) => Promise<Voucher>;
  selectedVoucher: Voucher | null;
  setSelectedVoucher: (v: Voucher | null) => void;

  // Customers
  customers: Customer[];
  addCustomer: (customer: Omit<Customer, 'id' | 'totalPurchases' | 'lastPurchaseDate'>) => Customer;

  // Notifications
  notifications: NotificationToast[];
  removeNotification: (id: string) => void;
  notify: (title: string, message: string, type?: 'success' | 'warning' | 'info' | 'error') => void;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isLoggedIn, setIsLoggedIn] = useState(true);
  const [user, setUser] = useState<UserSession>({
    name: 'Valeria Mendoza',
    role: 'Jefa de Tienda / Cajera',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    storeBranch: 'Boutique San Isidro',
    registerNumber: 'Caja 01 - Principal',
  });

  const [activeTab, setActiveTab] = useState<NavTab>('dashboard');
  const [storeInfo] = useState<StoreInfo>(INITIAL_STORE_INFO);
  const [sunatConnected, setSunatConnected] = useState(true);
  const [products, setProducts] = useState<Product[]>(INITIAL_PRODUCTS);
  const [cart, setCart] = useState<CartItem[]>([]);
  const [discountPercentage, setDiscountPercentage] = useState(0);
  const [vouchers, setVouchers] = useState<Voucher[]>(INITIAL_VOUCHERS);
  const [customers, setCustomers] = useState<Customer[]>(INITIAL_CUSTOMERS);
  const [selectedVoucher, setSelectedVoucher] = useState<Voucher | null>(null);
  const [notifications, setNotifications] = useState<NotificationToast[]>([]);

  const login = () => setIsLoggedIn(true);
  const logout = () => setIsLoggedIn(false);

  const toggleSunatConnection = () => {
    setSunatConnected(prev => !prev);
    notify(
      !sunatConnected ? 'SUNAT Conectado' : 'Modo Contingencia SUNAT',
      !sunatConnected
        ? 'Servidor OSE / SUNAT respondiendo con normalidad.'
        : 'Se activó modo local. Los comprobantes se sincronizarán al reconectar.',
      !sunatConnected ? 'success' : 'warning'
    );
  };

  const notify = (title: string, message: string, type: 'success' | 'warning' | 'info' | 'error' = 'info') => {
    const id = Date.now().toString() + Math.random().toString();
    setNotifications(prev => [...prev, { id, title, message, type }]);
    setTimeout(() => {
      removeNotification(id);
    }, 4500);
  };

  const removeNotification = (id: string) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  };

  // Add product to inventory
  const addProduct = (newProdData: Omit<Product, 'id'>) => {
    const newProduct: Product = {
      ...newProdData,
      id: `prod-${Date.now()}`,
    };
    setProducts(prev => [newProduct, ...prev]);
    notify('Producto Creado', `Se agregó "${newProduct.name}" al catálogo.`, 'success');
  };

  // Update product stock
  const updateProductStock = (productId: string, newStock: number, reason: string) => {
    setProducts(prev =>
      prev.map(p => {
        if (p.id === productId) {
          const status = newStock <= 0 ? 'out_of_stock' : newStock <= p.minStock ? 'low_stock' : 'active';
          return { ...p, stock: newStock, status };
        }
        return p;
      })
    );
    notify('Stock Actualizado', `Ajuste registrado: ${reason} (Nuevo stock: ${newStock})`, 'info');
  };

  // Cart operations
  const addToCart = (product: Product, size?: string, color?: string, quantity: number = 1) => {
    if (product.stock <= 0) {
      notify('Stock Agotado', `El producto ${product.name} no tiene stock disponible.`, 'error');
      return;
    }

    const chosenSize = size || (product.variants.length > 0 ? product.variants[0].size : 'Estándar');
    const chosenColor = color || (product.variants.length > 0 ? product.variants[0].color : 'Único');

    setCart(prev => {
      const existingIndex = prev.findIndex(
        item => item.product.id === product.id && item.selectedSize === chosenSize && item.selectedColor === chosenColor
      );

      if (existingIndex > -1) {
        const updated = [...prev];
        const newQty = updated[existingIndex].quantity + quantity;
        if (newQty > product.stock) {
          notify('Límite de Stock', `Solo hay ${product.stock} unidades disponibles en tienda.`, 'warning');
          return prev;
        }
        updated[existingIndex].quantity = newQty;
        return updated;
      } else {
        return [
          ...prev,
          {
            product,
            selectedSize: chosenSize,
            selectedColor: chosenColor,
            quantity,
            unitPrice: product.salePrice,
          },
        ];
      }
    });

    notify('Producto Añadido', `${product.name} (${chosenSize} / ${chosenColor}) agregado al carrito.`, 'success');
  };

  const removeFromCart = (index: number) => {
    setCart(prev => prev.filter((_, i) => i !== index));
  };

  const updateCartQuantity = (index: number, quantity: number) => {
    if (quantity <= 0) {
      removeFromCart(index);
      return;
    }
    setCart(prev => {
      const updated = [...prev];
      const item = updated[index];
      if (item && quantity > item.product.stock) {
        notify('Límite de Stock', `Stock máximo disponible: ${item.product.stock}`, 'warning');
        return prev;
      }
      if (item) {
        item.quantity = quantity;
      }
      return updated;
    });
  };

  const clearCart = () => {
    setCart([]);
    setDiscountPercentage(0);
  };

  // Calculations for Peru IGV (18%)
  // Total = Subtotal + IGV
  // If price includes IGV (standard retail Peru):
  // Subtotal = Total / 1.18
  // IGV = Total - Subtotal
  const rawTotal = cart.reduce((acc, item) => acc + item.unitPrice * item.quantity, 0);
  const discountAmount = Number(((rawTotal * discountPercentage) / 100).toFixed(2));
  const finalTotal = Math.max(0, rawTotal - discountAmount);
  const subtotalGravada = Number((finalTotal / 1.18).toFixed(2));
  const igvAmount = Number((finalTotal - subtotalGravada).toFixed(2));

  const cartTotals = {
    subtotal: subtotalGravada,
    igv: igvAmount,
    discount: discountAmount,
    total: Number(finalTotal.toFixed(2)),
    itemsCount: cart.reduce((acc, item) => acc + item.quantity, 0),
  };

  // Create Voucher (SUNAT simulation)
  const createVoucher = async ({
    type,
    customerName,
    customerDocType,
    customerDocNumber,
    customerAddress,
    paymentMethod,
  }: {
    type: 'BOLETA' | 'FACTURA';
    customerName: string;
    customerDocType: 'DNI' | 'RUC';
    customerDocNumber: string;
    customerAddress?: string;
    paymentMethod: 'EFECTIVO' | 'TARJETA' | 'YAPE' | 'PLIN';
  }): Promise<Voucher> => {
    // Generate Correlative
    const prefix = type === 'BOLETA' ? 'B001' : 'F001';
    const sameTypeVouchers = vouchers.filter(v => v.type === type);
    const nextCorrelative = sameTypeVouchers.length + 429;
    const seriesNumber = `${prefix}-${String(nextCorrelative).padStart(8, '0')}`;

    const now = new Date();
    const dateStr = now.toISOString().split('T')[0];
    const timeStr = now.toLocaleTimeString('es-PE', { hour: '2-digit', minute: '2-digit', hour12: true });

    // Deduct products stock
    setProducts(prev => {
      const updated = [...prev];
      cart.forEach(cartItem => {
        const prodIndex = updated.findIndex(p => p.id === cartItem.product.id);
        if (prodIndex > -1) {
          const currentProd = { ...updated[prodIndex] };
          const newTotalStock = Math.max(0, currentProd.stock - cartItem.quantity);
          currentProd.stock = newTotalStock;
          currentProd.status = newTotalStock <= 0 ? 'out_of_stock' : newTotalStock <= currentProd.minStock ? 'low_stock' : 'active';
          updated[prodIndex] = currentProd;
        }
      });
      return updated;
    });

    const newVoucher: Voucher = {
      id: `vouch-${Date.now()}`,
      seriesNumber,
      type,
      date: dateStr,
      time: timeStr,
      customerName,
      customerDocType,
      customerDocNumber,
      customerAddress: customerAddress || (customerDocType === 'RUC' ? 'Lima, Perú' : undefined),
      paymentMethod,
      items: cart.map(item => ({
        productId: item.product.id,
        productName: item.product.name,
        size: item.selectedSize,
        color: item.selectedColor,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        total: Number((item.unitPrice * item.quantity).toFixed(2)),
      })),
      subtotal: cartTotals.subtotal,
      igv: cartTotals.igv,
      discount: cartTotals.discount,
      total: cartTotals.total,
      sunatStatus: 'ACEPTADO',
      sunatCdrDescription: `CDR SUNAT: El comprobante electrónico ${seriesNumber} ha sido aceptado y validado satisfactoriamente.`,
      hashCpe: `${Math.random().toString(36).substring(2, 10).toUpperCase()}=${Math.random().toString(36).substring(2, 10)}`,
    };

    setVouchers(prev => [newVoucher, ...prev]);

    // Update customer purchases if exists
    setCustomers(prev =>
      prev.map(c => {
        if (c.docNumber === customerDocNumber) {
          return {
            ...c,
            totalPurchases: Number((c.totalPurchases + cartTotals.total).toFixed(2)),
            lastPurchaseDate: dateStr,
          };
        }
        return c;
      })
    );

    clearCart();
    return newVoucher;
  };

  // Add customer
  const addCustomer = (customerData: Omit<Customer, 'id' | 'totalPurchases' | 'lastPurchaseDate'>): Customer => {
    const newCust: Customer = {
      ...customerData,
      id: `c-${Date.now()}`,
      totalPurchases: 0,
      lastPurchaseDate: new Date().toISOString().split('T')[0],
    };
    setCustomers(prev => [newCust, ...prev]);
    notify('Cliente Registrado', `Cliente ${newCust.name} agregado al sistema.`, 'success');
    return newCust;
  };

  return (
    <AppContext.Provider
      value={{
        isLoggedIn,
        user,
        login,
        logout,
        activeTab,
        setActiveTab,
        storeInfo,
        sunatConnected,
        toggleSunatConnection,
        products,
        addProduct,
        updateProductStock,
        cart,
        addToCart,
        removeFromCart,
        updateCartQuantity,
        clearCart,
        cartTotals,
        discountPercentage,
        setDiscountPercentage,
        vouchers,
        createVoucher,
        selectedVoucher,
        setSelectedVoucher,
        customers,
        addCustomer,
        notifications,
        removeNotification,
        notify,
      }}
    >
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};
