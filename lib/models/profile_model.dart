import 'package:cloud_firestore/cloud_firestore.dart';

enum ProfileStatus { available, sold, reserved, disabled }

class ProfileModel {
  final String id;
  final String userId;
  final String accountId;
  final String platformId;
  final String platformName;
  final String name;
  final String pin;
  final ProfileStatus status;
  final String? currentSaleId; // id of the active sale if sold
  final String? currentClientName; // name of current client for display
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
      name: data['name'] as String? ?? '',
      pin: data['pin'] as String? ?? '',
      status: _statusFromString(data['status'] as String?),
      currentSaleId: data['currentSaleId'] as String?,
      currentClientName: data['currentClientName'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static ProfileStatus _statusFromString(String? s) {
    switch (s) {
      case 'sold':
        return ProfileStatus.sold;
      case 'reserved':
        return ProfileStatus.reserved;
      case 'disabled':
        return ProfileStatus.disabled;
      default:
        return ProfileStatus.available;
    }
  }

  static String statusToString(ProfileStatus status) {
    switch (status) {
      case ProfileStatus.sold:
        return 'sold';
      case ProfileStatus.reserved:
        return 'reserved';
      case ProfileStatus.disabled:
        return 'disabled';
      default:
        return 'available';
    }
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
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
