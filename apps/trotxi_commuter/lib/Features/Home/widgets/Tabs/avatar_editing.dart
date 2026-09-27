import 'package:dio/dio.dart' show MultipartFile;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trotxi_client/trotxi_client.dart';
import 'package:trotxi_commuter/core/config/client_metadata.dart';
import 'package:trotxi_commuter/core/config/theme/app_colors.dart';

enum _AvatarAction { camera, gallery, remove }

/// Result of a successful [AvatarEditing.editAvatar] call. `avatarUrl` is
/// the new value to store — null for a removed photo — distinct from the
/// `null` [AvatarEditing.editAvatar] itself returns on cancel/failure.
class AvatarEditOutcome {
  const AvatarEditOutcome(this.avatarUrl);
  final String? avatarUrl;
}

/// Shared "change/remove profile photo" flow — the action sheet plus the
/// `PUT`/`DELETE /v1/me/avatar` calls — for any [State] that needs it.
/// Both [ProfileTab]'s header and [PersonalInfoPage] use this so the two
/// entry points to the same edit stay in sync instead of drifting.
mixin AvatarEditing<T extends StatefulWidget> on State<T> {
  bool avatarBusy = false;

  Future<AvatarEditOutcome?> editAvatar({
    required TrotxiApiClient client,
    required bool hasAvatar,
  }) async {
    final colors = context.appColors;

    final choice = await showModalBottomSheet<_AvatarAction>(
      context: context,
      showDragHandle: true,
      backgroundColor: colors.surfaceElevated,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_AvatarAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from library'),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_AvatarAction.gallery),
            ),
            if (hasAvatar)
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: colors.error,
                ),
                title: Text(
                  'Remove photo',
                  style: TextStyle(color: colors.error),
                ),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_AvatarAction.remove),
              ),
          ],
        ),
      ),
    );

    if (choice == null || !mounted) return null;
    switch (choice) {
      case _AvatarAction.camera:
        return _pickAndUpload(client, ImageSource.camera);
      case _AvatarAction.gallery:
        return _pickAndUpload(client, ImageSource.gallery);
      case _AvatarAction.remove:
        return _remove(client);
    }
  }

  Future<AvatarEditOutcome?> _pickAndUpload(
    TrotxiApiClient client,
    ImageSource source,
  ) async {
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open the camera or library.")),
      );
      debugPrint('Error picking avatar image: $e');
      return null;
    }
    if (picked == null || !mounted) return null;

    setState(() => avatarBusy = true);
    try {
      final response = await client.getSelfApi().uploadAvatar(
        idempotencyKey: newIdempotencyKey(),
        xTrotxiClient: commuterMetadata.client,
        xTrotxiBuild: commuterMetadata.build,
        xTrotxiPlatform: commuterMetadata.platform,
        file: await MultipartFile.fromFile(picked.path, filename: picked.name),
      );
      if (!mounted) return null;
      return AvatarEditOutcome(response.data?.data.url);
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not upload photo. Try again.')),
      );
      debugPrint('Error uploading avatar: $e');
      return null;
    } finally {
      if (mounted) setState(() => avatarBusy = false);
    }
  }

  Future<AvatarEditOutcome?> _remove(TrotxiApiClient client) async {
    setState(() => avatarBusy = true);
    try {
      await client.getSelfApi().deleteAvatar(
        idempotencyKey: newIdempotencyKey(),
        xTrotxiClient: commuterMetadata.client,
        xTrotxiBuild: commuterMetadata.build,
        xTrotxiPlatform: commuterMetadata.platform,
      );
      if (!mounted) return null;
      return const AvatarEditOutcome(null);
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not remove photo. Try again.')),
      );
      debugPrint('Error removing avatar: $e');
      return null;
    } finally {
      if (mounted) setState(() => avatarBusy = false);
    }
  }
}
