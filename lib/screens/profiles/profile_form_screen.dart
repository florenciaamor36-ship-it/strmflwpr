import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/account_model.dart';
import '../../models/platform_model.dart';
import '../../models/profile_model.dart';
import '../../services/firestore_service.dart';
import '../../services/whatsapp_service.dart';

class ProfileFormScreen extends StatefulWidget {
  final AccountModel account;
  final PlatformModel platform;
  final FirestoreService firestore;
  final ProfileModel? existingProfile;

  const ProfileFormScreen({
    super.key,
    required this.account,
    required this.platform,
    required this.firestore,
    this.existingProfile,
  });

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _clientNameCtrl = TextEditingController();
  final _clientPhoneCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _reminderCtrl = TextEditingController(text: '7,3,1');

  ProfileStatus _status = ProfileStatus.available;
  DateTime? _saleDate;
  DateTime? _expirationDate;
  bool _loading = false;
  bool _saved = false;
  String? _savedProfileId;

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      final p = widget.existingProfile!;
      _nameCtrl.text = p.profileName;
      _pinCtrl.text = p.profilePin;
      _clientNameCtrl.text = p.clientName;
      _clientPhoneCtrl.text = p.clientPhone;
      _priceCtrl.text = p.price > 0 ? p.price.toString() : '';
      _notesCtrl.text = p.notes;
      _status = p.status;
      _saleDate = p.saleDate;
      _expirationDate = p.expirationDate;
      _reminderCtrl.text = p.reminderDays.join(',');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pinCtrl.dispose();
    _clientNameCtrl.dispose();
    _clientPhoneCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    _reminderCtrl.dispose();
    super.dispose();
  }

  List<int> _parseReminderDays() {
    try {
      return _reminderCtrl.text
          .split(',')
          .map((s) => int.parse(s.trim()))
          .where((d) => d > 0)
          .toList();
    } catch (_) {
      return [7, 3, 1];
    }
  }

  Future<void> _pickDate({required bool isSale}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isSale
          ? (_saleDate ?? DateTime.now())
          : (_expirationDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isSale) {
          _saleDate = picked;
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
      final profile = ProfileModel(
        id: widget.existingProfile?.id ?? '',
        accountId: widget.account.id,
        userId: widget.firestore.userId,
        platformId: widget.platform.id,
        platformName: widget.platform.name,
        profileName: _nameCtrl.text.trim(),
        profilePin: _pinCtrl.text.trim(),
        status: _status,
        clientName: _clientNameCtrl.text.trim(),
        clientPhone: _clientPhoneCtrl.text.trim(),
        saleDate: _saleDate,
        expirationDate: _expirationDate,
        price: double.tryParse(_priceCtrl.text) ?? 0.0,
        reminderDays: _parseReminderDays(),
        notes: _notesCtrl.text.trim(),
      );

      String id;
      if (widget.existingProfile != null) {
        await widget.firestore.updateProfile(profile);
        id = widget.existingProfile!.id;
      } else {
        id = await widget.firestore.addProfile(profile);
      }

      setState(() {
        _saved = true;
        _savedProfileId = id;
      });
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

  Widget _buildSavedActions() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 48),
        const SizedBox(height: 8),
        const Text('¡Perfil guardado!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_clientPhoneCtrl.text.isNotEmpty &&
            _expirationDate != null &&
            _status == ProfileStatus.sold) ...[
          FilledButton.icon(
            onPressed: () async {
              final wa = WhatsAppService();
              final msg = wa.generateSaleMessage(
                platformName: widget.platform.name,
                profileName: _nameCtrl.text,
                clientName: _clientNameCtrl.text,
                email: widget.account.email,
                password: widget.account.password,
                pin: _pinCtrl.text,
                expirationDate: _expirationDate!,
              );
              await wa.sendWhatsAppMessage(
                  phone: _clientPhoneCtrl.text, message: msg);
            },
            icon: const Text('💬'),
            label: const Text('Enviar mensaje de bienvenida por WhatsApp'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Volver'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final isEdit = widget.existingProfile != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar perfil' : 'Nuevo perfil'),
        centerTitle: true,
      ),
      body: _saved
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildSavedActions(),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Platform + Account chip
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        avatar: Text(widget.platform.iconEmoji),
                        label: Text(widget.platform.name),
                      ),
                      Chip(
                        avatar: const Icon(Icons.email_outlined, size: 16),
                        label: Text(widget.account.email,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Profile name
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del perfil',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  // PIN
                  TextFormField(
                    controller: _pinCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'PIN (opcional)',
                      prefixIcon: Icon(Icons.pin_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Status
                  DropdownButtonFormField<ProfileStatus>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      prefixIcon: Icon(Icons.toggle_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: ProfileStatus.values
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text(s.displayName)))
                        .toList(),
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                  if (_status != ProfileStatus.available) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    Text('Datos del cliente',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _clientNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del cliente',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _clientPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono (WhatsApp)',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                        hintText: '549XXXXXXXXXX',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_outlined),
                      title: const Text('Fecha de venta'),
                      subtitle: Text(_saleDate != null
                          ? fmt.format(_saleDate!)
                          : 'Sin fecha'),
                      onTap: () => _pickDate(isSale: true),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_busy_outlined),
                      title: const Text('Fecha de vencimiento'),
                      subtitle: Text(_expirationDate != null
                          ? fmt.format(_expirationDate!)
                          : 'Sin fecha'),
                      onTap: () => _pickDate(isSale: false),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _reminderCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Días de recordatorio (separados por coma)',
                        prefixIcon: Icon(Icons.notifications_outlined),
                        border: OutlineInputBorder(),
                        hintText: '7,3,1',
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notas',
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
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(isEdit ? 'Guardar cambios' : 'Guardar perfil',
                            style: const TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
