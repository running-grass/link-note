// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

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
abstract class TopicCollectionReference
    implements TopicQuery, FirestoreCollectionReference<TopicQuerySnapshot> {
  factory TopicCollectionReference([
    FirebaseFirestore? firestore,
  ]) = _$TopicCollectionReference;

  static Topic fromFirestore(
    DocumentSnapshot<Map<String, Object?>> snapshot,
    SnapshotOptions? options,
  ) {
    return _$TopicFromJson(snapshot.data()!);
  }

  static Map<String, Object?> toFirestore(
    Topic value,
    SetOptions? options,
  ) {
    return _$TopicToJson(value);
  }

  @override
  TopicDocumentReference doc([String? id]);

  /// Add a new document to this collection with the specified data,
  /// assigning it a document ID automatically.
  Future<TopicDocumentReference> add(Topic value);
}

class _$TopicCollectionReference extends _$TopicQuery
    implements TopicCollectionReference {
  factory _$TopicCollectionReference([FirebaseFirestore? firestore]) {
    firestore ??= FirebaseFirestore.instance;

    return _$TopicCollectionReference._(
      firestore.collection('topics').withConverter(
            fromFirestore: TopicCollectionReference.fromFirestore,
            toFirestore: TopicCollectionReference.toFirestore,
          ),
    );
  }

  _$TopicCollectionReference._(
    CollectionReference<Topic> reference,
  ) : super(reference, reference);

  String get path => reference.path;

  @override
  CollectionReference<Topic> get reference =>
      super.reference as CollectionReference<Topic>;

  @override
  TopicDocumentReference doc([String? id]) {
    return TopicDocumentReference(
      reference.doc(id),
    );
  }

  @override
  Future<TopicDocumentReference> add(Topic value) {
    return reference.add(value).then((ref) => TopicDocumentReference(ref));
  }

  @override
  bool operator ==(Object other) {
    return other is _$TopicCollectionReference &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

abstract class TopicDocumentReference
    extends FirestoreDocumentReference<TopicDocumentSnapshot> {
  factory TopicDocumentReference(DocumentReference<Topic> reference) =
      _$TopicDocumentReference;

  DocumentReference<Topic> get reference;

  /// A reference to the [TopicCollectionReference] containing this document.
  TopicCollectionReference get parent {
    return _$TopicCollectionReference(reference.firestore);
  }

  @override
  Stream<TopicDocumentSnapshot> snapshots();

  @override
  Future<TopicDocumentSnapshot> get([GetOptions? options]);

  @override
  Future<void> delete();

  Future<void> update({
    String topicId,
    String topicName,
  });

  Future<void> set(Topic value);
}

class _$TopicDocumentReference
    extends FirestoreDocumentReference<TopicDocumentSnapshot>
    implements TopicDocumentReference {
  _$TopicDocumentReference(this.reference);

  @override
  final DocumentReference<Topic> reference;

  /// A reference to the [TopicCollectionReference] containing this document.
  TopicCollectionReference get parent {
    return _$TopicCollectionReference(reference.firestore);
  }

  @override
  Stream<TopicDocumentSnapshot> snapshots() {
    return reference.snapshots().map((snapshot) {
      return TopicDocumentSnapshot._(
        snapshot,
        snapshot.data(),
      );
    });
  }

  @override
  Future<TopicDocumentSnapshot> get([GetOptions? options]) {
    return reference.get(options).then((snapshot) {
      return TopicDocumentSnapshot._(
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
    Object? topicId = _sentinel,
    Object? topicName = _sentinel,
  }) async {
    final json = {
      if (topicId != _sentinel) "topicId": topicId as String,
      if (topicName != _sentinel) "topicName": topicName as String,
    };

    return reference.update(json);
  }

  Future<void> set(Topic value) {
    return reference.set(value);
  }

  @override
  bool operator ==(Object other) {
    return other is TopicDocumentReference &&
        other.runtimeType == runtimeType &&
        other.parent == parent &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, parent, id);
}

class TopicDocumentSnapshot extends FirestoreDocumentSnapshot {
  TopicDocumentSnapshot._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<Topic> snapshot;

  @override
  TopicDocumentReference get reference {
    return TopicDocumentReference(
      snapshot.reference,
    );
  }

  @override
  final Topic? data;
}

abstract class TopicQuery implements QueryReference<TopicQuerySnapshot> {
  @override
  TopicQuery limit(int limit);

  @override
  TopicQuery limitToLast(int limit);

  TopicQuery whereTopicId({
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
  TopicQuery whereTopicName({
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

  TopicQuery orderByTopicId({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    TopicDocumentSnapshot? startAtDocument,
    TopicDocumentSnapshot? endAtDocument,
    TopicDocumentSnapshot? endBeforeDocument,
    TopicDocumentSnapshot? startAfterDocument,
  });

  TopicQuery orderByTopicName({
    bool descending = false,
    String startAt,
    String startAfter,
    String endAt,
    String endBefore,
    TopicDocumentSnapshot? startAtDocument,
    TopicDocumentSnapshot? endAtDocument,
    TopicDocumentSnapshot? endBeforeDocument,
    TopicDocumentSnapshot? startAfterDocument,
  });
}

class _$TopicQuery extends QueryReference<TopicQuerySnapshot>
    implements TopicQuery {
  _$TopicQuery(
    this.reference,
    this._collection,
  );

  final CollectionReference<Object?> _collection;

  @override
  final Query<Topic> reference;

  TopicQuerySnapshot _decodeSnapshot(
    QuerySnapshot<Topic> snapshot,
  ) {
    final docs = snapshot.docs.map((e) {
      return TopicQueryDocumentSnapshot._(e, e.data());
    }).toList();

    final docChanges = snapshot.docChanges.map((change) {
      return FirestoreDocumentChange<TopicDocumentSnapshot>(
        type: change.type,
        oldIndex: change.oldIndex,
        newIndex: change.newIndex,
        doc: TopicDocumentSnapshot._(change.doc, change.doc.data()),
      );
    }).toList();

    return TopicQuerySnapshot._(
      snapshot,
      docs,
      docChanges,
    );
  }

  @override
  Stream<TopicQuerySnapshot> snapshots([SnapshotOptions? options]) {
    return reference.snapshots().map(_decodeSnapshot);
  }

  @override
  Future<TopicQuerySnapshot> get([GetOptions? options]) {
    return reference.get(options).then(_decodeSnapshot);
  }

  @override
  TopicQuery limit(int limit) {
    return _$TopicQuery(
      reference.limit(limit),
      _collection,
    );
  }

  @override
  TopicQuery limitToLast(int limit) {
    return _$TopicQuery(
      reference.limitToLast(limit),
      _collection,
    );
  }

  TopicQuery whereTopicId({
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
    return _$TopicQuery(
      reference.where(
        'topicId',
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

  TopicQuery whereTopicName({
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
    return _$TopicQuery(
      reference.where(
        'topicName',
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

  TopicQuery orderByTopicId({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    TopicDocumentSnapshot? startAtDocument,
    TopicDocumentSnapshot? endAtDocument,
    TopicDocumentSnapshot? endBeforeDocument,
    TopicDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('topicId', descending: false);

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

    return _$TopicQuery(query, _collection);
  }

  TopicQuery orderByTopicName({
    bool descending = false,
    Object? startAt = _sentinel,
    Object? startAfter = _sentinel,
    Object? endAt = _sentinel,
    Object? endBefore = _sentinel,
    TopicDocumentSnapshot? startAtDocument,
    TopicDocumentSnapshot? endAtDocument,
    TopicDocumentSnapshot? endBeforeDocument,
    TopicDocumentSnapshot? startAfterDocument,
  }) {
    var query = reference.orderBy('topicName', descending: false);

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

    return _$TopicQuery(query, _collection);
  }

  @override
  bool operator ==(Object other) {
    return other is _$TopicQuery &&
        other.runtimeType == runtimeType &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(runtimeType, reference);
}

class TopicQuerySnapshot
    extends FirestoreQuerySnapshot<TopicQueryDocumentSnapshot> {
  TopicQuerySnapshot._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  final QuerySnapshot<Topic> snapshot;

  @override
  final List<TopicQueryDocumentSnapshot> docs;

  @override
  final List<FirestoreDocumentChange<TopicDocumentSnapshot>> docChanges;
}

class TopicQueryDocumentSnapshot extends FirestoreQueryDocumentSnapshot
    implements TopicDocumentSnapshot {
  TopicQueryDocumentSnapshot._(this.snapshot, this.data);

  @override
  final QueryDocumentSnapshot<Topic> snapshot;

  @override
  TopicDocumentReference get reference {
    return TopicDocumentReference(snapshot.reference);
  }

  @override
  final Topic data;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
      topicId: json['topicId'] as String,
      topicName: json['topicName'] as String,
      created: DateTime.parse(json['created'] as String),
      updated: DateTime.parse(json['updated'] as String),
    );

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
      'topicId': instance.topicId,
      'topicName': instance.topicName,
      'created': instance.created.toIso8601String(),
      'updated': instance.updated.toIso8601String(),
    };
