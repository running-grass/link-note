import 'package:models/objectbox.g.dart';
import 'package:models/src/topic.dart';

import '../store.dart';

class TopicService {
  Box<Topic> topicBox = store.box<Topic>();

  Stream<Query<Topic>>? __allTopicX;

  Stream<Query<Topic>> get _allTopicX {
    if (__allTopicX == null) {
      var queryBuild = topicBox.query(Topic_.id.notNull())
        ..order(Topic_.updated, flags: Order.descending);

      __allTopicX = queryBuild.watch(triggerImmediately: true);
    }

    return __allTopicX!;
  }

  int addTopic(topicName) {
    var topic = Topic(name: topicName);
    return topicBox.put(topic);
  }

  Topic? getTopic(id) {
    return topicBox.get(id);
  }

  Stream<Topic> getTopicX(id) {
    var qx =
        topicBox.query(Topic_.id.equals(id)).watch(triggerImmediately: true);

    return qx.map((qt) {
      var t = qt.findFirst();
      if (t == null) {
        throw Error();
      }
      return t;
    });
  }

  Topic? getTopicByName(topicName) {
    var query = topicBox.query(Topic_.name.equals(topicName)).build();
    return query.findFirst();
  }

  List<Topic> getAllTopic() {
    return topicBox.getAll();
  }

  Stream<List<Topic>> getAllTopicX() {
    return _allTopicX.map((Query<Topic> qt) {
      qt..limit = 10;
      return qt.find();
    });
  }
}
