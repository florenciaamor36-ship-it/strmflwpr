import 'package:cloud_firestore/cloud_firestore.dart';

enum SaleStatus { active, expired, renewed }

extension SaleStatusExtension on SaleStatus {
  String get displayName {
    switch (this) {
      case SaleStatus.active:
        return 'Activa';
      case SaleStatus.expired:
        return 'Expirada';
      case SaleStatus.renewed:
        return 'Renovada';
    }
  }

  String get value => name;

  static SaleStatus fromString(String? value) {
    switch (value) {
      case 'expired':
        return SaleStatus.expired;
      case 'renewed':
        return SaleStatus.renewed;
      default:
        return SaleStatus.active;
    }
  }
}

class SaleModel {
  final String id;
  final String userId;
  final String profileId;
  final String accountId;
  final String platformId;
  final String platformName;
  final String clientName;
  final String clientPhone;
  final DateTime saleDate;
  final DateTime expirationDate;
  final double price;
  final SaleStatus status;
  final bool whatsappTemplateSent;

  SaleModel({
    required this.id,
    required this.userId,
    required this.profileId,
    required this.accountId,
    required this.platformId,
    required this.platformName,
    required this.clientName,
    required this.clientPhone,
    required this.saleDate,
    required this.expirationDate,
    required this.price,
    this.status = SaleStatus.active,
    this.whatsappTemplateSent = false,
  });

  factory SaleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SaleModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      profileId: data['profileId'] ?? '',
      accountId: data['accountId'] ?? '',
      platformId: data['platformId'] ?? '',
      platformName: data['platformName'] ?? '',
      clientName: data['clientName'] ?? '',
      clientPhone: data['clientPhone'] ?? '',
      saleDate: (data['saleDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expirationDate: (data['expirationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: (data['price'] ?? 0.0).toDouble(),
      status: SaleStatusExtension.fromString(data['status']),
      whatsappTemplateSent: data['whatsappTemplateSent'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'profileId': profileId,
      'accountId': accountId,
      'platformId': platformId,
      'platformName': platformName,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'saleDate': Timestamp.fromDate(saleDate),
      'expirationDate': Timestamp.fromDate(expirationDate),
      'price': price,
      'status': status.value,
      'whatsappTemplateSent': whatsappTemplateSent,
    };
  }

  bool get isExpired => expirationDate.isBefore(DateTime.now());

  int get daysUntilExpiration =>
      expirationDate.difference(DateTime.now()).inDays;

  bool get isExpiringSoon =>
      daysUntilExpiration >= 0 && daysUntilExpiration <= 7;

  SaleModel copyWith({
    String? id,
    String? userId,
    String? profileId,
    String? accountId,
    String? platformId,
    String? platformName,
    String? clientName,
    String? clientPhone,
    DateTime? saleDate,
    DateTime? expirationDate,
    double? price,
    SaleStatus? status,
    bool? whatsappTemplateSent,
  }) {
    return SaleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profileId: profileId ?? this.profileId,
      accountId: accountId ?? this.accountId,
      platformId: platformId ?? this.platformId,
      platformName: platformName ?? this.platformName,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      saleDate: saleDate ?? this.saleDate,
      expirationDate: expirationDate ?? this.expirationDate,
      price: price ?? this.price,
      status: status ?? this.status,
      whatsappTemplateSent: whatsappTemplateSent ?? this.whatsappTemplateSent,
    );
  }
}
