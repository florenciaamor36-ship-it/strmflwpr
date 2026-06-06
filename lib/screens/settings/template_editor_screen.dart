import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/template_model.dart';
import '../../models/platform_model.dart';
import '../../services/whatsapp_service.dart';
import '../../utils/constants.dart';

class TemplateEditorScreen extends StatelessWidget {
  final String userId;
  const TemplateEditorScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Plantillas de WhatsApp')),
      body: StreamBuilder<List<TemplateModel>>(
        stream: service.templatesStream(userId),
        builder: (context, templateSnap) {
          return StreamBuilder<List<PlatformModel>>(
            stream: service.platformsStream(userId),
            builder: (context, platformSnap) {
              final templates = templateSnap.data ?? [];
              final platforms = platformSnap.data ?? [];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Personalizá los mensajes de WhatsApp para cada plataforma. '
                    'Las variables entre {} se reemplazan automáticamente.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Variables reference
                  ExpansionTile(
                    title: const Text('Variables disponibles'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: AppConstants.templateVariables
                              .map((v) => Chip(
                                    label: Text(v,
                                        style:
                                            const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Global templates
                  Text('Plantillas globales',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  for (final type in TemplateType.values)
                    _TemplateCard(
                      type: type,
                      platformId: null,
                      platformName: 'Global',
                      template: _findTemplate(templates, type, null),
                      userId: userId,
                      service: service,
                    ),
                  const SizedBox(height: 24),

                  // Per-platform templates
                  if (platforms.isNotEmpty) ...[
                    Text('Plantillas por plataforma',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    for (final platform in platforms)
                      ExpansionTile(
                        title: Row(
                          children: [
                            Text(platform.emoji),
                            const SizedBox(width: 8),
                            Text(platform.name),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: TemplateType.values
                                  .map((type) => _TemplateCard(
                                        type: type,
                                        platformId: platform.id,
                                        platformName: platform.name,
                                        template: _findTemplate(
                                            templates, type, platform.id),
                                        userId: userId,
                                        service: service,
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  TemplateModel? _findTemplate(
      List<TemplateModel> templates, TemplateType type, String? platformId) {
    try {
      return templates.firstWhere(
          (t) => t.type == type && t.platformId == platformId);
    } catch (_) {
      return null;
    }
  }
}

class _TemplateCard extends StatefulWidget {
  final TemplateType type;
  final String? platformId;
  final String platformName;
  final TemplateModel? template;
  final String userId;
  final FirestoreService service;

  const _TemplateCard({
    required this.type,
    required this.platformId,
    required this.platformName,
    required this.template,
    required this.userId,
    required this.service,
  });

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  late TextEditingController _controller;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.template?.content ?? _defaultContent());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _defaultContent() {
    switch (widget.type) {
      case TemplateType.welcome:
        return AppConstants.defaultWelcomeTemplate;
      case TemplateType.reminder:
        return AppConstants.defaultReminderTemplate;
      case TemplateType.expired:
        return AppConstants.defaultExpiredTemplate;
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final template = TemplateModel(
        id: widget.template?.id ?? '',
        userId: widget.userId,
        platformId: widget.platformId,
        type: widget.type,
        name:
            '${TemplateModel.typeLabel(widget.type)} - ${widget.platformName}',
        content: _controller.text,
        isDefault: false,
        createdAt: widget.template?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.template != null) {
        await widget.service.updateTemplate(template);
      } else {
        await widget.service.addTemplate(template);
      }

      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plantilla guardada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _resetToDefault() async {
    setState(() {
      _controller.text = _defaultContent();
    });
    if (widget.template != null) {
      await widget.service.deleteTemplate(widget.template!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = WhatsAppService.previewTemplate(_controller.text);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  TemplateModel.typeLabel(widget.type),
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (!_isEditing) ...[
                  IconButton(
                    icon: const Icon(Icons.preview, size: 20),
                    onPressed: () =>
                        setState(() => _showPreview = !_showPreview),
                    tooltip: 'Vista previa',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () =>
                        setState(() => _isEditing = true),
                    tooltip: 'Editar',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (_isEditing)
              TextField(
                controller: _controller,
                maxLines: 8,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              )
            else if (_showPreview)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7FFDB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(preview,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black87)),
              )
            else
              Text(
                _controller.text.length > 100
                    ? '${_controller.text.substring(0, 100)}...'
                    : _controller.text,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            if (_isEditing) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        setState(() => _isEditing = false),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Restablecer'),
                          content: const Text(
                              '¿Restaurar la plantilla por defecto?'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancelar')),
                            TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Restablecer')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _resetToDefault();
                        setState(() => _isEditing = false);
                      }
                    },
                    child: const Text('Restablecer'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
