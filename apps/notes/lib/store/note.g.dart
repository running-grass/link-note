// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$NoteStore on _NoteStore, Store {
  Computed<ObservableList<NoteStore>>? _$siblingsComputed;

  @override
  ObservableList<NoteStore> get siblings => (_$siblingsComputed ??=
          Computed<ObservableList<NoteStore>>(() => super.siblings,
              name: '_NoteStore.siblings'))
      .value;
  Computed<NoteStatus>? _$statusComputed;

  @override
  NoteStatus get status => (_$statusComputed ??=
          Computed<NoteStatus>(() => super.status, name: '_NoteStore.status'))
      .value;
  Computed<int>? _$inParentIndexComputed;

  @override
  int get inParentIndex =>
      (_$inParentIndexComputed ??= Computed<int>(() => super.inParentIndex,
              name: '_NoteStore.inParentIndex'))
          .value;
  Computed<NoteStore?>? _$prevNoteComputed;

  @override
  NoteStore? get prevNote =>
      (_$prevNoteComputed ??= Computed<NoteStore?>(() => super.prevNote,
              name: '_NoteStore.prevNote'))
          .value;
  Computed<NoteStore?>? _$nextNoteComputed;

  @override
  NoteStore? get nextNote =>
      (_$nextNoteComputed ??= Computed<NoteStore?>(() => super.nextNote,
              name: '_NoteStore.nextNote'))
          .value;

  final _$sortAtom = Atom(name: '_NoteStore.sort');

  @override
  int get sort {
    _$sortAtom.reportRead();
    return super.sort;
  }

  @override
  set sort(int value) {
    _$sortAtom.reportWrite(value, super.sort, () {
      super.sort = value;
    });
  }

  final _$contentAtom = Atom(name: '_NoteStore.content');

  @override
  String get content {
    _$contentAtom.reportRead();
    return super.content;
  }

  @override
  set content(String value) {
    _$contentAtom.reportWrite(value, super.content, () {
      super.content = value;
    });
  }

  final _$childrenAtom = Atom(name: '_NoteStore.children');

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

  final _$_NoteStoreActionController = ActionController(name: '_NoteStore');

  @override
  dynamic refresh() {
    final _$actionInfo =
        _$_NoteStoreActionController.startAction(name: '_NoteStore.refresh');
    try {
      return super.refresh();
    } finally {
      _$_NoteStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic updateContent(String newContent) {
    final _$actionInfo = _$_NoteStoreActionController.startAction(
        name: '_NoteStore.updateContent');
    try {
      return super.updateContent(newContent);
    } finally {
      _$_NoteStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic addNextNote(String newContent) {
    final _$actionInfo = _$_NoteStoreActionController.startAction(
        name: '_NoteStore.addNextNote');
    try {
      return super.addNextNote(newContent);
    } finally {
      _$_NoteStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic addChildNote(String newContent) {
    final _$actionInfo = _$_NoteStoreActionController.startAction(
        name: '_NoteStore.addChildNote');
    try {
      return super.addChildNote(newContent);
    } finally {
      _$_NoteStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic toChild() {
    final _$actionInfo =
        _$_NoteStoreActionController.startAction(name: '_NoteStore.toChild');
    try {
      return super.toChild();
    } finally {
      _$_NoteStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic toParent() {
    final _$actionInfo =
        _$_NoteStoreActionController.startAction(name: '_NoteStore.toParent');
    try {
      return super.toParent();
    } finally {
      _$_NoteStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
sort: ${sort},
content: ${content},
children: ${children},
siblings: ${siblings},
status: ${status},
inParentIndex: ${inParentIndex},
prevNote: ${prevNote},
nextNote: ${nextNote}
    ''';
  }
}
