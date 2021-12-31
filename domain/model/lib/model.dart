import 'src/store.dart';

export 'src/enums.dart';
export 'src/topic.dart';
export 'src/note.dart';
export 'src/goal.dart';
export 'src/service/topic_service.dart';
export 'src/service/note_service.dart';
export 'src/service/goal_service.dart';

Future<void> initModel() async {
  await initStore();
}
