import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/profile_model.dart';
import '../../widgets/profile_card.dart';
import '../../widgets/confirmation_dialog.dart';
import '../accounts/account_form_screen.dart';
import 'profile_form_screen.dart';

class ProfilesScreen extends StatelessWidget {
  final String userId;
  const ProfilesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfiles')),
      body: StreamBuilder<List<ProfileModel>>(
        stream: service.profilesStream(userId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final profiles = snap.data ?? [];
          if (profiles.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay perfiles',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('Los perfiles se crean desde las cuentas',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return ProfileCard(
                profile: profile,
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                      title: 'Eliminar perfil',
                      message: '¿Eliminar "${profile.name}"?',
                      confirmLabel: 'Eliminar',
                      isDestructive: true,
                    ),
                  );
                  if (confirm == true) {
                    await service.deleteProfile(profile.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
