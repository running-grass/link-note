// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TopicStore on _TopicStore, Store {
  Computed<int>? _$idComputed;

  @override
  int get id =>
      (_$idComputed ??= Computed<int>(() => super.id, name: '_TopicStore.id'))
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

  final _$topicNameAtom = Atom(name: '_TopicStore.topicName');

  @override
  String get topicName {
    _$topicNameAtom.reportRead();
    return super.topicName;
  }

  @override
  set topicName(String value) {
    _$topicNameAtom.reportWrite(value, super.topicName, () {
      super.topicName = value;
    });
  }

  final _$childrenAtom = Atom(name: '_TopicStore.children');

  @override
  ObservableList<NoteStore> get children {
    _$childrenAtom.reportRead();
    return super.children;
  }

  @override
  set children(ObservableList<NoteStore> value) {
    _$childrenAtom.reportWrite(value, super.children, () {
      super.children = value;
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
  String toString() {
    return '''
topicName: ${topicName},
children: ${children},
id: ${id}
    ''';
  }
}
