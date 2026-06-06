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
  
  // Compatibility
  final bool whatsappTemplateSent;
  final DateTime? saleDate;

  SaleModel({
    required this.id,
    required this.userId,
    required this.platformId,
    required this.platformName,
    this.platformEmoji = '📺',
    required this.accountId,
    this.accountEmail = '',
    this.accountPassword = '',
    required this.profileId,
    this.profileName = '',
    this.profilePin = '',
    this.clientId = '',
    required this.clientName,
    required this.clientPhone,
    required this.price,
    DateTime? startDate,
    required this.expirationDate,
    required this.status,
    this.reminderDays = const [7, 3, 1],
    this.remindersSent = const [],
    this.renewalCount = 0,
    this.lastRenewalDate,
    this.clientToken = '',
    this.whatsappSentAt,
    this.notes = '',
    DateTime? createdAt,
    this.whatsappTemplateSent = false,
    this.saleDate,
    String? phone, // Compatibility
  }) : this.startDate = startDate ?? saleDate ?? DateTime.now(),
       this.createdAt = createdAt ?? DateTime.now(),
       this.clientPhone = phone ?? clientPhone;

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
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      expirationDate: (data['expirationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _statusFromString(data['status'] as String?),
      reminderDays: List<int>.from(data['reminderDays'] as List? ?? [1, 3, 7]),
      remindersSent: List<int>.from(data['remindersSent'] as List? ?? []),
      renewalCount: (data['renewalCount'] as num?)?.toInt() ?? 0,
      lastRenewalDate: (data['lastRenewalDate'] as Timestamp?)?.toDate(),
      clientToken: data['clientToken'] as String? ?? '',
      whatsappSentAt: (data['whatsappSentAt'] as Timestamp?)?.toDate(),
      notes: data['notes'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      whatsappTemplateSent: data['whatsappTemplateSent'] as bool? ?? false,
      saleDate: (data['saleDate'] as Timestamp?)?.toDate(),
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
      'whatsappTemplateSent': whatsappTemplateSent,
      'saleDate': saleDate != null ? Timestamp.fromDate(saleDate!) : null,
    };
  }

  SaleModel copyWith({
    String? id,
    String? userId,
    String? platformId,
    String? platformName,
    String? platformEmoji,
    String? accountId,
    String? accountEmail,
    String? accountPassword,
    String? profileId,
    String? profileName,
    String? profilePin,
    String? clientId,
    String? clientName,
    String? clientPhone,
    double? price,
    DateTime? startDate,
    DateTime? expirationDate,
    SaleStatus? status,
    List<int>? reminderDays,
    List<int>? remindersSent,
    int? renewalCount,
    DateTime? lastRenewalDate,
    String? clientToken,
    DateTime? whatsappSentAt,
    String? notes,
    DateTime? createdAt,
    bool? whatsappTemplateSent,
    DateTime? saleDate,
  }) {
    return SaleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      platformId: platformId ?? this.platformId,
      platformName: platformName ?? this.platformName,
      platformEmoji: platformEmoji ?? this.platformEmoji,
      accountId: accountId ?? this.accountId,
      accountEmail: accountEmail ?? this.accountEmail,
      accountPassword: accountPassword ?? this.accountPassword,
      profileId: profileId ?? this.profileId,
      profileName: profileName ?? this.profileName,
      profilePin: profilePin ?? this.profilePin,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
      expirationDate: expirationDate ?? this.expirationDate,
      status: status ?? this.status,
      reminderDays: reminderDays ?? this.reminderDays,
      remindersSent: remindersSent ?? this.remindersSent,
      renewalCount: renewalCount ?? this.renewalCount,
      lastRenewalDate: lastRenewalDate ?? this.lastRenewalDate,
      clientToken: clientToken ?? this.clientToken,
      whatsappSentAt: whatsappSentAt ?? this.whatsappSentAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      whatsappTemplateSent: whatsappTemplateSent ?? this.whatsappTemplateSent,
      saleDate: saleDate ?? this.saleDate,
    );
  }
}
