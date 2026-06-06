import 'package:cloud_firestore/cloud_firestore.dart';

enum ProfileStatus { 
  available, sold, reserved, disabled;
  
  String get displayName {
    switch (this) {
      case ProfileStatus.sold: return 'Vendido';
      case ProfileStatus.reserved: return 'Reservado';
      case ProfileStatus.disabled: return 'Desactivado';
      default: return 'Disponible';
    }
  }
}

class ProfileModel {
  final String id;
  final String userId;
  final String accountId;
  final String platformId;
  final String platformName;
  final String name;
  final String pin;
  final ProfileStatus status;
  final String? currentSaleId;
  final String? currentClientName;
  final DateTime? saleDate;
  final DateTime? expirationDate;
  final List<int> reminderDays;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.platformId,
    required this.platformName,
    required this.name,
    required this.pin,
    required this.status,
    this.currentSaleId,
    this.currentClientName,
    this.saleDate,
    this.expirationDate,
    this.reminderDays = const [],
    required this.createdAt,
  });

  bool get isAvailable => status == ProfileStatus.available;
  bool get isSold => status == ProfileStatus.sold;

  factory ProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfileModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      accountId: data['accountId'] as String? ?? '',
      platformId: data['platformId'] as String? ?? '',
      platformName: data['platformName'] as String? ?? '',
      name: data['name'] as String? ?? data['profileName'] as String? ?? '',
      pin: data['pin'] as String? ?? '',
      status: _statusFromString(data['status'] as String?),
      currentSaleId: data['currentSaleId'] as String?,
      currentClientName: data['currentClientName'] as String?,
      saleDate: (data['saleDate'] as Timestamp?)?.toDate(),
      expirationDate: (data['expirationDate'] as Timestamp?)?.toDate(),
      reminderDays: List<int>.from(data['reminderDays'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static ProfileStatus _statusFromString(String? s) {
    switch (s) {
      case 'sold': return ProfileStatus.sold;
      case 'reserved': return ProfileStatus.reserved;
      case 'disabled': return ProfileStatus.disabled;
      default: return ProfileStatus.available;
    }
  }

  static String statusToString(ProfileStatus status) {
    return status.name;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'accountId': accountId,
      'platformId': platformId,
      'platformName': platformName,
      'name': name,
      'pin': pin,
      'status': statusToString(status),
      'currentSaleId': currentSaleId,
      'currentClientName': currentClientName,
      'saleDate': saleDate != null ? Timestamp.fromDate(saleDate!) : null,
      'expirationDate': expirationDate != null ? Timestamp.fromDate(expirationDate!) : null,
      'reminderDays': reminderDays,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? platformId,
    String? platformName,
    String? name,
    String? pin,
    ProfileStatus? status,
    String? currentSaleId,
    String? currentClientName,
    DateTime? saleDate,
    DateTime? expirationDate,
    List<int>? reminderDays,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      platformId: platformId ?? this.platformId,
      platformName: platformName ?? this.platformName,
      name: name ?? this.name,
      pin: pin ?? this.pin,
      status: status ?? this.status,
      currentSaleId: currentSaleId ?? this.currentSaleId,
      currentClientName: currentClientName ?? this.currentClientName,
      saleDate: saleDate ?? this.saleDate,
      expirationDate: expirationDate ?? this.expirationDate,
      reminderDays: reminderDays ?? this.reminderDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
