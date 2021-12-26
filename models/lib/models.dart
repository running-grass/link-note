import 'package:models/src/store.dart';

export 'src/topic.dart';
export 'src/note.dart';
export 'src/service/topic_service.dart';

Future<void> initModel() async {
  await initStore();
}
