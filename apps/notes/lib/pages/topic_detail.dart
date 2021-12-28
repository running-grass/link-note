import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:models/models.dart';

enum NoteStatus { normal, selected, editing }

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
  Map<int, NoteStatus> statusMap = {};
  TextEditingController teContr = TextEditingController();

  @override
  void initState() {
    super.initState();

    topicStream = topicService.loadTopicAndFillX(widget.topicId);
  }

  Widget renderRow(Note note) {
    // note.content = "abcd";

    return GestureDetector(
        key: Key(note.id.toString()),
        onTap: () {
          // if (event.kind == PointerDeviceKind.) {
          // editingNoteId = note.id;
          // teContr.text = note.content;
          setState(() {
            editingNoteId = note.id;
            teContr.text = note.content;
          });
          // }
        },
        child: KeyboardListener(
            focusNode: FocusNode(skipTraversal: true),
            onKeyEvent: (event) {
              if (event.runtimeType == KeyDownEvent) {
                if (event.physicalKey == PhysicalKeyboardKey.enter) {
                  Note newNote = noteService.addTopicNote(
                      note.topicHost.target!, "", note.sort + 100);

                  setState(() {
                    editingNoteId = newNote.id;
                    teContr.text = "";
                  });
                }
              }
            },
            child: Container(
                color: Colors.amber,
                padding: const EdgeInsets.all(10),
                width: 1000,
                height: 50,
                child: editingNoteId == note.id
                    ? TextField(
                        controller: teContr,
                        onChanged: (val) {
                          note.content = val;
                          noteService.updateNote(note);
                        },
                        // initialValue: note.content == "" ? " " : note.content,
                        autofocus: true,
                        // onEditingComplete: ,
                      )
                    : Text(
                        note.content,
                      ))));
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

          return GestureDetector(
              onTap: () {
                editingNoteId = null;
              },
              child: Scaffold(
                  appBar: AppBar(title: Text(topic.name), actions: [
                    IconButton(
                      onPressed: () {
                        topicService.remove(topic);
                        Get.back();
                      },
                      icon: const Icon(Icons.delete_forever),
                    ),
                  ]),
                  body: Row(
                    children: [
                      Column(
                        children: topic.noteTree!.map(renderRow).toList(),
                      ),
                    ],
                  )));
        });
  }
}
