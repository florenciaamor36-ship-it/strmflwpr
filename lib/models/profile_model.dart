import 'package:cloud_firestore/cloud_firestore.dart';

enum ProfileStatus { available, sold, reserved }

extension ProfileStatusExtension on ProfileStatus {
  String get displayName {
    switch (this) {
      case ProfileStatus.available:
        return 'Disponible';
      case ProfileStatus.sold:
        return 'Vendido';
      case ProfileStatus.reserved:
        return 'Reservado';
    }
  }

  String get value {
    return name;
  }

  static ProfileStatus fromString(String? value) {
    switch (value) {
      case 'sold':
        return ProfileStatus.sold;
      case 'reserved':
        return ProfileStatus.reserved;
      default:
        return ProfileStatus.available;
    }
  }
}

class ProfileModel {
  final String id;
  final String accountId;
  final String userId;
  final String platformId;
  final String platformName;
  final String profileName;
  final String profilePin;
  final ProfileStatus status;
  final String clientName;
  final String clientPhone;
  final DateTime? saleDate;
  final DateTime? expirationDate;
  final double price;
  final List<int> reminderDays;
  final String notes;

  ProfileModel({
    required this.id,
    required this.accountId,
    required this.userId,
    required this.platformId,
    required this.platformName,
    required this.profileName,
    this.profilePin = '',
    this.status = ProfileStatus.available,
    this.clientName = '',
    this.clientPhone = '',
    this.saleDate,
    this.expirationDate,
    this.price = 0.0,
    this.reminderDays = const [7, 3, 1],
    this.notes = '',
  });

  factory ProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfileModel(
      id: doc.id,
      accountId: data['accountId'] ?? '',
      userId: data['userId'] ?? '',
      platformId: data['platformId'] ?? '',
      platformName: data['platformName'] ?? '',
      profileName: data['profileName'] ?? '',
      profilePin: data['profilePin'] ?? '',
      status: ProfileStatusExtension.fromString(data['status']),
      clientName: data['clientName'] ?? '',
      clientPhone: data['clientPhone'] ?? '',
      saleDate: (data['saleDate'] as Timestamp?)?.toDate(),
      expirationDate: (data['expirationDate'] as Timestamp?)?.toDate(),
      price: (data['price'] ?? 0.0).toDouble(),
      reminderDays: List<int>.from(data['reminderDays'] ?? [7, 3, 1]),
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'accountId': accountId,
      'userId': userId,
      'platformId': platformId,
      'platformName': platformName,
      'profileName': profileName,
      'profilePin': profilePin,
      'status': status.value,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'saleDate': saleDate != null ? Timestamp.fromDate(saleDate!) : null,
      'expirationDate': expirationDate != null ? Timestamp.fromDate(expirationDate!) : null,
      'price': price,
      'reminderDays': reminderDays,
      'notes': notes,
    };
  }

  bool get isExpired =>
      expirationDate != null && expirationDate!.isBefore(DateTime.now());

  int get daysUntilExpiration =>
      expirationDate?.difference(DateTime.now()).inDays ?? -1;

  bool get isExpiringSoon =>
      expirationDate != null &&
      daysUntilExpiration >= 0 &&
      daysUntilExpiration <= 7;

  ProfileModel copyWith({
    String? id,
    String? accountId,
    String? userId,
    String? platformId,
    String? platformName,
    String? profileName,
    String? profilePin,
    ProfileStatus? status,
    String? clientName,
    String? clientPhone,
    DateTime? saleDate,
    DateTime? expirationDate,
    double? price,
    List<int>? reminderDays,
    String? notes,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      userId: userId ?? this.userId,
      platformId: platformId ?? this.platformId,
      platformName: platformName ?? this.platformName,
      profileName: profileName ?? this.profileName,
      profilePin: profilePin ?? this.profilePin,
      status: status ?? this.status,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      saleDate: saleDate ?? this.saleDate,
      expirationDate: expirationDate ?? this.expirationDate,
      price: price ?? this.price,
      reminderDays: reminderDays ?? this.reminderDays,
      notes: notes ?? this.notes,
    );
  }
}
