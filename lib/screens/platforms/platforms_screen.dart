import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/platform_model.dart';
import '../../widgets/platform_card.dart';
import '../../widgets/confirmation_dialog.dart';
import 'platform_form_screen.dart';
import 'platform_detail_screen.dart';

class PlatformsScreen extends StatelessWidget {
  final String userId;
  const PlatformsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Plataformas')),
      body: StreamBuilder<List<PlatformModel>>(
        stream: service.platformsStream(userId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final platforms = snap.data ?? [];
          if (platforms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.tv_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No hay plataformas',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Agregá tu primera plataforma',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar plataforma'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) =>
                              PlatformFormScreen(userId: userId)),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: platforms.length,
            itemBuilder: (context, index) {
              final platform = platforms[index];
              return PlatformCard(
                platform: platform,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => PlatformDetailScreen(
                          platform: platform, userId: userId)),
                ),
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => PlatformFormScreen(
                          userId: userId, platform: platform)),
                ),
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                      title: 'Eliminar plataforma',
                      message:
                          '¿Eliminar "${platform.name}"? Esta acción no se puede deshacer.',
                      confirmLabel: 'Eliminar',
                      isDestructive: true,
                    ),
                  );
                  if (confirm == true) {
                    await service.deletePlatform(platform.id);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => PlatformFormScreen(userId: userId)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
