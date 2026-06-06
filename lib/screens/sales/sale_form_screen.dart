import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/settings_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/client_service.dart';
import '../../models/sale_model.dart';
import '../../models/platform_model.dart';
import '../../models/profile_model.dart';
import '../../models/client_model.dart';
import '../../utils/phone_utils.dart';
import '../../utils/date_utils.dart';

class SaleFormScreen extends StatefulWidget {
  final String userId;
  final SaleModel? sale; // for editing

  const SaleFormScreen({super.key, required this.userId, this.sale});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final FirestoreService _service = FirestoreService();
  final ClientService _clientService = ClientService();

  PlatformModel? _selectedPlatform;
  ProfileModel? _selectedProfile;
  ClientModel? _existingClient;
  List<PlatformModel> _platforms = [];
  List<ProfileModel> _availableProfiles = [];
  List<ClientModel> _clients = [];
  DateTime _startDate = DateTime.now();
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;
  List<int> _reminderDays = [1, 3, 7];

  @override
  void initState() {
    super.initState();
    final s = widget.sale;
    if (s != null) {
      _clientNameController.text = s.clientName;
      _clientPhoneController.text = s.clientPhone;
      _priceController.text = s.price.toStringAsFixed(0);
      _notesController.text = s.notes;
      _startDate = s.startDate;
      _expirationDate = s.expirationDate;
      _reminderDays = List.from(s.reminderDays);
    } else {
      final settings = context.read<SettingsProvider>();
      _reminderDays = settings.defaultReminderDays;
    }
    _loadData();
  }

  void _loadData() {
    _service.platformsStream(widget.userId).listen((p) {
      if (mounted) setState(() => _platforms = p);
    });
    _service.clientsStream(widget.userId).listen((c) {
      if (mounted) setState(() => _clients = c);
    });
  }

  void _onPlatformChanged(PlatformModel? platform) {
    setState(() {
      _selectedPlatform = platform;
      _selectedProfile = null;
      _availableProfiles = [];
    });
    if (platform != null) {
      _service
          .availableProfilesStream(widget.userId, platform.id)
          .listen((profiles) {
        if (mounted) setState(() => _availableProfiles = profiles);
      });
      if (_priceController.text.isEmpty) {
        _priceController.text =
            platform.defaultPrice.toStringAsFixed(0);
      }
    }
  }

  void _checkExistingClient(String phone) {
    if (phone.length >= 8) {
      final client = _clientService.findByPhone(_clients, phone);
      if (client != null && mounted) {
        setState(() {
          _existingClient = client;
          _clientNameController.text = client.name;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate phone
    final settings = context.read<SettingsProvider>();
    final phoneError = PhoneUtils.validate(_clientPhoneController.text);
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(phoneError),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Continuar igual',
            onPressed: _saveWithoutPhoneValidation,
          ),
        ),
      );
      return;
    }

    await _saveWithoutPhoneValidation();
  }

  Future<void> _saveWithoutPhoneValidation() async {
    if (_selectedPlatform == null || _selectedProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná plataforma y perfil')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final settings = context.read<SettingsProvider>();
      final uuid = const Uuid();

      // Find or create client
      String clientId = _existingClient?.id ?? '';
      if (clientId.isEmpty) {
        final newClient = ClientModel(
          id: '',
          userId: widget.userId,
          name: _clientNameController.text.trim(),
          phone: _clientPhoneController.text.trim(),
          email: '',
          notes: '',
          tags: [],
          createdAt: DateTime.now(),
        );
        clientId = await _service.addClient(newClient);
      }

      final account = await _getAccountForProfile();

      final sale = SaleModel(
        id: widget.sale?.id ?? '',
        userId: widget.userId,
        platformId: _selectedPlatform!.id,
        platformName: _selectedPlatform!.name,
        platformEmoji: _selectedPlatform!.emoji,
        accountId: _selectedProfile!.accountId,
        accountEmail: account?.email ?? '',
        accountPassword: account?.password ?? '',
        profileId: _selectedProfile!.id,
        profileName: _selectedProfile!.name,
        profilePin: _selectedProfile!.pin,
        clientId: clientId,
        clientName: _clientNameController.text.trim(),
        clientPhone: _clientPhoneController.text.trim(),
        price: double.tryParse(
                _priceController.text.replaceAll(',', '.')) ??
            0,
        startDate: _startDate,
        expirationDate: _expirationDate,
        status: SaleStatus.active,
        reminderDays: _reminderDays,
        remindersSent: [],
        renewalCount: 0,
        clientToken: widget.sale?.clientToken ?? _service.generateClientToken(),
        notes: _notesController.text.trim(),
        createdAt: widget.sale?.createdAt ?? DateTime.now(),
      );

      if (widget.sale != null) {
        await _service.updateSale(sale);
      } else {
        await _service.addSale(sale);
        await _clientService.updateClientStats(clientId);
      }

      if (mounted) Navigator.of(context).pop(true);
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

  Future<dynamic> _getAccountForProfile() async {
    if (_selectedProfile == null) return null;
    // Get account by listening once
    try {
      final accounts = await _service
          .accountsByPlatformStream(widget.userId, _selectedPlatform!.id)
          .first;
      return accounts.firstWhere(
          (a) => a.id == _selectedProfile!.accountId,
          orElse: () => accounts.first);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _expirationDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _expirationDate = date;
        }
      });
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.sale != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar venta' : 'Nueva venta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Plataforma y perfil',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<PlatformModel>(
              value: _selectedPlatform,
              decoration: const InputDecoration(
                  labelText: 'Plataforma',
                  prefixIcon: Icon(Icons.tv_outlined)),
              items: _platforms
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Row(children: [
                          Text(p.emoji),
                          const SizedBox(width: 8),
                          Text(p.name),
                        ]),
                      ))
                  .toList(),
              onChanged: _onPlatformChanged,
              validator: (v) =>
                  v == null ? 'Seleccioná una plataforma' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProfileModel>(
              value: _selectedProfile,
              decoration: const InputDecoration(
                  labelText: 'Perfil disponible',
                  prefixIcon: Icon(Icons.person_outlined)),
              items: _availableProfiles
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text('${p.name}${p.pin.isNotEmpty ? " (PIN: ${p.pin})" : ""}'),
                      ))
                  .toList(),
              onChanged: (p) => setState(() => _selectedProfile = p),
              validator: (v) => v == null ? 'Seleccioná un perfil' : null,
            ),
            const SizedBox(height: 24),
            Text('Datos del cliente',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _clientPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono del cliente',
                hintText: '+54 9 11 1234-5678',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              onChanged: _checkExistingClient,
              validator: (v) =>
                  v == null || v.isEmpty ? 'El teléfono es requerido' : null,
            ),
            if (_existingClient != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '✅ Cliente existente encontrado',
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clientNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del cliente',
                prefixIcon: Icon(Icons.person_outlined),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'El nombre es requerido' : null,
            ),
            const SizedBox(height: 24),
            Text('Precio y fechas',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Precio',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'El precio es requerido' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today, size: 20),
                    title: const Text('Inicio'),
                    subtitle: Text(AppDateUtils.formatDate(_startDate)),
                    onTap: () => _pickDate(true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event, size: 20),
                    title: const Text('Vencimiento'),
                    subtitle: Text(AppDateUtils.formatDate(_expirationDate)),
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isEdit ? 'Guardar cambios' : 'Crear venta'),
            ),
          ],
        ),
      ),
    );
  }
}
