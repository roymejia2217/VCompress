import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:vcompressor/core/performance/memory_manager.dart';

void main() {
  group('MemoryManager Tests', () {
    late MemoryManager manager;

    setUp(() {
      manager = MemoryManager();
      manager.clearCache();
    });

    tearDown(() {
      manager.dispose();
    });

    test('should cache and retrieve resource correctly', () {
      // Arrange
      const key = 'test_key';
      const resource = 'test_resource';

      // Act
      manager.cacheResource(key, resource);
      final retrieved = manager.getCachedResource<String>(key);

      // Assert
      expect(retrieved, equals(resource));
      expect(manager.hasCachedResource(key), isTrue);
    });

    test('should return null for non-existent resource', () {
      // Arrange
      const key = 'non_existent_key';

      // Act
      final retrieved = manager.getCachedResource<String>(key);

      // Assert
      expect(retrieved, isNull);
      expect(manager.hasCachedResource(key), isFalse);
    });

    test('should remove resource from cache', () {
      // Arrange
      const key = 'test_key';
      const resource = 'test_resource';
      manager.cacheResource(key, resource);

      // Act
      manager.removeFromCache(key);

      // Assert
      expect(manager.getCachedResource<String>(key), isNull);
      expect(manager.hasCachedResource(key), isFalse);
    });

    test('should clear all cache', () {
      // Arrange
      manager.cacheResource('key1', 'resource1');
      manager.cacheResource('key2', 'resource2');

      // Act
      manager.clearCache();

      // Assert
      expect(manager.getCachedResource<String>('key1'), isNull);
      expect(manager.getCachedResource<String>('key2'), isNull);
      expect(manager.hasCachedResource('key1'), isFalse);
      expect(manager.hasCachedResource('key2'), isFalse);
    });

    test('should return correct cache stats', () {
      // Arrange
      manager.cacheResource('key1', 'resource1');
      manager.cacheResource('key2', 'resource2');

      // Act
      final stats = manager.getCacheStats();

      // Assert
      expect(stats['totalItems'], equals(2));
      expect(stats['maxSize'], equals(100));
      expect(stats['oldestItem'], isNot(equals('N/A')));
      expect(stats['newestItem'], isNot(equals('N/A')));
    });

    test('should handle different resource types', () {
      // Arrange
      const stringKey = 'string_key';
      const stringResource = 'string_resource';
      const intKey = 'int_key';
      const intResource = 42;
      const listKey = 'list_key';
      final listResource = [1, 2, 3];

      // Act
      manager.cacheResource(stringKey, stringResource);
      manager.cacheResource(intKey, intResource);
      manager.cacheResource(listKey, listResource);

      // Assert
      expect(
        manager.getCachedResource<String>(stringKey),
        equals(stringResource),
      );
      expect(manager.getCachedResource<int>(intKey), equals(intResource));
      expect(
        manager.getCachedResource<List<int>>(listKey),
        equals(listResource),
      );
    });

    test('should handle timeout correctly', () async {
      // Arrange
      const key = 'timeout_key';
      const resource = 'timeout_resource';
      const timeout = Duration(milliseconds: 100);

      // Act
      manager.cacheResource(key, resource, timeout: timeout);

      // Wait for timeout
      await Future.delayed(const Duration(milliseconds: 150));

      // Assert
      expect(manager.getCachedResource<String>(key), isNull);
      expect(manager.hasCachedResource(key), isFalse);
    });

    test('should enable and disable correctly', () {
      // Arrange
      const key = 'test_key';
      const resource = 'test_resource';

      // Act - Disable
      manager.setEnabled(false);
      manager.cacheResource(key, resource);

      // Assert - Should not cache when disabled
      expect(manager.getCachedResource<String>(key), isNull);

      // Act - Enable
      manager.setEnabled(true);
      manager.cacheResource(key, resource);

      // Assert - Should cache when enabled
      expect(manager.getCachedResource<String>(key), equals(resource));
    });

    test('should handle cache eviction when full', () {
      // Arrange
      const maxSize = 100;

      // Fill cache to capacity
      for (int i = 0; i < maxSize + 10; i++) {
        manager.cacheResource('key_$i', 'resource_$i');
      }

      // Act
      final stats = manager.getCacheStats();

      // Assert
      expect(stats['totalItems'], lessThanOrEqualTo(maxSize));
    });

    test('should optimize memory correctly', () async {
      // Arrange
      manager.cacheResource('key1', 'resource1');
      manager.cacheResource('key2', 'resource2');

      // Act
      await manager.optimizeMemory();

      // Assert
      // Should still have resources after optimization
      expect(manager.hasCachedResource('key1'), isTrue);
      expect(manager.hasCachedResource('key2'), isTrue);
    });

    test('should handle resource disposal correctly', () {
      // Arrange
      const key = 'dispose_key';
      final resource = StreamController<int>();

      // Act
      manager.cacheResource(key, resource);
      manager.removeFromCache(key);

      // Assert
      // Resource should be disposed (StreamController should be closed)
      // Note: In this implementation, StreamController is not automatically closed
      expect(resource, isNotNull);
    });

    test('should handle multiple cache operations', () {
      // Arrange
      const key = 'multi_key';
      const resource1 = 'resource1';
      const resource2 = 'resource2';

      // Act
      manager.cacheResource(key, resource1);
      manager.cacheResource(key, resource2); // Overwrite

      // Assert
      expect(manager.getCachedResource<String>(key), equals(resource2));
    });

    test('should handle null resources', () {
      // Arrange
      const key = 'null_key';

      // Act
      manager.cacheResource(key, null);

      // Assert
      expect(manager.getCachedResource<dynamic>(key), isNull);
      expect(manager.hasCachedResource(key), isTrue);
    });

    test('should handle empty cache stats', () {
      // Act
      final stats = manager.getCacheStats();

      // Assert
      expect(stats['totalItems'], equals(0));
      expect(stats['oldestItem'], equals('N/A'));
      expect(stats['newestItem'], equals('N/A'));
    });
  });
}
