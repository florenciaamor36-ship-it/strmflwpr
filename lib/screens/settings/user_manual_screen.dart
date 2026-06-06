import 'package:flutter/material.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual de Usuario')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Bienvenido a strmflwpr',
            'Tu herramienta definitiva para gestionar tu negocio de reventa de servicios de streaming de forma profesional y eficiente.',
          ),
          _buildSection(
            '1. Gestión de Cuentas',
            'En la sección de Inventario puedes agregar cuentas individuales o usar la "Carga Masiva" para pegar listas de correos y contraseñas rápidamente.',
          ),
          _buildSection(
            '2. Registro de Ventas',
            'Al vender una cuenta, asígnala a un cliente. El sistema llevará el control del vencimiento y te notificará cuando esté por caducar.',
          ),
          _buildSection(
            '3. Lista de Precios',
            'Define tus precios en la sección correspondiente y compártelos con un solo click a tus grupos de WhatsApp con un formato profesional.',
          ),
          _buildSection(
            '4. Clientes',
            'Mantén una base de datos de tus clientes, sus números de contacto y su historial de compras.',
          ),
          _buildSection(
            '5. Suscripción Pro',
            'La aplicación ofrece 3 días de prueba gratuita. Luego, deberás contactar al administrador para activar tu suscripción Pro y seguir disfrutando de todas las funciones.',
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'strmflwpr v3.0.0\nDesarrollado con ❤️ para Florencia',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
