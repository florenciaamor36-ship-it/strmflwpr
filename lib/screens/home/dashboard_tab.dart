import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/stats_service.dart';
import '../../services/whatsapp_service.dart';
import '../../models/sale_model.dart';
import '../../utils/date_utils.dart';
import '../../utils/currency_utils.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/low_stock_banner.dart';
import '../../widgets/expiration_badge.dart';
import '../sales/sale_detail_screen.dart';
import '../platforms/platforms_screen.dart';
import '../accounts/accounts_screen.dart';
import '../inventory/inventory_screen.dart';
import '../inventory/bulk_load_screen.dart';
import '../inventory/price_list_screen.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().userId ?? '';
    final settings = context.read<SettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('strmflwpr Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Inventario',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => InventoryScreen(userId: userId)),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: StreamBuilder<List<SaleModel>>(
          stream: _firestoreService.salesStream(userId),
          builder: (context, salesSnap) {
            if (salesSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allSales = salesSnap.data ?? [];
            final activeSales = allSales
                .where((s) => s.status == SaleStatus.active)
                .toList();
            final expiringSoon =
                StatsService.expiringSoon(activeSales, 7);
            final monthRevenue =
                StatsService.totalRevenueThisMonth(allSales);

            return StreamBuilder<Map<String, Map<String, int>>>(
              stream: _firestoreService.inventoryStream(userId),
              builder: (context, inventorySnap) {
                final inventory = inventorySnap.data ?? {};
                final noStockPlatforms =
                    StatsService.platformsWithNoStock(inventory);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Low stock banner
                    if (noStockPlatforms.isNotEmpty)
                      LowStockBanner(
                        platformCount: noStockPlatforms.length,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  InventoryScreen(userId: userId)),
                        ),
                      ),
                    if (noStockPlatforms.isNotEmpty)
                      const SizedBox(height: 12),

                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Activos',
                            value: activeSales.length.toString(),
                            icon: Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Por vencer',
                            value: expiringSoon.length.toString(),
                            icon: Icons.timer_outlined,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Este mes',
                            value: CurrencyUtils.formatCompact(monthRevenue,
                                symbol: settings.currencySymbol),
                            icon: Icons.attach_money,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Total ventas',
                            value: allSales.length.toString(),
                            icon: Icons.receipt_long_outlined,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick actions
                    Text('Accesos rápidos',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.9,
                      children: [
                        _QuickAction(
                          icon: Icons.tv,
                          label: 'Plataformas',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    PlatformsScreen(userId: userId)),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.inventory_2,
                          label: 'Stock',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    InventoryScreen(userId: userId)),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.upload_file,
                          label: 'Carga Masiva',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const BulkLoadScreen()),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.attach_money,
                          label: 'Lista Precios',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const PriceListScreen()),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.manage_accounts,
                          label: 'Cuentas',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    AccountsScreen(userId: userId)),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.help_outline,
                          label: 'Manual',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const UserManualScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Expiring soon
                    if (expiringSoon.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Por vencer (7 días)',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          Text('${expiringSoon.length}',
                              style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...expiringSoon
                          .take(10)
                          .map((sale) => _ExpiringSaleCard(
                                sale: sale,
                                currencySymbol: settings.currencySymbol,
                                countryCode: settings.defaultCountryCode,
                                businessName: settings.businessName,
                                onTap: () =>
                                    Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          SaleDetailScreen(saleId: sale.id)),
                                ),
                              )),
                    ] else ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.celebration,
                                  size: 48,
                                  color: theme.colorScheme.primary),
                              const SizedBox(height: 8),
                              Text('¡Todo en orden!',
                                  style: theme.textTheme.titleMedium),
                              Text(
                                  'No hay servicios por vencer en los próximos 7 días',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ExpiringSaleCard extends StatelessWidget {
  final SaleModel sale;
  final String currencySymbol;
  final String countryCode;
  final String businessName;
  final VoidCallback onTap;

  const _ExpiringSaleCard({
    required this.sale,
    required this.currencySymbol,
    required this.countryCode,
    required this.businessName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(sale.platformEmoji, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(sale.clientName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${sale.platformName} · ${sale.profileName}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExpirationBadge(daysRemaining: sale.daysRemaining),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.message, size: 20),
              tooltip: 'Enviar recordatorio',
              onPressed: () {
                final service = WhatsAppService(
                  defaultCountryCode: countryCode,
                  businessName: businessName,
                  currencySymbol: currencySymbol,
                );
                service.sendReminderMessage(sale);
              },
            ),
          ],
        ),
      ),
    );
  }
}
