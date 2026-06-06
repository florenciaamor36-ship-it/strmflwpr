import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/profile_model.dart';
import '../../models/account_model.dart';

class ProfileFormScreen extends StatefulWidget {
  final String userId;
  final AccountModel account;
  final ProfileModel? profile;

  const ProfileFormScreen({
    super.key,
    required this.userId,
    required this.account,
    this.profile,
  });

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final FirestoreService _service = FirestoreService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    if (p != null) {
      _nameController.text = p.name;
      _pinController.text = p.pin;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final profile = ProfileModel(
        id: widget.profile?.id ?? '',
        userId: widget.userId,
        accountId: widget.account.id,
        platformId: widget.account.platformId,
        platformName: widget.account.platformName,
        name: _nameController.text.trim(),
        pin: _pinController.text.trim(),
        status: widget.profile?.status ?? ProfileStatus.available,
        currentSaleId: widget.profile?.currentSaleId,
        currentClientName: widget.profile?.currentClientName,
        createdAt: widget.profile?.createdAt ?? DateTime.now(),
      );

      if (widget.profile != null) {
        await _service.updateProfile(profile);
      } else {
        await _service.addProfile(profile);
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
    final isEdit = widget.profile != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar perfil' : 'Nuevo perfil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Account info
            Card(
              child: ListTile(
                leading: const Icon(Icons.tv_outlined),
                title: Text(widget.account.platformName),
                subtitle: Text(widget.account.maskedEmail),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del perfil',
                hintText: 'ej: Perfil 1, Mi Perfil, Familiar',
                prefixIcon: Icon(Icons.person_outlined),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'El nombre es requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'PIN (opcional)',
                hintText: 'ej: 1234',
                prefixIcon: Icon(Icons.pin_outlined),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEdit ? 'Guardar cambios' : 'Crear perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
