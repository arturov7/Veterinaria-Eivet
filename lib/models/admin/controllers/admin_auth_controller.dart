import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/app_config.dart';

class AdminAuthController extends ChangeNotifier {
  AdminAuthController(this.config);
  final AppConfig config;
  bool loading = false;
  String? error;
  String name = 'Administrador DEMO', role = 'administrador';
  bool _demo = false;
  bool get authenticated =>
      _demo ||
      (config.useSupabase &&
          Supabase.instance.client.auth.currentSession != null);
  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      if (config.useSupabase) {
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
    notifyListeners();
  }
}
