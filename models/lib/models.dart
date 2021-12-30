import 'package:models/src/store.dart';

export 'src/topic.dart';
export 'src/note.dart';
export 'src/service/topic_service.dart';
export 'src/service/note_service.dart';

Future<void> initModel() async {
  await initStore();
}
