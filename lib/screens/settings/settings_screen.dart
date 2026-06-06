import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _defaultReminderDays = '7,3,1';
  bool _darkMode = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _defaultReminderDays =
          prefs.getString('default_reminder_days') ?? '7,3,1';
      _darkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_reminder_days', _defaultReminderDays);
    await prefs.setBool('dark_mode', _darkMode);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = auth.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // User info section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'CUENTA',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.5),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(Icons.person,
                    color: theme.colorScheme.onPrimaryContainer),
              ),
              title: Text(
                user?.email ?? 'Usuario',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(user?.uid?.substring(0, 8) ?? '' + '...'),
            ),
          ),
          const SizedBox(height: 16),
          // Reminders section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              'RECORDATORIOS',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.5),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Días de recordatorio por defecto',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Se aplica a nuevos perfiles vendidos',
                    style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: _defaultReminderDays,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '7,3,1',
                      helperText:
                          'Separados por coma: notificar 7, 3 y 1 día antes',
                    ),
                    onChanged: (v) {
                      _defaultReminderDays = v;
                      _savePrefs();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // App section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              'APLICACIÓN',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.5),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Modo oscuro'),
                  subtitle: const Text('Seguir configuración del sistema'),
                  trailing: Switch(
                    value: _darkMode,
                    onChanged: (v) {
                      setState(() => _darkMode = v);
                      _savePrefs();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // About section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              'ACERCA DE',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.5),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('strmflwpr'),
                  subtitle: const Text('v1.0.0 — Gestor de cuentas streaming'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.code_outlined),
                  title: const Text('Código fuente'),
                  subtitle: const Text('github.com/florenciaamor36-ship-it/strmflwpr'),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Sign out
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text('¿Estás seguro que querés cerrar sesión?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Cerrar sesión')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await auth.signOut();
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
