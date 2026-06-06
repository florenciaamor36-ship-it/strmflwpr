import 'package:cloud_firestore/cloud_firestore.dart';

class PlatformModel {
  final String id;
  final String userId;
  final String name;
  final String emoji;
  final String color;
  final int maxProfiles;
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

  String get iconEmoji => emoji;

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
}
