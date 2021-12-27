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
      backlinks: <ModelBacklink>[
        ModelBacklink(name: 'notes', srcEntity: 'Note', srcField: 'topicHost')
      ]),
  ModelEntity(
      id: const IdUid(3, 8840987132589955310),
      name: 'Note',
      lastPropertyId: const IdUid(8, 5243233848208816543),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 972597120646244128),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 5493128642329471596),
            name: 'content',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 7163679847600962018),
            name: 'topicHostId',
            type: 11,
            flags: 520,
            indexId: const IdUid(4, 2152447811398348364),
            relationTarget: 'Topic'),
        ModelProperty(
            id: const IdUid(4, 5718845313534156547),
            name: 'created',
            type: 10,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 8635675070695137572),
            name: 'updated',
            type: 10,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 5957813094198534738),
            name: 'parentId',
            type: 11,
            flags: 520,
            indexId: const IdUid(5, 4678217749439454243),
            relationTarget: 'Note'),
        ModelProperty(
            id: const IdUid(7, 5816775280175756865),
            name: 'sort',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 5243233848208816543),
            name: 'dbHostType',
            type: 6,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[
        ModelBacklink(name: 'children', srcEntity: 'Note', srcField: 'parent')
      ])
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
      lastEntityId: const IdUid(3, 8840987132589955310),
      lastIndexId: const IdUid(5, 4678217749439454243),
      lastRelationId: const IdUid(0, 0),
      lastSequenceId: const IdUid(0, 0),
      retiredEntityUids: const [6982083494255468818],
      retiredIndexUids: const [],
      retiredPropertyUids: const [
        667535159863864105,
        1396143653258340247,
        3916338933042732974,
        8046029469376208444,
        2263209739778943288,
        6957555029595781360,
        7337653828649379800,
        3018144189272499669,
        1908709577643032015,
        8296804171398951893
      ],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, EntityDefinition>{
    Topic: EntityDefinition<Topic>(
        model: _entities[0],
        toOneRelations: (Topic object) => [],
        toManyRelations: (Topic object) => {
              RelInfo<Note>.toOneBacklink(
                      3, object.id, (Note srcObject) => srcObject.topicHost):
                  object.notes
            },
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
          InternalToManyAccess.setRelInfo(
              object.notes,
              store,
              RelInfo<Note>.toOneBacklink(
                  3, object.id, (Note srcObject) => srcObject.topicHost),
              store.box<Topic>());
          return object;
        }),
    Note: EntityDefinition<Note>(
        model: _entities[1],
        toOneRelations: (Note object) => [object.topicHost, object.parent],
        toManyRelations: (Note object) => {
              RelInfo<Note>.toOneBacklink(
                      6, object.id, (Note srcObject) => srcObject.parent):
                  object.children
            },
        getId: (Note object) => object.id,
        setId: (Note object, int id) {
          object.id = id;
        },
        objectToFB: (Note object, fb.Builder fbb) {
          final contentOffset = fbb.writeString(object.content);
          fbb.startTable(9);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, contentOffset);
          fbb.addInt64(2, object.topicHost.targetId);
          fbb.addInt64(3, object.created.millisecondsSinceEpoch);
          fbb.addInt64(4, object.updated.millisecondsSinceEpoch);
          fbb.addInt64(5, object.parent.targetId);
          fbb.addInt64(6, object.sort);
          fbb.addInt64(7, object.dbHostType);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = Note(
              content:
                  const fb.StringReader().vTableGet(buffer, rootOffset, 6, ''),
              sort: const fb.Int64Reader().vTableGet(buffer, rootOffset, 16, 0),
              dbHostType:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 18, 0),
              created: DateTime.fromMillisecondsSinceEpoch(
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0)),
              updated: DateTime.fromMillisecondsSinceEpoch(
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 12, 0)))
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          object.topicHost.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0);
          object.topicHost.attach(store);
          object.parent.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0);
          object.parent.attach(store);
          InternalToManyAccess.setRelInfo(
              object.children,
              store,
              RelInfo<Note>.toOneBacklink(
                  6, object.id, (Note srcObject) => srcObject.parent),
              store.box<Note>());
          return object;
        })
  };

  return ModelDefinition(model, bindings);
}

/// [Topic] entity fields to define ObjectBox queries.
class Topic_ {
  /// see [Topic.id]
  static final id = QueryIntegerProperty<Topic>(_entities[0].properties[0]);

  /// see [Topic.name]
  static final name = QueryStringProperty<Topic>(_entities[0].properties[1]);

  /// see [Topic.created]
  static final created =
      QueryIntegerProperty<Topic>(_entities[0].properties[2]);

  /// see [Topic.updated]
  static final updated =
      QueryIntegerProperty<Topic>(_entities[0].properties[3]);
}

/// [Note] entity fields to define ObjectBox queries.
class Note_ {
  /// see [Note.id]
  static final id = QueryIntegerProperty<Note>(_entities[1].properties[0]);

  /// see [Note.content]
  static final content = QueryStringProperty<Note>(_entities[1].properties[1]);

  /// see [Note.topicHost]
  static final topicHost =
      QueryRelationToOne<Note, Topic>(_entities[1].properties[2]);

  /// see [Note.created]
  static final created = QueryIntegerProperty<Note>(_entities[1].properties[3]);

  /// see [Note.updated]
  static final updated = QueryIntegerProperty<Note>(_entities[1].properties[4]);

  /// see [Note.parent]
  static final parent =
      QueryRelationToOne<Note, Note>(_entities[1].properties[5]);

  /// see [Note.sort]
  static final sort = QueryIntegerProperty<Note>(_entities[1].properties[6]);

  /// see [Note.dbHostType]
  static final dbHostType =
      QueryIntegerProperty<Note>(_entities[1].properties[7]);
}
