import 'dart:async';

import 'package:models/objectbox.g.dart';
import 'package:models/src/service/note_service.dart';
import 'package:models/src/topic.dart';

import '../note.dart';
import '../store.dart';

class TopicService {
  Box<Topic> _topicBox = store.box<Topic>();
  NoteService _noteService = NoteService();

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
    _noteService.addTopicNote(topic, "", 100);
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
    return getTopicX(topicId).map((Topic topic) {
      topic.noteTree = topic.notes.toList();
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
}
