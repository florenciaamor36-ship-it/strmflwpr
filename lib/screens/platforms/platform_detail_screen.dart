import 'package:flutter/material.dart';
import '../../models/platform_model.dart';
import '../../services/firestore_service.dart';
import '../../models/account_model.dart';
import '../../widgets/account_card.dart';
import '../accounts/account_form_screen.dart';
import '../accounts/account_detail_screen.dart';

class PlatformDetailScreen extends StatelessWidget {
  final PlatformModel platform;
  final String userId;

  const PlatformDetailScreen(
      {super.key, required this.platform, required this.userId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(platform.name)),
      body: StreamBuilder<List<AccountModel>>(
        stream: service.accountsByPlatformStream(userId, platform.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final accounts = snap.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Platform info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(platform.emoji,
                          style: const TextStyle(fontSize: 48)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(platform.name,
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            Text(
                                '${accounts.length} cuenta(s) · max ${platform.maxProfiles} perfiles',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Cuentas',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (accounts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No hay cuentas para esta plataforma'),
                  ),
                )
              else
                ...accounts.map((account) => StreamBuilder(
                      stream: service.profilesByAccountStream(
                          userId, account.id),
                      builder: (context, profileSnap) {
                        final profiles = profileSnap.data ?? [];
                        final sold = profiles
                            .where((p) =>
                                p.status.name == 'sold')
                            .length;
                        final available = profiles
                            .where((p) =>
                                p.status.name == 'available')
                            .length;
                        account.totalProfiles = profiles.length;
                        account.soldProfiles = sold;
                        account.availableProfiles = available;
                        return AccountCard(
                          account: account,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => AccountDetailScreen(
                                    account: account,
                                    userId: userId)),
                          ),
                        );
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
                  AccountFormScreen(userId: userId, platformId: platform.id, platformName: platform.name)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
