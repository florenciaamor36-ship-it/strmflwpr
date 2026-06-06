import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/platform_model.dart';
import '../models/account_model.dart';
import '../models/profile_model.dart';
import '../models/sale_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  FirestoreService({required this.userId});

  // ─── Collection References ───────────────────────────────────────────────

  CollectionReference get _platformsRef =>
      _db.collection('users').doc(userId).collection('platforms');

  CollectionReference get _accountsRef =>
      _db.collection('users').doc(userId).collection('accounts');

  CollectionReference get _profilesRef =>
      _db.collection('users').doc(userId).collection('profiles');

  CollectionReference get _salesRef =>
      _db.collection('users').doc(userId).collection('sales');

  // ─── Platforms ────────────────────────────────────────────────────────────

  Stream<List<PlatformModel>> platformsStream() {
    return _platformsRef
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => PlatformModel.fromFirestore(d)).toList());
  }

  Future<List<PlatformModel>> getPlatforms() async {
    final snap = await _platformsRef.orderBy('name').get();
    return snap.docs.map((d) => PlatformModel.fromFirestore(d)).toList();
  }

  Future<String> addPlatform(PlatformModel platform) async {
    final doc = await _platformsRef.add(platform.toFirestore());
    return doc.id;
  }

  Future<void> updatePlatform(PlatformModel platform) async {
    await _platformsRef.doc(platform.id).update(platform.toFirestore());
  }

  Future<void> deletePlatform(String platformId) async {
    await _platformsRef.doc(platformId).delete();
  }

  // ─── Accounts ─────────────────────────────────────────────────────────────

  Stream<List<AccountModel>> accountsStream() {
    return _accountsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AccountModel.fromFirestore(d)).toList());
  }

  Stream<List<AccountModel>> accountsByPlatformStream(String platformId) {
    return _accountsRef
        .where('platformId', isEqualTo: platformId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => AccountModel.fromFirestore(d)).toList());
  }

  Future<List<AccountModel>> getAccounts() async {
    final snap = await _accountsRef.orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => AccountModel.fromFirestore(d)).toList();
  }

  Future<String> addAccount(AccountModel account) async {
    final doc = await _accountsRef.add(account.toFirestore());
    return doc.id;
  }

  Future<void> updateAccount(AccountModel account) async {
    await _accountsRef.doc(account.id).update(account.toFirestore());
  }

  Future<void> deleteAccount(String accountId) async {
    await _accountsRef.doc(accountId).delete();
  }

  // ─── Profiles ─────────────────────────────────────────────────────────────

  Stream<List<ProfileModel>> profilesStream() {
    return _profilesRef
        .orderBy('platformName')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ProfileModel.fromFirestore(d)).toList());
  }

  Stream<List<ProfileModel>> profilesByAccountStream(String accountId) {
    return _profilesRef
        .where('accountId', isEqualTo: accountId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ProfileModel.fromFirestore(d)).toList());
  }

  Stream<List<ProfileModel>> expiringSoonProfilesStream() {
    final soon = DateTime.now().add(const Duration(days: 7));
    return _profilesRef
        .where('status', isEqualTo: 'sold')
        .snapshots()
        .map((snap) {
      final profiles =
          snap.docs.map((d) => ProfileModel.fromFirestore(d)).toList();
      return profiles.where((p) {
        if (p.expirationDate == null) return false;
        return p.expirationDate!.isBefore(soon) &&
            p.expirationDate!.isAfter(DateTime.now().subtract(const Duration(days: 1)));
      }).toList()
        ..sort((a, b) =>
            a.expirationDate!.compareTo(b.expirationDate!));
    });
  }

  Future<List<ProfileModel>> getProfiles() async {
    final snap = await _profilesRef.get();
    return snap.docs.map((d) => ProfileModel.fromFirestore(d)).toList();
  }

  Future<String> addProfile(ProfileModel profile) async {
    final doc = await _profilesRef.add(profile.toFirestore());
    return doc.id;
  }

  Future<void> updateProfile(ProfileModel profile) async {
    await _profilesRef.doc(profile.id).update(profile.toFirestore());
  }

  Future<void> deleteProfile(String profileId) async {
    await _profilesRef.doc(profileId).delete();
  }

  // ─── Sales ────────────────────────────────────────────────────────────────

  Stream<List<SaleModel>> salesStream() {
    return _salesRef
        .orderBy('expirationDate')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => SaleModel.fromFirestore(d)).toList());
  }

  Stream<List<SaleModel>> activeSalesStream() {
    return _salesRef
        .where('status', isEqualTo: 'active')
        .orderBy('expirationDate')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => SaleModel.fromFirestore(d)).toList());
  }

  Future<List<SaleModel>> getSales() async {
    final snap = await _salesRef.orderBy('expirationDate').get();
    return snap.docs.map((d) => SaleModel.fromFirestore(d)).toList();
  }

  Future<String> addSale(SaleModel sale) async {
    final doc = await _salesRef.add(sale.toFirestore());
    return doc.id;
  }

  Future<void> updateSale(SaleModel sale) async {
    await _salesRef.doc(sale.id).update(sale.toFirestore());
  }

  Future<void> deleteSale(String saleId) async {
    await _salesRef.doc(saleId).delete();
  }

  // ─── Stats ────────────────────────────────────────────────────────────────

  Future<Map<String, int>> getDashboardStats() async {
    final accounts = await getAccounts();
    final sales = await getSales();
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 7));

    final activeSales = sales.where((s) => s.status == SaleStatus.active).length;
    final expiringSoon = sales.where((s) {
      return s.status == SaleStatus.active &&
          s.expirationDate.isAfter(now) &&
          s.expirationDate.isBefore(soon);
    }).length;

    return {
      'totalAccounts': accounts.length,
      'activeSales': activeSales,
      'expiringSoon': expiringSoon,
    };
  }
}
