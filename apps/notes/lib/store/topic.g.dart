// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TopicStore on _TopicStore, Store {
  Computed<List<int>>? _$linerNoteIdsComputed;

  @override
  List<int> get linerNoteIds =>
      (_$linerNoteIdsComputed ??= Computed<List<int>>(() => super.linerNoteIds,
              name: '_TopicStore.linerNoteIds'))
          .value;

  final _$_editingNoteIdAtom = Atom(name: '_TopicStore._editingNoteId');

  int? get editingNoteId {
    _$_editingNoteIdAtom.reportRead();
    return super._editingNoteId;
  }

  @override
  int? get _editingNoteId => editingNoteId;

  @override
  set _editingNoteId(int? value) {
    _$_editingNoteIdAtom.reportWrite(value, super._editingNoteId, () {
      super._editingNoteId = value;
    });
  }

  final _$_topicNameAtom = Atom(name: '_TopicStore._topicName');

  String get topicName {
    _$_topicNameAtom.reportRead();
    return super._topicName;
  }

  @override
  String get _topicName => topicName;

  @override
  set _topicName(String value) {
    _$_topicNameAtom.reportWrite(value, super._topicName, () {
      super._topicName = value;
    });
  }

  final _$_childrenAtom = Atom(name: '_TopicStore._children');

  ObservableList<NoteStore> get children {
    _$_childrenAtom.reportRead();
    return super._children;
  }

  @override
  ObservableList<NoteStore> get _children => children;

  @override
  set _children(ObservableList<NoteStore> value) {
    _$_childrenAtom.reportWrite(value, super._children, () {
      super._children = value;
    });
  }

  final _$_TopicStoreActionController = ActionController(name: '_TopicStore');

  @override
  dynamic loadTopic() {
    final _$actionInfo = _$_TopicStoreActionController.startAction(
        name: '_TopicStore.loadTopic');
    try {
      return super.loadTopic();
    } finally {
      _$_TopicStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic refresh() {
    final _$actionInfo =
        _$_TopicStoreActionController.startAction(name: '_TopicStore.refresh');
    try {
      return super.refresh();
    } finally {
      _$_TopicStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic updateName(String newName) {
    final _$actionInfo = _$_TopicStoreActionController.startAction(
        name: '_TopicStore.updateName');
    try {
      return super.updateName(newName);
    } finally {
      _$_TopicStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setEditingNoteId(int id) {
    final _$actionInfo = _$_TopicStoreActionController.startAction(
        name: '_TopicStore.setEditingNoteId');
    try {
      return super.setEditingNoteId(id);
    } finally {
      _$_TopicStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic clearEditingNote() {
    final _$actionInfo = _$_TopicStoreActionController.startAction(
        name: '_TopicStore.clearEditingNote');
    try {
      return super.clearEditingNote();
    } finally {
      _$_TopicStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic moveFoucsNext(int noteId) {
    final _$actionInfo = _$_TopicStoreActionController.startAction(
        name: '_TopicStore.moveFoucsNext');
    try {
      return super.moveFoucsNext(noteId);
    } finally {
      _$_TopicStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic moveFoucsPrev(int noteId) {
    final _$actionInfo = _$_TopicStoreActionController.startAction(
        name: '_TopicStore.moveFoucsPrev');
    try {
      return super.moveFoucsPrev(noteId);
    } finally {
      _$_TopicStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
linerNoteIds: ${linerNoteIds}
    ''';
  }
}
