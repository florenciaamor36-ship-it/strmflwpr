import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/whatsapp_service.dart';
import '../../models/sale_model.dart';
import '../../models/renewal_model.dart';
import '../../widgets/expiration_badge.dart';
import '../../widgets/qr_dialog.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../utils/date_utils.dart';
import '../../utils/currency_utils.dart';
import 'sale_form_screen.dart';

class SaleDetailScreen extends StatelessWidget {
  final String saleId;
  const SaleDetailScreen({super.key, required this.saleId});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().userId ?? '';
    final settings = context.read<SettingsProvider>();
    final service = FirestoreService();
    final theme = Theme.of(context);

    return StreamBuilder<List<SaleModel>>(
      stream: service.salesStream(userId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        SaleModel? sale;
        try {
          sale = snap.data?.firstWhere((s) => s.id == saleId);
        } catch (_) {}

        if (sale == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Venta')),
            body: const Center(child: Text('Venta no encontrada')),
          );
        }

        final whatsapp = WhatsAppService(
          defaultCountryCode: settings.defaultCountryCode,
          businessName: settings.businessName,
          currencySymbol: settings.currencySymbol,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(sale.clientName),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) =>
                          SaleFormScreen(userId: userId, sale: sale)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => QrDialog(sale: sale!),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(sale.platformEmoji,
                              style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sale.platformName,
                                    style: theme.textTheme.titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                                Text('Perfil: ${sale.profileName}',
                                    style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          ),
                          ExpirationBadge(
                              daysRemaining: sale.daysRemaining),
                        ],
                      ),
                      const Divider(height: 24),
                      _InfoRow(label: 'Cliente', value: sale.clientName),
                      _InfoRow(label: 'Teléfono', value: sale.clientPhone),
                      _InfoRow(
                          label: 'Email cuenta', value: sale.accountEmail),
                      _InfoRow(
                          label: 'Contraseña', value: sale.accountPassword),
                      if (sale.profilePin.isNotEmpty)
                        _InfoRow(label: 'PIN', value: sale.profilePin),
                      _InfoRow(
                          label: 'Inicio',
                          value: AppDateUtils.formatDate(sale.startDate)),
                      _InfoRow(
                          label: 'Vencimiento',
                          value: AppDateUtils.formatDate(sale.expirationDate)),
                      _InfoRow(
                          label: 'Precio',
                          value: CurrencyUtils.format(sale.price,
                              symbol: settings.currencySymbol)),
                      if (sale.renewalCount > 0)
                        _InfoRow(
                            label: 'Renovaciones',
                            value: sale.renewalCount.toString()),
                      if (sale.notes.isNotEmpty)
                        _InfoRow(label: 'Notas', value: sale.notes),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // WhatsApp actions
              Text('WhatsApp',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.message),
                      label: const Text('Bienvenida'),
                      onPressed: () => whatsapp.sendWelcomeMessage(sale!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.timer_outlined),
                      label: const Text('Recordatorio'),
                      onPressed: () =>
                          whatsapp.sendReminderMessage(sale!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Renewal section
              Text('Renovaciones',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Renovar suscripción'),
                onPressed: () =>
                    _showRenewDialog(context, sale!, service, settings),
              ),
              const SizedBox(height: 12),

              // Renewal history
              StreamBuilder<List<RenewalModel>>(
                stream: service.renewalsForSaleStream(saleId),
                builder: (context, renewalSnap) {
                  final renewals = renewalSnap.data ?? [];
                  if (renewals.isEmpty) {
                    return const Text('Sin historial de renovaciones',
                        style: TextStyle(color: Colors.grey));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Historial',
                          style: theme.textTheme.labelLarge),
                      ...renewals.map((r) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.history,
                                color: Colors.green),
                            title: Text(
                                '${AppDateUtils.formatDate(r.previousExpiration)} → ${AppDateUtils.formatDate(r.newExpiration)}'),
                            subtitle: Text(
                                '${AppDateUtils.formatDate(r.renewedAt)} · ${CurrencyUtils.format(r.price, symbol: settings.currencySymbol)}'),
                          )),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Danger zone
              if (sale.status == SaleStatus.active)
                OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined,
                      color: Colors.red),
                  label: const Text('Marcar como vencida',
                      style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red)),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => const ConfirmationDialog(
                        title: 'Marcar como vencida',
                        message:
                            '¿Marcar esta venta como vencida? El perfil quedará disponible nuevamente.',
                        confirmLabel: 'Confirmar',
                        isDestructive: true,
                      ),
                    );
                    if (confirm == true) {
                      await service.markSaleExpired(
                          sale!.id, sale.profileId);
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRenewDialog(BuildContext context, SaleModel sale,
      FirestoreService service, SettingsProvider settings) async {
    DateTime newExpiration =
        sale.expirationDate.add(const Duration(days: 30));
    final priceController =
        TextEditingController(text: sale.price.toStringAsFixed(0));

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Renovar suscripción'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Nueva fecha de vencimiento'),
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
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Precio de renovación',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: settings.currencySymbol,
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
                await service.renewSale(
                    sale.id, sale.profileId, newExpiration, price);
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text('$label:',
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
