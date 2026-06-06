import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/profile_model.dart';

class ProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback? onTap;
  final VoidCallback? onWhatsAppTap;

  const ProfileCard({
    super.key,
    required this.profile,
    this.onTap,
    this.onWhatsAppTap,
  });

  Color _statusColor(ProfileStatus s) {
    switch (s) {
      case ProfileStatus.sold:
        return Colors.blue;
      case ProfileStatus.reserved:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(profile.status);
    final fmt = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Text(
                  profile.profileName.isNotEmpty
                      ? profile.profileName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.profileName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (profile.clientName.isNotEmpty)
                      Text(
                        profile.clientName,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (profile.expirationDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Vence: ${fmt.format(profile.expirationDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: profile.isExpired
                              ? Colors.red
                              : profile.isExpiringSoon
                                  ? Colors.orange
                                  : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Chip(
                    label: Text(
                      profile.status.displayName,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: color.withOpacity(0.15),
                    padding: EdgeInsets.zero,
                    side: BorderSide.none,
                  ),
                  if (onWhatsAppTap != null &&
                      profile.clientPhone.isNotEmpty &&
                      profile.status == ProfileStatus.sold)
                    IconButton(
                      icon: const Text('💬', style: TextStyle(fontSize: 18)),
                      onPressed: onWhatsAppTap,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
