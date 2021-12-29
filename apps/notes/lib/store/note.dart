import 'dart:async';
import 'package:mobx/mobx.dart';
import 'package:models/models.dart';
import 'package:notes/store/topic.dart';

// Include generated file
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

  final TopicStore topicStore;
  NoteStore? parentNote;

  @computed
  ObservableList<NoteStore> get siblings {
    return parentNote?.children ?? topicStore.children;
  }

  @observable
  int sort;

  @observable
  int id;
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
    this.children = ObservableList.of(children.map((n) => toStore(
        note: n, topicStore: topicStore, parentNoteStore: this as NoteStore)));

    _updateContent$.stream.listen((newContent) {
      _noteService.updateContent(id, newContent);
    });
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
        topicId: topicStore.id, content: newContent, sort: newSort);

    // 手动插入父级列表
    siblings.insert(
        inParentIndex + 1,
        toStore(
            note: note, topicStore: topicStore, parentNoteStore: parentNote));
    topicStore.setEditingNoteId(note.id);
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

    topicStore.refresh();
    // 插入到前节点的子节点中
    // prevNote!.children.add(this as NoteStore);

    // 手动从sibling中移除
    // siblings.removeAt(inParentIndex);

    // 更改状态
    // parentNote = prevNote;
    // sort = newSort;
  }

  dispose() {
    _updateContent$.close();
  }
}
