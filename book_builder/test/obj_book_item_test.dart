import 'package:book_builder/objects/obj_book_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ObjBookItem serialization round-trip', () {
    test('toMap/fromMapWithDefaults preserves all fields', () {
      final now = DateTime.now();
      final item = ObjBookItem(
        id: 42,
        title: 'Test',
        description: 'Desc',
        isCompleted: true,
        createdAt: now,
        dueDate: now,
        priority: Priority.high,
        isHeader: false,
        headerId: 1,
        bookDod: 100,
        bookCounter: 50,
      );

      final map = item.toMap();
      final restored = ObjBookItem.fromMapWithDefaults(map);

      expect(restored.id, 42);
      expect(restored.title, 'Test');
      expect(restored.description, 'Desc');
      expect(restored.isCompleted, true);
      expect(restored.priority, Priority.high);
      expect(restored.isHeader, false);
      expect(restored.headerId, 1);
      expect(restored.bookDod, 100);
      expect(restored.bookCounter, 50);
    });

    test('parses isCompleted as int 0/1', () {
      final map = <String, dynamic>{
        'id': 1,
        'title': 'T',
        'description': 'D',
        'isCompleted': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'dueDate': DateTime.now().toIso8601String(),
        'priority': 0,
        'isHeader': false,
        'headerId': 0,
      };
      final item = ObjBookItem.fromMapWithDefaults(map);
      expect(item.isCompleted, true);
    });

    test('parses isHeader as int 0/1', () {
      final map = <String, dynamic>{
        'id': 1,
        'title': 'T',
        'description': 'D',
        'isCompleted': false,
        'createdAt': DateTime.now().toIso8601String(),
        'dueDate': DateTime.now().toIso8601String(),
        'priority': 0,
        'isHeader': 1,
        'headerId': 0,
      };
      final item = ObjBookItem.fromMapWithDefaults(map);
      expect(item.isHeader, true);
    });
  });

  group('ObjBookHeader type discrimination', () {
    test('rejects _type == item', () {
      final map = <String, dynamic>{
        'id': 1,
        'title': 'T',
        'description': 'D',
        'isCompleted': false,
        'createdAt': DateTime.now().toIso8601String(),
        'dueDate': DateTime.now().toIso8601String(),
        'priority': 0,
        'isHeader': true,
        'headerId': 0,
        '_type': 'item',
      };
      expect(
        () => ObjBookHeader.fromMapWithDefaults(map),
        throwsA(isA<FormatException>()),
      );
    });

    test('accepts _type == header', () {
      final map = <String, dynamic>{
        'id': 1,
        'title': 'T',
        'description': 'D',
        'isCompleted': false,
        'createdAt': DateTime.now().toIso8601String(),
        'dueDate': DateTime.now().toIso8601String(),
        'priority': 0,
        'isHeader': true,
        'headerId': 0,
        '_type': 'header',
        'subTopics': [],
      };
      final header = ObjBookHeader.fromMapWithDefaults(map);
      expect(header.id, 1);
      expect(header.subTopics, isEmpty);
    });

    test('fallback to isHeader when _type is unknown', () {
      final map = <String, dynamic>{
        'id': 1,
        'title': 'T',
        'description': 'D',
        'isCompleted': false,
        'createdAt': DateTime.now().toIso8601String(),
        'dueDate': DateTime.now().toIso8601String(),
        'priority': 0,
        'isHeader': true,
        'headerId': 0,
        '_type': 'unknown',
        'subTopics': [],
      };
      final header = ObjBookHeader.fromMapWithDefaults(map);
      expect(header.id, 1);
    });

    test('rejects when _type unknown and isHeader is false', () {
      final map = <String, dynamic>{
        'id': 1,
        'title': 'T',
        'description': 'D',
        'isCompleted': false,
        'createdAt': DateTime.now().toIso8601String(),
        'dueDate': DateTime.now().toIso8601String(),
        'priority': 0,
        'isHeader': false,
        'headerId': 0,
        '_type': 'unknown',
        'subTopics': [],
      };
      expect(
        () => ObjBookHeader.fromMapWithDefaults(map),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
