import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel {
  final String id;
  final String userId;
  final String platformId;
  final String platformName;
  final String email;
  final String password;
  final DateTime purchaseDate;
  final DateTime expirationDate;
  final int totalProfiles;
  final String notes;
  final DateTime createdAt;

  AccountModel({
    required this.id,
    required this.userId,
    required this.platformId,
    required this.platformName,
    required this.email,
    required this.password,
    required this.purchaseDate,
    required this.expirationDate,
    required this.totalProfiles,
    this.notes = '',
    required this.createdAt,
  });

  factory AccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AccountModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      platformId: data['platformId'] ?? '',
      platformName: data['platformName'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expirationDate: (data['expirationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalProfiles: data['totalProfiles'] ?? 1,
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'platformId': platformId,
      'platformName': platformName,
      'email': email,
      'password': password,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'expirationDate': Timestamp.fromDate(expirationDate),
      'totalProfiles': totalProfiles,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isExpired => expirationDate.isBefore(DateTime.now());

  int get daysUntilExpiration =>
      expirationDate.difference(DateTime.now()).inDays;

  AccountModel copyWith({
    String? id,
    String? userId,
    String? platformId,
    String? platformName,
    String? email,
    String? password,
    DateTime? purchaseDate,
    DateTime? expirationDate,
    int? totalProfiles,
    String? notes,
    DateTime? createdAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      platformId: platformId ?? this.platformId,
      platformName: platformName ?? this.platformName,
      email: email ?? this.email,
      password: password ?? this.password,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expirationDate: expirationDate ?? this.expirationDate,
      totalProfiles: totalProfiles ?? this.totalProfiles,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
