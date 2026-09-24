import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/app_config.dart';

class AdminAuthController extends ChangeNotifier {
  AdminAuthController(this.config) {
    if (config.useSupabase &&
        Supabase.instance.client.auth.currentSession != null) {
      _restoreSession();
    }
  }
  final AppConfig config;
  bool loading = false;
  String? error;
  String name = 'Administrador DEMO', role = 'administrador';
  bool _demo = false;
  bool _authorized = false;
  bool get authenticated => _demo ||
      (_authorized && config.useSupabase &&
          Supabase.instance.client.auth.currentSession != null);

  Future<void> _restoreSession() async {
    loading = true;
    notifyListeners();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final row = await Supabase.instance.client.from('perfiles')
          .select('nombre, rol').eq('id', user.id).maybeSingle();
      role = row?['rol']?.toString() ?? '';
      name = row?['nombre']?.toString() ?? user.email ?? '';
      _authorized = role == 'administrador' || role == 'veterinario';
      if (!_authorized) await Supabase.instance.client.auth.signOut();
    } catch (_) {
      _authorized = false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      if (config.useSupabase) {
        _authorized = false;
        await Supabase.instance.client.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        final row = await Supabase.instance.client
            .from('perfiles')
            .select()
            .eq('id', Supabase.instance.client.auth.currentUser!.id)
            .maybeSingle();
        role = row?['rol']?.toString() ?? '';
        name = row?['nombre']?.toString() ?? email;
        if (role != 'administrador' && role != 'veterinario') {
          await Supabase.instance.client.auth.signOut();
          throw StateError('Tu cuenta no tiene un rol administrativo.');
        }
        _authorized = true;
      } else {
        if (email.trim().isEmpty || password.isEmpty)
          throw StateError('Ingresa correo y contraseña.');
        _demo = true;
        name = email.split('@').first;
        role = 'administrador';
      }
      return true;
    } catch (e) {
      if (e is AuthException) {
        error =
            'Correo o contraseña incorrectos. Verifica los datos e inténtalo de nuevo.';
      } else if (e is StateError) {
        error = e.message;
      } else {
        error =
            'No se pudo iniciar sesión. Revisa tu conexión y vuelve a intentarlo.';
      }
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (config.useSupabase) await Supabase.instance.client.auth.signOut();
    _demo = false;
    _authorized = false;
    notifyListeners();
  }
}
