import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:models/topic.dart';
import 'package:notes/pages/topic_detail.dart';
import 'package:uuid/uuid.dart';

Topic getNewTopic(String topicName) {
  var now = DateTime.now();
  const uuid = Uuid();
  return Topic(
      topicId: uuid.v1(), topicName: topicName, created: now, updated: now);
}

class TopicList extends StatelessWidget {
  const TopicList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IconButton(
        icon: const Icon(Icons.add),
        tooltip: "新建主题",
        onPressed: () async {
          // TODO 在输入的时候要检测输入的主题名称是否重名
          var topicName =
              // ignore: argument_type_not_assignable_to_error_handler
              await getNewTopicName("请输入新主题的标题");
          if (topicName != null) {
            var oldT = await topicRef
                .whereTopicName(isEqualTo: topicName)
                .limit(1)
                .get();
            var id;
            if (oldT.docs.isNotEmpty) {
              Get.snackbar("警告", "主题名称已存在");
              id = oldT.docs[0].data.topicId;
            } else {
              var topic = getNewTopic(topicName);
              await topicRef.add(topic);
              id = topic.topicId;
            }

            Get.to(() => TopicDetail(
                  topicId: id,
                ));
          }
        },
      ),
      body: _TopicListWidget(),
    );
  }
}

class _TopicListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TopicListState();
  }
}

class _TopicListState extends State<_TopicListWidget> {
  final listStream = topicRef.snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TopicQuerySnapshot>(
        stream: listStream,
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return const Text("数据有误");
          }

          if (!snapshot.hasData) {
            return const Text("数据加载中");
          }

          return ListView(
              children: snapshot.data!.docs
                  .map((e) => e.data)
                  .map((topic) => ListTile(
                      onTap: () {
                        Get.to(() => TopicDetail(topicId: topic.topicId));
                      },
                      leading: const Icon(Icons.ac_unit),
                      title: Text(topic.topicName)))
                  .toList());
        });
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
