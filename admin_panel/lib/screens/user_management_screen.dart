import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final users = snapshot.data!.docs;
          
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final data = userDoc.data() as Map<String, dynamic>;
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
              final isPro = data['isPro'] ?? false;
              final subEnd = (data['subscriptionEndDate'] as Timestamp?)?.toDate();
              
              return ListTile(
                title: Text(data['email'] ?? 'No email'),
                subtitle: Text('Created: ${DateFormat('dd/MM/yyyy').format(createdAt)} | Pro: $isPro'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(isPro ? Icons.star : Icons.star_border, color: Colors.amber),
                      onPressed: () {
                        FirebaseFirestore.instance.collection('users').doc(userDoc.id).update({
                          'isPro': !isPro,
                          'subscriptionEndDate': !isPro ? Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))) : null,
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: subEnd ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (date != null) {
                          FirebaseFirestore.instance.collection('users').doc(userDoc.id).update({
                            'subscriptionEndDate': Timestamp.fromDate(date),
                            'isPro': true,
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
