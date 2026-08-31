enum AppMode { demo, supabase }
class AppConfig {
  const AppConfig({required this.requestedMode, required this.supabaseUrl, required this.supabasePublishableKey});
  final AppMode requestedMode; final String supabaseUrl; final String supabasePublishableKey;
  factory AppConfig.fromEnvironment() => const AppConfig(requestedMode: String.fromEnvironment('APP_MODE', defaultValue: 'demo') == 'supabase' ? AppMode.supabase : AppMode.demo, supabaseUrl: String.fromEnvironment('SUPABASE_URL'), supabasePublishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'));
  bool get hasSupabaseCredentials => supabaseUrl.startsWith('https://') && supabasePublishableKey.isNotEmpty;
  bool get useSupabase => requestedMode == AppMode.supabase && hasSupabaseCredentials;
  String get modeLabel => useSupabase ? 'Supabase' : 'DEMO local';
}
