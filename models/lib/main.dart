import 'package:models/models.dart';
import 'package:models/src/service/topic_service.dart';

void main() async {
  // await init();

  var topicService = TopicService();
  topicService.addTopic("测试名称");

  var list = topicService.getAllTopic();
}
