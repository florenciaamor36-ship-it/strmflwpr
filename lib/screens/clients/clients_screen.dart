import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/client_service.dart';
import '../../models/client_model.dart';
import '../../widgets/client_card.dart';
import '../../widgets/confirmation_dialog.dart';
import 'client_form_screen.dart';
import 'client_detail_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final ClientService _clientService = ClientService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().userId ?? '';
    final settings = context.read<SettingsProvider>();
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ClientModel>>(
              stream: service.clientsStream(userId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final all = snap.data ?? [];
                final filtered =
                    _clientService.search(all, _searchQuery);

                if (all.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_outline,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No hay clientes',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text(
                            'Los clientes se crean al agregar una venta',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: const Text('Agregar cliente'),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    ClientFormScreen(userId: userId)),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return const Center(
                      child: Text('Sin resultados para esa búsqueda'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final client = filtered[index];
                    return ClientCard(
                      client: client,
                      currencySymbol: settings.currencySymbol,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => ClientDetailScreen(
                                clientId: client.id, userId: userId)),
                      ),
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => ConfirmationDialog(
                            title: 'Eliminar cliente',
                            message:
                                '¿Eliminar a "${client.name}"? No se eliminarán sus ventas.',
                            confirmLabel: 'Eliminar',
                            isDestructive: true,
                          ),
                        );
                        if (confirm == true) {
                          await service.deleteClient(client.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => ClientFormScreen(userId: userId)),
        ),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
