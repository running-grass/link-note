import 'package:mobx/mobx.dart';
import 'package:models/models.dart';

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

  _TopicStore(this._topicId) {
    // _topic = topicService.getTopic(_topicId)!;
    loadTopic();
  }

  @computed
  String get topicName => _topic.name;

  @computed
  List<Note> get children {
    return _topic.notes.toList();
  }

  @action
  loadTopic() {
    _topic = topicService.getTopic(_topicId)!;
  }

  @action
  updateName(newName) {
    _topic.name = newName;
    if (topicService.updateName(_topicId, newName)) {
      loadTopic();
    }
  }
}
