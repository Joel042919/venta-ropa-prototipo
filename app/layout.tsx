import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Estilo & Moda Boutique | Sistema POS & Facturación SUNAT",
  description: "Prototipo interactivo de alto impacto de Punto de Venta, Control de Inventario por tallas y Facturación Electrónica SUNAT.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="es"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="min-h-full flex flex-col bg-[#faf8f5] text-stone-900 selection:bg-[#c26d60] selection:text-white">
        {children}
      </body>
    </html>
  );
}
