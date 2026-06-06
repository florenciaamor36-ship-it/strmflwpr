import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/sale_model.dart';
import '../../services/firestore_service.dart';
import '../../services/whatsapp_service.dart';
import '../inventory/inventory_screen.dart';
import '../sales/sale_detail_screen.dart';

class DashboardTab extends StatefulWidget {
  final String userId;
  const DashboardTab({super.key, required this.userId});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService(userId: widget.userId);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          // Stats row
          StreamBuilder<Map<String, int>>(
            stream: firestore.dashboardStatsStream(widget.userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final stats = snapshot.data!;
              return Row(
                children: [
                  _StatCard(title: 'Activas', value: stats['active'].toString(), color: Colors.green),
                  const SizedBox(width: 16),
                  _StatCard(title: 'Vencen', value: stats['expiringSoon'].toString(), color: Colors.orange),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Vencimientos Próximos', style: theme.textTheme.titleLarge),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InventoryScreen(userId: widget.userId))),
                child: const Text('Ver Todo'),
              ),
            ],
          ),
          // Sales list
          StreamBuilder<List<SaleModel>>(
            stream: firestore.activeSalesStream(widget.userId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final sales = snapshot.data!;
              if (sales.isEmpty) return const Text('No hay ventas activas');
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return Card(
                    child: ListTile(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SaleDetailScreen(saleId: sale.id))),
                      leading: Text(sale.platformEmoji, style: const TextStyle(fontSize: 24)),
                      title: Text(sale.clientName),
                      subtitle: Text('Vence: ${DateFormat('dd/MM').format(sale.expirationDate)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.message, color: Colors.green),
                        onPressed: () => WhatsAppService().sendSaleReminder(sale),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: TextStyle(color: color)),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
      ),
    );
  }
}
