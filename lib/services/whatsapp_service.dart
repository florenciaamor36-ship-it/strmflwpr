import 'package:url_launcher/url_launcher.dart';
import '../models/sale_model.dart';

class WhatsAppService {
  final String defaultCountryCode;
  final String? businessName;

  WhatsAppService({this.defaultCountryCode = '54', this.businessName});

  Future<void> sendExpirationReminder({
    required String phoneNumber,
    required String clientName,
    required String platformName,
    required DateTime expirationDate,
  }) async {
    final message = "Hola $clientName, te recordamos que tu perfil de $platformName vence el ${expirationDate.day}/${expirationDate.month}.";
    await _launchWhatsApp(phoneNumber, message);
  }

  Future<void> sendSaleReminder(SaleModel sale) async {
    final message = "Hola ${sale.clientName}, tu perfil de ${sale.platformName} vence el ${sale.expirationDate.day}/${sale.expirationDate.month}.";
    await _launchWhatsApp(sale.clientPhone, message);
  }

  String generateSaleMessage({
    required String platformName,
    required String profileName,
    required String clientName,
    required String email,
    required String password,
    required String pin,
    required DateTime expirationDate,
    String? businessName,
  }) {
    return "Hola $clientName, gracias por tu compra de $platformName. Tus datos son:\nEmail: $email\nPassword: $password\nPerfil: $profileName\nPIN: $pin\nVence: ${expirationDate.day}/${expirationDate.month}.";
  }

  Future<void> sendWhatsAppMessage({required String phone, required String message}) async {
    await _launchWhatsApp(phone, message);
  }

  Future<void> _launchWhatsApp(String phone, String message) async {
    String number = phone;
    if (!number.startsWith('+')) {
      if (number.length <= 10) number = defaultCountryCode + number;
    }
    final url = "https://wa.me/$number/?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
