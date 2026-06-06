import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/platform_model.dart';
import '../../models/account_model.dart';
import '../../services/firestore_service.dart';
import '../accounts/account_form_screen.dart';
import '../accounts/account_detail_screen.dart';

class PlatformDetailScreen extends StatelessWidget {
  final PlatformModel platform;
  final FirestoreService firestore;

  const PlatformDetailScreen({
    super.key,
    required this.platform,
    required this.firestore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final platformColor =
        Color(int.parse(platform.color.replaceFirst('#', '0xFF')));
    final fmt = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('${platform.iconEmoji} ${platform.name}'),
        centerTitle: true,
        backgroundColor: platformColor.withOpacity(0.1),
      ),
      body: StreamBuilder<List<AccountModel>>(
        stream: firestore.accountsByPlatformStream(platform.id),
        builder: (context, snap) {
          final accounts = snap.data ?? [];

          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(platform.iconEmoji,
                      style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    'No hay cuentas de ${platform.name}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agregá tu primera cuenta con el botón +',
                    style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            itemBuilder: (ctx, i) {
              final acc = accounts[i];
              final expired = acc.isExpired;
              final days = acc.daysUntilExpiration;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: platformColor.withOpacity(0.15),
                    child: Text(
                      platform.iconEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    acc.email,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Vence: ${fmt.format(acc.expirationDate)}'),
                      Text(
                        expired
                            ? '⚠️ Expirada'
                            : days <= 7
                                ? '⏰ Vence en $days días'
                                : '✅ ${acc.totalProfiles} perfiles',
                        style: TextStyle(
                          color: expired
                              ? Colors.red
                              : days <= 7
                                  ? Colors.orange
                                  : Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountDetailScreen(
                        account: acc,
                        platform: platform,
                        firestore: firestore,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AccountFormScreen(
              platform: platform,
              firestore: firestore,
            ),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Agregar cuenta'),
      ),
    );
  }
}
