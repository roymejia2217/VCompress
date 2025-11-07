import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:vcompressor/core/performance/memory_manager.dart';

void main() {
  group('MemoryManager Real Implementation Tests', () {
    late MemoryManager manager;

    setUp(() {
      manager = MemoryManager();
      manager.clearCache();
    });

    tearDown(() {
      manager.dispose();
    });

    test('should cache and retrieve simple resources', () {
      // Arrange
      const testKey = 'test_resource';
      const testData = 'test_value';

      // Act
      manager.cacheResource(testKey, testData);
      final retrieved = manager.getCachedResource<String>(testKey);

      // Assert
      expect(retrieved, equals(testData));
      expect(manager.hasCachedResource(testKey), isTrue);
    });

    test('should return null for uncached resources', () {
      // Act
      final retrieved = manager.getCachedResource<String>('non_existent');

      // Assert
      expect(retrieved, isNull);
      expect(manager.hasCachedResource('non_existent'), isFalse);
    });

    test('should remove resources from cache', () {
      // Arrange
      const key = 'test_key';
      manager.cacheResource(key, 'test_value');

      // Act
      manager.removeFromCache(key);
      final retrieved = manager.getCachedResource<String>(key);

      // Assert
      expect(retrieved, isNull);
      expect(manager.hasCachedResource(key), isFalse);
    });

    test('should clear all cached resources', () {
      // Arrange
      manager.cacheResource('key1', 'value1');
      manager.cacheResource('key2', 'value2');
      manager.cacheResource('key3', 'value3');

      // Act
      manager.clearCache();

      // Assert
      expect(manager.hasCachedResource('key1'), isFalse);
      expect(manager.hasCachedResource('key2'), isFalse);
      expect(manager.hasCachedResource('key3'), isFalse);
    });

    test('should provide cache statistics', () {
      // Arrange
      manager.cacheResource('key1', 'value1');
      manager.cacheResource('key2', 'value2');

      // Act
      final stats = manager.getCacheStats();

      // Assert
      expect(stats['totalItems'], equals(2));
      expect(stats['maxSize'], equals(100));
      expect(stats['oldestItem'], isNotEmpty);
      expect(stats['newestItem'], isNotEmpty);
    });

    test('should handle different resource types', () {
      // Act
      manager.cacheResource('string_key', 'string_value');
      manager.cacheResource('int_key', 42);
      manager.cacheResource('double_key', 3.14);
      manager.cacheResource('list_key', [1, 2, 3]);
      manager.cacheResource('map_key', {'nested': 'value'});

      // Assert
      expect(manager.getCachedResource<String>('string_key'),
          equals('string_value'));
      expect(manager.getCachedResource<int>('int_key'), equals(42));
      expect(manager.getCachedResource<double>('double_key'),
          closeTo(3.14, 0.01));
      expect(manager.getCachedResource<List<int>>('list_key'),
          equals([1, 2, 3]));
      expect(manager.getCachedResource<Map<String, String>>('map_key'),
          equals({'nested': 'value'}));
    });

    test('should handle cache timeout correctly', () async {
      // Arrange
      const key = 'timeout_key';
      const timeout = Duration(milliseconds: 100);

      // Act
      manager.cacheResource(key, 'timeout_value', timeout: timeout);
      expect(manager.getCachedResource<String>(key), equals('timeout_value'));

      // Wait for timeout
      await Future.delayed(const Duration(milliseconds: 150));

      // Assert - Resource should be expired
      expect(manager.getCachedResource<String>(key), isNull);
      expect(manager.hasCachedResource(key), isFalse);
    });

    test('should enable and disable functionality', () {
      // Arrange & Act
      manager.setEnabled(false);
      manager.cacheResource('key1', 'value1');

      // Assert - Should not cache when disabled
      expect(manager.getCachedResource<String>('key1'), isNull);

      // Act - Enable
      manager.setEnabled(true);
      manager.cacheResource('key2', 'value2');

      // Assert - Should cache when enabled
      expect(manager.getCachedResource<String>('key2'), equals('value2'));
    });

    test('should handle cache eviction when full', () {
      // Arrange
      const maxSize = 100;

      // Act - Add more items than max size
      for (int i = 0; i < maxSize + 20; i++) {
        manager.cacheResource('key_$i', 'resource_$i');
      }

      // Assert - Cache should not exceed max size
      final stats = manager.getCacheStats();
      expect(
        stats['totalItems'] as int,
        lessThanOrEqualTo(maxSize),
      );
    });

    test('should optimize memory correctly', () async {
      // Arrange
      manager.cacheResource('key1', 'resource1');
      manager.cacheResource('key2', 'resource2');

      // Act
      await manager.optimizeMemory();

      // Assert - Resources should still be available
      expect(manager.hasCachedResource('key1'), isTrue);
      expect(manager.hasCachedResource('key2'), isTrue);
    });

    test('should handle overwriting resources', () {
      // Arrange
      const key = 'test_key';

      // Act
      manager.cacheResource(key, 'value1');
      manager.cacheResource(key, 'value2'); // Overwrite

      // Assert
      expect(manager.getCachedResource<String>(key), equals('value2'));
    });

    test('should handle null resource caching', () {
      // Act
      manager.cacheResource('null_key', null);

      // Assert
      expect(manager.getCachedResource<dynamic>('null_key'), isNull);
      expect(manager.hasCachedResource('null_key'), isTrue);
    });

    test('should provide correct stats for empty cache', () {
      // Act
      final stats = manager.getCacheStats();

      // Assert
      expect(stats['totalItems'], equals(0));
      expect(stats['oldestItem'], equals('N/A'));
      expect(stats['newestItem'], equals('N/A'));
      expect(stats['maxSize'], equals(100));
    });

    test('should handle rapid cache operations', () {
      // Act - Rapid add/remove operations
      for (int i = 0; i < 50; i++) {
        manager.cacheResource('key_$i', 'value_$i');
      }

      for (int i = 0; i < 25; i++) {
        manager.removeFromCache('key_$i');
      }

      // Assert
      var stats = manager.getCacheStats();
      expect(stats['totalItems'], equals(25));

      // Clear and verify
      manager.clearCache();
      stats = manager.getCacheStats();
      expect(stats['totalItems'], equals(0));
    });

    test('should handle memory management with StreamController', () {
      // Arrange
      final streamController = StreamController<String>();

      // Act
      manager.cacheResource('stream_key', streamController);
      expect(manager.hasCachedResource('stream_key'), isTrue);

      // Remove and verify cleanup
      manager.removeFromCache('stream_key');
      expect(manager.hasCachedResource('stream_key'), isFalse);
    });

    test('should handle memory management with Timer', () {
      // Arrange
      final timer = Timer(const Duration(seconds: 10), () {});

      // Act
      manager.cacheResource('timer_key', timer);
      expect(manager.hasCachedResource('timer_key'), isTrue);

      // Remove and verify cleanup
      manager.removeFromCache('timer_key');
      expect(manager.hasCachedResource('timer_key'), isFalse);
    });

    test('should handle concurrent cache operations', () async {
      // Act - Concurrent operations
      final futures = <Future>[];

      for (int i = 0; i < 20; i++) {
        futures.add(Future(() {
          manager.cacheResource('key_$i', 'value_$i');
        }));
      }

      await Future.wait(futures);

      // Assert
      final stats = manager.getCacheStats();
      expect(stats['totalItems'], equals(20));
    });

    test('should preserve data integrity through multiple operations', () {
      // Arrange
      const testData = {
        'video_id': 123,
        'filename': 'test_video.mp4',
        'size': 1000000,
        'duration': 120.5,
      };

      // Act
      manager.cacheResource('video_metadata', testData);
      final retrieved1 = manager.getCachedResource<Map>('video_metadata');
      final retrieved2 = manager.getCachedResource<Map>('video_metadata');

      // Assert
      expect(retrieved1, equals(testData));
      expect(retrieved2, equals(testData));
      expect(identical(retrieved1, retrieved2), isTrue); // Same reference
    });
  });
}
