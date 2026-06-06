class AppConstants {
  static const String appName = 'strmflwpr';
  static const String appVersion = '2.0.0';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String platformsCollection = 'platforms';
  static const String accountsCollection = 'accounts';
  static const String profilesCollection = 'profiles';
  static const String salesCollection = 'sales';
  static const String clientsCollection = 'clients';
  static const String templatesCollection = 'templates';
  static const String renewalsCollection = 'renewals';

  // SharedPreferences keys
  static const String prefDefaultCountryCode = 'default_country_code';
  static const String prefDefaultReminderDays = 'default_reminder_days';
  static const String prefCurrencySymbol = 'currency_symbol';
  static const String prefBusinessName = 'business_name';
  static const String prefThemeMode = 'theme_mode';
  static const String prefDisplayName = 'display_name';

  // Default values
  static const String defaultCountryCode = '54';
  static const List<int> defaultReminderDays = [1, 3, 7];
  static const String defaultCurrencySymbol = 'ARS';
  static const String defaultBusinessName = 'Mi Negocio';

  // Notification channels
  static const String expirationChannelId = 'expiration_channel';
  static const String expirationChannelName = 'Vencimientos';
  static const String lowStockChannelId = 'low_stock_channel';
  static const String lowStockChannelName = 'Stock Bajo';

  // Template variables
  static const List<String> templateVariables = [
    '{clientName}',
    '{platformName}',
    '{profileName}',
    '{email}',
    '{password}',
    '{pin}',
    '{expirationDate}',
    '{daysRemaining}',
    '{price}',
    '{businessName}',
    '{clientLink}',
  ];

  // Default templates
  static const String defaultWelcomeTemplate =
      '¡Hola {clientName}! 👋\n\n'
      'Tu acceso a *{platformName}* está listo.\n\n'
      '📧 Email: {email}\n'
      '🔑 Contraseña: {password}\n'
      '👤 Perfil: {profileName}\n'
      '🔐 PIN: {pin}\n\n'
      '📅 Vence el: {expirationDate}\n'
      '💰 Precio: \${price}\n\n'
      '🔗 Tu página personal: {clientLink}\n\n'
      'Cualquier consulta, acá estoy. ¡Que lo disfrutes! 🎬';

  static const String defaultReminderTemplate =
      'Hola {clientName}! ⏰\n\n'
      'Te recuerdo que tu *{platformName}* ({profileName}) '
      'vence en *{daysRemaining} día(s)*, el {expirationDate}.\n\n'
      '¿Renovamos? 💪';

  static const String defaultExpiredTemplate =
      'Hola {clientName}!\n\n'
      'Tu acceso a *{platformName}* ha vencido. '
      'Avisame si querés renovar 🔄';

  // Deep link scheme
  static const String deepLinkScheme = 'strmflwpr';
  static const String clientPagePath = 'client';
}
