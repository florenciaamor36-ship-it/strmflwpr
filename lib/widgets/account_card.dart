import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/account_model.dart';
import '../models/platform_model.dart';

class AccountCard extends StatelessWidget {
  final AccountModel account;
  final PlatformModel? platform;
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.account,
    this.platform,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('dd/MM/yyyy');
    final color = platform != null
        ? Color(int.parse(platform!.color.replaceFirst('#', '0xFF')))
        : theme.colorScheme.primary;
    final expired = account.isExpired;
    final days = account.daysUntilExpiration;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                radius: 22,
                child: Text(
                  platform?.iconEmoji ?? '📺',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.platformName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      account.email,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          expired
                              ? Icons.error_outline
                              : days <= 7
                                  ? Icons.warning_amber
                                  : Icons.check_circle_outline,
                          size: 14,
                          color: expired
                              ? Colors.red
                              : days <= 7
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          expired
                              ? 'Expirada'
                              : 'Vence: ${fmt.format(account.expirationDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: expired
                                ? Colors.red
                                : days <= 7
                                    ? Colors.orange
                                    : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${account.totalProfiles}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'perfiles',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
