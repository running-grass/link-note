import 'dart:async';

import 'package:models/objectbox.g.dart';
import 'package:models/src/service/note_service.dart';
import 'package:models/src/topic.dart';
import 'package:rxdart/rxdart.dart';
import '../note.dart';
import '../store.dart';

class TopicService {
  // 单例处理
  TopicService._internal();
  factory TopicService() => _instance;
  static late final TopicService _instance = TopicService._internal();

  late final Box<Topic> _topicBox = store.box<Topic>();
  late final NoteService _noteService = NoteService();

  Stream<Query<Topic>>? __allTopicX;

  Stream<Query<Topic>> get _allTopicX {
    if (__allTopicX == null) {
      var queryBuild = _topicBox.query(Topic_.id.notNull())
        ..order(Topic_.updated, flags: Order.descending);

      __allTopicX = queryBuild.watch(triggerImmediately: true);
    }

    return __allTopicX!;
  }

  int addTopic(topicName) {
    var topic = Topic(name: topicName);
    var id = _topicBox.put(topic);
    // 预置一个空的note
    _addEmptyNoteToNewTopic(topic);
    return id;
  }

  // 为新的主题增加一个空的note，无视失败
  _addEmptyNoteToNewTopic(Topic topic) async {
    assert(topic.id != 0);
    _noteService.addTopicNote(
        topic: topic, content: "", sort: 100, parentId: null);
  }

  Topic? getTopic(id) {
    return _topicBox.get(id);
  }

  Stream<Topic> getTopicX(id) {
    var qx =
        _topicBox.query(Topic_.id.equals(id)).watch(triggerImmediately: true);

    return qx.map((qt) {
      var t = qt.findFirst();
      if (t == null) {
        throw Error();
      }
      return t;
    });
  }

  Stream<Topic> loadTopicAndFillX(int topicId) {
    var qx = _noteService.getNotesXByTopicId(topicId);

    return CombineLatestStream.combine2<Topic, List<Note>, Topic>(
        getTopicX(topicId), qx, (Topic topic, List<Note> notes) {
      topic.noteTree = notes;
      topic.noteTree?.sort((a, b) => a.sort.compareTo(b.sort));

      return topic;
    });
  }

  Topic? getTopicByName(topicName) {
    var query = _topicBox.query(Topic_.name.equals(topicName)).build();
    return query.findFirst();
  }

  List<Topic> getAllTopic() {
    return _topicBox.getAll();
  }

  Stream<List<Topic>> getAllTopicX() {
    return _allTopicX.map((Query<Topic> qt) {
      qt..limit = 10;
      return qt.find();
    });
  }

  bool remove(Topic topic) {
    assert(topic.id != 0);
    return _topicBox.remove(topic.id);
  }

  bool updateName(id, name) {
    if (getTopicByName(name) != null) {
      throw Error();
    }

    Topic? topic = getTopic(id);

    if (topic == null) {
      throw Error();
    } else {
      topic
        ..name = name
        ..updated = DateTime.now();
    }
    return _topicBox.put(topic, mode: PutMode.update) != 0;
  }
}
