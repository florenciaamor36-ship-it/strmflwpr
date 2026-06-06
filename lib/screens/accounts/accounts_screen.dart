import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/account_model.dart';
import '../../widgets/account_card.dart';
import '../../widgets/confirmation_dialog.dart';
import 'account_form_screen.dart';
import 'account_detail_screen.dart';

class AccountsScreen extends StatelessWidget {
  final String userId;
  const AccountsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Cuentas')),
      body: StreamBuilder<List<AccountModel>>(
        stream: service.accountsStream(userId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final accounts = snap.data ?? [];
          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.manage_accounts,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No hay cuentas',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Agregá tu primera cuenta de streaming',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar cuenta'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) =>
                              AccountFormScreen(userId: userId)),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return StreamBuilder(
                stream: service.profilesByAccountStream(userId, account.id),
                builder: (context, profileSnap) {
                  final profiles = profileSnap.data ?? [];
                  final sold = profiles
                      .where((p) => p.status.name == 'sold')
                      .length;
                  final available = profiles
                      .where((p) => p.status.name == 'available')
                      .length;
                  account.totalProfiles = profiles.length;
                  account.soldProfiles = sold;
                  account.availableProfiles = available;

                  return AccountCard(
                    account: account,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => AccountDetailScreen(
                              account: account, userId: userId)),
                    ),
                    onEdit: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => AccountFormScreen(
                              userId: userId, account: account)),
                    ),
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => ConfirmationDialog(
                          title: 'Eliminar cuenta',
                          message:
                              '¿Eliminar la cuenta "${account.maskedEmail}"? Se eliminarán todos sus perfiles.',
                          confirmLabel: 'Eliminar',
                          isDestructive: true,
                        ),
                      );
                      if (confirm == true) {
                        await service.deleteAccount(account.id);
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => AccountFormScreen(userId: userId)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
