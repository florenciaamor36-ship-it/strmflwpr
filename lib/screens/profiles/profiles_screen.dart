import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/profile_model.dart';
import '../../models/platform_model.dart';
import '../../models/account_model.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  ProfileStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUserId ?? '';
    final firestore = FirestoreService(userId: uid);
    final theme = Theme.of(context);
    final fmt = DateFormat('dd/MM/yy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfiles'),
        centerTitle: true,
        actions: [
          PopupMenuButton<ProfileStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) => setState(() => _filterStatus = v),
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: null, child: Text('Todos')),
              const PopupMenuItem(
                  value: ProfileStatus.available,
                  child: Text('Disponibles')),
              const PopupMenuItem(
                  value: ProfileStatus.sold, child: Text('Vendidos')),
              const PopupMenuItem(
                  value: ProfileStatus.reserved,
                  child: Text('Reservados')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<ProfileModel>>(
        stream: firestore.profilesStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var profiles = snap.data ?? [];
          if (_filterStatus != null) {
            profiles = profiles
                .where((p) => p.status == _filterStatus)
                .toList();
          }

          if (profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No hay perfiles',
                      style: theme.textTheme.titleMedium),
                  const Text('Agregá perfiles desde una cuenta'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profiles.length,
            itemBuilder: (ctx, i) {
              final p = profiles[i];
              final color = p.status == ProfileStatus.sold
                  ? Colors.blue
                  : p.status == ProfileStatus.reserved
                      ? Colors.orange
                      : Colors.green;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.15),
                    child: Text(
                      p.profileName.isNotEmpty
                          ? p.profileName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    '${p.platformName} — ${p.profileName}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.status.displayName,
                          style: TextStyle(color: color)),
                      if (p.clientName.isNotEmpty)
                        Text('Cliente: ${p.clientName}',
                            style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12)),
                      if (p.expirationDate != null)
                        Text('Vence: ${fmt.format(p.expirationDate!)}',
                            style: TextStyle(
                                color: p.isExpiringSoon
                                    ? Colors.orange
                                    : theme.colorScheme.onSurfaceVariant,
                                fontSize: 12)),
                    ],
                  ),
                  trailing: p.expirationDate != null
                      ? Text(
                          p.isExpired
                              ? 'VENCIDO'
                              : '${p.daysUntilExpiration}d',
                          style: TextStyle(
                            color: p.isExpired
                                ? Colors.red
                                : p.isExpiringSoon
                                    ? Colors.orange
                                    : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
