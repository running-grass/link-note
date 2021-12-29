import 'package:mobx/mobx.dart';
import 'package:models/models.dart';
import 'package:notes/store/note.dart';

// Include generated file
part 'topic.g.dart';

// This is the class used by rest of your codebase
class TopicStore = _TopicStore with _$TopicStore;

// The store-class
abstract class _TopicStore with Store {
  final int _topicId;
  final TopicService topicService = TopicService();

  @observable
  late Topic _topic = topicService.getTopic(_topicId)!;

  @readonly
  int? _editingNoteId;

  _TopicStore(this._topicId) {
    loadTopic();
  }

  @computed
  int get id => _topicId;

  @computed
  String get topicName => _topic.name;

  @computed
  ObservableList<NoteStore> get children {
    return ObservableList.of(_topic.notes.map((n) => NoteStore(
        id: n.id,
        content: n.content,
        sort: n.sort,
        children: n.children,
        topicStore: this as TopicStore,
        parentNote: null)));
  }

  @action
  loadTopic() {
    _topic = topicService.getTopic(_topicId)!;
  }

  @action
  updateName(String newName) {
    _topic.name = newName;
    if (topicService.updateName(_topicId, newName)) {
      loadTopic();
    }
  }

  @action
  setEditingNoteId(int id) {
    _editingNoteId = id;
  }

  @action
  clearEditingNote() {
    _editingNoteId = null;
  }

  remove() {
    throw UnimplementedError();
  }
}
