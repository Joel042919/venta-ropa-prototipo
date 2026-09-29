'use client';

import React, { useEffect } from 'react';
import { AppProvider, useApp } from '@/context/AppContext';
import { Header } from '@/components/Header';
import { Sidebar } from '@/components/Sidebar';
import { LoginScreen } from '@/components/LoginScreen';
import { PosView } from '@/components/POS/PosView';
import { DashboardView } from '@/components/Dashboard/DashboardView';
import { InventoryView } from '@/components/Inventory/InventoryView';
import { VouchersView } from '@/components/Vouchers/VouchersView';
import { CustomersView } from '@/components/Customers/CustomersView';
import { ReportsView } from '@/components/Reports/ReportsView';
import { NotificationToastContainer } from '@/components/NotificationToastContainer';

const MainAppContent: React.FC = () => {
  const { isLoggedIn, activeTab, setActiveTab } = useApp();

  // Keyboard shortcut listener: F2 opens POS
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'F2') {
        e.preventDefault();
        setActiveTab('pos');
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [setActiveTab]);

  if (!isLoggedIn) {
    return <LoginScreen />;
  }

  return (
    <div className="min-h-screen flex flex-col bg-[#faf8f5]">
      {/* Top Header */}
      <Header />

      {/* Main Workspace with Sidebar & Active View */}
      <div className="flex-1 flex overflow-hidden">
        <Sidebar />

        <main className="flex-1 flex flex-col overflow-hidden relative">
          {activeTab === 'pos' && <PosView />}
          {activeTab === 'dashboard' && <DashboardView />}
          {activeTab === 'inventory' && <InventoryView />}
          {activeTab === 'vouchers' && <VouchersView />}
          {activeTab === 'customers' && <CustomersView />}
          {activeTab === 'reports' && <ReportsView />}
        </main>
      </div>

      {/* Notification Toast Stack */}
      <NotificationToastContainer />
    </div>
  );
};

export default function HomePage() {
  return (
    <AppProvider>
      <MainAppContent />
    </AppProvider>
  );
}
