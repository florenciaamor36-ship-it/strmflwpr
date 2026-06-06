import 'package:flutter/material.dart';
import '../models/sale_model.dart';
import '../services/whatsapp_service.dart';
import '../utils/currency_utils.dart';
import '../utils/date_utils.dart';
import 'expiration_badge.dart';
import 'confirmation_dialog.dart';
import 'qr_dialog.dart';

class SaleCard extends StatelessWidget {
  final SaleModel sale;
  final String currencySymbol;
  final String countryCode;
  final String businessName;
  final VoidCallback onTap;
  final Future<void> Function() onMarkExpired;
  final Future<void> Function() onDelete;
  final Future<void> Function(DateTime newDate, double price) onRenew;

  const SaleCard({
    super.key,
    required this.sale,
    required this.currencySymbol,
    required this.countryCode,
    required this.businessName,
    required this.onTap,
    required this.onMarkExpired,
    required this.onDelete,
    required this.onRenew,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showOptions(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(sale.platformEmoji,
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sale.clientName,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                        Text(
                          '${sale.platformName} · ${sale.profileName}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  ExpirationBadge(daysRemaining: sale.daysRemaining),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyUtils.format(sale.price,
                        symbol: currencySymbol),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    AppDateUtils.formatDate(sale.expirationDate),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // WhatsApp reminder button
                      IconButton(
                        icon: const Icon(Icons.message, size: 18),
                        tooltip: 'Enviar recordatorio',
                        onPressed: () {
                          final whatsapp = WhatsAppService(
                            defaultCountryCode: countryCode,
                            businessName: businessName,
                            currencySymbol: currencySymbol,
                          );
                          whatsapp.sendReminderMessage(sale);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      // QR button
                      IconButton(
                        icon: const Icon(Icons.qr_code, size: 18),
                        tooltip: 'Ver QR',
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => QrDialog(sale: sale),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      // More options
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 18),
                        onPressed: () => _showOptions(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.green),
              title: const Text('Renovar'),
              onTap: () async {
                Navigator.of(context).pop();
                await _showRenewDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Ver QR'),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (_) => QrDialog(sale: sale),
                );
              },
            ),
            if (sale.status == SaleStatus.active)
              ListTile(
                leading: const Icon(Icons.cancel_outlined,
                    color: Colors.orange),
                title: const Text('Marcar como vencida'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => const ConfirmationDialog(
                      title: 'Marcar como vencida',
                      message:
                          '¿Marcar esta venta como vencida? El perfil quedará disponible.',
                      confirmLabel: 'Confirmar',
                      isDestructive: true,
                    ),
                  );
                  if (confirm == true) await onMarkExpired();
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Eliminar venta',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.of(context).pop();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => const ConfirmationDialog(
                    title: 'Eliminar venta',
                    message:
                        '¿Eliminar esta venta? El perfil quedará disponible.',
                    confirmLabel: 'Eliminar',
                    isDestructive: true,
                  ),
                );
                if (confirm == true) await onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showRenewDialog(BuildContext context) async {
    DateTime newExpiration =
        sale.expirationDate.add(const Duration(days: 30));
    final priceController =
        TextEditingController(text: sale.price.toStringAsFixed(0));

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Renovar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Nueva fecha'),
                subtitle: Text(AppDateUtils.formatDate(newExpiration)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: newExpiration,
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 1825)),
                  );
                  if (date != null) {
                    setStateDialog(() => newExpiration = date);
                  }
                },
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final price = double.tryParse(
                        priceController.text.replaceAll(',', '.')) ??
                    sale.price;
                await onRenew(newExpiration, price);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Renovar'),
            ),
          ],
        ),
      ),
    );
    priceController.dispose();
  }
}
