class PhoneUtils {
  static bool hasCountryCode(String phone) {
    final clean = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return clean.startsWith('+') ||
        (clean.startsWith('0') && clean.length > 10);
  }

  static String normalize(String phone, String defaultCountryCode) {
    final clean = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (hasCountryCode(phone)) return clean;
    return '$defaultCountryCode$clean';
  }

  static String? validate(String phone) {
    if (phone.isEmpty) return 'El teléfono es requerido';
    if (!hasCountryCode(phone)) {
      return 'Agregá el código de país (ej: +54)';
    }
    return null;
  }

  /// Returns the phone number formatted for WhatsApp URL (digits only, no +)
  static String toWhatsAppNumber(String phone, String defaultCountryCode) {
    final normalized = normalize(phone, defaultCountryCode);
    return normalized.replaceAll(RegExp(r'\D'), '');
  }

  /// Masks a phone number for display privacy
  static String mask(String phone) {
    if (phone.length <= 4) return phone;
    return '${phone.substring(0, phone.length - 4)}****';
  }
}
