import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/platform_model.dart';
import '../../widgets/platform_card.dart';
import 'platform_detail_screen.dart';

class PlatformsScreen extends StatefulWidget {
  const PlatformsScreen({super.key});

  @override
  State<PlatformsScreen> createState() => _PlatformsScreenState();
}

class _PlatformsScreenState extends State<PlatformsScreen> {
  bool _showAddDialog = false;
  final _nameCtrl = TextEditingController();
  final _emojiCtrl = TextEditingController();
  String _selectedColor = '#6750A4';
  int _profileCount = 5;

  final List<String> _colorOptions = [
    '#E50914', '#113CCF', '#5822B4', '#00A8E1',
    '#1DB954', '#FF0000', '#0064FF', '#1C1C1E',
    '#FF6B00', '#F47521', '#7D2AE8', '#0078D4',
    '#6750A4', '#FF5722', '#4CAF50', '#FF9800',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emojiCtrl.dispose();
    super.dispose();
  }

  void _showAddPlatformDialog(FirestoreService firestore) {
    _nameCtrl.clear();
    _emojiCtrl.text = '📺';
    _selectedColor = '#6750A4';
    _profileCount = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nueva plataforma'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emojiCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Emoji',
                    border: OutlineInputBorder(),
                    hintText: '📺',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Perfiles por defecto: '),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (_profileCount > 1) {
                          setDialogState(() => _profileCount--);
                        }
                      },
                    ),
                    Text('$_profileCount'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () =>
                          setDialogState(() => _profileCount++),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Color:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorOptions.map((c) {
                    final color = Color(
                        int.parse(c.replaceFirst('#', '0xFF')));
                    return GestureDetector(
                      onTap: () => setDialogState(() => _selectedColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _selectedColor == c
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (_nameCtrl.text.trim().isEmpty) return;
                final platform = PlatformModel(
                  id: '',
                  name: _nameCtrl.text.trim(),
                  iconEmoji: _emojiCtrl.text.trim().isEmpty
                      ? '📺'
                      : _emojiCtrl.text.trim(),
                  color: _selectedColor,
                  defaultProfileCount: _profileCount,
                  isCustom: true,
                  createdAt: DateTime.now(),
                );
                await firestore.addPlatform(platform);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final uid = auth.currentUserId ?? '';
    final firestore = FirestoreService(userId: uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plataformas'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Default platforms header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            alignment: Alignment.centerLeft,
            child: Text(
              'Plataformas disponibles',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PlatformModel>>(
              stream: firestore.platformsStream(),
              builder: (context, snap) {
                final customPlatforms = snap.data ?? [];

                // Combine default + custom
                final allPlatforms = [
                  ...PlatformModel.defaultPlatforms,
                  ...customPlatforms,
                ];

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: allPlatforms.length,
                  itemBuilder: (ctx, i) {
                    final platform = allPlatforms[i];
                    return PlatformCard(
                      platform: platform,
                      firestore: firestore,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlatformDetailScreen(
                            platform: platform,
                            firestore: firestore,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlatformDialog(firestore),
        icon: const Icon(Icons.add),
        label: const Text('Plataforma'),
      ),
    );
  }
}
