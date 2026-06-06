import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/profile_model.dart';
import '../../models/account_model.dart';

class InventoryScreen extends StatelessWidget {
  final String userId;
  const InventoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventario / Stock')),
      body: StreamBuilder<Map<String, Map<String, int>>>(
        stream: service.inventoryStream(userId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final inventory = snap.data ?? {};
          if (inventory.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay perfiles registrados',
                      style: TextStyle(fontSize: 16)),
                  Text(
                      'Agregá cuentas y perfiles para ver el stock',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: inventory.length,
            itemBuilder: (context, index) {
              final entry = inventory.entries.toList()[index];
              final platformName = entry.key;
              final stats = entry.value;
              final total = stats['total'] ?? 0;
              final available = stats['available'] ?? 0;
              final sold = stats['sold'] ?? 0;
              final utilization = total > 0 ? sold / total : 0.0;

              Color statusColor;
              if (available == 0) {
                statusColor = Colors.red;
              } else if (available <= 1) {
                statusColor = Colors.orange;
              } else {
                statusColor = Colors.green;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(platformName,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              available == 0
                                  ? '⚠️ Sin stock'
                                  : '$available disponibles',
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: utilization.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _InventoryStat(
                              label: 'Total',
                              value: '$total',
                              color: Colors.grey),
                          const SizedBox(width: 16),
                          _InventoryStat(
                              label: 'Vendidos',
                              value: '$sold',
                              color: Colors.orange),
                          const SizedBox(width: 16),
                          _InventoryStat(
                              label: 'Disponibles',
                              value: '$available',
                              color: Colors.green),
                          const Spacer(),
                          Text(
                            '${(utilization * 100).toStringAsFixed(0)}% usado',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
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

class _InventoryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InventoryStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
