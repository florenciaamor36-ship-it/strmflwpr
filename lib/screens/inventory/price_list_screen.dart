import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PriceListScreen extends StatefulWidget {
  const PriceListScreen({super.key});

  @override
  State<PriceListScreen> createState() => _PriceListScreenState();
}

class _PriceListScreenState extends State<PriceListScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final List<String> _platforms = [
    'Netflix 4K', 
    'Disney+', 
    'HBO Max', 
    'Prime Video', 
    'Star+', 
    'YouTube Premium', 
    'Spotify Premium', 
    'Crunchyroll', 
    'Combo+'
  ];

  @override
  void initState() {
    super.initState();
    for (var p in _platforms) {
      _controllers[p] = TextEditingController();
    }
    _loadPrices();
  }

  void _loadPrices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('settings').doc(user.uid).get();
    if (doc.exists && doc.data()!['prices'] != null) {
      final prices = doc.data()!['prices'] as Map<String, dynamic>;
      prices.forEach((key, value) {
        if (_controllers.containsKey(key)) {
          _controllers[key]!.text = value.toString();
        }
      });
    }
  }

  void _savePrices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, String> prices = {};
    _controllers.forEach((key, controller) {
      prices[key] = controller.text;
    });

    await FirebaseFirestore.instance.collection('settings').doc(user.uid).set({
      'prices': prices,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Precios guardados exitosamente')),
      );
    }
  }

  void _shareToWhatsApp() {
    String message = "✨ *LISTA DE PRECIOS ACTUALIZADA* ✨\n\n";
    _controllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        String emoji = "📺";
        if (key.contains('Spotify')) emoji = "🎵";
        if (key.contains('YouTube')) emoji = "🔴";
        message += "$emoji *$key:* \$${controller.text}\n";
      }
    });
    message += "\n🚀 *¡Contratá ahora y empezá a disfrutar!*";
    
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Precios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePrices,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _platforms.length,
        itemBuilder: (context, index) {
          final platform = _platforms[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _controllers[platform],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: platform,
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _shareToWhatsApp,
        label: const Text('Compartir'),
        icon: const Icon(Icons.share),
        backgroundColor: Colors.green,
      ),
    );
  }
}
