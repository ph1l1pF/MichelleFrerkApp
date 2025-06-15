import 'package:flutter/material.dart';
import 'package:michelle_frerk/repositories/media_item_repository.dart';
import 'package:michelle_frerk/models/media_item.dart';
import 'package:video_player/video_player.dart';

class VideoSlide extends StatefulWidget {
  final MediaItem mediaItem;

  const VideoSlide({required this.mediaItem});

  @override
  State<VideoSlide> createState() => _VideoSlideState();
}

class _VideoSlideState extends State<VideoSlide> {
  late VideoPlayerController _controller = VideoPlayerController.asset('');

  @override
  void initState() {
    super.initState();
    _downloadAndPlayVideo();
  }

  Future<void> _downloadAndPlayVideo() async {
    final file = await MediaItemRepository.get(widget.mediaItem);
    if (file == null) {
      return;
    }
    _controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
        : const Center(child: CircularProgressIndicator());
  }
}
