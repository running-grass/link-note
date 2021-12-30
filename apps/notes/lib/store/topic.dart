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

  @readonly
  int? _editingNoteId;

  _TopicStore(this._topicId) {
    loadTopic();
  }

  @computed
  int get id => _topicId;

  @observable
  String topicName = "";

  @observable
  ObservableList<NoteStore> children = ObservableList.of([]);

  @action
  loadTopic() {
    var _topic = topicService.getTopic(_topicId)!;
    topicName = _topic.name;
    children = ObservableList.of(_topic.notes
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
    topicName = newName;

    topicService.updateName(_topicId, newName);
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
