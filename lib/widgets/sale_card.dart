import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sale_model.dart';
import '../services/whatsapp_service.dart';

class SaleCard extends StatelessWidget {
  final SaleModel sale;
  final VoidCallback? onRenew;

  const SaleCard({
    super.key,
    required this.sale,
    this.onRenew,
  });

  Color _expirationColor() {
    if (sale.isExpired) return Colors.red;
    final days = sale.daysUntilExpiration;
    if (days <= 7) return Colors.red;
    if (days <= 30) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('dd/MM/yyyy');
    final color = _expirationColor();
    final days = sale.daysUntilExpiration;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.platformName,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        sale.clientName,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Days remaining badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
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
            // Date and price row
            Row(
              children: [
                Icon(Icons.event_outlined,
                    size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Vence: ${fmt.format(sale.expirationDate)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  '\$${sale.price.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Phone row
            if (sale.clientPhone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '📞 ${sale.clientPhone}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 10),
            // Action buttons
            Row(
              children: [
                if (sale.clientPhone.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final wa = WhatsAppService();
                      await wa.sendSaleReminder(sale);
                    },
                    icon: const Text('💬', style: TextStyle(fontSize: 14)),
                    label: const Text('Recordatorio'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF25D366),
                      side: const BorderSide(color: Color(0xFF25D366)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                const SizedBox(width: 8),
                if (onRenew != null && sale.status == SaleStatus.active)
                  OutlinedButton(
                    onPressed: onRenew,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    child: const Text('Renovar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
