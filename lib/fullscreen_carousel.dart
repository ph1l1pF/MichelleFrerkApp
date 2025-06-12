import 'package:flutter/material.dart';
import 'package:michelle_frerk/get-products.dart';
import 'package:michelle_frerk/media_viewer.dart';

class FullScreenCarousel extends StatelessWidget {
  final List<MediaItem> mediaItems;
  final int initialPage;

  const FullScreenCarousel({
    super.key,
    required this.mediaItems,
    required this.initialPage,
  });

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: initialPage);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: mediaItems.length,
        itemBuilder: (context, index) {
          final media = mediaItems[index];
          return Center(
            child: MediaViewer(mediaItem: media),
          );
        },
      ),
    );
  }
}