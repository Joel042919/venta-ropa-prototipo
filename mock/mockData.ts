export interface ProductVariant {
  size: 'XS' | 'S' | 'M' | 'L' | 'XL' | 'Estándar';
  color: string;
  colorHex: string;
  stock: number;
}

export interface Product {
  id: string;
  sku: string;
  name: string;
  category: 'Vestidos' | 'Blusas & Tops' | 'Pantalones & Jeans' | 'Accesorios' | 'Calzado';
  description: string;
  costPrice: number;
  salePrice: number;
  stock: number;
  minStock: number;
  image: string;
  barcode: string;
  variants: ProductVariant[];
  status: 'active' | 'low_stock' | 'out_of_stock';
}

export interface CartItem {
  product: Product;
  selectedSize: string;
  selectedColor: string;
  quantity: number;
  unitPrice: number;
}

export interface Customer {
  id: string;
  docType: 'DNI' | 'RUC';
  docNumber: string;
  name: string;
  email?: string;
  phone?: string;
  address?: string;
  totalPurchases: number;
  lastPurchaseDate: string;
}

export interface VoucherItem {
  productId: string;
  productName: string;
  size: string;
  color: string;
  quantity: number;
  unitPrice: number;
  total: number;
}

export interface Voucher {
  id: string;
  seriesNumber: string; // ej: B001-000428 o F001-000115
  type: 'BOLETA' | 'FACTURA';
  date: string;
  time: string;
  customerName: string;
  customerDocType: 'DNI' | 'RUC';
  customerDocNumber: string;
  customerAddress?: string;
  paymentMethod: 'EFECTIVO' | 'TARJETA' | 'YAPE' | 'PLIN' | 'MIXTO';
  items: VoucherItem[];
  subtotal: number; // Op. Gravada
  igv: number;      // 18%
  discount: number;
  total: number;
  sunatStatus: 'ACEPTADO' | 'ENVIADO' | 'PENDIENTE';
  sunatCdrDescription: string;
  hashCpe: string;
}

export interface StoreInfo {
  name: string;
  commercialName: string;
  ruc: string;
  address: string;
  district: string;
  city: string;
  phone: string;
  email: string;
  website: string;
  sunatResolution: string;
}

export const INITIAL_STORE_INFO: StoreInfo = {
  name: 'ESTILO & MODA S.A.C.',
  commercialName: 'Estilo & Moda Boutique',
  ruc: '20608912345',
  address: 'Av. Los Conquistadores 780, Int. 201',
  district: 'San Isidro',
  city: 'Lima - Perú',
  phone: '+51 987 654 321',
  email: 'ventas@estiloymoda.pe',
  website: 'www.estiloymoda.pe',
  sunatResolution: 'R.S. 034-005-0005312/SUNAT',
};

export const INITIAL_CUSTOMERS: Customer[] = [
  {
    id: 'c-1',
    docType: 'DNI',
    docNumber: '72345678',
    name: 'Camila Rossi Morales',
    phone: '984 123 456',
    email: 'camila.rossi@gmail.com',
    address: 'Av. Pardo y Aliaga 450, San Isidro',
    totalPurchases: 1420.00,
    lastPurchaseDate: '2026-09-22',
  },
  {
    id: 'c-2',
    docType: 'DNI',
    docNumber: '46890123',
    name: 'Fiorella Chang Castro',
    phone: '992 881 223',
    email: 'fiochang@hotmail.com',
    address: 'Calle Las Camelias 210, Miraflores',
    totalPurchases: 890.50,
    lastPurchaseDate: '2026-09-23',
  },
  {
    id: 'c-3',
    docType: 'RUC',
    docNumber: '20554433221',
    name: 'AGENCIA DE TALENTOS & MODELAJE GLAM S.A.C.',
    phone: '981 772 334',
    email: 'administracion@glamtalents.com',
    address: 'Av. Javier Prado Este 3200, San Borja',
    totalPurchases: 3850.00,
    lastPurchaseDate: '2026-09-20',
  },
  {
    id: 'c-4',
    docType: 'DNI',
    docNumber: '71556677',
    name: 'Valeria Benavides Díaz',
    phone: '976 543 210',
    email: 'valeria.bena@yahoo.com',
    address: 'Malecón Cisneros 890, Miraflores',
    totalPurchases: 2150.00,
    lastPurchaseDate: '2026-09-24',
  },
  {
    id: 'c-5',
    docType: 'RUC',
    docNumber: '20601998877',
    name: 'PRODUCCIONES AUDIOVISUALES ESTUDIO LIMA E.I.R.L.',
    phone: '998 334 112',
    email: 'contacto@estudiolima.pe',
    address: 'Calle Dos de Mayo 740, San Isidro',
    totalPurchases: 4200.00,
    lastPurchaseDate: '2026-09-21',
  },
  {
    id: 'c-6',
    docType: 'DNI',
    docNumber: '45123490',
    name: 'Andrea Lucía Paredes',
    phone: '965 412 879',
    email: 'andrea.paredes@gmail.com',
    address: 'Jr. Batalla de Junín 215, Barranco',
    totalPurchases: 620.00,
    lastPurchaseDate: '2026-09-18',
  },
  {
    id: 'c-7',
    docType: 'DNI',
    docNumber: '70891244',
    name: 'Luciana Fernández Rivera',
    phone: '987 112 455',
    email: 'luciana.fr@outlook.com',
    address: 'Av. Dos de Mayo 1420, San Isidro',
    totalPurchases: 1180.00,
    lastPurchaseDate: '2026-09-24',
  },
  {
    id: 'c-8',
    docType: 'DNI',
    docNumber: '48321098',
    name: 'Claudia Mendoza Prado',
    phone: '993 654 119',
    email: 'claudia.mendoza@gmail.com',
    address: 'Calle Monterrey 340, Surco',
    totalPurchases: 450.00,
    lastPurchaseDate: '2026-09-15',
  },
];

export const INITIAL_PRODUCTS: Product[] = [
  {
    id: 'prod-1',
    sku: 'VES-001',
    name: 'Vestido Midi Terracota Lino',
    category: 'Vestidos',
    description: 'Vestido midi confeccionado en lino premium con escote en V y botones de madera.',
    costPrice: 65.00,
    salePrice: 159.00,
    stock: 14,
    minStock: 5,
    barcode: '775123400101',
    image: 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?auto=format&fit=crop&w=600&q=80',
    status: 'active',
    variants: [
      { size: 'S', color: 'Terracota', colorHex: '#C26D60', stock: 5 },
      { size: 'M', color: 'Terracota', colorHex: '#C26D60', stock: 6 },
      { size: 'L', color: 'Terracota', colorHex: '#C26D60', stock: 3 },
    ],
  },
  {
    id: 'prod-2',
    sku: 'BLU-002',
    name: 'Blusa Floral Manga Abullonada',
    category: 'Blusas & Tops',
    description: 'Blusa romántica con estampado floral suave, cuello cuadrado y mangas estilo princesa.',
    costPrice: 38.00,
    salePrice: 89.00,
    stock: 18,
    minStock: 6,
    barcode: '775123400102',
    image: 'https://images.unsplash.com/photo-1564257631407-4deb1f99d992?auto=format&fit=crop&w=600&q=80',
    status: 'active',
    variants: [
      { size: 'S', color: 'Palo Rosa', colorHex: '#DDA7A5', stock: 7 },
      { size: 'M', color: 'Palo Rosa', colorHex: '#DDA7A5', stock: 8 },
      { size: 'L', color: 'Blanco Lirio', colorHex: '#FDFBF7', stock: 3 },
    ],
  },
  {
    id: 'prod-3',
    sku: 'PAN-003',
    name: 'Jean Mom Fit Celeste Vintage',
    category: 'Pantalones & Jeans',
    description: 'Jean de tiro alto rígido 100% algodón denim peruano, lavado medio vintage.',
    costPrice: 55.00,
    salePrice: 139.00,
    stock: 3,
    minStock: 6,
    barcode: '775123400103',
    image: 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=600&q=80',
    status: 'low_stock',
    variants: [
      { size: 'S', color: 'Celeste Denim', colorHex: '#93B5C6', stock: 1 },
      { size: 'M', color: 'Celeste Denim', colorHex: '#93B5C6', stock: 2 },
      { size: 'L', color: 'Celeste Denim', colorHex: '#93B5C6', stock: 0 },
    ],
  },
  {
    id: 'prod-4',
    sku: 'VES-004',
    name: 'Vestido Camisero Safari Beige',
    category: 'Vestidos',
    description: 'Diseño utilitario chic con cinturón ajustable en cintura y bolsillos frontales.',
    costPrice: 72.00,
    salePrice: 179.00,
    stock: 12,
    minStock: 4,
    barcode: '775123400104',
    image: 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?auto=format&fit=crop&w=600&q=80',
    status: 'active',
    variants: [
      { size: 'S', color: 'Beige Arena', colorHex: '#D8CBB5', stock: 4 },
      { size: 'M', color: 'Beige Arena', colorHex: '#D8CBB5', stock: 5 },
      { size: 'L', color: 'Verde Oliva', colorHex: '#708238', stock: 3 },
    ],
  },
  {
    id: 'prod-5',
    sku: 'ACC-005',
    name: 'Cartera Crossbody Cuero Caramelo',
    category: 'Accesorios',
    description: 'Bolso bandolera en cuero vacuno suave con herrajes dorados mate y correa desmontable.',
    costPrice: 85.00,
    salePrice: 219.00,
    stock: 2,
    minStock: 4,
    barcode: '775123400105',
    image: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=600&q=80',
    status: 'low_stock',
    variants: [
      { size: 'Estándar', color: 'Caramelo', colorHex: '#AF6E4D', stock: 2 },
    ],
  },
  {
    id: 'prod-6',
    sku: 'TOP-006',
    name: 'Top Halter Seda Champagne',
    category: 'Blusas & Tops',
    description: 'Top elegante en satén satinado con lazo posterior regulable y espalda descubierta.',
    costPrice: 32.00,
    salePrice: 79.00,
    stock: 22,
    minStock: 5,
    barcode: '775123400106',
    image: 'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?auto=format&fit=crop&w=600&q=80',
    status: 'active',
    variants: [
      { size: 'S', color: 'Champagne', colorHex: '#F7E7CE', stock: 9 },
      { size: 'M', color: 'Champagne', colorHex: '#F7E7CE', stock: 10 },
      { size: 'L', color: 'Negro Azabache', colorHex: '#1B1B1B', stock: 3 },
    ],
  },
  {
    id: 'prod-7',
    sku: 'PAN-007',
    name: 'Pantalón Palazzo Lino Marfil',
    category: 'Pantalones & Jeans',
    description: 'Corte fluido de tiro alto con pinzas delanteras y caída impecable para toda ocasión.',
    costPrice: 58.00,
    salePrice: 149.00,
    stock: 8,
    minStock: 4,
    barcode: '775123400107',
    image: 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=600&q=80',
    status: 'active',
    variants: [
      { size: 'S', color: 'Marfil', colorHex: '#FAF0E6', stock: 3 },
      { size: 'M', color: 'Marfil', colorHex: '#FAF0E6', stock: 3 },
      { size: 'L', color: 'Terracota', colorHex: '#C26D60', stock: 2 },
    ],
  },
  {
    id: 'prod-8',
    sku: 'CAL-008',
    name: 'Mules Cuero Trenzado Nude',
    category: 'Calzado',
    description: 'Calzado mules destalonados con taco bloque de 5cm y plantilla acolchada confort.',
    costPrice: 75.00,
    salePrice: 189.00,
    stock: 0,
    minStock: 3,
    barcode: '775123400108',
    image: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=600&q=80',
    status: 'out_of_stock',
    variants: [
      { size: 'S', color: 'Nude', colorHex: '#E3BC9A', stock: 0 },
      { size: 'M', color: 'Nude', colorHex: '#E3BC9A', stock: 0 },
    ],
  },
  {
    id: 'prod-9',
    sku: 'BLU-009',
    name: 'Camisa Oversize Algodón Pima',
    category: 'Blusas & Tops',
    description: 'Camisa boyfriend en 100% Algodón Pima peruano extra suave, corte relajado.',
    costPrice: 48.00,
    salePrice: 119.00,
    stock: 16,
    minStock: 5,
    barcode: '775123400109',
    image: 'https://images.unsplash.com/photo-1598554747436-c9293d6a588f?auto=format&fit=crop&w=600&q=80',
    status: 'active',
    variants: [
      { size: 'S', color: 'Blanco Puro', colorHex: '#FFFFFF', stock: 6 },
      { size: 'M', color: 'Blanco Puro', colorHex: '#FFFFFF', stock: 7 },
      { size: 'L', color: 'Raya Celeste', colorHex: '#A0C4E2', stock: 3 },
    ],
  },
  {
    id: 'prod-10',
    sku: 'VES-010',
    name: 'Vestido Gala Asimétrico Vino',
    category: 'Vestidos',
    description: 'Vestido largo formal con hombro descubierto, caída al bies y abertura lateral sutil.',
    costPrice: 95.00,
    salePrice: 249.00,
    stock: 5,
    minStock: 3,
    barcode: '775123400110',
    image: 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?auto=format&fit=crop&w=600&q=80',
    status: 'active',
    variants: [
      { size: 'S', color: 'Vino Borgoña', colorHex: '#671D28', stock: 2 },
      { size: 'M', color: 'Vino Borgoña', colorHex: '#671D28', stock: 2 },
      { size: 'L', color: 'Negro Noche', colorHex: '#121212', stock: 1 },
    ],
  },
  {
    id: 'prod-11',
    sku: 'ACC-011',
    name: 'Cinturón Cuero Hebilla Dorada',
    category: 'Accesorios',
    description: 'Cinturón fino de cuero genuino con hebilla orgánica dorada cepillada.',
    costPrice: 22.00,
    salePrice: 59.00,
    stock: 15,
    minStock: 4,
    barcode: '775123400111',
    image: 'https://images.unsplash.com/photo-1624222247344-550fb60583dc?auto=format&fit=crop&w=600&q=80',
    status: 'active',
    variants: [
      { size: 'Estándar', color: 'Marrón Suela', colorHex: '#7B3F00', stock: 9 },
      { size: 'Estándar', color: 'Negro', colorHex: '#000000', stock: 6 },
    ],
  },
  {
    id: 'prod-12',
    sku: 'CAL-012',
    name: 'Sandalias Plataforma Yute Arena',
    category: 'Calzado',
    description: 'Sandalias veraniegas de cuña con tiras de gamuza suave y suela trenzada artesanal.',
    costPrice: 68.00,
    salePrice: 169.00,
    stock: 7,
    minStock: 3,
    barcode: '775123400112',
    image: 'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?auto=format&fit=crop&w=600&q=80',
    status: 'active',
    variants: [
      { size: 'S', color: 'Arena', colorHex: '#E0D7C6', stock: 3 },
      { size: 'M', color: 'Arena', colorHex: '#E0D7C6', stock: 4 },
    ],
  },
  {
    id: 'prod-13',
    sku: 'BLU-013',
    name: 'Blazer Entallado Crepé Mostaza',
    category: 'Blusas & Tops',
    description: 'Blazer estructurado moderno sin solapa con forro interior sedoso en tono mostaza suave.',
    costPrice: 80.00,
    salePrice: 199.00,
    stock: 6,
    minStock: 3,
    barcode: '775123400113',
    image: 'https://images.unsplash.com/photo-1554412933-514a83d2f3c8?auto=format&fit=crop&w=600&q=80',
    status: 'active',
    variants: [
      { size: 'S', color: 'Mostaza Suave', colorHex: '#D4AF37', stock: 2 },
      { size: 'M', color: 'Mostaza Suave', colorHex: '#D4AF37', stock: 3 },
      { size: 'L', color: 'Mostaza Suave', colorHex: '#D4AF37', stock: 1 },
    ],
  },
  {
    id: 'prod-14',
    sku: 'ACC-014',
    name: 'Sombrero Panamá Cinta Terracota',
    category: 'Accesorios',
    description: 'Sombrero tejido en paja toquilla fina con cinta decorativa de gasa terracota.',
    costPrice: 42.00,
    salePrice: 110.00,
    stock: 9,
    minStock: 3,
    barcode: '775123400114',
    image: 'https://images.unsplash.com/photo-1572307480813-ceb0e59d8325?auto=format&fit=crop&w=600&q=80',
    status: 'active',
    variants: [
      { size: 'Estándar', color: 'Paja Natural', colorHex: '#F3E5AB', stock: 9 },
    ],
  },
  {
    id: 'prod-15',
    sku: 'PAN-015',
    name: 'Short Sastrero Cintura Alta Salvia',
    category: 'Pantalones & Jeans',
    description: 'Short elegante con pinzas y presillas anchas, perfecto para combinaciones casual-chic.',
    costPrice: 40.00,
    salePrice: 99.00,
    stock: 1,
    minStock: 4,
    barcode: '775123400115',
    image: 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?auto=format&fit=crop&w=600&q=80',
    status: 'low_stock',
    variants: [
      { size: 'S', color: 'Verde Salvia', colorHex: '#9CAF88', stock: 1 },
      { size: 'M', color: 'Verde Salvia', colorHex: '#9CAF88', stock: 0 },
    ],
  },
];

export const INITIAL_VOUCHERS: Voucher[] = [
  {
    id: 'vouch-1',
    seriesNumber: 'B001-000428',
    type: 'BOLETA',
    date: '2026-09-24',
    time: '10:15 AM',
    customerName: 'Camila Rossi Morales',
    customerDocType: 'DNI',
    customerDocNumber: '72345678',
    customerAddress: 'Av. Pardo y Aliaga 450, San Isidro',
    paymentMethod: 'YAPE',
    items: [
      {
        productId: 'prod-1',
        productName: 'Vestido Midi Terracota Lino',
        size: 'M',
        color: 'Terracota',
        quantity: 1,
        unitPrice: 159.00,
        total: 159.00,
      },
      {
        productId: 'prod-11',
        productName: 'Cinturón Cuero Hebilla Dorada',
        size: 'Estándar',
        color: 'Marrón Suela',
        quantity: 1,
        unitPrice: 59.00,
        total: 59.00,
      },
    ],
    subtotal: 184.75,
    igv: 33.25,
    discount: 0,
    total: 218.00,
    sunatStatus: 'ACEPTADO',
    sunatCdrDescription: 'CDR: La Boleta número B001-000428 ha sido aceptada por SUNAT.',
    hashCpe: 'Q041kX9t2Bvw7Kj3Mv8sPq1L=',
  },
  {
    id: 'vouch-2',
    seriesNumber: 'F001-000115',
    type: 'FACTURA',
    date: '2026-09-24',
    time: '09:40 AM',
    customerName: 'AGENCIA DE TALENTOS & MODELAJE GLAM S.A.C.',
    customerDocType: 'RUC',
    customerDocNumber: '20554433221',
    customerAddress: 'Av. Javier Prado Este 3200, San Borja, Lima',
    paymentMethod: 'TARJETA',
    items: [
      {
        productId: 'prod-10',
        productName: 'Vestido Gala Asimétrico Vino',
        size: 'S',
        color: 'Vino Borgoña',
        quantity: 2,
        unitPrice: 249.00,
        total: 498.00,
      },
      {
        productId: 'prod-13',
        productName: 'Blazer Entallado Crepé Mostaza',
        size: 'M',
        color: 'Mostaza Suave',
        quantity: 1,
        unitPrice: 199.00,
        total: 199.00,
      },
    ],
    subtotal: 590.68,
    igv: 106.32,
    discount: 0,
    total: 697.00,
    sunatStatus: 'ACEPTADO',
    sunatCdrDescription: 'CDR: La Factura número F001-000115 ha sido aceptada por SUNAT.',
    hashCpe: 'Zw89pL2o0Aqq4Rz7Yx5tNm3K=',
  },
  {
    id: 'vouch-3',
    seriesNumber: 'B001-000427',
    type: 'BOLETA',
    date: '2026-09-23',
    time: '06:20 PM',
    customerName: 'Fiorella Chang Castro',
    customerDocType: 'DNI',
    customerDocNumber: '46890123',
    customerAddress: 'Calle Las Camelias 210, Miraflores',
    paymentMethod: 'EFECTIVO',
    items: [
      {
        productId: 'prod-2',
        productName: 'Blusa Floral Manga Abullonada',
        size: 'S',
        color: 'Palo Rosa',
        quantity: 1,
        unitPrice: 89.00,
        total: 89.00,
      },
      {
        productId: 'prod-7',
        productName: 'Pantalón Palazzo Lino Marfil',
        size: 'M',
        color: 'Marfil',
        quantity: 1,
        unitPrice: 149.00,
        total: 149.00,
      },
    ],
    subtotal: 201.69,
    igv: 36.31,
    discount: 0,
    total: 238.00,
    sunatStatus: 'ACEPTADO',
    sunatCdrDescription: 'CDR: La Boleta número B001-000427 ha sido aceptada por SUNAT.',
    hashCpe: 'Lk31jH7s6Mn4Bv2Xz8aQp0W=',
  },
  {
    id: 'vouch-4',
    seriesNumber: 'B001-000426',
    type: 'BOLETA',
    date: '2026-09-23',
    time: '04:10 PM',
    customerName: 'Clientes Varios',
    customerDocType: 'DNI',
    customerDocNumber: '00000000',
    paymentMethod: 'PLIN',
    items: [
      {
        productId: 'prod-6',
        productName: 'Top Halter Seda Champagne',
        size: 'M',
        color: 'Champagne',
        quantity: 1,
        unitPrice: 79.00,
        total: 79.00,
      },
    ],
    subtotal: 66.95,
    igv: 12.05,
    discount: 0,
    total: 79.00,
    sunatStatus: 'ACEPTADO',
    sunatCdrDescription: 'CDR: La Boleta número B001-000426 ha sido aceptada por SUNAT.',
    hashCpe: 'As76dF2g8Hj1Kl4Qw9eRt3Y=',
  },
  {
    id: 'vouch-5',
    seriesNumber: 'F001-000114',
    type: 'FACTURA',
    date: '2026-09-22',
    time: '02:50 PM',
    customerName: 'PRODUCCIONES AUDIOVISUALES ESTUDIO LIMA E.I.R.L.',
    customerDocType: 'RUC',
    customerDocNumber: '20601998877',
    customerAddress: 'Calle Dos de Mayo 740, San Isidro, Lima',
    paymentMethod: 'TARJETA',
    items: [
      {
        productId: 'prod-5',
        productName: 'Cartera Crossbody Cuero Caramelo',
        size: 'Estándar',
        color: 'Caramelo',
        quantity: 1,
        unitPrice: 219.00,
        total: 219.00,
      },
      {
        productId: 'prod-4',
        productName: 'Vestido Camisero Safari Beige',
        size: 'M',
        color: 'Beige Arena',
        quantity: 1,
        unitPrice: 179.00,
        total: 179.00,
      },
    ],
    subtotal: 337.29,
    igv: 60.71,
    discount: 0,
    total: 398.00,
    sunatStatus: 'ACEPTADO',
    sunatCdrDescription: 'CDR: La Factura número F001-000114 ha sido aceptada por SUNAT.',
    hashCpe: 'Yu90iO3p5As7Df1Gh4Jk6Lz=',
  },
  {
    id: 'vouch-6',
    seriesNumber: 'B001-000425',
    type: 'BOLETA',
    date: '2026-09-22',
    time: '11:30 AM',
    customerName: 'Luciana Fernández Rivera',
    customerDocType: 'DNI',
    customerDocNumber: '70891244',
    customerAddress: 'Av. Dos de Mayo 1420, San Isidro',
    paymentMethod: 'YAPE',
    items: [
      {
        productId: 'prod-9',
        productName: 'Camisa Oversize Algodón Pima',
        size: 'S',
        color: 'Blanco Puro',
        quantity: 1,
        unitPrice: 119.00,
        total: 119.00,
      },
    ],
    subtotal: 100.85,
    igv: 18.15,
    discount: 0,
    total: 119.00,
    sunatStatus: 'ACEPTADO',
    sunatCdrDescription: 'CDR: La Boleta número B001-000425 ha sido aceptada por SUNAT.',
    hashCpe: 'Mnb23Vcx4Zas5Qwe6Rty7Uio=',
  },
];

export const MOCK_SALES_CHART = [
  { day: 'Lun 18', ventas: 1850, boletas: 12, facturas: 2 },
  { day: 'Mar 19', ventas: 2420, boletas: 15, facturas: 3 },
  { day: 'Mié 20', ventas: 3100, boletas: 19, facturas: 4 },
  { day: 'Jue 21', ventas: 2150, boletas: 14, facturas: 2 },
  { day: 'Vie 22', ventas: 3890, boletas: 24, facturas: 5 },
  { day: 'Sáb 23', ventas: 5400, boletas: 35, facturas: 6 },
  { day: 'Dom 24', ventas: 3620, boletas: 22, facturas: 3 },
];

export const MOCK_CATEGORY_SHARE = [
  { name: 'Vestidos', value: 42, color: '#C26D60' },
  { name: 'Blusas & Tops', value: 25, color: '#DDA7A5' },
  { name: 'Pantalones & Jeans', value: 18, color: '#93B5C6' },
  { name: 'Accesorios', value: 10, color: '#AF6E4D' },
  { name: 'Calzado', value: 5, color: '#D4AF37' },
];

export const MOCK_PAYMENT_SHARE = [
  { name: 'Yape / Plin', percentage: 48, count: 85, color: '#7b1fa2' },
  { name: 'Tarjetas (Visa/MC)', percentage: 34, count: 60, color: '#1976d2' },
  { name: 'Efectivo', percentage: 18, count: 32, color: '#388e3c' },
];
