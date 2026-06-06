import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';
import '../../services/whatsapp_service.dart';
import '../../models/profile_model.dart';
import '../platforms/platforms_screen.dart';
import '../accounts/accounts_screen.dart';
import '../sales/sales_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardTab(),
    PlatformsScreen(),
    AccountsScreen(),
    SalesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Plataformas',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts),
            label: 'Cuentas',
          ),
          NavigationDestination(
            icon: Icon(Icons.sell_outlined),
            selectedIcon: Icon(Icons.sell),
            label: 'Ventas',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Config',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUserId ?? '';
    final firestore = FirestoreService(userId: uid);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📺 strmflwpr'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Row
              FutureBuilder<Map<String, int>>(
                future: firestore.getDashboardStats(),
                builder: (context, snap) {
                  final stats = snap.data ?? {};
                  return Row(
                    children: [
                      _StatCard(
                        label: 'Cuentas',
                        value: '${stats['totalAccounts'] ?? 0}',
                        icon: Icons.manage_accounts,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Ventas activas',
                        value: '${stats['activeSales'] ?? 0}',
                        icon: Icons.sell,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Vencen pronto',
                        value: '${stats['expiringSoon'] ?? 0}',
                        icon: Icons.warning_amber,
                        color: Colors.orange,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // Expiring Soon
              Text(
                '⏰ Vencen en 7 días',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<ProfileModel>>(
                stream: firestore.expiringSoonProfilesStream(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final profiles = snap.data ?? [];
                  if (profiles.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.green),
                            const SizedBox(width: 12),
                            Text('No hay vencimientos próximos'),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: profiles.map((p) {
                      return _ExpiringProfileCard(profile: p);
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpiringProfileCard extends StatelessWidget {
  final ProfileModel profile;

  const _ExpiringProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = profile.daysUntilExpiration;
    final color = days <= 1
        ? Colors.red
        : days <= 3
            ? Colors.orange
            : Colors.amber;
    final fmt = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Text(
            days == 0 ? '!' : '$days',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${profile.platformName} — ${profile.profileName}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          profile.clientName.isNotEmpty
              ? '${profile.clientName} • Vence: ${fmt.format(profile.expirationDate!)}'
              : 'Vence: ${fmt.format(profile.expirationDate!)}',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: profile.clientPhone.isNotEmpty
            ? IconButton(
                icon: const Text('💬', style: TextStyle(fontSize: 22)),
                onPressed: () async {
                  final wa = WhatsAppService();
                  final msg = wa.generateReminderMessage(
                    platformName: profile.platformName,
                    profileName: profile.profileName,
                    clientName: profile.clientName,
                    clientPhone: profile.clientPhone,
                    expirationDate: profile.expirationDate!,
                    daysRemaining: days,
                  );
                  await wa.sendWhatsAppMessage(
                      phone: profile.clientPhone, message: msg);
                },
              )
            : null,
      ),
    );
  }
}
