import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/platform_model.dart';
import '../models/account_model.dart';
import '../models/profile_model.dart';
import '../models/sale_model.dart';
import '../models/client_model.dart';
import '../models/template_model.dart';
import '../models/renewal_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final String? userId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  FirestoreService({this.userId});

  Stream<List<PlatformModel>> platformsStream(String userId) {
    return _db.collection(AppConstants.platformsCollection).where('userId', isEqualTo: userId).where('isActive', isEqualTo: true).orderBy('name').snapshots().map((snap) => snap.docs.map((d) => PlatformModel.fromFirestore(d)).toList());
  }
  
  Future<String> addPlatform(PlatformModel platform) async {
    final doc = await _db.collection(AppConstants.platformsCollection).add(platform.toFirestore());
    return doc.id;
  }
  
  Future<void> updatePlatform(PlatformModel platform) async {
    await _db.collection(AppConstants.platformsCollection).doc(platform.id).update(platform.toFirestore());
  }
  
  Future<void> deletePlatform(String platformId) async {
    await _db.collection(AppConstants.platformsCollection).doc(platformId).delete();
  }
  
  Stream<List<AccountModel>> accountsStream(String userId) {
    return _db.collection(AppConstants.accountsCollection).where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).snapshots().map((snap) => snap.docs.map((d) => AccountModel.fromFirestore(d)).toList());
  }
  
  Stream<List<AccountModel>> accountsByPlatformStream(String userId, String platformId) {
    return _db.collection(AppConstants.accountsCollection).where('userId', isEqualTo: userId).where('platformId', isEqualTo: platformId).snapshots().map((snap) => snap.docs.map((d) => AccountModel.fromFirestore(d)).toList());
  }
  
  Future<String> addAccount(AccountModel account) async {
    final doc = await _db.collection(AppConstants.accountsCollection).add(account.toFirestore());
    return doc.id;
  }
  
  Future<void> updateAccount(AccountModel account) async {
    await _db.collection(AppConstants.accountsCollection).doc(account.id).update(account.toFirestore());
  }
  
  Future<void> deleteAccount(String accountId) async {
    await _db.collection(AppConstants.accountsCollection).doc(accountId).delete();
  }
  
  Stream<List<ProfileModel>> profilesStream(String userId) {
    return _db.collection(AppConstants.profilesCollection).where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).snapshots().map((snap) => snap.docs.map((d) => ProfileModel.fromFirestore(d)).toList());
  }
  
  Stream<List<ProfileModel>> profilesByAccountStream(String userId, String accountId) {
    return _db.collection(AppConstants.profilesCollection).where('userId', isEqualTo: userId).where('accountId', isEqualTo: accountId).snapshots().map((snap) => snap.docs.map((d) => ProfileModel.fromFirestore(d)).toList());
  }
  
  Stream<List<ProfileModel>> availableProfilesStream(String userId, String platformId) {
    return _db.collection(AppConstants.profilesCollection).where('userId', isEqualTo: userId).where('platformId', isEqualTo: platformId).where('status', isEqualTo: 'available').snapshots().map((snap) => snap.docs.map((d) => ProfileModel.fromFirestore(d)).toList());
  }
  
  Future<String> addProfile(ProfileModel profile) async {
    final doc = await _db.collection(AppConstants.profilesCollection).add(profile.toFirestore());
    return doc.id;
  }
  
  Future<void> updateProfile(ProfileModel profile) async {
    await _db.collection(AppConstants.profilesCollection).doc(profile.id).update(profile.toFirestore());
  }
  
  Future<void> deleteProfile(String profileId) async {
    await _db.collection(AppConstants.profilesCollection).doc(profileId).delete();
  }
  
  Stream<List<SaleModel>> salesStream(String userId) {
    return _db.collection(AppConstants.salesCollection).where('userId', isEqualTo: userId).orderBy('expirationDate').snapshots().map((snap) => snap.docs.map((d) => SaleModel.fromFirestore(d)).toList());
  }
  
  Stream<List<SaleModel>> activeSalesStream(String userId) {
    return _db.collection(AppConstants.salesCollection).where('userId', isEqualTo: userId).where('status', isEqualTo: 'active').orderBy('expirationDate').snapshots().map((snap) => snap.docs.map((d) => SaleModel.fromFirestore(d)).toList());
  }
  
  Stream<List<SaleModel>> clientSalesStream(String userId, String clientId) {
    return _db.collection(AppConstants.salesCollection).where('userId', isEqualTo: userId).where('clientId', isEqualTo: clientId).orderBy('createdAt', descending: true).snapshots().map((snap) => snap.docs.map((d) => SaleModel.fromFirestore(d)).toList());
  }
  
  Stream<Map<String, int>> dashboardStatsStream(String userId) {
    return _db.collection(AppConstants.salesCollection).where('userId', isEqualTo: userId).snapshots().map((snap) {
      final sales = snap.docs.map((d) => SaleModel.fromFirestore(d)).toList();
      final now = DateTime.now();
      final active = sales.where((s) => s.status == SaleStatus.active).length;
      final expired = sales.where((s) => s.status == SaleStatus.expired).length;
      final expiringSoon = sales.where((s) {
        if (s.status != SaleStatus.active) return false;
        final days = s.daysRemaining;
        return days >= 0 && days <= 7;
      }).length;
      final totalClients = sales.map((s) => s.clientId).toSet().length;
      final thisMonthRevenue = sales.where((s) => s.createdAt.year == now.year && s.createdAt.month == now.month).fold<double>(0, (sum, s) => sum + s.price).toInt();
      return {
        'active': active,
        'expired': expired,
        'expiringSoon': expiringSoon,
        'totalClients': totalClients,
        'thisMonthRevenue': thisMonthRevenue,
        'total': sales.length,
      };
    });
  }
  
  Future<String> addSale(SaleModel sale) async {
    final batch = _db.batch();
    final saleRef = _db.collection(AppConstants.salesCollection).doc();
    batch.set(saleRef, sale.toFirestore());
    if (sale.profileId.isNotEmpty) {
      final profileRef = _db.collection(AppConstants.profilesCollection).doc(sale.profileId);
      batch.update(profileRef, {'status': 'sold', 'currentSaleId': saleRef.id, 'currentClientName': sale.clientName});
    }
    await batch.commit();
    return saleRef.id;
  }
  
  Future<void> updateSale(SaleModel sale) async {
    await _db.collection(AppConstants.salesCollection).doc(sale.id).update(sale.toFirestore());
  }
  
  Future<void> markSaleExpired(String saleId, String profileId) async {
    final batch = _db.batch();
    final saleRef = _db.collection(AppConstants.salesCollection).doc(saleId);
    batch.update(saleRef, {'status': 'expired'});
    if (profileId.isNotEmpty) {
      final profileRef = _db.collection(AppConstants.profilesCollection).doc(profileId);
      batch.update(profileRef, {'status': 'available', 'currentSaleId': null, 'currentClientName': null});
    }
    await batch.commit();
  }
  
  Future<void> renewSale(String saleId, String profileId, DateTime newExpiration, double price, {String notes = ''}) async {
    final saleDoc = await _db.collection(AppConstants.salesCollection).doc(saleId).get();
    if (!saleDoc.exists) throw Exception('Sale not found');
    final sale = SaleModel.fromFirestore(saleDoc);
    final batch = _db.batch();
    final saleRef = _db.collection(AppConstants.salesCollection).doc(saleId);
    batch.update(saleRef, {'expirationDate': Timestamp.fromDate(newExpiration), 'status': 'active', 'renewalCount': sale.renewalCount + 1, 'lastRenewalDate': FieldValue.serverTimestamp(), 'remindersSent': []});
    final renewalRef = _db.collection(AppConstants.renewalsCollection).doc();
    final renewal = RenewalModel(id: renewalRef.id, saleId: saleId, userId: sale.userId, clientName: sale.clientName, platformName: sale.platformName, profileName: sale.profileName, renewedAt: DateTime.now(), previousExpiration: sale.expirationDate, newExpiration: newExpiration, price: price, notes: notes);
    batch.set(renewalRef, renewal.toFirestore());
    await batch.commit();
  }
  
  Future<void> deleteSale(String saleId, String profileId) async {
    final batch = _db.batch();
    batch.delete(_db.collection(AppConstants.salesCollection).doc(saleId));
    if (profileId.isNotEmpty) {
      final profileRef = _db.collection(AppConstants.profilesCollection).doc(profileId);
      batch.update(profileRef, {'status': 'available', 'currentSaleId': null, 'currentClientName': null});
    }
    await batch.commit();
  }
  
  Future<void> markReminderSent(String saleId, int daysBefore) async {
    await _db.collection(AppConstants.salesCollection).doc(saleId).update({'remindersSent': FieldValue.arrayUnion([daysBefore])});
  }
  
  Future<void> updateWhatsappSentAt(String saleId) async {
    await _db.collection(AppConstants.salesCollection).doc(saleId).update({'whatsappSentAt': FieldValue.serverTimestamp()});
  }
  
  Stream<List<ClientModel>> clientsStream(String userId) {
    return _db.collection(AppConstants.clientsCollection).where('userId', isEqualTo: userId).orderBy('name').snapshots().map((snap) => snap.docs.map((d) => ClientModel.fromFirestore(d)).toList());
  }
  
  Future<String> addClient(ClientModel client) async {
    final doc = await _db.collection(AppConstants.clientsCollection).add(client.toFirestore());
    return doc.id;
  }
  
  Future<void> updateClient(ClientModel client) async {
    await _db.collection(AppConstants.clientsCollection).doc(client.id).update(client.toFirestore());
  }
  
  Future<void> deleteClient(String clientId) async {
    await _db.collection(AppConstants.clientsCollection).doc(clientId).delete();
  }
  
  Stream<List<TemplateModel>> templatesStream(String userId) {
    return _db.collection(AppConstants.templatesCollection).where('userId', isEqualTo: userId).snapshots().map((snap) => snap.docs.map((d) => TemplateModel.fromFirestore(d)).toList());
  }
  
  Future<String> addTemplate(TemplateModel template) async {
    final doc = await _db.collection(AppConstants.templatesCollection).add(template.toFirestore());
    return doc.id;
  }
  
  Future<void> updateTemplate(TemplateModel template) async {
    await _db.collection(AppConstants.templatesCollection).doc(template.id).update(template.toFirestore());
  }
  
  Future<void> deleteTemplate(String templateId) async {
    await _db.collection(AppConstants.templatesCollection).doc(templateId).delete();
  }
  
  Stream<List<RenewalModel>> renewalsForSaleStream(String saleId) {
    return _db.collection(AppConstants.renewalsCollection).where('saleId', isEqualTo: saleId).orderBy('renewedAt', descending: true).snapshots().map((snap) => snap.docs.map((d) => RenewalModel.fromFirestore(d)).toList());
  }
  
  Stream<List<RenewalModel>> renewalsStream(String userId) {
    return _db.collection(AppConstants.renewalsCollection).where('userId', isEqualTo: userId).orderBy('renewedAt', descending: true).snapshots().map((snap) => snap.docs.map((d) => RenewalModel.fromFirestore(d)).toList());
  }
  
  Future<Map<String, double>> revenueByPlatform(String userId) async {
    final snap = await _db.collection(AppConstants.salesCollection).where('userId', isEqualTo: userId).get();
    final Map<String, double> result = {};
    for (final doc in snap.docs) {
      final sale = SaleModel.fromFirestore(doc);
      result[sale.platformName] = (result[sale.platformName] ?? 0) + sale.price;
    }
    return result;
  }
  
  Future<List<Map<String, dynamic>>> monthlyRevenue(String userId, int months) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months + 1, 1);
    final snap = await _db.collection(AppConstants.salesCollection).where('userId', isEqualTo: userId).where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate)).get();
    final Map<String, double> monthMap = {};
    for (final doc in snap.docs) {
      final sale = SaleModel.fromFirestore(doc);
      final key = '${sale.createdAt.year}-${sale.createdAt.month.toString().padLeft(2, '0')}';
      monthMap[key] = (monthMap[key] ?? 0) + sale.price;
    }
    return monthMap.entries.map((e) => {'month': e.key, 'revenue': e.value}).toList()..sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));
  }
  
  Stream<Map<String, Map<String, int>>> inventoryStream(String userId) {
    return _db.collection(AppConstants.profilesCollection).where('userId', isEqualTo: userId).snapshots().map((snap) {
      final profiles = snap.docs.map((d) => ProfileModel.fromFirestore(d)).toList();
      final Map<String, Map<String, int>> result = {};
      for (final profile in profiles) {
        final platform = profile.platformName;
        result.putIfAbsent(platform, () => {'total': 0, 'available': 0, 'sold': 0});
        result[platform]!['total'] = result[platform]!['total']! + 1;
        if (profile.status == ProfileStatus.available) {
          result[platform]!['available'] = result[platform]!['available']! + 1;
        } else if (profile.status == ProfileStatus.sold) {
          result[platform]!['sold'] = result[platform]!['sold']! + 1;
        }
      }
      return result;
    });
  }
  
  Future<SaleModel?> getSaleByToken(String token) async {
    final snap = await _db.collection(AppConstants.salesCollection).where('clientToken', isEqualTo: token).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return SaleModel.fromFirestore(snap.docs.first);
  }
  
  String generateClientToken() => _uuid.v4().replaceAll('-', '');
}
