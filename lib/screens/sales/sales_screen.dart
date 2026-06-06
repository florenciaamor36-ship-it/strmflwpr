import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/whatsapp_service.dart';
import '../../models/sale_model.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  SaleStatus? _filterStatus;

  Color _expirationColor(SaleModel sale) {
    if (sale.isExpired) return Colors.red;
    final days = sale.daysUntilExpiration;
    if (days <= 7) return Colors.red;
    if (days <= 30) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUserId ?? '';
    final firestore = FirestoreService(userId: uid);
    final fmt = DateFormat('dd/MM/yyyy');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        centerTitle: true,
        actions: [
          PopupMenuButton<SaleStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) => setState(() => _filterStatus = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Todas')),
              const PopupMenuItem(
                  value: SaleStatus.active, child: Text('Activas')),
              const PopupMenuItem(
                  value: SaleStatus.expired, child: Text('Expiradas')),
              const PopupMenuItem(
                  value: SaleStatus.renewed, child: Text('Renovadas')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<SaleModel>>(
        stream: firestore.salesStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var sales = snap.data ?? [];
          if (_filterStatus != null) {
            sales = sales.where((s) => s.status == _filterStatus).toList();
          }

          if (sales.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sell_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No hay ventas registradas',
                      style: theme.textTheme.titleMedium),
                  const Text(
                      'Las ventas aparecen cuando vendés un perfil'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sales.length,
            itemBuilder: (ctx, i) {
              final sale = sales[i];
              final color = _expirationColor(sale);
              final days = sale.daysUntilExpiration;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sale.platformName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  sale.clientName,
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sale.isExpired
                                  ? 'VENCIDA'
                                  : days == 0
                                      ? 'HOY'
                                      : '${days}d',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            'Vence: ${fmt.format(sale.expirationDate)}',
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            '\$${sale.price.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (sale.clientPhone.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () async {
                                final wa = WhatsAppService();
                                await wa.sendSaleReminder(sale);
                              },
                              icon: const Text('💬',
                                  style: TextStyle(fontSize: 14)),
                              label: const Text('Recordatorio WhatsApp'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF25D366),
                                side: const BorderSide(
                                    color: Color(0xFF25D366)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (sale.status == SaleStatus.active)
                              OutlinedButton(
                                onPressed: () async {
                                  final updated = sale.copyWith(
                                      status: SaleStatus.renewed);
                                  await firestore.updateSale(updated);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                ),
                                child: const Text('Renovar'),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
