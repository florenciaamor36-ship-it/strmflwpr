import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  final String defaultCountryCode;

  WhatsAppService({this.defaultCountryCode = '54'});

  Future<void> sendExpirationReminder({
    required String phoneNumber,
    required String clientName,
    required String platformName,
    required DateTime expirationDate,
  }) async {
    String number = phoneNumber;
    if (!number.startsWith('+')) {
      if (number.length <= 10) {
        number = defaultCountryCode + number;
      }
    }
    
    final message = "Hola $clientName, te recordamos que tu perfil de $platformName vence el ${expirationDate.day}/${expirationDate.month}.";
    final url = "https://wa.me/$number/?text=${Uri.encodeComponent(message)}";
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
