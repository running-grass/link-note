import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:models/models.dart';

class TopicDetail extends StatefulWidget {
  final int topicId;
  const TopicDetail({Key? key, required this.topicId}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _TopicState();
  }
}

// 主题的状态监听，不做渲染
class _TopicState extends State<TopicDetail> {
  final TopicService topicService = Get.find<TopicService>();
  late final Stream<Topic> topicStream;

  @override
  void initState() {
    super.initState();

    topicStream = topicService.getTopicX(widget.topicId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Topic>(
        stream: topicStream,
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return const Text("数据加载错误");
          }
          if (!snapshot.hasData) {
            return const Text("加载中");
          }

          var topic = snapshot.data;

          if (topic == null) {
            return const Text("数据加载错误2");
          }

          return Scaffold(
              appBar: AppBar(
            title: Text(topic.name),
          ));
        });
  }
}
