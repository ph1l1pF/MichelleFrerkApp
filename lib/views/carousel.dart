import 'package:flutter/material.dart';
import 'package:michelle_frerk/repositories/media_item_repository.dart';
import 'package:michelle_frerk/views/fullscreen_carousel.dart';
import 'package:michelle_frerk/views/media_viewer.dart';
import 'package:michelle_frerk/models/media_item.dart';
import 'package:provider/provider.dart';

class ImageCarousel extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialPage;

  const ImageCarousel({
    super.key,
    required this.mediaItems,
    this.initialPage = 0,
  });

  @override
  State<ImageCarousel> createState() => ImageCarouselState();
}

class ImageCarouselState extends State<ImageCarousel> {
  PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _controller = PageController(initialPage: widget.initialPage);

    final mediaItemRepository = Provider.of<MediaItemRepository>(context, listen: false);

  Future.microtask(() async {
    await mediaItemRepository.loadAll(
      widget.mediaItems.where((mediaItem) => mediaItem.origin == 'network').toList(),
    );
  });    
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenCarousel(
                  mediaItems: widget.mediaItems,
                  initialPage: _currentPage,
                ),
              ),
            );
          },
          child: SizedBox(
            height: 500,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.mediaItems.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final media = widget.mediaItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: MediaViewer(mediaItem: media),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.mediaItems.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.black : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void jumpToPage(int pageIndex) {
    _controller.jumpToPage(pageIndex);
    setState(() => _currentPage = pageIndex);
  }
}
