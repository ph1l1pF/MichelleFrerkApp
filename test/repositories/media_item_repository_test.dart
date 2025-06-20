import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:michelle_frerk/models/media_item.dart';
import 'package:michelle_frerk/repositories/media_item_repository.dart';

import '../mocks.mocks.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    final dir = Directory.systemTemp.createTempSync();
    return dir.path;
  }
}

void main() {
  late MediaItemRepository repository;
  late MockClient mockClient;

  setUpAll(() {
    // Override PathProvider for tests
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  setUp(() {
    mockClient = MockClient();
    repository = MediaItemRepository(client: mockClient);
  });

  group('MediaItemRepository', () {
    test('downloads and caches image file', () async {
      final mediaItem = MediaItem(locator: 'http://example.com/image.jpg', type: 'image', origin: 'network');

      when(mockClient.get(Uri.parse(mediaItem.locator)))
          .thenAnswer((_) async => http.Response.bytes(Uint8List.fromList([1, 2, 3]), 200));

      final file = await repository.get(mediaItem);

      expect(file, isA<File>());
      expect(file!.path.endsWith('.jpg'), isTrue);
    });

    test('downloads and caches video file', () async {
      final mediaItem = MediaItem(locator: 'http://example.com/video.mp4', type: 'video', origin: 'network');

      when(mockClient.get(Uri.parse(mediaItem.locator)))
          .thenAnswer((_) async => http.Response.bytes(Uint8List.fromList([4, 5, 6]), 200));

      final file = await repository.get(mediaItem);

      expect(file, isA<File>());
      expect(file!.path.endsWith('.mp4'), isTrue);
    });

    test('caches the downloaded file and returns from cache', () async {
      final mediaItem = MediaItem(locator: 'http://example.com/test.jpg', type: 'image', origin: 'network');

      when(mockClient.get(Uri.parse(mediaItem.locator)))
          .thenAnswer((_) async => http.Response.bytes(Uint8List.fromList([7, 8, 9]), 200));

      final file1 = await repository.get(mediaItem);
      final file2 = await repository.get(mediaItem);

      // Should not trigger second HTTP call
      verify(mockClient.get(Uri.parse(mediaItem.locator))).called(1);

      expect(file1!.path, file2!.path);
    });

    test('returns null if download fails', () async {
      final mediaItem = MediaItem(locator: 'http://example.com/fail.jpg', type: 'image', origin: 'network');

      when(mockClient.get(Uri.parse(mediaItem.locator)))
          .thenAnswer((_) async => http.Response('Error', 404));

      final file = await repository.get(mediaItem);

      expect(file, isNull);
    });

    test('loads all mediatems from list and caches them', () async {
      final mediaItem1 = MediaItem(locator: 'http://example.com/pic.jpg', type: 'image', origin: 'network');
      final mediaItem2 = MediaItem(locator: 'http://example.com/pic2.jpg', type: 'image', origin: 'network');

      when(mockClient.get(Uri.parse(mediaItem1.locator)))
          .thenAnswer((_) async => http.Response.bytes(Uint8List.fromList([7, 8, 9]), 200));
      when(mockClient.get(Uri.parse(mediaItem2.locator)))
      .thenAnswer((_) async => http.Response.bytes(Uint8List.fromList([7, 8, 9]), 200));

      await repository.loadAll([mediaItem1, mediaItem2]);

      await repository.get(mediaItem1);
      await repository.get(mediaItem2);

      verify(mockClient.get(Uri.parse(mediaItem1.locator))).called(1);
      verify(mockClient.get(Uri.parse(mediaItem2.locator))).called(1);
    });
  });
}
