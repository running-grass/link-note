import 'dart:math';

import 'package:models/objectbox.g.dart';

import '../note.dart';
import '../store.dart';
import '../topic.dart';

class NoteService {
  // 单例处理
  NoteService._internal();
  factory NoteService() => _instance;
  static late final NoteService _instance = NoteService._internal();

  late final Box<Note> _noteBox = store.box<Note>();

  late final Box<Topic> _topicBox = store.box<Topic>();

  Note addTopicNote(Topic topic, String content, int sort) {
    var note = Note(
        content: content,
        dbHostType: HostType.topic.index,
        topicHost: topic,
        sort: sort);
    _noteBox.put(note);
    return note;
  }

  Note addTopicNoteByTopicId(
      {required int topicId, required String content, required int sort}) {
    var topic = _topicBox.get(topicId);
    if (topic == null) {
      throw Error();
    }

    return addTopicNote(topic, content, sort);
  }

  Stream<List<Note>> getNotesXByTopicId(int topicId) {
    return _noteBox
        .query(Note_.topicHost.equals(topicId))
        .watch(triggerImmediately: true)
        .map((event) => event.find());
  }

  int updateNote(Note note) {
    assert(note.id != 0);
    return _noteBox.put(note);
  }

  Note? getNoteById(int id) {
    return _noteBox.get(id);
  }

  bool updateContent(int id, String newContent) {
    Note? note = getNoteById(id);

    if (note == null) {
      throw Error();
    } else {
      note
        ..content = newContent
        ..updated = DateTime.now();
    }
    return _noteBox.put(note, mode: PutMode.update) != 0;
  }

  bool updateParentId(int id, int? pid, int sort) {
    Note? note = getNoteById(id);

    if (note == null) {
      throw Error();
    }

    if (pid != null) {
      note.parent.targetId = pid;
    }

    note
      ..sort = sort
      ..updated = DateTime.now();

    return _noteBox.put(note, mode: PutMode.update) != 0;
  }
}
