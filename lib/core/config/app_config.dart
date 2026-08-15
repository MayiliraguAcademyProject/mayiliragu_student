class AppConfig {
  AppConfig._();

  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    // defaultValue: 'https://api-mayiliragu.sathishdev.in/api',
    //defaultValue: 'http://192.168.31.86:5000/api',
    defaultValue: 'http://api-stage-mayiliragu.sathishdev.in/api',
  );

  static const appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Mayiliragu',
  );

  static const apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: 'v1',
  );

  static const enableLogs = bool.fromEnvironment(
    'ENABLE_LOGS',
    defaultValue: false,
  );

  static const firebaseSenderId = String.fromEnvironment(
    'FIREBASE_SENDER_ID',
    defaultValue: '',
  );
}
