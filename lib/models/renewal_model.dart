import 'package:cloud_firestore/cloud_firestore.dart';

class RenewalModel {
  final String id;
  final String saleId;
  final String userId;
  final String clientName;
  final String platformName;
  final String profileName;
  final DateTime renewedAt;
  final DateTime previousExpiration;
  final DateTime newExpiration;
  final double price;
  final String notes;

  RenewalModel({
    required this.id,
    required this.saleId,
    required this.userId,
    required this.clientName,
    required this.platformName,
    required this.profileName,
    required this.renewedAt,
    required this.previousExpiration,
    required this.newExpiration,
    required this.price,
    required this.notes,
  });

  factory RenewalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RenewalModel(
      id: doc.id,
      saleId: data['saleId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      clientName: data['clientName'] as String? ?? '',
      platformName: data['platformName'] as String? ?? '',
      profileName: data['profileName'] as String? ?? '',
      renewedAt: (data['renewedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      previousExpiration:
          (data['previousExpiration'] as Timestamp?)?.toDate() ?? DateTime.now(),
      newExpiration:
          (data['newExpiration'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      notes: data['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'saleId': saleId,
      'userId': userId,
      'clientName': clientName,
      'platformName': platformName,
      'profileName': profileName,
      'renewedAt': Timestamp.fromDate(renewedAt),
      'previousExpiration': Timestamp.fromDate(previousExpiration),
      'newExpiration': Timestamp.fromDate(newExpiration),
      'price': price,
      'notes': notes,
    };
  }

  /// How many days were added in this renewal
  int get daysAdded =>
      newExpiration.difference(previousExpiration).inDays;

  RenewalModel copyWith({
    String? id,
    String? saleId,
    String? userId,
    String? clientName,
    String? platformName,
    String? profileName,
    DateTime? renewedAt,
    DateTime? previousExpiration,
    DateTime? newExpiration,
    double? price,
    String? notes,
  }) {
    return RenewalModel(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      userId: userId ?? this.userId,
      clientName: clientName ?? this.clientName,
      platformName: platformName ?? this.platformName,
      profileName: profileName ?? this.profileName,
      renewedAt: renewedAt ?? this.renewedAt,
      previousExpiration: previousExpiration ?? this.previousExpiration,
      newExpiration: newExpiration ?? this.newExpiration,
      price: price ?? this.price,
      notes: notes ?? this.notes,
    );
  }
}
