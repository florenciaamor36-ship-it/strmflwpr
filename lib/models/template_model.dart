import 'package:cloud_firestore/cloud_firestore.dart';

enum TemplateType { welcome, reminder, expired }

class TemplateModel {
  final String id;
  final String userId;
  final String? platformId; // null = global template
  final TemplateType type;
  final String name;
  final String content; // message with {variable} placeholders
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TemplateModel({
    required this.id,
    required this.userId,
    this.platformId,
    required this.type,
    required this.name,
    required this.content,
    required this.isDefault,
    required this.createdAt,
    this.updatedAt,
  });

  factory TemplateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TemplateModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      platformId: data['platformId'] as String?,
      type: _typeFromString(data['type'] as String?),
      name: data['name'] as String? ?? '',
      content: data['content'] as String? ?? '',
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static TemplateType _typeFromString(String? s) {
    switch (s) {
      case 'reminder':
        return TemplateType.reminder;
      case 'expired':
        return TemplateType.expired;
      default:
        return TemplateType.welcome;
    }
  }

  static String typeToString(TemplateType type) {
    switch (type) {
      case TemplateType.reminder:
        return 'reminder';
      case TemplateType.expired:
        return 'expired';
      default:
        return 'welcome';
    }
  }

  static String typeLabel(TemplateType type) {
    switch (type) {
      case TemplateType.reminder:
        return 'Recordatorio';
      case TemplateType.expired:
        return 'Vencido';
      default:
        return 'Bienvenida / Venta';
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'platformId': platformId,
      'type': typeToString(type),
      'name': name,
      'content': content,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  /// Render the template by substituting variables
  String render(Map<String, String> variables) {
    String result = content;
    variables.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  TemplateModel copyWith({
    String? id,
    String? userId,
    String? platformId,
    TemplateType? type,
    String? name,
    String? content,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      platformId: platformId ?? this.platformId,
      type: type ?? this.type,
      name: name ?? this.name,
      content: content ?? this.content,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
