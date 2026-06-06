import 'package:cloud_firestore/cloud_firestore.dart';

class ClientModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String notes;
  final List<String> tags;
  final double totalSpent; // computed/cached value
  final int activeSubscriptions; // computed/cached
  final DateTime createdAt;
  final DateTime? updatedAt;

  ClientModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.notes,
    required this.tags,
    this.totalSpent = 0.0,
    this.activeSubscriptions = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory ClientModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClientModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      tags: List<String>.from(data['tags'] as List? ?? []),
      totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0.0,
      activeSubscriptions:
          (data['activeSubscriptions'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'notes': notes,
      'tags': tags,
      'totalSpent': totalSpent,
      'activeSubscriptions': activeSubscriptions,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  ClientModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? email,
    String? notes,
    List<String>? tags,
    double? totalSpent,
    int? activeSubscriptions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      totalSpent: totalSpent ?? this.totalSpent,
      activeSubscriptions: activeSubscriptions ?? this.activeSubscriptions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
