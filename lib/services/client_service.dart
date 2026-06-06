import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client_model.dart';
import '../models/sale_model.dart';
import '../utils/constants.dart';

class ClientService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Update client's cached stats after a sale change
  Future<void> updateClientStats(String clientId) async {
    if (clientId.isEmpty) return;

    final salesSnap = await _db
        .collection(AppConstants.salesCollection)
        .where('clientId', isEqualTo: clientId)
        .get();

    final sales =
        salesSnap.docs.map((d) => SaleModel.fromFirestore(d)).toList();
    final totalSpent = sales.fold<double>(0, (sum, s) => sum + s.price);
    final activeCount =
        sales.where((s) => s.status == SaleStatus.active).length;

    await _db
        .collection(AppConstants.clientsCollection)
        .doc(clientId)
        .update({
      'totalSpent': totalSpent,
      'activeSubscriptions': activeCount,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Search clients by name or phone (client-side filter)
  List<ClientModel> search(List<ClientModel> clients, String query) {
    if (query.isEmpty) return clients;
    final q = query.toLowerCase();
    return clients.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.phone.contains(q) ||
          c.email.toLowerCase().contains(q);
    }).toList();
  }

  /// Find a client by phone number
  ClientModel? findByPhone(List<ClientModel> clients, String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    try {
      return clients.firstWhere((c) {
        final clientClean = c.phone.replaceAll(RegExp(r'\D'), '');
        return clientClean == clean || clientClean.endsWith(clean);
      });
    } catch (_) {
      return null;
    }
  }
}
