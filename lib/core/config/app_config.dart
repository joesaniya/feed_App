class AppConfig {
  AppConfig._();

  static const String authToken = String.fromEnvironment('AUTH_TOKEN');
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://liveapi.cness.io',
  );
}
