import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/settings_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/client_service.dart';
import '../../services/whatsapp_service.dart';
import '../../models/platform_model.dart';
import '../../models/profile_model.dart';
import '../../models/client_model.dart';
import '../../models/sale_model.dart';
import '../../utils/phone_utils.dart';
import '../../utils/date_utils.dart';

class QuickSaleScreen extends StatefulWidget {
  final String userId;
  const QuickSaleScreen({super.key, required this.userId});

  @override
  State<QuickSaleScreen> createState() => _QuickSaleScreenState();
}

class _QuickSaleScreenState extends State<QuickSaleScreen> {
  int _currentStep = 0;
  final FirestoreService _service = FirestoreService();
  final ClientService _clientService = ClientService();

  // Step 1
  List<PlatformModel> _platforms = [];
  PlatformModel? _selectedPlatform;

  // Step 2
  List<ProfileModel> _availableProfiles = [];
  ProfileModel? _selectedProfile;

  // Step 3
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 30));
  List<ClientModel> _clients = [];
  ClientModel? _existingClient;

  bool _isLoading = false;
  bool _isSaved = false;
  SaleModel? _savedSale;

  @override
  void initState() {
    super.initState();
    _loadPlatforms();
    _loadClients();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _loadPlatforms() {
    _service.platformsStream(widget.userId).listen((platforms) {
      if (mounted) setState(() => _platforms = platforms);
    });
  }

  void _loadClients() {
    _service.clientsStream(widget.userId).listen((clients) {
      if (mounted) setState(() => _clients = clients);
    });
  }

  void _selectPlatform(PlatformModel platform) {
    setState(() {
      _selectedPlatform = platform;
      _availableProfiles = [];
      _selectedProfile = null;
    });
    _service
        .availableProfilesStream(widget.userId, platform.id)
        .listen((profiles) {
      if (mounted) setState(() => _availableProfiles = profiles);
    });
    if (platform.defaultPrice > 0) {
      _priceController.text = platform.defaultPrice.toStringAsFixed(0);
    }
    setState(() => _currentStep = 1);
  }

  void _selectProfile(ProfileModel profile) {
    setState(() {
      _selectedProfile = profile;
      _currentStep = 2;
    });
  }

  void _checkExistingClient(String phone) {
    if (phone.length >= 8) {
      final client = _clientService.findByPhone(_clients, phone);
      if (client != null && mounted) {
        setState(() {
          _existingClient = client;
          _nameController.text = client.name;
        });
      } else {
        setState(() => _existingClient = null);
      }
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
    );
    if (date != null) setState(() => _expirationDate = date);
  }

  Future<void> _saveSale() async {
    if (_selectedPlatform == null || _selectedProfile == null) return;
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá nombre y teléfono')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final settings = context.read<SettingsProvider>();

      // Create or find client
      String clientId = _existingClient?.id ?? '';
      if (clientId.isEmpty) {
        final newClient = ClientModel(
          id: '',
          userId: widget.userId,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: '',
          notes: '',
          tags: [],
          createdAt: DateTime.now(),
        );
        clientId = await _service.addClient(newClient);
      }

      // Get account info
      List<dynamic> accounts = [];
      try {
        accounts = await _service
            .accountsByPlatformStream(widget.userId, _selectedPlatform!.id)
            .first;
      } catch (_) {}

      dynamic account;
      try {
        account = accounts.firstWhere(
            (a) => a.id == _selectedProfile!.accountId);
      } catch (_) {
        account = accounts.isNotEmpty ? accounts.first : null;
      }

      final sale = SaleModel(
        id: '',
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
        clientName: _nameController.text.trim(),
        clientPhone: _phoneController.text.trim(),
        price: double.tryParse(
                _priceController.text.replaceAll(',', '.')) ??
            0,
        startDate: DateTime.now(),
        expirationDate: _expirationDate,
        status: SaleStatus.active,
        reminderDays: settings.defaultReminderDays,
        remindersSent: [],
        renewalCount: 0,
        clientToken: _service.generateClientToken(),
        notes: '',
        createdAt: DateTime.now(),
      );

      final saleId = await _service.addSale(sale);
      await _clientService.updateClientStats(clientId);

      setState(() {
        _isSaved = true;
        _savedSale = sale.copyWith(id: saleId);
      });
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
    final settings = context.read<SettingsProvider>();
    final theme = Theme.of(context);

    if (_isSaved && _savedSale != null) {
      return _SuccessScreen(
        sale: _savedSale!,
        settings: settings,
        onDone: () => Navigator.of(context).pop(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ Venta Rápida'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: theme.colorScheme.surfaceVariant,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentStep,
        children: [
          _Step1Platform(
            platforms: _platforms,
            selectedPlatform: _selectedPlatform,
            onSelect: _selectPlatform,
          ),
          _Step2Profile(
            profiles: _availableProfiles,
            selectedProfile: _selectedProfile,
            onSelect: _selectProfile,
            onBack: () => setState(() => _currentStep = 0),
          ),
          _Step3Client(
            nameController: _nameController,
            phoneController: _phoneController,
            priceController: _priceController,
            expirationDate: _expirationDate,
            existingClient: _existingClient,
            isLoading: _isLoading,
            onPhoneChanged: _checkExistingClient,
            onPickDate: _pickDate,
            onBack: () => setState(() => _currentStep = 1),
            onSave: _saveSale,
          ),
        ],
      ),
    );
  }
}

class _Step1Platform extends StatelessWidget {
  final List<PlatformModel> platforms;
  final PlatformModel? selectedPlatform;
  final Function(PlatformModel) onSelect;

  const _Step1Platform(
      {required this.platforms,
      required this.selectedPlatform,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Paso 1: ¿Qué plataforma?',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (platforms.isEmpty)
            const Center(
                child: Text('No hay plataformas. Creá una primero.'))
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: platforms.length,
                itemBuilder: (context, index) {
                  final p = platforms[index];
                  final isSelected = selectedPlatform?.id == p.id;
                  return InkWell(
                    onTap: () => onSelect(p),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(
                                color:
                                    Theme.of(context).colorScheme.primary,
                                width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(p.emoji,
                              style: const TextStyle(fontSize: 36)),
                          const SizedBox(height: 8),
                          Text(p.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Step2Profile extends StatelessWidget {
  final List<ProfileModel> profiles;
  final ProfileModel? selectedProfile;
  final Function(ProfileModel) onSelect;
  final VoidCallback onBack;

  const _Step2Profile(
      {required this.profiles,
      required this.selectedProfile,
      required this.onSelect,
      required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios)),
              Text('Paso 2: Elegí un perfil',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          if (profiles.isEmpty)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                        'No hay perfiles disponibles para esta plataforma')))
          else
            Expanded(
              child: ListView.separated(
                itemCount: profiles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  final isSelected =
                      selectedProfile?.id == profile.id;
                  return InkWell(
                    onTap: () => onSelect(profile),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color:
                                    Theme.of(context).colorScheme.primary,
                                width: 2)
                            : null,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(profile.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                if (profile.pin.isNotEmpty)
                                  Text('PIN: ${profile.pin}',
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Step3Client extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController priceController;
  final DateTime expirationDate;
  final ClientModel? existingClient;
  final bool isLoading;
  final Function(String) onPhoneChanged;
  final VoidCallback onPickDate;
  final VoidCallback onBack;
  final VoidCallback onSave;

  const _Step3Client({
    required this.nameController,
    required this.phoneController,
    required this.priceController,
    required this.expirationDate,
    required this.existingClient,
    required this.isLoading,
    required this.onPhoneChanged,
    required this.onPickDate,
    required this.onBack,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios)),
            Text('Paso 3: Datos del cliente',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Teléfono (+54 9 11...)',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          onChanged: onPhoneChanged,
        ),
        if (existingClient != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '✅ Cliente encontrado: ${existingClient!.name}',
              style: const TextStyle(
                  color: Colors.green, fontWeight: FontWeight.w600),
            ),
          ),
        const SizedBox(height: 16),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del cliente',
            prefixIcon: Icon(Icons.person_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Precio',
            prefixIcon: Icon(Icons.attach_money),
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: const Text('Fecha de vencimiento'),
          subtitle:
              Text(AppDateUtils.formatDate(expirationDate)),
          trailing: const Icon(Icons.chevron_right),
          onTap: onPickDate,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Confirmar venta'),
          onPressed: isLoading ? null : onSave,
        ),
      ],
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  final SaleModel sale;
  final SettingsProvider settings;
  final VoidCallback onDone;

  const _SuccessScreen({
    required this.sale,
    required this.settings,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final whatsapp = WhatsAppService(
      defaultCountryCode: settings.defaultCountryCode,
      businessName: settings.businessName,
      currencySymbol: settings.currencySymbol,
    );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle,
                  color: Colors.green, size: 80),
              const SizedBox(height: 24),
              Text('¡Venta creada!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                  '${sale.platformName} · ${sale.profileName}\n${sale.clientName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.message),
                label: const Text('Enviar mensaje de bienvenida'),
                onPressed: () => whatsapp.sendWelcomeMessage(sale),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onDone,
                child: const Text('Listo, sin mensaje'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
