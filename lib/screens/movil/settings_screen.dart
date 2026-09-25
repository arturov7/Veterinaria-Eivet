import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../controllers/movil/preferences_controller.dart';
import '../../services/movil/auth_service.dart';
import 'about_adaptation_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.embedded = false, this.onBack});

  final bool embedded;
  final VoidCallback? onBack;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _darkGreen = Color(0xFF063D32);
  static const _mint = Color(0xFFE9F7EF);
  static const _muted = Color(0xFF74827E);

  bool _uploadingPhoto = false;

  User? get _user => AuthService().getCurrentUser();

  String get _displayName {
    final user = _user;
    final metadataName = user?.userMetadata?['full_name']?.toString().trim();
    if (metadataName != null && metadataName.isNotEmpty) return metadataName;
    final savedName = context.read<PreferencesController>().name.trim();
    if (savedName.isNotEmpty) return savedName;
    final emailName = user?.email?.split('@').first;
    if (emailName != null && emailName.isNotEmpty) return emailName;
    return 'Usuario EIVET';
  }

  String get _role {
    final user = _user;
    final metadata = user?.userMetadata ?? const <String, dynamic>{};
    final appMetadata = user?.appMetadata ?? const <String, dynamic>{};
    final value =
        (metadata['role'] ??
                metadata['rol'] ??
                appMetadata['role'] ??
                appMetadata['rol'])
            ?.toString()
            .trim();
    return value == null || value.isEmpty ? 'Usuario EIVET' : value;
  }

  String? get _avatarUrl {
    final value = _user?.userMetadata?['avatar_url']?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar tu sesión en EIVET?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay una sesión iniciada.')),
      );
      return;
    }
    try {
      await AuthService().signOut();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo cerrar la sesión.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _profileContent();
    return widget.embedded
        ? content
        : Scaffold(backgroundColor: const Color(0xFFF7FAF8), body: content);
  }

  Widget _profileContent() {
    final preferences = context.watch<PreferencesController>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 22),
      children: [
        _header(),
        _profileBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: [
              _settingTile(
                icon: Icons.person_outline_rounded,
                title: 'Información personal',
                subtitle: 'Tu nombre y datos de contacto',
                onTap: _editPersonalInfo,
              ),
              const SizedBox(height: 10),
              _settingTile(
                icon: Icons.settings_rounded,
                title: 'Preferencias',
                subtitle: 'Tema, notificaciones e idioma',
                onTap: _showPreferences,
              ),
              const SizedBox(height: 10),
              _settingTile(
                icon: Icons.shield_outlined,
                title: 'Seguridad',
                subtitle: 'Cambiar contraseña y sesiones',
                onTap: _showSecurity,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesión'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE8EA),
                    foregroundColor: const Color(0xFFD52D3A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AboutAdaptationScreen(),
                  ),
                ),
                icon: const Icon(Icons.info_outline_rounded, size: 18),
                label: const Text('Sobre la aplicación'),
              ),
              if (preferences.darkMode) ...[
                const SizedBox(height: 10),
                Text(
                  'Tema oscuro activado',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(10, 5, 12, 5),
    child: SizedBox(
      height: 54,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Volver',
            onPressed: widget.onBack ?? () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
          ),
          const Expanded(
            child: Text(
              'Mi perfil',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            tooltip: 'Editar perfil',
            onPressed: _editPersonalInfo,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    ),
  );

  Widget _profileBanner() => Container(
    color: _mint,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
    child: Row(
      children: [
        _avatar(radius: 49),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF162B26),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _role,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, color: Color(0xFF667570)),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _uploadingPhoto ? null : _editPhoto,
                icon: _uploadingPhoto
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_a_photo_outlined, size: 16),
                label: Text(_uploadingPhoto ? 'Subiendo foto…' : 'Editar foto'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _darkGreen,
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _avatar({required double radius}) => CircleAvatar(
    radius: radius,
    backgroundColor: _darkGreen,
    foregroundImage: _avatarUrl == null ? null : NetworkImage(_avatarUrl!),
    onForegroundImageError: _avatarUrl == null ? null : (_, __) {},
    child: Icon(Icons.person_rounded, color: Colors.white, size: radius * 1.12),
  );

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool? status,
  }) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(19),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xFFF0F3F1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x090B3E32),
              blurRadius: 13,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: _darkGreen, size: 27),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (status != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: status ? const Color(0xFF15935D) : _muted,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: _muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF8A9994)),
          ],
        ),
      ),
    ),
  );

  Future<void> _editPersonalInfo() async {
    final nameController = TextEditingController(text: _displayName);
    final email = _user?.email ?? 'Sin correo asociado';
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Información personal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            Text('Correo: $email', style: const TextStyle(color: _muted)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, nameController.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    nameController.dispose();
    if (name == null || !mounted) return;
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      _showMessage('Escribe un nombre válido.');
      return;
    }
    try {
      final user = _user;
      if (user != null) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            data: {...user.userMetadata ?? {}, 'full_name': cleanName},
          ),
        );
      }
      await context.read<PreferencesController>().setName(cleanName);
      if (mounted) setState(() {});
      _showMessage('Información personal actualizada.');
    } catch (_) {
      _showMessage('No se pudo guardar el nombre. Intenta nuevamente.');
    }
  }

  Future<void> _editPhoto() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cambiar foto de perfil',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir desde la galería'),
              subtitle: const Text('Selecciona una imagen del celular'),
              onTap: () => Navigator.pop(sheetContext, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: const Text('Usar un enlace'),
              subtitle: const Text('Pegar la dirección de una imagen'),
              onTap: () => Navigator.pop(sheetContext, 'link'),
            ),
            if (_avatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Quitar foto actual'),
                onTap: () => Navigator.pop(sheetContext, 'remove'),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (_user == null) {
      _showMessage('Inicia sesión para guardar tu foto de perfil.');
      return;
    }
    switch (action) {
      case 'gallery':
        await _pickAndUploadPhoto();
      case 'link':
        await _editPhotoUrl();
      case 'remove':
        await _removePhoto();
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (image == null || !mounted) return;
      final extension = image.name.split('.').last.toLowerCase();
      const mimeTypes = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'webp': 'image/webp',
      };
      final contentType = mimeTypes[extension];
      if (contentType == null) {
        _showMessage('Elige una imagen JPG, PNG o WEBP.');
        return;
      }
      final bytes = await image.readAsBytes();
      if (bytes.lengthInBytes > 5 * 1024 * 1024) {
        _showMessage('La foto debe pesar como máximo 5 MB.');
        return;
      }
      setState(() => _uploadingPhoto = true);
      final user = _user;
      if (user == null) {
        _showMessage('La sesión venció. Inicia sesión nuevamente.');
        return;
      }
      final client = Supabase.instance.client;
      final path =
          '${user.id}/${DateTime.now().toUtc().millisecondsSinceEpoch}.$extension';
      await client.storage
          .from('avatars')
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );
      final publicUrl = client.storage.from('avatars').getPublicUrl(path);
      final metadata = {...user.userMetadata ?? <String, dynamic>{}}
        ..['avatar_url'] = publicUrl
        ..['avatar_path'] = path;
      await client.auth.updateUser(UserAttributes(data: metadata));
      if (mounted) {
        setState(() {});
        _showMessage('Foto de perfil actualizada.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          'No se pudo subir la foto. Verifica el bucket avatars en Supabase.',
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _editPhotoUrl() async {
    final controller = TextEditingController(text: _avatarUrl ?? '');
    final url = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar foto'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Enlace de la foto',
            hintText: 'https://…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (url == null || !mounted) return;
    final cleaned = url.trim();
    final photoUri = Uri.tryParse(cleaned);
    if (cleaned.isNotEmpty &&
        (photoUri == null ||
            !photoUri.hasAuthority ||
            !{'http', 'https'}.contains(photoUri.scheme))) {
      _showMessage('Escribe un enlace válido para la foto.');
      return;
    }
    try {
      final user = _user!;
      final metadata = {...user.userMetadata ?? <String, dynamic>{}};
      if (cleaned.isEmpty) {
        metadata.remove('avatar_url');
        metadata.remove('avatar_path');
      } else {
        metadata['avatar_url'] = cleaned;
        metadata.remove('avatar_path');
      }
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: metadata),
      );
      if (mounted) setState(() {});
      _showMessage('Foto de perfil actualizada.');
    } catch (_) {
      _showMessage('No se pudo actualizar la foto.');
    }
  }

  Future<void> _removePhoto() async {
    final user = _user;
    if (user == null) return;
    try {
      final metadata = {...user.userMetadata ?? <String, dynamic>{}}
        ..remove('avatar_url');
      final path = metadata.remove('avatar_path') as String?;
      if (path != null && path.startsWith('${user.id}/')) {
        await Supabase.instance.client.storage.from('avatars').remove([path]);
      }
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: metadata),
      );
      if (mounted) {
        setState(() {});
        _showMessage('Foto de perfil eliminada.');
      }
    } catch (_) {
      _showMessage('No se pudo quitar la foto.');
    }
  }

  Future<void> _showPreferences() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 2, 18, 22),
          child: Consumer<PreferencesController>(
            builder: (context, preferences, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Preferencias',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: preferences.darkMode,
                  title: const Text('Tema oscuro'),
                  subtitle: const Text('Se guarda en este dispositivo'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  onChanged: preferences.setDarkMode,
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.notifications_active_outlined),
                  title: Text('Notificaciones'),
                  subtitle: Text(
                    'Se muestran los avisos disponibles en la app',
                  ),
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.language_rounded),
                  title: Text('Idioma'),
                  subtitle: Text('Español'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSecurity() async {
    if (_user == null) {
      _showMessage('Inicia sesión para administrar la seguridad de tu cuenta.');
      return;
    }
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Seguridad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nueva contraseña'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'La sesión abierta en este dispositivo se conserva.',
              style: TextStyle(fontSize: 12, color: _muted),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () => Navigator.pop(dialogContext, 'others'),
              icon: const Icon(Icons.devices_outlined, size: 18),
              label: const Text('Cerrar otras sesiones'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, 'save'),
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
    final password = passwordController.text;
    final confirmation = confirmController.text;
    passwordController.dispose();
    confirmController.dispose();
    if (!mounted) return;
    if (result == 'others') {
      try {
        await Supabase.instance.client.auth.signOut(scope: SignOutScope.others);
        _showMessage('Se cerraron las otras sesiones de tu cuenta.');
      } catch (_) {
        _showMessage('No se pudieron cerrar las otras sesiones.');
      }
      return;
    }
    if (result != 'save') return;
    if (password.length < 6) {
      _showMessage('La contraseña debe tener al menos 6 caracteres.');
      return;
    }
    if (password != confirmation) {
      _showMessage('Las contraseñas no coinciden.');
      return;
    }
    try {
      await AuthService().updatePassword(password);
      _showMessage('Contraseña actualizada correctamente.');
    } catch (_) {
      _showMessage('No se pudo cambiar la contraseña.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
