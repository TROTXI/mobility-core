import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:image_picker/image_picker.dart';
import 'package:trotxi_commuter/core/api/commuter_api.dart';
import 'package:trotxi_commuter/core/config/layout/responsive_layout.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';
import 'package:trotxi_commuter/core/config/theme/app_typography.dart';

/// Full-page "Personal information" editor, pushed from ProfileTab's
/// "Personal information" row.
///
/// `displayName` and the rider's photo are the two things this page changes.
/// The photo matters beyond the profile screen: a driver checks it against the
/// person in front of them at boarding, so a missing one weakens that check.
class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({
    super.key,
    required this.client,
    required this.initialUser,
  });

  final CommuterApi client;
  final Account initialUser;

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialUser.displayName,
  );
  bool _saving = false;
  bool _uploading = false;
  /// Set once an upload returns, so the new picture shows without a round trip.
  /// Signed and short-lived: never persisted, never reused after this screen.
  String? _avatarUrl;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String get _initials {
    final trimmed = widget.initialUser.displayName.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length == 1) {
      final word = parts.first;
      return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// The types the server accepts. It reads the file's own header rather than
  /// trusting the extension, so anything else is refused however it is named.
  static const _accepted = {'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png', 'webp': 'image/webp'};

  Future<void> _onChangePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(sheet).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from library'),
              onTap: () => Navigator.of(sheet).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final XFile? picked;
    try {
      // Resized before it leaves the device: a modern phone photo is several
      // megabytes and the server caps the upload, so sending the original
      // wastes a rider's data to earn a 413. 1024px is far more than the
      // boarding screen shows.
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } on PlatformException {
      if (!mounted) return;
      _say('Trotxi needs permission to use that. Check your settings.');
      return;
    }
    if (picked == null || !mounted) return;

    final extension = picked.name.split('.').last.toLowerCase();
    final contentType = _accepted[extension];
    if (contentType == null) {
      _say('Choose a JPEG, PNG or WebP image.');
      return;
    }

    setState(() => _uploading = true);
    try {
      final Uint8List bytes = await picked.readAsBytes();
      final avatar = await widget.client.uploadAvatar(
        bytes,
        contentType: contentType,
        filename: picked.name,
      );
      if (!mounted) return;
      // The URL is signed and short-lived, so it is held only for this screen
      // and re-read from the server the next time anything needs it.
      setState(() => _avatarUrl = avatar.url);
      _say('Photo updated.');
    } on ApiException catch (error) {
      if (!mounted) return;
      _say(switch (error.statusCode) {
        413 => 'That photo is too large. Try a smaller one.',
        415 => 'That file is not an image Trotxi can read.',
        429 => 'Too many attempts. Wait a moment and try again.',
        _ => 'Could not upload that photo. Try again.',
      });
    } catch (error) {
      if (!mounted) return;
      _say('Could not upload that photo. Try again.');
      debugPrint('Avatar upload error: ${error.runtimeType}');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _say(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _onSave() async {
    final trimmed = _nameController.text.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty.')));
      return;
    }
    if (trimmed == widget.initialUser.displayName) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.client.updateAccount(trimmed);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save changes. Try again.')),
      );
      debugPrint('Profile update error: ${e.runtimeType}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final layout = ResponsiveLayoutInfo.of(context);
    final maxContentWidth = layout.select(
      phone: 520.0,
      tabletPortrait: 680.0,
      tabletLandscape: 960.0,
    );
    final horizontalPadding = layout.select(
      phone: 16.0,
      tabletPortrait: 24.0,
      tabletLandscape: 32.0,
    );

    return Scaffold(
      backgroundColor: colors.backgroundDefault,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildAvatarSection(context),
                  const SizedBox(height: 28),
                  _FieldShell(
                    label: 'Full name',
                    child: TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.textPrimary,
                      ),
                      decoration: const InputDecoration.collapsed(hintText: ''),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: colors.actionPrimaryDefault,
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: _saving ? null : _onSave,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: _saving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: colors.actionOnPrimary,
                                    ),
                                  )
                                : Text(
                                    'Save changes',
                                    style: AppTypography.buttonAction.copyWith(
                                      color: colors.actionOnPrimary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Back',
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Personal information',
          style: AppTypography.title.copyWith(color: colors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    final colors = context.appColors;
    final avatarUrl = _avatarUrl ?? widget.initialUser.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: hasAvatar
                ? null
                : colors.actionPrimaryDefault.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            image: hasAvatar
                ? DecorationImage(
                    image: NetworkImage(avatarUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: hasAvatar
              ? null
              : Center(
                  child: Text(
                    _initials,
                    style: AppTypography.heading3.copyWith(
                      color: colors.actionPrimaryDefault,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        if (_uploading)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.actionPrimaryDefault,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Uploading',
                style: AppTypography.label.copyWith(color: colors.textSecondary),
              ),
            ],
          )
        else
          // A button, not a tappable label: a GestureDetector defers hit
          // testing to its child and a bare Text does not hit test itself, so
          // this rendered correctly and never fired.
          TextButton(
            onPressed: _onChangePhoto,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              minimumSize: const Size(0, 44),
              foregroundColor: colors.actionPrimaryDefault,
            ),
            child: Text(
              hasAvatar ? 'Change photo' : 'Add a photo',
              style: AppTypography.label,
            ),
          ),
      ],
    );
  }
}

/// A labeled, rounded/bordered field container — an editable [TextField]
/// for "Full name", or a plain [Text] for the read-only/placeholder rows.
class _FieldShell extends StatelessWidget {
  const _FieldShell({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border.all(color: colors.borderSubtle),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ],
    );
  }
}
