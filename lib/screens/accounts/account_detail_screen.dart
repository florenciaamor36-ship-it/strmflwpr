import 'package:flutter/material.dart';
import '../../models/account_model.dart';
import '../../models/profile_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/profile_card.dart';
import '../../widgets/confirmation_dialog.dart';
import '../profiles/profile_form_screen.dart';

class AccountDetailScreen extends StatelessWidget {
  final AccountModel account;
  final String userId;

  const AccountDetailScreen(
      {super.key, required this.account, required this.userId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(account.maskedEmail),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar perfil',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => ProfileFormScreen(
                      userId: userId, account: account)),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<ProfileModel>>(
        stream: service.profilesByAccountStream(userId, account.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final profiles = snap.data ?? [];
          final available =
              profiles.where((p) => p.isAvailable).length;
          final sold = profiles.where((p) => p.isSold).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Account summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Chip(
                            label: Text(account.platformName),
                            avatar: const Icon(Icons.tv, size: 16),
                          ),
                          const Spacer(),
                          if (account.accountExpiration != null)
                            Chip(
                              label: Text(
                                  'Vence: ${account.accountExpiration!.day}/${account.accountExpiration!.month}/${account.accountExpiration!.year}'),
                              avatar: const Icon(Icons.calendar_today, size: 16),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(account.email,
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StatChip(
                              label: '$sold vendidos', color: Colors.orange),
                          const SizedBox(width: 8),
                          _StatChip(
                              label: '$available disponibles',
                              color: Colors.green),
                          const SizedBox(width: 8),
                          _StatChip(
                              label: '${profiles.length} total',
                              color: Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Perfiles',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (profiles.isEmpty)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No hay perfiles. Agregá uno.')))
              else
                ...profiles.map((profile) => ProfileCard(
                      profile: profile,
                      onEdit: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => ProfileFormScreen(
                                userId: userId,
                                account: account,
                                profile: profile)),
                      ),
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => ConfirmationDialog(
                            title: 'Eliminar perfil',
                            message:
                                '¿Eliminar "${profile.name}"?',
                            confirmLabel: 'Eliminar',
                            isDestructive: true,
                          ),
                        );
                        if (confirm == true) {
                          await service.deleteProfile(profile.id);
                        }
                      },
                    )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) =>
                  ProfileFormScreen(userId: userId, account: account)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
