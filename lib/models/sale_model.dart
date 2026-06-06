import 'package:cloud_firestore/cloud_firestore.dart';

enum SaleStatus { active, expired, renewed }

class SaleModel {
  final String id;
  final String userId;
  final String platformId;
  final String platformName;
  final String platformEmoji;
  final String accountId;
  final String accountEmail;
  final String accountPassword;
  final String profileId;
  final String profileName;
  final String profilePin;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final double price;
  final DateTime startDate;
  final DateTime expirationDate;
  final SaleStatus status;
  final List<int> reminderDays;
  final List<int> remindersSent;
  final int renewalCount;
  final DateTime? lastRenewalDate;
  final String clientToken;
  final DateTime? whatsappSentAt;
  final String notes;
  final DateTime createdAt;

  SaleModel({
    required this.id,
    required this.userId,
    required this.platformId,
    required this.platformName,
    required this.platformEmoji,
    required this.accountId,
    required this.accountEmail,
    required this.accountPassword,
    required this.profileId,
    required this.profileName,
    required this.profilePin,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.price,
    required this.startDate,
    required this.expirationDate,
    required this.status,
    required this.reminderDays,
    required this.remindersSent,
    required this.renewalCount,
    this.lastRenewalDate,
    required this.clientToken,
    this.whatsappSentAt,
    required this.notes,
    required this.createdAt,
  });

  bool get isActive => status == SaleStatus.active;
  bool get isExpired => status == SaleStatus.expired;

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final exp = DateTime(expirationDate.year, expirationDate.month, expirationDate.day);
    return exp.difference(today).inDays;
  }
  
  int get daysUntilExpiration => daysRemaining;

  factory SaleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SaleModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      platformId: data['platformId'] as String? ?? '',
      platformName: data['platformName'] as String? ?? '',
      platformEmoji: data['platformEmoji'] as String? ?? '📺',
      accountId: data['accountId'] as String? ?? '',
      accountEmail: data['accountEmail'] as String? ?? '',
      accountPassword: data['accountPassword'] as String? ?? '',
      profileId: data['profileId'] as String? ?? '',
      profileName: data['profileName'] as String? ?? '',
      profilePin: data['profilePin'] as String? ?? '',
      clientId: data['clientId'] as String? ?? '',
      clientName: data['clientName'] as String? ?? '',
      clientPhone: data['clientPhone'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expirationDate: (data['expirationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _statusFromString(data['status'] as String?),
      reminderDays: List<int>.from(data['reminderDays'] as List? ?? [1, 3, 7]),
      remindersSent: List<int>.from(data['remindersSent'] as List? ?? []),
      renewalCount: (data['renewalCount'] as num?)?.toInt() ?? 0,
      lastRenewalDate: (data['lastRenewalDate'] as Timestamp?)?.toDate(),
      clientToken: data['clientToken'] as String? ?? '',
      whatsappSentAt: (data['whatsappSentAt'] as Timestamp?)?.toDate(),
      notes: data['notes'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static SaleStatus _statusFromString(String? s) {
    switch (s) {
      case 'expired': return SaleStatus.expired;
      case 'renewed': return SaleStatus.renewed;
      default: return SaleStatus.active;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'platformId': platformId,
      'platformName': platformName,
      'platformEmoji': platformEmoji,
      'accountId': accountId,
      'accountEmail': accountEmail,
      'accountPassword': accountPassword,
      'profileId': profileId,
      'profileName': profileName,
      'profilePin': profilePin,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'price': price,
      'startDate': Timestamp.fromDate(startDate),
      'expirationDate': Timestamp.fromDate(expirationDate),
      'status': status.name,
      'reminderDays': reminderDays,
      'remindersSent': remindersSent,
      'renewalCount': renewalCount,
      'lastRenewalDate': lastRenewalDate != null ? Timestamp.fromDate(lastRenewalDate!) : null,
      'clientToken': clientToken,
      'whatsappSentAt': whatsappSentAt != null ? Timestamp.fromDate(whatsappSentAt!) : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
