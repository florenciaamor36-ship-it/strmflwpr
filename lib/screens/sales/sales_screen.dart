import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/sale_model.dart';
import '../../widgets/sale_card.dart';
import 'sale_form_screen.dart';
import 'sale_detail_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _service = FirestoreService();
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().userId ?? '';
    final settings = context.read<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Activas'),
            Tab(text: 'Vencidas'),
            Tab(text: 'Todas'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por cliente, plataforma...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<SaleModel>>(
              stream: _service.salesStream(userId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final all = snap.data ?? [];
                final filtered = _filter(all);
                final active = filtered
                    .where((s) => s.status == SaleStatus.active)
                    .toList();
                final expired = filtered
                    .where((s) => s.status == SaleStatus.expired)
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _SaleList(
                      sales: active,
                      service: _service,
                      settings: settings,
                      emptyMessage: 'No hay ventas activas',
                    ),
                    _SaleList(
                      sales: expired,
                      service: _service,
                      settings: settings,
                      emptyMessage: 'No hay ventas vencidas',
                    ),
                    _SaleList(
                      sales: filtered,
                      service: _service,
                      settings: settings,
                      emptyMessage: 'No hay ventas',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => SaleFormScreen(userId: userId)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<SaleModel> _filter(List<SaleModel> sales) {
    if (_searchQuery.isEmpty) return sales;
    final q = _searchQuery.toLowerCase();
    return sales.where((s) {
      return s.clientName.toLowerCase().contains(q) ||
          s.platformName.toLowerCase().contains(q) ||
          s.profileName.toLowerCase().contains(q) ||
          s.clientPhone.contains(q);
    }).toList();
  }
}

class _SaleList extends StatelessWidget {
  final List<SaleModel> sales;
  final FirestoreService service;
  final SettingsProvider settings;
  final String emptyMessage;

  const _SaleList({
    required this.sales,
    required this.service,
    required this.settings,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (sales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(emptyMessage,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        return SaleCard(
          sale: sale,
          currencySymbol: settings.currencySymbol,
          countryCode: settings.defaultCountryCode,
          businessName: settings.businessName,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => SaleDetailScreen(saleId: sale.id)),
          ),
          onMarkExpired: () async {
            await service.markSaleExpired(sale.id, sale.profileId);
          },
          onDelete: () async {
            await service.deleteSale(sale.id, sale.profileId);
          },
          onRenew: (newDate, price) async {
            await service.renewSale(
                sale.id, sale.profileId, newDate, price);
          },
        );
      },
    );
  }
}
