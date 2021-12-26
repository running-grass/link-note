// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: camel_case_types

import 'dart:typed_data';

import 'package:objectbox/flatbuffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart';
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'src/note.dart';
import 'src/topic.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <ModelEntity>[
  ModelEntity(
      id: const IdUid(1, 6982083494255468818),
      name: 'Note',
      lastPropertyId: const IdUid(8, 3018144189272499669),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 8046029469376208444),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 1396143653258340247),
            name: 'heading',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 3916338933042732974),
            name: 'hostId',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 2263209739778943288),
            name: 'created',
            type: 10,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 6957555029595781360),
            name: 'updated',
            type: 10,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 7337653828649379800),
            name: 'sort',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 3018144189272499669),
            name: 'dbHostType',
            type: 6,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(2, 3776260088135967609),
      name: 'Topic',
      lastPropertyId: const IdUid(4, 4194465525803451613),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 1082495477619517297),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 1007320869159049661),
            name: 'name',
            type: 9,
            flags: 2080,
            indexId: const IdUid(1, 453444612888480580)),
        ModelProperty(
            id: const IdUid(3, 2471867717588145268),
            name: 'created',
            type: 10,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 4194465525803451613),
            name: 'updated',
            type: 10,
            flags: 8,
            indexId: const IdUid(2, 3977556944673999604))
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[])
];

/// Open an ObjectBox store with the model declared in this file.
Future<Store> openStore(
        {String? directory,
        int? maxDBSizeInKB,
        int? fileMode,
        int? maxReaders,
        bool queriesCaseSensitiveDefault = true,
        String? macosApplicationGroup}) async =>
    Store(getObjectBoxModel(),
        directory: directory ?? (await defaultStoreDirectory()).path,
        maxDBSizeInKB: maxDBSizeInKB,
        fileMode: fileMode,
        maxReaders: maxReaders,
        queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
        macosApplicationGroup: macosApplicationGroup);

/// ObjectBox model definition, pass it to [Store] - Store(getObjectBoxModel())
ModelDefinition getObjectBoxModel() {
  final model = ModelInfo(
      entities: _entities,
      lastEntityId: const IdUid(2, 3776260088135967609),
      lastIndexId: const IdUid(2, 3977556944673999604),
      lastRelationId: const IdUid(0, 0),
      lastSequenceId: const IdUid(0, 0),
      retiredEntityUids: const [],
      retiredIndexUids: const [],
      retiredPropertyUids: const [667535159863864105],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, EntityDefinition>{
    Note: EntityDefinition<Note>(
        model: _entities[0],
        toOneRelations: (Note object) => [],
        toManyRelations: (Note object) => {},
        getId: (Note object) => object.id,
        setId: (Note object, int id) {
          object.id = id;
        },
        objectToFB: (Note object, fb.Builder fbb) {
          final headingOffset = fbb.writeString(object.heading);
          fbb.startTable(9);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, headingOffset);
          fbb.addInt64(2, object.hostId);
          fbb.addInt64(3, object.created.millisecondsSinceEpoch);
          fbb.addInt64(4, object.updated.millisecondsSinceEpoch);
          fbb.addInt64(5, object.sort);
          fbb.addInt64(7, object.dbHostType);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = Note(
              heading:
                  const fb.StringReader().vTableGet(buffer, rootOffset, 6, ''),
              hostId:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0),
              sort: const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0))
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0)
            ..created = DateTime.fromMillisecondsSinceEpoch(
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0))
            ..updated = DateTime.fromMillisecondsSinceEpoch(
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 12, 0))
            ..dbHostType =
                const fb.Int64Reader().vTableGet(buffer, rootOffset, 18, 0);

          return object;
        }),
    Topic: EntityDefinition<Topic>(
        model: _entities[1],
        toOneRelations: (Topic object) => [],
        toManyRelations: (Topic object) => {},
        getId: (Topic object) => object.id,
        setId: (Topic object, int id) {
          object.id = id;
        },
        objectToFB: (Topic object, fb.Builder fbb) {
          final nameOffset = fbb.writeString(object.name);
          fbb.startTable(5);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, nameOffset);
          fbb.addInt64(2, object.created.millisecondsSinceEpoch);
          fbb.addInt64(3, object.updated.millisecondsSinceEpoch);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = Topic(
              name:
                  const fb.StringReader().vTableGet(buffer, rootOffset, 6, ''),
              created: DateTime.fromMillisecondsSinceEpoch(
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0)),
              updated: DateTime.fromMillisecondsSinceEpoch(
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0)))
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);

          return object;
        })
  };

  return ModelDefinition(model, bindings);
}

/// [Note] entity fields to define ObjectBox queries.
class Note_ {
  /// see [Note.id]
  static final id = QueryIntegerProperty<Note>(_entities[0].properties[0]);

  /// see [Note.heading]
  static final heading = QueryStringProperty<Note>(_entities[0].properties[1]);

  /// see [Note.hostId]
  static final hostId = QueryIntegerProperty<Note>(_entities[0].properties[2]);

  /// see [Note.created]
  static final created = QueryIntegerProperty<Note>(_entities[0].properties[3]);

  /// see [Note.updated]
  static final updated = QueryIntegerProperty<Note>(_entities[0].properties[4]);

  /// see [Note.sort]
  static final sort = QueryIntegerProperty<Note>(_entities[0].properties[5]);

  /// see [Note.dbHostType]
  static final dbHostType =
      QueryIntegerProperty<Note>(_entities[0].properties[6]);
}

/// [Topic] entity fields to define ObjectBox queries.
class Topic_ {
  /// see [Topic.id]
  static final id = QueryIntegerProperty<Topic>(_entities[1].properties[0]);

  /// see [Topic.name]
  static final name = QueryStringProperty<Topic>(_entities[1].properties[1]);

  /// see [Topic.created]
  static final created =
      QueryIntegerProperty<Topic>(_entities[1].properties[2]);

  /// see [Topic.updated]
  static final updated =
      QueryIntegerProperty<Topic>(_entities[1].properties[3]);
}
