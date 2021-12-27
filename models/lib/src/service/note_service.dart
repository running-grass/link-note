import 'package:models/objectbox.g.dart';

import '../note.dart';
import '../store.dart';
import '../topic.dart';

class NoteService {
  Box<Note> noteBox = store.box<Note>();

  int addTopicNote(Topic topic, String content, int sort) {
    var note = Note(
        content: content,
        dbHostType: HostType.topic.index,
        topicHost: topic,
        sort: sort);
    return noteBox.put(note);
  }
}
