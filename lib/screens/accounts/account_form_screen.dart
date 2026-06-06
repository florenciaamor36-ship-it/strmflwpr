import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/platform_model.dart';
import '../../models/account_model.dart';
import '../../services/firestore_service.dart';

class AccountFormScreen extends StatefulWidget {
  final PlatformModel platform;
  final FirestoreService firestore;
  final AccountModel? existingAccount;

  const AccountFormScreen({
    super.key,
    required this.platform,
    required this.firestore,
    this.existingAccount,
  });

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _purchaseDate = DateTime.now();
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 30));
  int _totalProfiles = 5;
  bool _loading = false;
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    _totalProfiles = widget.platform.defaultProfileCount;
    if (widget.existingAccount != null) {
      final a = widget.existingAccount!;
      _emailCtrl.text = a.email;
      _passCtrl.text = a.password;
      _notesCtrl.text = a.notes;
      _purchaseDate = a.purchaseDate;
      _expirationDate = a.expirationDate;
      _totalProfiles = a.totalProfiles;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isPurchase}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isPurchase ? _purchaseDate : _expirationDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isPurchase) {
          _purchaseDate = picked;
        } else {
          _expirationDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final account = AccountModel(
        id: widget.existingAccount?.id ?? '',
        userId: widget.firestore.userId,
        platformId: widget.platform.id,
        platformName: widget.platform.name,
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        purchaseDate: _purchaseDate,
        expirationDate: _expirationDate,
        totalProfiles: _totalProfiles,
        notes: _notesCtrl.text.trim(),
        createdAt: widget.existingAccount?.createdAt ?? DateTime.now(),
      );

      if (widget.existingAccount != null) {
        await widget.firestore.updateAccount(account);
      } else {
        await widget.firestore.addAccount(account);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final isEdit = widget.existingAccount != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar cuenta' : 'Nueva cuenta'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Platform chip
            Chip(
              avatar: Text(widget.platform.iconEmoji),
              label: Text(widget.platform.name),
              backgroundColor: Color(int.parse(
                      widget.platform.color.replaceFirst('#', '0xFF')))
                  .withOpacity(0.15),
            ),
            const SizedBox(height: 16),
            // Email
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email de la cuenta',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            // Password
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outlined),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            // Profile count
            Row(
              children: [
                const Text('Cantidad de perfiles:'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _totalProfiles > 1
                      ? () => setState(() => _totalProfiles--)
                      : null,
                ),
                Text(
                  '$_totalProfiles',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _totalProfiles++),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Purchase date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Fecha de compra'),
              subtitle: Text(fmt.format(_purchaseDate)),
              onTap: () => _pickDate(isPurchase: true),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            const Divider(),
            // Expiration date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_busy_outlined),
              title: const Text('Fecha de vencimiento'),
              subtitle: Text(fmt.format(_expirationDate)),
              onTap: () => _pickDate(isPurchase: false),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            const Divider(),
            const SizedBox(height: 8),
            // Notes
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.notes_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _save,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Guardar cambios' : 'Agregar cuenta',
                      style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
