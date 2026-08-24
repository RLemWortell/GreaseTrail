import 'dart:io';

import 'package:flutter/material.dart';

import '../data/photos.dart';
import '../theme.dart';

void _openViewer(BuildContext context, String uri) {
  showDialog<void>(
    context: context,
    barrierColor: const Color(0xF01A1A1A),
    builder: (ctx) => _PhotoViewer(uri: uri),
  );
}

class _PhotoViewer extends StatelessWidget {
  final String uri;
  const _PhotoViewer({required this.uri});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Center(child: Image.file(File(uri), fit: BoxFit.contain)),
            Positioned(
              top: 56,
              right: AppSpace.side,
              child: const Icon(Icons.close, size: 22, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final String uri;
  final double size;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _PhotoTile({required this.uri, required this.size, required this.onTap, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: size,
                height: size,
                color: c.photo,
                child: Image.file(File(uri), width: size, height: size, fit: BoxFit.cover),
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.ink),
                  alignment: Alignment.center,
                  child: Icon(Icons.close, size: 12, color: c.card),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Horizontal photo row. Read-only when [editable] is false and [uris] is empty
/// (renders nothing); otherwise shows an add tile when editable.
class PhotoStrip extends StatelessWidget {
  final List<String> uris;
  final ValueChanged<List<String>> onChange;
  final bool editable;

  const PhotoStrip({super.key, required this.uris, required this.onChange, this.editable = false});

  @override
  Widget build(BuildContext context) {
    if (!editable && uris.isEmpty) return const SizedBox.shrink();
    final c = AppColors.of(context);

    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < uris.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _PhotoTile(
                uri: uris[i],
                size: 72,
                onTap: () => _openViewer(context, uris[i]),
                onRemove: editable
                    ? () async {
                        await removePhotoFile(uris[i]);
                        onChange(uris.where((u) => u != uris[i]).toList());
                      }
                    : null,
              ),
            ),
          if (editable && uris.length < maxPhotos)
            GestureDetector(
              onTap: () async {
                final added = await addPhotos(context, uris);
                if (added.isNotEmpty) onChange([...uris, ...added].take(maxPhotos).toList());
              },
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: c.border)),
                alignment: Alignment.center,
                child: Icon(Icons.camera_alt_outlined, size: 22, color: c.ink),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small read-only photo thumbnails (up to 4), used under a log entry row.
class PhotoThumbs extends StatelessWidget {
  final List<String>? uris;
  final double size;

  const PhotoThumbs({super.key, this.uris, this.size = 44});

  @override
  Widget build(BuildContext context) {
    if (uris == null || uris!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final uri in uris!.take(4))
            _PhotoTile(uri: uri, size: size, onTap: () => _openViewer(context, uri)),
        ],
      ),
    );
  }
}
