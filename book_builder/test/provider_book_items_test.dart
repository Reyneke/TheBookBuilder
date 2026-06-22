import 'package:book_builder/objects/obj_book_item.dart';
import 'package:book_builder/providers/provider_book_items.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProviderBookItems dirty-tracking', () {
    test('hasDirtyItems starts false', () {
      final provider = ProviderBookItems();
      expect(provider.hasDirtyItems, false);
    });

    test('markHeaderDirty sets hasDirtyItems true', () {
      final provider = ProviderBookItems();
      provider.markHeaderDirty(1);
      expect(provider.hasDirtyItems, true);
      expect(provider.dirtyHeaderIds, contains(1));
    });

    test('markSubTopicDirty sets hasDirtyItems true', () {
      final provider = ProviderBookItems();
      provider.markSubTopicDirty(1, 2);
      expect(provider.hasDirtyItems, true);
      expect(provider.dirtySubTopicKeys, contains('1_2'));
    });

    test('clearDirtyFlags resets state', () {
      final provider = ProviderBookItems();
      provider.markHeaderDirty(1);
      provider.markSubTopicDirty(1, 2);
      provider.clearDirtyFlags();
      expect(provider.hasDirtyItems, false);
      expect(provider.dirtyHeaderIds, isEmpty);
      expect(provider.dirtySubTopicKeys, isEmpty);
    });
  });

  group('ProviderBookItems header/subtopic operations', () {
    test('addHeader and getHeaderId work', () {
      final provider = ProviderBookItems();
      final header = ObjBookHeader(
        id: 1,
        title: 'H1',
        description: 'D',
        isCompleted: false,
        createdAt: DateTime.now(),
        dueDate: DateTime.now(),
        priority: Priority.low,
        isHeader: true,
        headerId: 0,
        bookDod: 0,
        bookCounter: 0,
        subTopics: [],
      );
      provider.addHeader(header);
      expect(provider.headerList.length, 1);
      expect(provider.getHeaderId(1).title, 'H1');
    });

    test('addItemToHeader and getSubtopicsForHeader work', () {
      final provider = ProviderBookItems();
      final header = ObjBookHeader(
        id: 1,
        title: 'H1',
        description: 'D',
        isCompleted: false,
        createdAt: DateTime.now(),
        dueDate: DateTime.now(),
        priority: Priority.low,
        isHeader: true,
        headerId: 0,
        bookDod: 0,
        bookCounter: 0,
        subTopics: [],
      );
      provider.addHeader(header);

      final item = ObjBookItem(
        id: 10,
        title: 'Sub1',
        description: 'D',
        isCompleted: false,
        createdAt: DateTime.now(),
        dueDate: DateTime.now(),
        priority: Priority.low,
        isHeader: false,
        headerId: 1,
        bookDod: 0,
        bookCounter: 0,
      );
      provider.addItemToHeader(1, item);

      final subs = provider.getSubtopicsForHeader(1);
      expect(subs.length, 1);
      expect(subs.first.title, 'Sub1');
    });

    test('getSubtopicsForHeader returns mutable list', () {
      final provider = ProviderBookItems();
      final header = ObjBookHeader(
        id: 1,
        title: 'H1',
        description: 'D',
        isCompleted: false,
        createdAt: DateTime.now(),
        dueDate: DateTime.now(),
        priority: Priority.low,
        isHeader: true,
        headerId: 0,
        bookDod: 0,
        bookCounter: 0,
        subTopics: [],
      );
      provider.addHeader(header);

      final item = ObjBookItem(
        id: 10,
        title: 'Sub1',
        description: 'D',
        isCompleted: false,
        createdAt: DateTime.now(),
        dueDate: DateTime.now(),
        priority: Priority.low,
        isHeader: false,
        headerId: 1,
        bookDod: 0,
        bookCounter: 0,
      );
      provider.addItemToHeader(1, item);

      final subs = provider.getSubtopicsForHeader(1);
      expect(() => subs.sort((a, b) => a.id.compareTo(b.id)), returnsNormally);
    });

    test('removeItemFromHeader works', () {
      final provider = ProviderBookItems();
      final header = ObjBookHeader(
        id: 1,
        title: 'H1',
        description: 'D',
        isCompleted: false,
        createdAt: DateTime.now(),
        dueDate: DateTime.now(),
        priority: Priority.low,
        isHeader: true,
        headerId: 0,
        bookDod: 0,
        bookCounter: 0,
        subTopics: [],
      );
      provider.addHeader(header);

      final item = ObjBookItem(
        id: 10,
        title: 'Sub1',
        description: 'D',
        isCompleted: false,
        createdAt: DateTime.now(),
        dueDate: DateTime.now(),
        priority: Priority.low,
        isHeader: false,
        headerId: 1,
        bookDod: 0,
        bookCounter: 0,
      );
      provider.addItemToHeader(1, item);
      expect(provider.getSubtopicsForHeader(1).length, 1);

      provider.removeItemFromHeader(1, item);
      expect(provider.getSubtopicsForHeader(1).length, 0);
    });

    test('removeHeader clears subtopics', () {
      final provider = ProviderBookItems();
      final header = ObjBookHeader(
        id: 1,
        title: 'H1',
        description: 'D',
        isCompleted: false,
        createdAt: DateTime.now(),
        dueDate: DateTime.now(),
        priority: Priority.low,
        isHeader: true,
        headerId: 0,
        bookDod: 0,
        bookCounter: 0,
        subTopics: [],
      );
      provider.addHeader(header);

      final item = ObjBookItem(
        id: 10,
        title: 'Sub1',
        description: 'D',
        isCompleted: false,
        createdAt: DateTime.now(),
        dueDate: DateTime.now(),
        priority: Priority.low,
        isHeader: false,
        headerId: 1,
        bookDod: 0,
        bookCounter: 0,
      );
      provider.addItemToHeader(1, item);
      provider.removeHeader(header);
      expect(provider.headerList.length, 0);
    });
  });
}
