import 'package:supabase_flutter/supabase_flutter.dart';

/// Adaptador de autenticación de la app móvil.
/// La UI solo conoce estas operaciones; una futura API puede reemplazarlo.
class AuthService {
  GoTrueClient get _auth => Supabase.instance.client.auth;

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;
  Session? get currentSession => _auth.currentSession;

  User? getCurrentUser() => _auth.currentUser;
  bool isAuthenticated() => currentSession != null;

  Future<AuthResponse> login(String email, String password) =>
      _auth.signInWithPassword(email: email.trim(), password: password);

  Future<AuthResponse> register(
    String email,
    String password, {
    String? name,
  }) => _auth.signUp(
    email: email.trim(),
    password: password,
    data: {'full_name': name?.trim()},
  );

  // Alias de compatibilidad para las pantallas ya implementadas.
  Future<AuthResponse> signIn(String email, String password) =>
      login(email, password);
  Future<AuthResponse> signUp(String email, String password, {String? name}) =>
      register(email, password, name: name);

  Future<void> resetPassword(String email) =>
      _auth.resetPasswordForEmail(email.trim());
  Future<UserResponse> updatePassword(String password) =>
      _auth.updateUser(UserAttributes(password: password));
  Future<void> signOut() => _auth.signOut();
}
