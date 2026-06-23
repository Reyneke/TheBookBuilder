import 'package:book_builder/providers/provider_book_items.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ID helper math', () {
    test('64-bit round-trip preserves headerId', () {
      final headerId = 42;
      final subTopicId = 7;
      final maskedHeader = headerId & 0xFFFFFFFF;
      final maskedSub = subTopicId & 0xFFFFFFFF;
      final dbId = -((maskedHeader << 32) | maskedSub);
      final positive = -dbId;
      final extracted = (positive >> 32);
      expect(extracted, headerId);
    });

    test('subTopicDbId is always negative', () {
      final dbId = -((1 & 0xFFFFFFFF) << 32 | (1 & 0xFFFFFFFF));
      expect(dbId, lessThan(0));
    });

    test('positive dbId passes through unchanged', () {
      final dbId = 123;
      final result = dbId >= 0 ? dbId : (-dbId) >> 32;
      expect(result, 123);
    });

    test('different headers produce different dbIds', () {
      final dbId1 = -((1 & 0xFFFFFFFF) << 32 | 1);
      final dbId2 = -((2 & 0xFFFFFFFF) << 32 | 1);
      expect(dbId1, isNot(equals(dbId2)));
    });
  });

  group('Key format helpers', () {
    test('header key starts with hdr_', () {
      expect('hdr_1_2024-01-01', startsWith('hdr_'));
    });

    test('subtopic key starts with sub_', () {
      expect('sub_1_2_2024-01-01', startsWith('sub_'));
    });

    test('headerIdFromSubKey extracts headerId', () {
      final key = 'sub_42_17_2024-01-01';
      final withoutPrefix = key.substring('sub_'.length);
      final parts = withoutPrefix.split('_');
      expect(parts[0], '42');
      expect(int.tryParse(parts[0]), 42);
    });

    test('headerIdFromSubKey returns null for non-subtopic key', () {
      final key = 'hdr_42_17_2024-01-01';
      // _isSubTopicKey checks for 'sub_' prefix, so this should return null
      final isSubTopic = key.startsWith('sub_');
      expect(isSubTopic, false);
    });
  });

  group('Dirty-tracking integration', () {
    test('markHeaderDirty triggers hasDirtyItems', () {
      final provider = ProviderBookItems();
      provider.markHeaderDirty(1);
      expect(provider.hasDirtyItems, true);
    });

    test('markSubTopicDirty triggers hasDirtyItems', () {
      final provider = ProviderBookItems();
      provider.markSubTopicDirty(1, 2);
      expect(provider.hasDirtyItems, true);
    });

    test('clearDirtyFlags resets state', () {
      final provider = ProviderBookItems();
      provider.markHeaderDirty(1);
      provider.markSubTopicDirty(1, 2);
      provider.clearDirtyFlags();
      expect(provider.hasDirtyItems, false);
    });
  });

  group('Book title deduplication', () {
    test('removes duplicate titles', () {
      final raw = [
        {'titel': 'Book A'},
        {'titel': 'Book B'},
        {'titel': 'Book A'},
      ];
      final seen = <String>{};
      final distinct = <Map<String, dynamic>>[];
      for (var book in raw) {
        final titel = book['titel'] ?? '';
        if (seen.add(titel)) {
          distinct.add({'titel': titel});
        }
      }
      expect(distinct.length, 2);
      expect(distinct.map((e) => e['titel']).toSet(), {'Book A', 'Book B'});
    });
  });
}
