import 'package:flutter/material.dart';

enum Priority { low, medium, high }

enum ToDoFilter { alle, offen, erledigt, ueberfaellig }

enum ToDoSort { titel, prioritaet, erstellungsdatum, faelligkeitsdatum }

class ObjTodo {
  Key key = UniqueKey();
  int id;
  String title;
  String description;
  bool isCompleted = false;
  DateTime createdAt;
  DateTime dueDate;
  Priority priority;
  bool isHeader = false;
  int headerId;

  ObjTodo({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    required this.dueDate,
    required this.priority,
    required this.isHeader,
    required this.headerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted
          ? 1
          : 0, // SQLite verwendet oft 0/1 für booleans
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.index, // speichere den Index (0, 1, 2)
      'isHeader': isHeader,
      'headerId': headerId,
    };
  }

  factory ObjTodo.fromMapWithDefaults(Map<String, dynamic> map) {
    try {
      // Pflichtfelder prüfen
      if (map['id'] == null) {
        throw ArgumentError('id darf nicht null sein');
      }
      if (map['title'] == null) {
        throw ArgumentError('title darf nicht null sein');
      }
      if (map['description'] == null) {
        throw ArgumentError('description darf nicht null sein');
      }
      if (map['createdAt'] == null) {
        throw ArgumentError('createdAt darf nicht null sein');
      }
      if (map['dueDate'] == null) {
        throw ArgumentError('dueDate darf nicht null sein');
      }
      if (map['priority'] == null) {
        throw ArgumentError('priority darf nicht null sein');
      }
      if (map['isHeader'] == null) {
        throw ArgumentError('isHeader darf nicht null sein');
      }
      if (map['headerId'] == null) {
        throw ArgumentError('headerId darf nicht null sein');
      }

      return ObjTodo(
        id: map['id'] as int,
        title: map['title'] as String,
        description: map['description'] as String,
        isCompleted: map['isCompleted'] != null
            ? (map['isCompleted'] as int) == 1
            : false, // Standardwert false wenn nicht vorhanden
        createdAt: DateTime.parse(map['createdAt'] as String),
        dueDate: DateTime.parse(map['dueDate'] as String),
        priority: Priority.values[map['priority'] as int],
        isHeader: map['isHeader'] != null ? (map['isHeader'] as bool) : false,
        headerId: map['headerId'] != null ? map['headerId'] as int : 0,
      );
    } catch (e) {
      throw FormatException('Fehler beim Parsen des Todo-Objekts: $e');
    }
  }
}

class ObjHeader extends ObjTodo {
  List<ObjTodo> subTopics = [];

  ObjHeader({
    required super.id,
    required super.title,
    required super.description,
    required super.isCompleted,
    required super.createdAt,
    required super.dueDate,
    required super.priority,
    required super.isHeader,
    required super.headerId,
    required this.subTopics,
  });

  @override
  Map<String, dynamic> toMap() {
    //Map<String, dynamic> topicMap = {};

    return {
      ...super.toMap(),
      'subTopics': subTopics.map((todo) => todo.toMap()).toList(),
      '_type': 'header', // Typkennung für Unterscheidung beim Parsen
    };
  }

  factory ObjHeader.fromMapWithDefaults(Map<String, dynamic> map) {
    try {
      // Pflichtfelder prüfen (von ObjTodo)
      if (map['id'] == null) {
        throw ArgumentError('id darf nicht null sein');
      }
      if (map['title'] == null) {
        throw ArgumentError('title darf nicht null sein');
      }
      if (map['description'] == null) {
        throw ArgumentError('description darf nicht null sein');
      }
      if (map['createdAt'] == null) {
        throw ArgumentError('createdAt darf nicht null sein');
      }
      if (map['dueDate'] == null) {
        throw ArgumentError('dueDate darf nicht null sein');
      }
      if (map['priority'] == null) {
        throw ArgumentError('priority darf nicht null sein');
      }
      if (map['isHeader'] == null) {
        throw ArgumentError('isHeader darf nicht null sein');
      }
      if (map['headerId'] == null) {
        throw ArgumentError('headerId darf nicht null sein');
      }

      // SubTopics parsen
      List<ObjTodo> parsedSubTopics = [];
      if (map['subTopics'] != null) {
        parsedSubTopics = (map['subTopics'] as List)
            .map(
              (item) =>
                  ObjTodo.fromMapWithDefaults(item as Map<String, dynamic>),
            )
            .toList();
      }

      return ObjHeader(
        id: map['id'] as int,
        title: map['title'] as String,
        description: map['description'] as String,
        isCompleted: map['isCompleted'] != null
            ? (map['isCompleted'] as int) == 1
            : false,
        createdAt: DateTime.parse(map['createdAt'] as String),
        dueDate: DateTime.parse(map['dueDate'] as String),
        priority: Priority.values[map['priority'] as int],
        isHeader: map['isHeader'] != null ? (map['isHeader'] as bool) : false,
        headerId: map['headerId'] != null ? map['headerId'] as int : 0,
        subTopics: parsedSubTopics,
      );
    } catch (e) {
      throw FormatException('Fehler beim Parsen des Header-Objekts: $e');
    }
  }
}
