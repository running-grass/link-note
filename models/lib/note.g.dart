// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// CollectionGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

class _Sentinel {
  const _Sentinel();
}

const _sentinel = _Sentinel();

/// A collection reference object can be used for adding documents,
/// getting document references, and querying for documents
/// (using the methods inherited from Query).
abstract class NoteCollectionReference
    implements NoteQuery, FirestoreCollectionReference<NoteQuerySnapshot> {
  factory NoteCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$NoteCollectionReference;

  static Note fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return _$NoteFromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    Note value,
    SetOptions? options,
  ) {
    return _$NoteToJson(value);
  }

  @override
  NoteDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<NoteDocumentReference> add(Note value);
}

class _$NoteCollectionReference extends _$NoteQuery
    implements NoteCollectionReference {
  factory _$NoteCollectionReference([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$NoteCollectionReference._(
      firestore.collection('notes').withConverter(
            fromFirestore: NoteCollectionReference.fromFirestore,
            toFirestore: NoteCollectionReference.toFirestore,
          ),
    );
  }

  _$NoteCollectionReference._(
    CollectionReference<Note> reference,
  ) : super(reference, reference);

  String get path => reference.path;

  @override
  CollectionReference<Note> get reference =>
      super.reference as CollectionReference<Note>;

  @override
  NoteDocumentReference doc([String? id]) {
    return NoteDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<NoteDocumentReference> add(Note value) {
    return reference.add(value).then((ref) => NoteDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$NoteCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class NoteDocumentReference
    extends FirestoreDocumentReference<NoteDocumentSnapshot> {
  factory NoteDocumentReference(DocumentReference<Note> reference) =
      _$NoteDocumentReference;

  DocumentReference<Note> get reference;

  /// A reference to the [NoteCollectionReference] containing this document.
  NoteCollectionReference get parent {
    return _$NoteCollectionReference(reference.firestore);
  }

  @override
  Stream<NoteDocumentSnapshot> snapshots();

  @override
  Future<NoteDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    String noteId,
    String heading,
    String hostId,
    String? parentId,
    int sort,
  });

  Future<void> set(Note value);
}

class _$NoteDocumentReference
    extends FirestoreDocumentReference<NoteDocumentSnapshot>
    implements NoteDocumentReference {
  _$NoteDocumentReference(this.reference);

  @override
  final DocumentReference<Note> reference;

  /// A reference to the [NoteCollectionReference] containing this document.
  NoteCollectionReference get parent {
    return _$NoteCollectionReference(reference.firestore);
  }

  @override
  Stream<NoteDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return NoteDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<NoteDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return NoteDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<void> delete() {
    return reference.delete();
  }

  Future<void> update({
    Object? noteId = _sentinel,
    Object? heading = _sentinel,
    Object? hostId = _sentinel,
    Object? parentId = _sentinel,
    Object? sort = _sentinel,
  }) async {
    final json = {
      if (noteId != _sentinel) "noteId": noteId as String,
      if (heading != _sentinel) "heading": heading as String,
      if (hostId != _sentinel) "hostId": hostId as String,
      if (parentId != _sentinel) "parentId": parentId as String?,
      if (sort != _sentinel) "sort": sort as int,
    };

    return reference.update(json);
  }

  Future<void> set(Note value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class NoteDocumentSnapshot extends FirestoreDocumentSnapshot {
  NoteDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<Note> snapshot;

  @override
  NoteDocumentReference get reference {
    return NoteDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final Note? data;
}

abstract class NoteQuery implements QueryReference<NoteQuerySnapshot> {
  @override
  NoteQuery limit(int limit);

  @override
  NoteQuery limitToLast(int limit);

  NoteQuery whereNoteId({
    String? isEqualTo,
    String? isNotEqualTo,
    String? isLessThan,
    String? isLessThanOrEqualTo,
    String? isGreaterThan,
    String? isGreaterThanOrEqualTo,
    bool? isNull,
    List<String>? whereIn,
    List<String>? whereNotIn,
  });
  NoteQuery whereHeading({
    String? isEqualTo,
    String? isNotEqualTo,
    String? isLessThan,
    String? isLessThanOrEqualTo,
    String? isGreaterThan,
    String? isGreaterThanOrEqualTo,
    bool? isNull,
    List<String>? whereIn,
    List<String>? whereNotIn,
  });
  NoteQuery whereHostId({
    String? isEqualTo,
    String? isNotEqualTo,
    String? isLessThan,
    String? isLessThanOrEqualTo,
    String? isGreaterThan,
    String? isGreaterThanOrEqualTo,
    bool? isNull,
    List<String>? whereIn,
    List<String>? whereNotIn,
  });
  NoteQuery whereParentId({
    String? isEqualTo,
    String? isNotEqualTo,
    String? isLessThan,
    String? isLessThanOrEqualTo,
    String? isGreaterThan,
    String? isGreaterThanOrEqualTo,
    bool? isNull,
    List<String?>? whereIn,
    List<String?>? whereNotIn,
  });
  NoteQuery whereSort({
    int? isEqualTo,
    int? isNotEqualTo,
    int? isLessThan,
    int? isLessThanOrEqualTo,
    int? isGreaterThan,
    int? isGreaterThanOrEqualTo,
    bool? isNull,
    List<int>? whereIn,
    List<int>? whereNotIn,
  });

  NoteQuery orderByNoteId({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    NoteDocumentSnapshot? startAtDocument,
    NoteDocumentSnapshot? endAtDocument,
    NoteDocumentSnapshot? endBeforeDocument,
    NoteDocumentSnapshot? startAfterDocument,
  });

  NoteQuery orderByHeading({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    NoteDocumentSnapshot? startAtDocument,
    NoteDocumentSnapshot? endAtDocument,
    NoteDocumentSnapshot? endBeforeDocument,
    NoteDocumentSnapshot? startAfterDocument,
  });

  NoteQuery orderByHostId({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    NoteDocumentSnapshot? startAtDocument,
    NoteDocumentSnapshot? endAtDocument,
    NoteDocumentSnapshot? endBeforeDocument,
    NoteDocumentSnapshot? startAfterDocument,
  });

  NoteQuery orderByParentId({
    bool descending = false,
    String? startAt,
    String? startAfter,
    String? endAt,
    String? endBefore,
    NoteDocumentSnapshot? startAtDocument,
    NoteDocumentSnapshot? endAtDocument,
    NoteDocumentSnapshot? endBeforeDocument,
    NoteDocumentSnapshot? startAfterDocument,
  });

  NoteQuery orderBySort({
    bool descending = false,
    int startAt,
    int startAfter,
    int endAt,
    int endBefore,
    NoteDocumentSnapshot? startAtDocument,
    NoteDocumentSnapshot? endAtDocument,
    NoteDocumentSnapshot? endBeforeDocument,
    NoteDocumentSnapshot? startAfterDocument,
  });
}

class _$NoteQuery extends QueryReference<NoteQuerySnapshot>
    implements NoteQuery {
  _$NoteQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<Note> reference;

  NoteQuerySnapshot _decodeSnapshot(
    QuerySnapshot<Note> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return NoteQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<NoteDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: NoteDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return NoteQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<NoteQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<NoteQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  NoteQuery limit(int limit) {
    return _$NoteQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  NoteQuery limitToLast(int limit) {
    return _$NoteQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  NoteQuery whereNoteId({
    String? isEqualTo,
    String? isNotEqualTo,
    String? isLessThan,
    String? isLessThanOrEqualTo,
    String? isGreaterThan,
    String? isGreaterThanOrEqualTo,
    bool? isNull,
    List<String>? whereIn,
    List<String>? whereNotIn,
  }) {
    return _$NoteQuery(
      reference.where(
        'noteId',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  NoteQuery whereHeading({
    String? isEqualTo,
    String? isNotEqualTo,
    String? isLessThan,
    String? isLessThanOrEqualTo,
    String? isGreaterThan,
    String? isGreaterThanOrEqualTo,
    bool? isNull,
    List<String>? whereIn,
    List<String>? whereNotIn,
  }) {
    return _$NoteQuery(
      reference.where(
        'heading',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  NoteQuery whereHostId({
    String? isEqualTo,
    String? isNotEqualTo,
    String? isLessThan,
    String? isLessThanOrEqualTo,
    String? isGreaterThan,
    String? isGreaterThanOrEqualTo,
    bool? isNull,
    List<String>? whereIn,
    List<String>? whereNotIn,
  }) {
    return _$NoteQuery(
      reference.where(
        'hostId',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  NoteQuery whereParentId({
    String? isEqualTo,
    String? isNotEqualTo,
    String? isLessThan,
    String? isLessThanOrEqualTo,
    String? isGreaterThan,
    String? isGreaterThanOrEqualTo,
    bool? isNull,
    List<String?>? whereIn,
    List<String?>? whereNotIn,
  }) {
    return _$NoteQuery(
      reference.where(
        'parentId',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  NoteQuery whereSort({
    int? isEqualTo,
    int? isNotEqualTo,
    int? isLessThan,
    int? isLessThanOrEqualTo,
    int? isGreaterThan,
    int? isGreaterThanOrEqualTo,
    bool? isNull,
    List<int>? whereIn,
    List<int>? whereNotIn,
  }) {
    return _$NoteQuery(
      reference.where(
        'sort',
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        isNull: isNull,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
      ),
      _collection,
    );
  }

  NoteQuery orderByNoteId({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    NoteDocumentSnapshot? startAtDocument,
    NoteDocumentSnapshot? endAtDocument,
    NoteDocumentSnapshot? endBeforeDocument,
    NoteDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('noteId', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$NoteQuery(query, _collection);
  }

  NoteQuery orderByHeading({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    NoteDocumentSnapshot? startAtDocument,
    NoteDocumentSnapshot? endAtDocument,
    NoteDocumentSnapshot? endBeforeDocument,
    NoteDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('heading', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$NoteQuery(query, _collection);
  }

  NoteQuery orderByHostId({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    NoteDocumentSnapshot? startAtDocument,
    NoteDocumentSnapshot? endAtDocument,
    NoteDocumentSnapshot? endBeforeDocument,
    NoteDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('hostId', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$NoteQuery(query, _collection);
  }

  NoteQuery orderByParentId({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    NoteDocumentSnapshot? startAtDocument,
    NoteDocumentSnapshot? endAtDocument,
    NoteDocumentSnapshot? endBeforeDocument,
    NoteDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('parentId', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$NoteQuery(query, _collection);
  }

  NoteQuery orderBySort({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    NoteDocumentSnapshot? startAtDocument,
    NoteDocumentSnapshot? endAtDocument,
    NoteDocumentSnapshot? endBeforeDocument,
    NoteDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('sort', descending: false);

    if (startAtDocument != null) {
      query = query.startAtDocument(startAtDocument.snapshot);
    }
    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument.snapshot);
    }
    if (endAtDocument != null) {
      query = query.endAtDocument(endAtDocument.snapshot);
    }
    if (endBeforeDocument != null) {
      query = query.endBeforeDocument(endBeforeDocument.snapshot);
    }

    if (startAt != _sentinel) {
      query = query.startAt([startAt]);
    }
    if (startAfter != _sentinel) {
      query = query.startAfter([startAfter]);
    }
    if (endAt != _sentinel) {
      query = query.endAt([endAt]);
    }
    if (endBefore != _sentinel) {
      query = query.endBefore([endBefore]);
    }

    return _$NoteQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$NoteQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class NoteQuerySnapshot
    extends FirestoreQuerySnapshot<NoteQueryDocumentSnapshot> {
  NoteQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<Note> snapshot;

  @override
  final List<NoteQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<NoteDocumentSnapshot>> docChanges;
}

class NoteQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements NoteDocumentSnapshot {
  NoteQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<Note> snapshot;

  @override
  NoteDocumentReference get reference {
    return NoteDocumentReference(snapshot.reference);
  }

  @override
  final Note data;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      noteId: json['noteId'] as String,
      heading: json['heading'] as String,
      hostType: $enumDecode(_$HostTypeEnumMap, json['hostType']),
      hostId: json['hostId'] as String,
      created: DateTime.parse(json['created'] as String),
      updated: DateTime.parse(json['updated'] as String),
      parentId: json['parentId'] as String?,
      sort: json['sort'] as int,
    );

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'noteId': instance.noteId,
      'heading': instance.heading,
      'hostType': _$HostTypeEnumMap[instance.hostType],
      'hostId': instance.hostId,
      'created': instance.created.toIso8601String(),
      'updated': instance.updated.toIso8601String(),
      'parentId': instance.parentId,
      'sort': instance.sort,
    };

const _$HostTypeEnumMap = {
  HostType.topic: 'topic',
  HostType.goal: 'goal',
};
