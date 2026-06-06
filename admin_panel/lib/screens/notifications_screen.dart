import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendNotification(String? targetToken) async {
    // Note: To send notifications directly from Flutter Web, you usually need a Cloud Function
    // because exposing the Server Key in the client is insecure.
    // This is a placeholder for the logic.
    setState(() => _isSending = true);
    
    // Logic to call a Cloud Function or your own backend
    print("Sending notification: ${_titleController.text}");
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification request sent')));
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Center')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _bodyController, decoration: const InputDecoration(labelText: 'Body')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSending ? null : () => _sendNotification(null), // Null means all users
              child: const Text('Send to All Users'),
            ),
          ],
        ),
      ),
    );
  }
}
