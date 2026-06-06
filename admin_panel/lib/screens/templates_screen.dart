import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Global Templates')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('global_templates').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final templates = snapshot.data!.docs;
          
          return ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final doc = templates[index];
              final data = doc.data() as Map<String, dynamic>;
              
              return ListTile(
                title: Text(data['name'] ?? ''),
                subtitle: Text(data['message'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => doc.reference.delete(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Show dialog to add template
        },
      ),
    );
  }
}
