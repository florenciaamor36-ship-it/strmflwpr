import 'package:cloud_firestore/cloud_firestore.dart';

class PlatformModel {
  final String id;
  final String userId;
  final String name;
  final String emoji;
  final String color; // hex color string
  final int maxProfiles; // max profiles per account
  final double defaultPrice;
  final bool isActive;
  final DateTime createdAt;

  PlatformModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.emoji,
    required this.color,
    required this.maxProfiles,
    required this.defaultPrice,
    required this.isActive,
    required this.createdAt,
  });

  factory PlatformModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlatformModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      emoji: data['emoji'] as String? ?? '📺',
      color: data['color'] as String? ?? '#6C63FF',
      maxProfiles: (data['maxProfiles'] as num?)?.toInt() ?? 5,
      defaultPrice: (data['defaultPrice'] as num?)?.toDouble() ?? 0.0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'emoji': emoji,
      'color': color,
      'maxProfiles': maxProfiles,
      'defaultPrice': defaultPrice,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PlatformModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? emoji,
    String? color,
    int? maxProfiles,
    double? defaultPrice,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PlatformModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      maxProfiles: maxProfiles ?? this.maxProfiles,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
