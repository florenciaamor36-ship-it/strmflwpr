import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/account_model.dart';
import '../../models/platform_model.dart';
import '../../models/profile_model.dart';
import '../../services/firestore_service.dart';
import '../profiles/profile_form_screen.dart';
import 'account_form_screen.dart';

class AccountDetailScreen extends StatelessWidget {
  final AccountModel account;
  final PlatformModel platform;
  final FirestoreService firestore;

  const AccountDetailScreen({
    super.key,
    required this.account,
    required this.platform,
    required this.firestore,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copiado'), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('dd/MM/yyyy');
    final platformColor =
        Color(int.parse(platform.color.replaceFirst('#', '0xFF')));

    return Scaffold(
      appBar: AppBar(
        title: Text('${platform.iconEmoji} ${account.email}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AccountFormScreen(
                  platform: platform,
                  firestore: firestore,
                  existingAccount: account,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Eliminar cuenta'),
                  content:
                      const Text('¿Eliminar esta cuenta y todos sus perfiles?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar')),
                  ],
                ),
              );
              if (confirm == true) {
                await firestore.deleteAccount(account.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Account info card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: platformColor.withOpacity(0.15),
                        radius: 24,
                        child: Text(platform.iconEmoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(platform.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold)),
                          Text(
                            account.isExpired
                                ? '⚠️ Expirada'
                                : account.daysUntilExpiration <= 7
                                    ? '⏰ Vence en ${account.daysUntilExpiration} días'
                                    : '✅ Activa',
                            style: TextStyle(
                              color: account.isExpired
                                  ? Colors.red
                                  : account.daysUntilExpiration <= 7
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    label: 'Email',
                    value: account.email,
                    onCopy: () =>
                        _copyToClipboard(context, account.email, 'Email'),
                  ),
                  _InfoRow(
                    label: 'Contraseña',
                    value: account.password,
                    isPassword: true,
                    onCopy: () => _copyToClipboard(
                        context, account.password, 'Contraseña'),
                  ),
                  _InfoRow(
                      label: 'Compra',
                      value: fmt.format(account.purchaseDate)),
                  _InfoRow(
                      label: 'Vencimiento',
                      value: fmt.format(account.expirationDate)),
                  _InfoRow(
                      label: 'Perfiles',
                      value: '${account.totalProfiles} perfiles'),
                  if (account.notes.isNotEmpty)
                    _InfoRow(label: 'Notas', value: account.notes),
                ],
              ),
            ),
          ),
          // Profiles header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Perfiles',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Profiles list
          Expanded(
            child: StreamBuilder<List<ProfileModel>>(
              stream: firestore.profilesByAccountStream(account.id),
              builder: (context, snap) {
                final profiles = snap.data ?? [];

                if (profiles.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay perfiles. Agregá con el botón +',
                      style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: profiles.length,
                  itemBuilder: (ctx, i) {
                    final p = profiles[i];
                    return _ProfileListTile(
                      profile: p,
                      firestore: firestore,
                      account: account,
                      platform: platform,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileFormScreen(
              account: account,
              platform: platform,
              firestore: firestore,
            ),
          ),
        ),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Agregar perfil'),
      ),
    );
  }
}

class _InfoRow extends StatefulWidget {
  final String label;
  final String value;
  final bool isPassword;
  final VoidCallback? onCopy;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isPassword = false,
    this.onCopy,
  });

  @override
  State<_InfoRow> createState() => _InfoRowState();
}

class _InfoRowState extends State<_InfoRow> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              widget.label,
              style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              widget.isPassword && !_show
                  ? '••••••••'
                  : widget.value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (widget.isPassword)
            GestureDetector(
              onTap: () => setState(() => _show = !_show),
              child: Icon(
                _show ? Icons.visibility_off : Icons.visibility,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (widget.onCopy != null)
            GestureDetector(
              onTap: widget.onCopy,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.copy, size: 16,
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileListTile extends StatelessWidget {
  final ProfileModel profile;
  final FirestoreService firestore;
  final AccountModel account;
  final PlatformModel platform;

  const _ProfileListTile({
    required this.profile,
    required this.firestore,
    required this.account,
    required this.platform,
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(profile.status).withOpacity(0.15),
          child: Text(
            profile.profileName.isNotEmpty
                ? profile.profileName[0].toUpperCase()
                : '?',
            style: TextStyle(
                color: _statusColor(profile.status),
                fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(profile.profileName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(profile.status.displayName,
            style: TextStyle(color: _statusColor(profile.status))),
        trailing: Chip(
          label: Text(profile.status.displayName,
              style: const TextStyle(fontSize: 11)),
          backgroundColor: _statusColor(profile.status).withOpacity(0.15),
          padding: EdgeInsets.zero,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileFormScreen(
              account: account,
              platform: platform,
              firestore: firestore,
              existingProfile: profile,
            ),
          ),
        ),
      ),
    );
  }
}
