import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/account_model.dart';
import '../../models/platform_model.dart';

class AccountFormScreen extends StatefulWidget {
  final String userId;
  final String? platformId;
  final String? platformName;
  final AccountModel? account;

  const AccountFormScreen({
    super.key,
    required this.userId,
    this.platformId,
    this.platformName,
    this.account,
  });

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _costController = TextEditingController();
  final FirestoreService _service = FirestoreService();

  PlatformModel? _selectedPlatform;
  List<PlatformModel> _platforms = [];
  bool _isLoading = false;
  bool _obscurePassword = true;
  DateTime? _accountExpiration;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    if (a != null) {
      _emailController.text = a.email;
      _passwordController.text = a.password;
      _costController.text = a.purchaseCost.toStringAsFixed(0);
      _accountExpiration = a.accountExpiration;
    }
    _loadPlatforms();
  }

  Future<void> _loadPlatforms() async {
    _service.platformsStream(widget.userId).listen((platforms) {
      if (mounted) {
        setState(() {
          _platforms = platforms;
          if (widget.platformId != null && _selectedPlatform == null) {
            try {
              _selectedPlatform = platforms
                  .firstWhere((p) => p.id == widget.platformId);
            } catch (_) {}
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _accountExpiration ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
    );
    if (date != null) setState(() => _accountExpiration = date);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlatform == null && widget.account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná una plataforma')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final platform = _selectedPlatform ??
          PlatformModel(
            id: widget.account?.platformId ?? '',
            userId: widget.userId,
            name: widget.account?.platformName ?? '',
            emoji: '📺',
            color: '#6C63FF',
            maxProfiles: 5,
            defaultPrice: 0,
            isActive: true,
            createdAt: DateTime.now(),
          );

      final account = AccountModel(
        id: widget.account?.id ?? '',
        userId: widget.userId,
        platformId: platform.id,
        platformName: platform.name,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        accountExpiration: _accountExpiration,
        purchaseCost:
            double.tryParse(_costController.text.replaceAll(',', '.')) ?? 0,
        isActive: true,
        createdAt: widget.account?.createdAt ?? DateTime.now(),
      );

      if (widget.account != null) {
        await _service.updateAccount(account);
      } else {
        await _service.addAccount(account);
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
    final isEdit = widget.account != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar cuenta' : 'Nueva cuenta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (!isEdit) ...[
              DropdownButtonFormField<PlatformModel>(
                value: _selectedPlatform,
                decoration: const InputDecoration(
                    labelText: 'Plataforma',
                    prefixIcon: Icon(Icons.tv_outlined)),
                items: _platforms
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Row(
                            children: [
                              Text(p.emoji),
                              const SizedBox(width: 8),
                              Text(p.name),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (p) => setState(() => _selectedPlatform = p),
                validator: (v) =>
                    v == null ? 'Seleccioná una plataforma' : null,
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email de la cuenta',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'El email es requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'La contraseña es requerida' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Costo de compra',
                prefixIcon: Icon(Icons.shopping_cart_outlined),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(_accountExpiration == null
                  ? 'Vencimiento de cuenta (opcional)'
                  : 'Vence: ${_accountExpiration!.day}/${_accountExpiration!.month}/${_accountExpiration!.year}'),
              trailing: _accountExpiration != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () =>
                          setState(() => _accountExpiration = null),
                    )
                  : null,
              onTap: _pickDate,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEdit ? 'Guardar cambios' : 'Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
