import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> checkSubscriptionStatus() async {
    final user = _auth.currentUser;
    if (user == null) return {'isSubscriptionValid': false};

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return {'isSubscriptionValid': false};

    final data = doc.data()!;
    final bool isPro = data['isPro'] ?? false;
    final DateTime createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final DateTime? subscriptionEndDate = (data['subscriptionEndDate'] as Timestamp?)?.toDate();

    final now = DateTime.now();
    
    // Check if Pro subscription is active
    if (isPro) {
      if (subscriptionEndDate == null || subscriptionEndDate.isAfter(now)) {
        return {'isSubscriptionValid': true, 'isPro': true};
      }
    }

    // Check if within 3-day trial
    final trialExpiry = createdAt.add(const Duration(days: 3));
    if (now.isBefore(trialExpiry)) {
      return {'isSubscriptionValid': true, 'isTrial': true, 'daysLeft': trialExpiry.difference(now).inDays};
    }

    return {
      'isSubscriptionValid': false,
      'isPro': isPro,
      'createdAt': createdAt,
      'subscriptionEndDate': subscriptionEndDate,
    };
  }

  Stream<DocumentSnapshot> get subscriptionStream {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(user.uid).snapshots();
  }
}
