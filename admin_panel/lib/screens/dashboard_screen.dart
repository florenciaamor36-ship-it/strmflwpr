import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_management_screen.dart';
import 'notifications_screen.dart';
import 'templates_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('strmflwpr Admin Dashboard')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('strmflwpr Admin', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User Management'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet),
              title: const Text('Templates'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TemplatesScreen())),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final users = snapshot.data!.docs;
          final totalUsers = users.length;
          final proUsers = users.where((u) => (u.data() as Map<String, dynamic>)['isPro'] == true).length;
          
          return GridView.count(
            padding: const EdgeInsets.all(24),
            crossAxisCount: 3,
            children: [
              _StatCard('Total Users', totalUsers.toString(), Colors.blue),
              _StatCard('Pro Users', proUsers.toString(), Colors.green),
              _StatCard('Trial Users', (totalUsers - proUsers).toString(), Colors.orange),
            ],
          );
        },
      ),
    );
  }

  Widget _StatCard(String title, String value, Color color) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
