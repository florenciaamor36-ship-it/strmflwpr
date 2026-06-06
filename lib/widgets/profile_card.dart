import 'package:flutter/material.dart';
import '../models/profile_model.dart';

class ProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProfileCard({
    super.key,
    required this.profile,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color statusColor;
    String statusLabel;
    switch (profile.status) {
      case ProfileStatus.sold:
        statusColor = Colors.orange;
        statusLabel = 'Vendido';
        break;
      case ProfileStatus.reserved:
        statusColor = Colors.blue;
        statusLabel = 'Reservado';
        break;
      case ProfileStatus.disabled:
        statusColor = Colors.grey;
        statusLabel = 'Deshabilitado';
        break;
      default:
        statusColor = Colors.green;
        statusLabel = 'Disponible';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.15),
          child: Icon(Icons.person, color: statusColor),
        ),
        title: Row(
          children: [
            Text(profile.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profile.pin.isNotEmpty) Text('PIN: ${profile.pin}'),
            if (profile.currentClientName != null &&
                profile.status == ProfileStatus.sold)
              Text('Cliente: ${profile.currentClientName}',
                  style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: (onEdit != null || onDelete != null)
            ? PopupMenuButton<String>(
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
                icon: const Icon(Icons.more_vert),
              )
            : null,
      ),
    );
  }
}
