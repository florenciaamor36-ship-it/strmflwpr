import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class BulkLoadScreen extends StatefulWidget {
  const BulkLoadScreen({super.key});

  @override
  State<BulkLoadScreen> createState() => _BulkLoadScreenState();
}

class _BulkLoadScreenState extends State<BulkLoadScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _platforms = ['Netflix', 'Disney+', 'HBO Max', 'Prime Video', 'Star+', 'YouTube', 'Spotify', 'Crunchyroll', 'Combo+'];
  String _selectedPlatform = 'Netflix';
  bool _isProcessing = false;

  void _processLoad() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final String input = _controller.text;
      final lines = input.split('\n');
      final user = FirebaseAuth.instance.currentUser;
      
      int count = 0;
      for (var line in lines) {
        if (line.trim().isEmpty) continue;

        // Simple parser: assumes "email:password" or "email password" or similar
        // Adjust regex or splitting logic as needed
        final parts = line.split(RegExp(r'[:|;,\s]')).where((e) => e.isNotEmpty).toList();
        
        if (parts.length >= 2) {
          final email = parts[0].trim();
          final password = parts[1].trim();
          
          await FirebaseFirestore.instance.collection('accounts').add({
            'userId': user?.uid,
            'platform': _selectedPlatform,
            'email': email,
            'password': password,
            'status': 'Disponible',
            'createdAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          count++;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Se cargaron $count cuentas exitosamente')),
        );
        _controller.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carga Masiva')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedPlatform,
              items: _platforms.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (val) => setState(() => _selectedPlatform = val!),
              decoration: const InputDecoration(labelText: 'Plataforma'),
            ),
            const SizedBox(height: 16),
            const Text('Pega aquí las cuentas (Formato: email:password o email password)'),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'ejemplo@mail.com:clave123\notro@mail.com:clave456',
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processLoad,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: _isProcessing 
                ? const CircularProgressIndicator() 
                : const Text('PROCESAR CARGA'),
            ),
          ],
        ),
      ),
    );
  }
}
