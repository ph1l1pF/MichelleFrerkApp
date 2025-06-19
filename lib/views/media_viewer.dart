import 'dart:io';

import 'package:flutter/material.dart';
import 'package:michelle_frerk/repositories/media_item_repository.dart';
import 'package:michelle_frerk/models/media_item.dart';
import 'package:michelle_frerk/views/videoslide.dart';
import 'package:provider/provider.dart';

class MediaViewer extends StatelessWidget {
  final MediaItem mediaItem;

  const MediaViewer({
    super.key,
    required this.mediaItem,
  });

  @override
  Widget build(BuildContext context) {
    final mediaItemRepository = Provider.of<MediaItemRepository>(context, listen: false);

    if (mediaItem.origin != 'network') {
      if (mediaItem.type == 'image' && mediaItem.origin == 'assets') {
        return InteractiveViewer(
          child: Image.asset(
            mediaItem.locator,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 80),
          ),
        );
      } else if (mediaItem.type == 'video') {
        return VideoSlide(mediaItem: mediaItem);
      } else {
        return const Icon(Icons.broken_image, size: 80);
      }
    }

    // Handle network media items using FutureBuilder
    return FutureBuilder<File?>(
      future: mediaItemRepository.get(mediaItem),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the future to complete
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Handle errors
          return const Icon(Icons.error, size: 80);
        } else if (snapshot.hasData && snapshot.data != null) {
          // Display the image if the file is available
          if (mediaItem.type == 'image') {
            return InteractiveViewer(
              child: Image.file(
                snapshot.data!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 80),
              ),
            );
          } 
          else if (mediaItem.type == 'video') {
            return VideoSlide(mediaItem: mediaItem);
          }
          else {
            return const Icon(Icons.broken_image, size: 80);
          }
        } else {
          // Handle the case where no file is found
          return const Icon(Icons.broken_image, size: 80);
        }
      },
    );
  }
}