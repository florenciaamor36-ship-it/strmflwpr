import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../utils/date_utils.dart';

class AccountCard extends StatelessWidget {
  final AccountModel account;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = account.totalProfiles;
    final sold = account.soldProfiles;
    final available = account.availableProfiles;

    // Color coding for availability
    Color availabilityColor;
    if (available == 0) {
      availabilityColor = Colors.red;
    } else if (available <= 1) {
      availabilityColor = Colors.orange;
    } else {
      availabilityColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(account.platformName,
                        style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.tv, size: 14),
                  ),
                  const Spacer(),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call();
                      },
                      itemBuilder: (_) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                              value: 'edit', child: Text('Editar')),
                        if (onDelete != null)
                          const PopupMenuItem(
                              value: 'delete',
                              child: Text('Eliminar',
                                  style: TextStyle(color: Colors.red))),
                      ],
                      icon: const Icon(Icons.more_vert, size: 20),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(account.maskedEmail,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              if (account.accountExpiration != null) ...[
                const SizedBox(height: 4),
                Text(
                    'Cuenta vence: ${AppDateUtils.formatDate(account.accountExpiration!)}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey)),
              ],
              const SizedBox(height: 12),

              // FIXED: Profile status summary
              if (total > 0) ...[
                Row(
                  children: [
                    // Progress bar
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total > 0 ? sold / total : 0,
                          minHeight: 6,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(availabilityColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$sold/$total vendidos · ',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '$available disponibles',
                      style: TextStyle(
                          fontSize: 12,
                          color: availabilityColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ] else ...[
                Text('Sin perfiles',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
