import 'package:flutter/material.dart';
import 'package:models/primTypeDefs.dart';
import 'package:models/topic.dart';

class TopicDetail extends StatefulWidget {
  final TopicId topicId;

  const TopicDetail({Key? key, required this.topicId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TopicState();
  }
}

// 主题的状态监听，不做渲染
class _TopicState extends State<TopicDetail> {
  late Stream<Topic?> topicStream;

  @override
  void initState() {
    topicStream = topicRef
        .whereTopicId(isEqualTo: widget.topicId)
        .limit(1)
        .snapshots()
        .map((event) => event.docs.isEmpty ? null : event.docs[0].data);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Topic?>(
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
            title: Text(topic.topicName),
          ));
        });
  }
}
