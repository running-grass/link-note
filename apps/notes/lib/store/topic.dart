import 'package:mobx/mobx.dart';
import 'package:models/models.dart';
import 'package:notes/store/note.dart';

// Include generated file
part 'topic.g.dart';

// This is the class used by rest of your codebase
class TopicStore = _TopicStore with _$TopicStore;

// The store-class
abstract class _TopicStore with Store {
  final int id;
  late final TopicService _topicService = TopicService();

  _TopicStore(this.id) {
    loadTopic();
  }

  @readonly
  int? _editingNoteId;

  @readonly
  String _topicName = "";

  @readonly
  ObservableList<NoteStore> _children = ObservableList.of([]);

  Iterable<int> _linerNotes(NoteStore note) {
    var childIds = note.children.expand(_linerNotes).toList();
    childIds.insert(0, note.id);
    return childIds;
  }

  @computed
  List<int> get linerNoteIds => _children.expand(_linerNotes).toList();

  @action
  loadTopic() {
    var _topic = _topicService.getTopic(id)!;
    _topicName = _topic.name;
    _children = ObservableList.of(_topic.notes
        .where((element) => !element.parent.hasValue)
        .map((n) => NoteStore(
            id: n.id,
            content: n.content,
            sort: n.sort,
            children: n.children,
            topicStore: this as TopicStore,
            parentNote: null)));
  }

  @action
  refresh() {
    loadTopic();
  }

  @action
  updateName(String newName) {
    _topicName = newName;
    _topicService.updateName(id, newName);
  }

  @action
  setEditingNoteId(int id) {
    _editingNoteId = id;
  }

  @action
  clearEditingNote() {
    _editingNoteId = null;
  }

  @action
  moveFoucsNext(int noteId) {
    var currGloalId = linerNoteIds.indexOf(noteId);
    assert(currGloalId >= 0);
    if (currGloalId == linerNoteIds.length - 1) {
      return;
    }
    _editingNoteId = linerNoteIds[currGloalId + 1];
  }

  @action
  moveFoucsPrev(int noteId) {
    var currGloalId = linerNoteIds.indexOf(noteId);
    assert(currGloalId >= 0);
    if (currGloalId == 0) {
      return;
    }
    _editingNoteId = linerNoteIds[currGloalId - 1];
  }

  remove() {
    _topicService.removeById(id);
  }
}
