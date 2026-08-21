import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models.dart' show uid;

const maxPhotos = 8;

Future<Directory> _photosDir() async {
  final docs = await getApplicationDocumentsDirectory();
  final dir = Directory('${docs.path}/photos');
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

Future<String> _persist(String sourcePath) async {
  final dir = await _photosDir();
  final name = '${DateTime.now().millisecondsSinceEpoch}-${uid()}.jpg';
  final dest = '${dir.path}/$name';
  await File(sourcePath).copy(dest);
  return dest;
}

Future<void> _showNotice(BuildContext context, String title, String message) async {
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
    ),
  );
}

Future<List<String>> _pick(BuildContext context, bool fromCamera, int limit) async {
  final picker = ImagePicker();
  try {
    if (fromCamera) {
      final shot = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (shot == null) return [];
      return [await _persist(shot.path)];
    }
    final picked = await picker.pickMultiImage(imageQuality: 70, limit: limit);
    if (picked.isEmpty) return [];
    final results = <String>[];
    for (final img in picked.take(limit)) {
      results.add(await _persist(img.path));
    }
    return results;
  } catch (e) {
    if (context.mounted) {
      await _showNotice(
        context,
        fromCamera ? 'Camera' : 'Photos',
        fromCamera ? 'Allow camera access to take a photo.' : 'Allow photo access to attach pictures.',
      );
    }
    return [];
  }
}

/// Shows a camera/library action sheet, then returns the newly added photo
/// file paths (empty if cancelled, denied, or the photo limit is already hit).
Future<List<String>> addPhotos(BuildContext context, List<String> current) async {
  final room = maxPhotos - current.length;
  if (room <= 0) {
    await _showNotice(context, 'Photos', 'You can attach up to $maxPhotos photos.');
    return [];
  }

  if (!context.mounted) return [];
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Camera'),
            onTap: () => Navigator.pop(ctx, 'camera'),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Library'),
            onTap: () => Navigator.pop(ctx, 'library'),
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Cancel'),
            onTap: () => Navigator.pop(ctx),
          ),
        ],
      ),
    ),
  );

  if (!context.mounted) return [];
  if (choice == 'camera') return _pick(context, true, room);
  if (choice == 'library') return _pick(context, false, room);
  return [];
}

Future<void> removePhotoFile(String? uri) async {
  if (uri == null) return;
  final dir = await _photosDir();
  if (!uri.startsWith(dir.path)) return;
  try {
    final file = File(uri);
    if (await file.exists()) await file.delete();
  } catch (e) {
    debugPrint('GreaseTrail: could not delete photo: $e');
  }
}
