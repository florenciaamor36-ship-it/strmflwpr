import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/subscription_screen.dart';
import 'theme.dart';

class StrmflwprApp extends StatelessWidget {
  const StrmflwprApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'strmflwpr',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeProvider.themeMode,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.user != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(authProvider.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final bool isPro = data['isPro'] ?? false;
            final DateTime createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
            final DateTime? subscriptionEndDate = (data['subscriptionEndDate'] as Timestamp?)?.toDate();
            
            final now = DateTime.now();
            bool isSubscriptionValid = false;

            // Check Pro status
            if (isPro) {
              if (subscriptionEndDate == null || subscriptionEndDate.isAfter(now)) {
                isSubscriptionValid = true;
              }
            }

            // Check Trial status (3 days)
            if (!isSubscriptionValid) {
              final trialExpiry = createdAt.add(const Duration(days: 3));
              if (now.isBefore(trialExpiry)) {
                isSubscriptionValid = true;
              }
            }

            if (isSubscriptionValid) {
              return const HomeScreen();
            } else {
              return const SubscriptionScreen();
            }
          }

          return const HomeScreen();
        },
      );
    }

    return const LoginScreen();
  }
}
