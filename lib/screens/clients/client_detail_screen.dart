import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/whatsapp_service.dart';
import '../../models/client_model.dart';
import '../../models/sale_model.dart';
import '../../widgets/sale_card.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../utils/currency_utils.dart';
import '../sales/sale_detail_screen.dart';
import 'client_form_screen.dart';

class ClientDetailScreen extends StatelessWidget {
  final String clientId;
  final String userId;

  const ClientDetailScreen(
      {super.key, required this.clientId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final settings = context.read<SettingsProvider>();
    final theme = Theme.of(context);

    return StreamBuilder<List<ClientModel>>(
      stream: service.clientsStream(userId),
      builder: (context, clientSnap) {
        ClientModel? client;
        try {
          client =
              clientSnap.data?.firstWhere((c) => c.id == clientId);
        } catch (_) {}

        if (client == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final whatsapp = WhatsAppService(
          defaultCountryCode: settings.defaultCountryCode,
          businessName: settings.businessName,
          currencySymbol: settings.currencySymbol,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(client.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => ClientFormScreen(
                          userId: userId, client: client)),
                ),
              ),
            ],
          ),
          body: StreamBuilder<List<SaleModel>>(
            stream: service.clientSalesStream(userId, clientId),
            builder: (context, salesSnap) {
              final sales = salesSnap.data ?? [];
              final totalSpent =
                  sales.fold<double>(0, (sum, s) => sum + s.price);
              final activeSales = sales
                  .where((s) => s.status == SaleStatus.active)
                  .length;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Client info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 36,
                            backgroundColor:
                                theme.colorScheme.primaryContainer,
                            child: Text(
                              client!.initials,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(client.name,
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          if (client.phone.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(client.phone,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6))),
                          ],
                          if (client.email.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(client.email,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5))),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatItem(
                                  label: 'Activos',
                                  value: '$activeSales',
                                  color: Colors.green),
                              _StatItem(
                                  label: 'Total ventas',
                                  value: '${sales.length}',
                                  color: Colors.blue),
                              _StatItem(
                                  label: 'Gastado',
                                  value: CurrencyUtils.formatCompact(
                                      totalSpent,
                                      symbol: settings.currencySymbol),
                                  color: Colors.purple),
                            ],
                          ),
                          if (client.tags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              children: client.tags
                                  .map((tag) => Chip(
                                        label: Text(tag),
                                        visualDensity:
                                            VisualDensity.compact,
                                      ))
                                  .toList(),
                            ),
                          ],
                          const SizedBox(height: 12),
                          // WhatsApp button
                          if (client.phone.isNotEmpty)
                            OutlinedButton.icon(
                              icon: const Icon(Icons.message),
                              label: const Text('WhatsApp'),
                              onPressed: () => whatsapp.sendCustomMessage(
                                client!.phone,
                                'Hola ${client.name}! 👋',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  if (client.notes.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notas',
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(client.notes),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Sales
                  Text('Historial de ventas',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (sales.isEmpty)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(32),
                            child:
                                Text('Sin historial de compras')))
                  else
                    ...sales.map((sale) => SaleCard(
                          sale: sale,
                          currencySymbol: settings.currencySymbol,
                          countryCode: settings.defaultCountryCode,
                          businessName: settings.businessName,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    SaleDetailScreen(saleId: sale.id)),
                          ),
                          onMarkExpired: () async {
                            await service.markSaleExpired(
                                sale.id, sale.profileId);
                          },
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => const ConfirmationDialog(
                                title: 'Eliminar venta',
                                message: '¿Eliminar esta venta?',
                                confirmLabel: 'Eliminar',
                                isDestructive: true,
                              ),
                            );
                            if (confirm == true) {
                              await service.deleteSale(
                                  sale.id, sale.profileId);
                            }
                          },
                          onRenew: (newDate, price) async {
                            await service.renewSale(
                                sale.id, sale.profileId, newDate, price);
                          },
                        )),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
