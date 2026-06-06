import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/export_service.dart';
import '../../models/sale_model.dart';
import '../platforms/platforms_screen.dart';
import '../accounts/accounts_screen.dart';
import '../profiles/profiles_screen.dart';
import 'template_editor_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final settings = context.watch<SettingsProvider>();
    final userId = auth.userId ?? '';
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          // Profile section
          _SectionHeader('Mi cuenta'),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                auth.user?.displayName?.isNotEmpty == true
                    ? auth.user!.displayName![0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(auth.user?.displayName ?? 'Usuario'),
            subtitle: Text(auth.user?.email ?? ''),
          ),

          // Business name
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text('Nombre del negocio'),
            subtitle: Text(settings.businessName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editTextField(
              context,
              title: 'Nombre del negocio',
              initialValue: settings.businessName,
              onSave: (v) => settings.setBusinessName(v),
            ),
          ),

          // Divider
          const Divider(),
          _SectionHeader('Gestión'),

          ListTile(
            leading: const Icon(Icons.tv_outlined),
            title: const Text('Plataformas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => PlatformsScreen(userId: userId)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined),
            title: const Text('Cuentas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => AccountsScreen(userId: userId)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Perfiles'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => ProfilesScreen(userId: userId)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.message_outlined),
            title: const Text('Plantillas de WhatsApp'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => TemplateEditorScreen(userId: userId)),
            ),
          ),

          const Divider(),
          _SectionHeader('Preferencias'),

          // Country code
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Código de país por defecto'),
            subtitle: Text('+${settings.defaultCountryCode}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _editTextField(
              context,
              title: 'Código de país',
              initialValue: settings.defaultCountryCode,
              hintText: 'ej: 54',
              onSave: (v) => settings.setCountryCode(v),
              keyboardType: TextInputType.number,
            ),
          ),

          // Currency
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Símbolo de moneda'),
            subtitle: Text(settings.currencySymbol),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCurrencyPicker(context, settings),
          ),

          // Reminder days
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Días de recordatorio'),
            subtitle: Text(settings.defaultReminderDays.join(', ') + ' días'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showReminderDaysPicker(context, settings),
          ),

          // Theme
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Tema'),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.themeMode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                    value: ThemeMode.system, child: Text('Sistema')),
                DropdownMenuItem(
                    value: ThemeMode.light, child: Text('Claro')),
                DropdownMenuItem(
                    value: ThemeMode.dark, child: Text('Oscuro')),
              ],
              onChanged: (mode) {
                if (mode != null) themeProvider.setThemeMode(mode);
              },
            ),
          ),

          const Divider(),
          _SectionHeader('Exportar'),

          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Exportar ventas a CSV'),
            onTap: () async {
              try {
                final stream = service.salesStream(userId);
                final sales = await stream.first;
                final path =
                    await ExportService.exportSalesToCsv(sales);
                await ExportService.shareFile(path);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al exportar: $e')),
                  );
                }
              }
            },
          ),

          const Divider(),
          _SectionHeader('Cuenta'),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content:
                      const Text('¿Seguro que querés cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Salir',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await auth.signOut();
              }
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: Text('strmflwpr v2.0.0',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _editTextField(
    BuildContext context, {
    required String title,
    required String initialValue,
    required Function(String) onSave,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final controller = TextEditingController(text: initialValue);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hintText),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) onSave(value);
              Navigator.of(ctx).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  void _showCurrencyPicker(BuildContext context, SettingsProvider settings) {
    const currencies = ['ARS', 'USD', 'EUR', 'BRL', 'CLP', 'COP', 'MXN'];
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Moneda'),
        children: currencies
            .map((c) => SimpleDialogOption(
                  onPressed: () {
                    settings.setCurrencySymbol(c);
                    Navigator.of(context).pop();
                  },
                  child: Text(c,
                      style: TextStyle(
                          fontWeight: c == settings.currencySymbol
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ))
            .toList(),
      ),
    );
  }

  void _showReminderDaysPicker(
      BuildContext context, SettingsProvider settings) {
    final selected = List<int>.from(settings.defaultReminderDays);
    const options = [1, 2, 3, 5, 7, 10, 14, 30];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Días de recordatorio'),
          content: Wrap(
            spacing: 8,
            children: options
                .map((day) => FilterChip(
                      label: Text('$day día${day > 1 ? "s" : ""}'),
                      selected: selected.contains(day),
                      onSelected: (v) {
                        setStateDialog(() {
                          if (v) {
                            selected.add(day);
                          } else {
                            selected.remove(day);
                          }
                          selected.sort();
                        });
                      },
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                settings.setReminderDays(selected);
                Navigator.of(ctx).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
