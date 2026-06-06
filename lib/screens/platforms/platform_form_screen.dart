import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/platform_model.dart';

class PlatformFormScreen extends StatefulWidget {
  final String userId;
  final PlatformModel? platform; // null = create, non-null = edit

  const PlatformFormScreen({super.key, required this.userId, this.platform});

  @override
  State<PlatformFormScreen> createState() => _PlatformFormScreenState();
}

class _PlatformFormScreenState extends State<PlatformFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxProfilesController = TextEditingController();
  final FirestoreService _service = FirestoreService();
  bool _isLoading = false;

  static const List<String> _emojiOptions = [
    '📺', '🎬', '🎵', '🎮', '📰', '📚', '🏋️', '🎭', '🌐', '⚽',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.platform;
    if (p != null) {
      _nameController.text = p.name;
      _emojiController.text = p.emoji;
      _priceController.text = p.defaultPrice.toStringAsFixed(0);
      _maxProfilesController.text = p.maxProfiles.toString();
    } else {
      _emojiController.text = '📺';
      _maxProfilesController.text = '5';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _priceController.dispose();
    _maxProfilesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final platform = PlatformModel(
        id: widget.platform?.id ?? '',
        userId: widget.userId,
        name: _nameController.text.trim(),
        emoji: _emojiController.text.trim(),
        color: '#6C63FF',
        maxProfiles: int.tryParse(_maxProfilesController.text) ?? 5,
        defaultPrice:
            double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0,
        isActive: true,
        createdAt: widget.platform?.createdAt ?? DateTime.now(),
      );

      if (widget.platform != null) {
        await _service.updatePlatform(platform);
      } else {
        await _service.addPlatform(platform);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.platform != null;

    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? 'Editar plataforma' : 'Nueva plataforma')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Emoji selector
            Text('Emoji', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _emojiOptions
                  .map((e) => GestureDetector(
                        onTap: () =>
                            setState(() => _emojiController.text = e),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _emojiController.text == e
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(e,
                              style: const TextStyle(fontSize: 28)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la plataforma',
                hintText: 'ej: Netflix, Disney+, Spotify',
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'El nombre es requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxProfilesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Máximo de perfiles por cuenta',
                prefixIcon: Icon(Icons.people_outline),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if (int.tryParse(v) == null) return 'Número inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Precio por defecto',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEdit ? 'Guardar cambios' : 'Crear plataforma'),
            ),
          ],
        ),
      ),
    );
  }
}
