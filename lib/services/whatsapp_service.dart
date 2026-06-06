import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/profile_model.dart';
import '../models/sale_model.dart';

class WhatsAppService {
  static final WhatsAppService _instance = WhatsAppService._internal();
  factory WhatsAppService() => _instance;
  WhatsAppService._internal();

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  /// Generate a welcome/sale message template
  String generateSaleMessage({
    required String platformName,
    required String profileName,
    required String clientName,
    required String email,
    required String password,
    required String pin,
    required DateTime expirationDate,
    String? extraNotes,
  }) {
    final expStr = _dateFormat.format(expirationDate);
    final buffer = StringBuffer();
    buffer.writeln('¡Hola $clientName! 👋');
    buffer.writeln();
    buffer.writeln('Tu perfil de *$platformName* está listo ✅');
    buffer.writeln();
    buffer.writeln('📋 *Datos de acceso:*');
    buffer.writeln('• Perfil: $profileName');
    if (email.isNotEmpty) buffer.writeln('• Email: $email');
    if (password.isNotEmpty) buffer.writeln('• Contraseña: $password');
    if (pin.isNotEmpty) buffer.writeln('• PIN: $pin');
    buffer.writeln();
    buffer.writeln('📅 *Vencimiento:* $expStr');
    buffer.writeln();
    if (extraNotes != null && extraNotes.isNotEmpty) {
      buffer.writeln('📝 $extraNotes');
      buffer.writeln();
    }
    buffer.writeln('Ante cualquier consulta, no dudes en escribirme 😊');
    return buffer.toString();
  }

  /// Generate a renewal reminder message
  String generateReminderMessage({
    required String platformName,
    required String profileName,
    required String clientName,
    required String clientPhone,
    required DateTime expirationDate,
    required int daysRemaining,
  }) {
    final expStr = _dateFormat.format(expirationDate);
    final buffer = StringBuffer();
    buffer.writeln('¡Hola $clientName! 👋');
    buffer.writeln();

    if (daysRemaining == 0) {
      buffer.writeln('⚠️ Tu perfil de *$platformName* vence *HOY*.');
    } else if (daysRemaining == 1) {
      buffer.writeln('⚠️ Tu perfil de *$platformName* vence *mañana*.');
    } else {
      buffer.writeln(
          '⏰ Tu perfil de *$platformName* vence en *$daysRemaining días* ($expStr).');
    }

    buffer.writeln();
    buffer.writeln('• Perfil: $profileName');
    buffer.writeln('• Fecha de vencimiento: $expStr');
    buffer.writeln();
    buffer.writeln('¿Deseas renovar? Avisame para coordinarlo 😊');
    return buffer.toString();
  }

  /// Generate a message from a ProfileModel
  String generateSaleMessageFromProfile({
    required ProfileModel profile,
    required String accountEmail,
    required String accountPassword,
  }) {
    return generateSaleMessage(
      platformName: profile.platformName,
      profileName: profile.profileName,
      clientName: profile.clientName.isNotEmpty ? profile.clientName : 'Cliente',
      email: accountEmail,
      password: accountPassword,
      pin: profile.profilePin,
      expirationDate: profile.expirationDate ?? DateTime.now(),
    );
  }

  /// Generate a reminder from a SaleModel
  String generateReminderFromSale(SaleModel sale) {
    return generateReminderMessage(
      platformName: sale.platformName,
      profileName: '',
      clientName: sale.clientName,
      clientPhone: sale.clientPhone,
      expirationDate: sale.expirationDate,
      daysRemaining: sale.daysUntilExpiration,
    );
  }

  /// Launch WhatsApp with a pre-filled message
  Future<bool> sendWhatsAppMessage({
    required String phone,
    required String message,
  }) async {
    // Clean phone number - remove spaces, dashes, +, etc.
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    final encodedMessage = Uri.encodeComponent(message);
    final url = 'https://wa.me/$cleanPhone?text=$encodedMessage';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // Fallback to whatsapp:// scheme
        final waUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedMessage');
        if (await canLaunchUrl(waUri)) {
          await launchUrl(waUri, mode: LaunchMode.externalApplication);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Launch WhatsApp with a SaleModel reminder
  Future<bool> sendSaleReminder(SaleModel sale) async {
    final message = generateReminderFromSale(sale);
    return sendWhatsAppMessage(
      phone: sale.clientPhone,
      message: message,
    );
  }
}
