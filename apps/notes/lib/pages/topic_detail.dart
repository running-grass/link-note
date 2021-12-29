import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get.dart';
import 'package:notes/store/note.dart';
import 'package:notes/store/topic.dart';

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
  late final TopicStore store;

  @override
  void initState() {
    super.initState();

    store = TopicStore(widget.topicId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          store.clearEditingNote();
        },
        child: Scaffold(
            appBar: AppBar(
                title: Observer(builder: (_) => Text(store.topicName)),
                actions: [
                  IconButton(
                    onPressed: () {
                      store.remove();
                      Get.back();
                    },
                    icon: const Icon(Icons.delete_forever),
                  ),
                ]),
            body: Row(
              children: [
                Observer(
                    builder: (_) => Column(
                          children: store.children
                              .map((noteStore) => NoteItem(noteStore))
                              .toList(),
                        )),
              ],
            )));
    // });
  }
}

class NoteItem extends StatelessWidget {
  final NoteStore store;

  const NoteItem(this.store, {Key? key}) : super(key: key);

  // note.content = "abcd";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          store.topicStore.setEditingNoteId(store.id);
        },
        child: KeyboardListener(
            focusNode: FocusNode(skipTraversal: true),
            onKeyEvent: (event) {
              if (event.runtimeType == KeyDownEvent) {
                if (event.physicalKey == PhysicalKeyboardKey.enter) {
                  store.addNextNote("");
                }
              }
            },
            child: Container(
                color: Colors.amber,
                padding: const EdgeInsets.all(10),
                width: 1000,
                height: 50,
                child: Observer(
                    builder: (_) => store.status == NoteStatus.editing
                        ? TextFormField(
                            initialValue: store.content,
                            onChanged: (val) {
                              store.updateContent(val);
                            },
                            autofocus: true,
                          )
                        : Text(
                            store.content,
                          )))));
  }
}
