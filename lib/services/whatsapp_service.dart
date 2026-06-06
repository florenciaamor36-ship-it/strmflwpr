import 'package:url_launcher/url_launcher.dart';
import '../models/sale_model.dart';
import '../models/template_model.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import '../utils/phone_utils.dart';

class WhatsAppService {
  final String defaultCountryCode;
  final String businessName;
  final String currencySymbol;

  WhatsAppService({
    required this.defaultCountryCode,
    required this.businessName,
    required this.currencySymbol,
  });

  /// Build variables map from a sale for template rendering
  Map<String, String> _buildVariables(SaleModel sale) {
    return {
      'clientName': sale.clientName,
      'platformName': sale.platformName,
      'profileName': sale.profileName,
      'email': sale.accountEmail,
      'password': sale.accountPassword,
      'pin': sale.profilePin,
      'expirationDate': AppDateUtils.formatDate(sale.expirationDate),
      'daysRemaining': sale.daysRemaining.toString(),
      'price': '$currencySymbol ${sale.price.toStringAsFixed(0)}',
      'businessName': businessName,
      'clientLink': sale.clientPageUrl,
    };
  }

  /// Send a welcome / sale confirmation message
  Future<bool> sendWelcomeMessage(SaleModel sale,
      {TemplateModel? customTemplate}) async {
    final variables = _buildVariables(sale);
    String message;

    if (customTemplate != null) {
      message = customTemplate.render(variables);
    } else {
      message = _renderDefault(AppConstants.defaultWelcomeTemplate, variables);
    }

    return _openWhatsApp(sale.clientPhone, message);
  }

  /// Send a reminder message
  Future<bool> sendReminderMessage(SaleModel sale,
      {TemplateModel? customTemplate}) async {
    final variables = _buildVariables(sale);
    String message;

    if (customTemplate != null) {
      message = customTemplate.render(variables);
    } else {
      message = _renderDefault(AppConstants.defaultReminderTemplate, variables);
    }

    return _openWhatsApp(sale.clientPhone, message);
  }

  /// Send an expired message
  Future<bool> sendExpiredMessage(SaleModel sale,
      {TemplateModel? customTemplate}) async {
    final variables = _buildVariables(sale);
    String message;

    if (customTemplate != null) {
      message = customTemplate.render(variables);
    } else {
      message = _renderDefault(AppConstants.defaultExpiredTemplate, variables);
    }

    return _openWhatsApp(sale.clientPhone, message);
  }

  /// Send a custom message
  Future<bool> sendCustomMessage(String phone, String message) async {
    return _openWhatsApp(phone, message);
  }

  String _renderDefault(String template, Map<String, String> variables) {
    String result = template;
    variables.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  Future<bool> _openWhatsApp(String phone, String message) async {
    final number =
        PhoneUtils.toWhatsAppNumber(phone, defaultCountryCode);
    final encoded = Uri.encodeComponent(message);

    // Try wa.me deep link first (works for all versions)
    final waUrl = Uri.parse('https://wa.me/$number?text=$encoded');
    // Fallback: WhatsApp intent
    final intentUrl =
        Uri.parse('whatsapp://send?phone=$number&text=$encoded');

    try {
      if (await canLaunchUrl(intentUrl)) {
        await launchUrl(intentUrl, mode: LaunchMode.externalApplication);
        return true;
      } else if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Preview a template with sample data
  static String previewTemplate(String template) {
    return template
        .replaceAll('{clientName}', 'Juan Pérez')
        .replaceAll('{platformName}', 'Netflix')
        .replaceAll('{profileName}', 'Perfil 1')
        .replaceAll('{email}', 'cuenta@ejemplo.com')
        .replaceAll('{password}', '**contraseña**')
        .replaceAll('{pin}', '1234')
        .replaceAll('{expirationDate}', '31/12/2024')
        .replaceAll('{daysRemaining}', '30')
        .replaceAll('{price}', 'ARS 2500')
        .replaceAll('{businessName}', 'Mi Negocio')
        .replaceAll('{clientLink}', 'strmflwpr://client/abc123');
  }
}
