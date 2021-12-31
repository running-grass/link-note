import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:model/model.dart';
import 'topic.dart';

part 'note.g.dart';

enum NoteStatus { normal, selected, editing }

// This is the class used by rest of your codebase
class NoteStore = _NoteStore with _$NoteStore;

NoteStore toStore(
    {required TopicStore topicStore,
    required NoteStore? parentNoteStore,
    required Note note}) {
  return NoteStore(
      id: note.id,
      content: note.content,
      sort: note.sort,
      topicStore: topicStore,
      children: note.children,
      parentNote: parentNoteStore);
}

// The store-class
abstract class _NoteStore with Store {
  final NoteService _noteService = NoteService();

  late final TextEditingController editingController = TextEditingController();

  final TopicStore topicStore;
  NoteStore? parentNote;

  @computed
  ObservableList<NoteStore> get siblings {
    return parentNote?.children ?? topicStore.children;
  }

  @observable
  int sort;

  final int id;

  @observable
  String content;

  @observable
  ObservableList<NoteStore> children = ObservableList.of([]);

  @computed
  NoteStatus get status =>
      topicStore.editingNoteId == id ? NoteStatus.editing : NoteStatus.normal;

  @computed
  int get inParentIndex {
    var idx = siblings.indexOf(this);
    assert(idx != -1);
    return idx;
  }

  @computed
  NoteStore? get prevNote {
    if (inParentIndex == 0) {
      return null;
    }
    return siblings[inParentIndex - 1];
  }

  @computed
  NoteStore? get nextNote {
    if (inParentIndex == siblings.length - 1) {
      return null;
    }
    return siblings[inParentIndex + 1];
  }

  final StreamController<String> _updateContent$ = StreamController<String>();

  _NoteStore(
      {required this.id,
      required this.content,
      required this.sort,
      required this.topicStore,
      required this.parentNote,
      required List<Note> children}) {
    // this.children =
    refresh();

    _updateContent$.stream.listen((newContent) {
      _noteService.updateContent(id, newContent);
    });
  }

  @action
  refresh() {
    var note = _noteService.getNoteById(id);
    assert(note != null);
    if (note == null) {
      throw Error();
    }
    content = note.content;
    sort = note.sort;
    children = ObservableList.of(note.children.map((n) => toStore(
        note: n, topicStore: topicStore, parentNoteStore: this as NoteStore)));

    editingController.text = content;
  }

  int? _getNextNewSort() {
    if (nextNote == null) {
      return sort + 100;
    }
    if (nextNote!.sort - sort < 2) {
      return null;
    }

    return (sort + nextNote!.sort) ~/ 2;
  }

  getNextAvailableNewSort() {
    var newSort = _getNextNewSort();
    if (newSort == null) {
      // TODO 如果没有可用的，需要更新全部的sort

    }
    return newSort!;
  }

  @action
  updateContent(String newContent) {
    content = newContent;
    _updateContent$.add(newContent);
  }

  @action
  addNextNote(String newContent) {
    var newSort = getNextAvailableNewSort();
    var note = _noteService.addTopicNoteByTopicId(
        topicId: topicStore.id,
        content: newContent,
        parentId: parentNote?.id,
        sort: newSort);

    topicStore.setEditingNoteId(note.id);
    if (parentNote != null) {
      parentNote!.refresh();
    } else {
      topicStore.refresh();
    }
  }

  @action
  addChildNote(String newContent) {
    var newSort = children.isEmpty ? 100 : children.last.sort + 100;

    var note = _noteService.addTopicNoteByTopicId(
        topicId: topicStore.id,
        content: newContent,
        parentId: id,
        sort: newSort);

    topicStore.setEditingNoteId(note.id);

    refresh();
  }

  @action
  toChild() {
    // 更改parentid
    if (prevNote == null) {
      return;
    }

    // 更新数据库
    var newSort = 100;
    if (prevNote!.children.isNotEmpty) {
      newSort = prevNote!.children.last.sort + 100;
    }
    _noteService.updateParentId(id, prevNote!.id, newSort);

    prevNote!.refresh();

    if (parentNote != null) {
      parentNote!.refresh();
    } else {
      topicStore.refresh();
    }
  }

  @action
  toParent() {
    // 更改parentid
    if (parentNote == null) {
      return;
    }

    // 更新数据库
    var newSort = parentNote!.getNextAvailableNewSort();

    _noteService.updateParentId(id, parentNote!.parentNote?.id, newSort);

    parentNote!.refresh();

    if (parentNote!.parentNote != null) {
      parentNote!.parentNote!.refresh();
    } else {
      topicStore.refresh();
    }
  }

  @action
  moveFoucsNext() {
    topicStore.moveFoucsNext(id);
  }

  @action
  moveFoucsPrev() {
    topicStore.moveFoucsPrev(id);
  }
}
