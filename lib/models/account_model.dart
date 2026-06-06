import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel {
  final String id;
  final String userId;
  final String platformId;
  final String platformName;
  final String email;
  final String password;
  final DateTime? accountExpiration; // when the master account expires
  final double purchaseCost; // what we paid for it
  final bool isActive;
  final DateTime createdAt;
  // Computed fields (populated by service layer)
  int totalProfiles;
  int soldProfiles;
  int availableProfiles;

  AccountModel({
    required this.id,
    required this.userId,
    required this.platformId,
    required this.platformName,
    required this.email,
    required this.password,
    this.accountExpiration,
    required this.purchaseCost,
    required this.isActive,
    required this.createdAt,
    this.totalProfiles = 0,
    this.soldProfiles = 0,
    this.availableProfiles = 0,
  });

  factory AccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AccountModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      platformId: data['platformId'] as String? ?? '',
      platformName: data['platformName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      password: data['password'] as String? ?? '',
      accountExpiration:
          (data['accountExpiration'] as Timestamp?)?.toDate(),
      purchaseCost: (data['purchaseCost'] as num?)?.toDouble() ?? 0.0,
      isActive: data['isActive'] as bool? ?? true,
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
      'accountExpiration': accountExpiration != null
          ? Timestamp.fromDate(accountExpiration!)
          : null,
      'purchaseCost': purchaseCost,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get maskedEmail {
    if (email.isEmpty) return '';
    final parts = email.split('@');
    if (parts.length < 2) return email;
    final user = parts[0];
    final masked = user.length > 3
        ? '${user.substring(0, 3)}***'
        : '${user[0]}***';
    return '$masked@${parts[1]}';
  }

  AccountModel copyWith({
    String? id,
    String? userId,
    String? platformId,
    String? platformName,
    String? email,
    String? password,
    DateTime? accountExpiration,
    double? purchaseCost,
    bool? isActive,
    DateTime? createdAt,
    int? totalProfiles,
    int? soldProfiles,
    int? availableProfiles,
  }) {
    return AccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      platformId: platformId ?? this.platformId,
      platformName: platformName ?? this.platformName,
      email: email ?? this.email,
      password: password ?? this.password,
      accountExpiration: accountExpiration ?? this.accountExpiration,
      purchaseCost: purchaseCost ?? this.purchaseCost,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      totalProfiles: totalProfiles ?? this.totalProfiles,
      soldProfiles: soldProfiles ?? this.soldProfiles,
      availableProfiles: availableProfiles ?? this.availableProfiles,
    );
  }
}
