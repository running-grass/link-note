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
  final NoteService noteService = Get.find<NoteService>();
  late final Stream<Topic> topicStream;
  bool hadInitNote = false;
  int? editingNoteId;

  @override
  void initState() {
    super.initState();

    topicStream = topicService.loadTopicAndFillX(widget.topicId);
  }

  Widget renderRow(Note note) {
    return GestureDetector(
        onTap: () {
          editingNoteId = note.id;
        },
        child: Container(
            color: Colors.amber, width: 1000, child: Text(note.content)));
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

          assert(topic.noteTree != null, "此处noteTree应该被填充");

          // 如果是空的需要调整
          if (!hadInitNote && topic.notes.isEmpty) {
            noteService.addTopicNote(topic, "", 100);
            hadInitNote = true;
          } else if (hadInitNote && topic.notes.isEmpty) {
            throw Error();
          }

          return Scaffold(
              appBar: AppBar(
                title: Text(topic.name),
              ),
              body: Row(
                children: [
                  Column(
                    children: topic.noteTree!.map(renderRow).toList(),
                  ),
                ],
              ));
        });
  }
}
