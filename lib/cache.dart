import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:michelle_frerk/get-products.dart';
import 'package:path_provider/path_provider.dart';

class MediaCache {
  static final Map<String, File> _cache = {};

  static loadAll(List<MediaItem> mediaItems) async {
    for (var mediaItem in mediaItems) {
      _load(mediaItem);
    }
  }

  static Future<File?> get(MediaItem mediaItem) async {
    var cached = _cache[mediaItem.locator];
    if (cached != null) {
      return cached;
    } else {
      await _load(mediaItem);
      return _cache[mediaItem.locator];
    }
  }

  static _load(MediaItem mediaItem) async {
    final file = await _downloadFile(mediaItem);
    if (file != null) {
      _cache[mediaItem.locator] = file;
    }
    else {
      print('!!!Failed to download file for ${mediaItem.locator}');
    }
  }

  static Future<File?> _downloadFile(MediaItem mediaItem) async {
    var fileName = _getRandFileName();
    // the video player need a file extension, otherwise it complains about wrong format
    if(mediaItem.type == 'image') {
      fileName += '.jpg';
    }
    if(mediaItem.type == 'video') {
      fileName += '.mp4';
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$fileName';

    final response = await http.get(Uri.parse(mediaItem.locator));
    if (response.statusCode != 200) {
      print('Failed to download video: ${response.statusCode}');
      return null;
    }
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    
    // file.length().then((length) {
    //   var lengthMB = length / 1000000.0;
    //   var type = mediaItem.type;
    //   if(lengthMB > 1 && type == 'image') {
    //     var x = mediaItem.locator;
    //     print('large image file detected: $x');
    //   }
    //   print('File size: $lengthMB MB ($type)');
    // });
    return file;
  }

  static String _getRandFileName() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNumber = random.nextInt(100000);
    return '${timestamp}_$randomNumber';
  }
}
