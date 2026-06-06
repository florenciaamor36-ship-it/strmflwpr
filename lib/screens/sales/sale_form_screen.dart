import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/profile_model.dart';
import '../../models/sale_model.dart';
import '../../services/firestore_service.dart';
import '../../services/whatsapp_service.dart';

class SaleFormScreen extends StatefulWidget {
  final ProfileModel profile;
  final FirestoreService firestore;
  final String accountEmail;
  final String accountPassword;

  const SaleFormScreen({
    super.key,
    required this.profile,
    required this.firestore,
    required this.accountEmail,
    required this.accountPassword,
  });

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameCtrl = TextEditingController();
  final _clientPhoneCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _reminderCtrl = TextEditingController(text: '7,3,1');
  DateTime _saleDate = DateTime.now();
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 30));
  bool _loading = false;
  bool _saved = false;
  SaleModel? _savedSale;

  @override
  void initState() {
    super.initState();
    _clientNameCtrl.text = widget.profile.clientName;
    _clientPhoneCtrl.text = widget.profile.clientPhone;
    _priceCtrl.text = widget.profile.price > 0
        ? widget.profile.price.toString()
        : '';
    if (widget.profile.saleDate != null) _saleDate = widget.profile.saleDate!;
    if (widget.profile.expirationDate != null) {
      _expirationDate = widget.profile.expirationDate!;
    }
    _reminderCtrl.text = widget.profile.reminderDays.join(',');
  }

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _clientPhoneCtrl.dispose();
    _priceCtrl.dispose();
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
      initialDate: isSale ? _saleDate : _expirationDate,
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
      final sale = SaleModel(
        id: '',
        userId: widget.firestore.userId,
        profileId: widget.profile.id,
        accountId: widget.profile.accountId,
        platformId: widget.profile.platformId,
        platformName: widget.profile.platformName,
        clientName: _clientNameCtrl.text.trim(),
        clientPhone: _clientPhoneCtrl.text.trim(),
        saleDate: _saleDate,
        expirationDate: _expirationDate,
        price: double.tryParse(_priceCtrl.text) ?? 0.0,
        status: SaleStatus.active,
        whatsappTemplateSent: false,
      );

      final saleId = await widget.firestore.addSale(sale);

      // Update profile status to sold
      final updatedProfile = widget.profile.copyWith(
        status: ProfileStatus.sold,
        clientName: _clientNameCtrl.text.trim(),
        clientPhone: _clientPhoneCtrl.text.trim(),
        saleDate: _saleDate,
        expirationDate: _expirationDate,
        price: double.tryParse(_priceCtrl.text) ?? 0.0,
        reminderDays: _parseReminderDays(),
      );
      await widget.firestore.updateProfile(updatedProfile);

      setState(() {
        _saved = true;
        _savedSale = sale.copyWith(id: saleId);
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

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    final theme = Theme.of(context);

    if (_saved && _savedSale != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Venta registrada')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text(
                  '¡Venta registrada!',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.profile.platformName} — ${widget.profile.profileName}',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Cliente: ${_clientNameCtrl.text}',
                  style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
                Text('Vence: ${fmt.format(_expirationDate)}'),
                const SizedBox(height: 24),
                if (_clientPhoneCtrl.text.isNotEmpty) ...[
                  FilledButton.icon(
                    onPressed: () async {
                      final wa = WhatsAppService();
                      final msg = wa.generateSaleMessage(
                        platformName: widget.profile.platformName,
                        profileName: widget.profile.profileName,
                        clientName: _clientNameCtrl.text,
                        email: widget.accountEmail,
                        password: widget.accountPassword,
                        pin: widget.profile.profilePin,
                        expirationDate: _expirationDate,
                      );
                      await wa.sendWhatsAppMessage(
                        phone: _clientPhoneCtrl.text,
                        message: msg,
                      );
                    },
                    icon: const Text('💬'),
                    label: const Text('Enviar bienvenida por WhatsApp'),
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366)),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar venta'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Perfil',
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    Text(
                      '${widget.profile.platformName} — ${widget.profile.profileName}',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (widget.profile.profilePin.isNotEmpty)
                      Text('PIN: ${widget.profile.profilePin}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Client name
            TextFormField(
              controller: _clientNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del cliente',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            // Client phone
            TextFormField(
              controller: _clientPhoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono WhatsApp',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
                hintText: '549XXXXXXXXXX',
              ),
            ),
            const SizedBox(height: 16),
            // Price
            TextFormField(
              controller: _priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Precio',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            // Sale date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Fecha de venta'),
              subtitle: Text(fmt.format(_saleDate)),
              onTap: () => _pickDate(isSale: true),
            ),
            const Divider(),
            // Expiration date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_busy_outlined),
              title: const Text('Fecha de vencimiento'),
              subtitle: Text(fmt.format(_expirationDate)),
              onTap: () => _pickDate(isSale: false),
            ),
            const Divider(),
            const SizedBox(height: 8),
            // Reminder days
            TextFormField(
              controller: _reminderCtrl,
              decoration: const InputDecoration(
                labelText: 'Días de recordatorio',
                prefixIcon: Icon(Icons.notifications_outlined),
                border: OutlineInputBorder(),
                hintText: '7,3,1',
                helperText: 'Separados por coma: ej. 7,3,1',
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
                  : const Text('Registrar venta',
                      style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
