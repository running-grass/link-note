import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:models/models.dart';
import 'package:notes/pages/topic_detail.dart';

class TopicList extends StatefulWidget {
  const TopicList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TopicListState();
  }
}

class _TopicListState extends State<TopicList> {
  final TopicService topicService = Get.find<TopicService>();
  late final Stream<List<Topic>> listStream;
  @override
  void initState() {
    super.initState();

    listStream = topicService.getAllTopicX();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IconButton(
        icon: const Icon(Icons.add),
        tooltip: "新建主题",
        onPressed: () async {
          // TODO 在输入的时候要检测输入的主题名称是否重名
          var topicName = await getNewTopicName("请输入新主题的标题");
          if (topicName != null) {
            var oldT = topicService.getTopicByName(topicName);
            var id = oldT?.id ?? topicService.addTopic(topicName);

            Get.to(() => TopicDetail(
                  topicId: id,
                ));
          }
        },
      ),
      body: StreamBuilder<List<Topic>>(
          stream: listStream,
          builder: (_, snapshot) {
            if (snapshot.hasError) {
              return const Text("数据有误");
            }

            if (!snapshot.hasData) {
              return const Text("数据加载中");
            }

            return ListView(
                children: snapshot.data!
                    .map((topic) => ListTile(
                        onTap: () {
                          Get.to(() => TopicDetail(topicId: topic.id));
                        },
                        leading: const Icon(Icons.ac_unit),
                        title: Text(topic.name)))
                    .toList());
          }),
    );
  }
}

// 获取一个字符串，提供tittle
Future<String?> getNewTopicName(title) async {
  String tempString = "";
  var res = await Get.defaultDialog<String>(
    title: title,
    content: TextFormField(
      onChanged: (value) => tempString = value,
      autofocus: true,
    ),
    textCancel: "取消",
    textConfirm: "确定",
    onConfirm: () => Get.back(result: 'ok'),
  );
  return res == 'ok' ? tempString : null;
}
