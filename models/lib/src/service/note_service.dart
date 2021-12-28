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

  Note addTopicNote(Topic topic, String content, int sort) {
    var note = Note(
        content: content,
        dbHostType: HostType.topic.index,
        topicHost: topic,
        sort: sort);
    _noteBox.put(note);
    return note;
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
}
