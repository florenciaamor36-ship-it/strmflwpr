import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/account_model.dart';
import '../../models/platform_model.dart';
import 'account_form_screen.dart';
import 'account_detail_screen.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUserId ?? '';
    final firestore = FirestoreService(userId: uid);
    final fmt = DateFormat('dd/MM/yyyy');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuentas'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por email o plataforma...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<AccountModel>>(
        stream: firestore.accountsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var accounts = snap.data ?? [];
          if (_searchQuery.isNotEmpty) {
            accounts = accounts.where((a) {
              return a.email.toLowerCase().contains(_searchQuery) ||
                  a.platformName.toLowerCase().contains(_searchQuery);
            }).toList();
          }

          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.manage_accounts_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'No se encontraron cuentas'
                        : 'No hay cuentas registradas',
                    style: theme.textTheme.titleMedium,
                  ),
                  if (_searchQuery.isEmpty)
                    const Text('Agregá una cuenta desde Plataformas'),
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
              final platform = PlatformModel.defaultPlatforms
                  .where((p) => p.id == acc.platformId)
                  .firstOrNull;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: platform != null
                        ? Color(int.parse(
                                platform.color.replaceFirst('#', '0xFF')))
                            .withOpacity(0.15)
                        : theme.colorScheme.primaryContainer,
                    child: Text(
                      platform?.iconEmoji ?? '📺',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    '${acc.platformName} — ${acc.email}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vence: ${fmt.format(acc.expirationDate)}'),
                      Text(
                        expired
                            ? '⚠️ Expirada'
                            : days <= 7
                                ? '⏰ Vence en $days días'
                                : '${acc.totalProfiles} perfiles disponibles',
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
                  onTap: () {
                    final plt = platform ??
                        PlatformModel(
                          id: acc.platformId,
                          name: acc.platformName,
                          iconEmoji: '📺',
                          color: '#6750A4',
                          defaultProfileCount: acc.totalProfiles,
                          isCustom: true,
                          createdAt: DateTime.now(),
                        );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AccountDetailScreen(
                          account: acc,
                          platform: plt,
                          firestore: firestore,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
