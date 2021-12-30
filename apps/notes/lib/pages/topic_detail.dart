import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get.dart';
import '../store/note.dart';
import '../store/topic.dart';
import '../action/note_action.dart';

class TopicDetail extends StatelessWidget {
  final int topicId;
  late final TopicStore store;

  TopicDetail({Key? key, required this.topicId}) : super(key: key) {
    store = TopicStore(topicId);
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
          body: Shortcuts(
            shortcuts: <LogicalKeySet, Intent>{
              LogicalKeySet(LogicalKeyboardKey.enter):
                  const NewNextNoteIntent(),
              LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.enter):
                  const NewChildNoteIntent(),
              LogicalKeySet(LogicalKeyboardKey.tab): const IndentNoteIntent(),
              LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab):
                  const UnIndentNoteIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowUp):
                  const MoveFocusPrevIntent(),
              LogicalKeySet(
                      LogicalKeyboardKey.control, LogicalKeyboardKey.keyP):
                  const MoveFocusPrevIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowDown):
                  const MoveFocusNextIntent(),
              LogicalKeySet(
                      LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
                  const MoveFocusNextIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowRight):
                  const MoveCurserForewardIntent(),
              LogicalKeySet(
                      LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
                  const MoveCurserForewardIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowLeft):
                  const MoveCurserBackwardIntent(),
              LogicalKeySet(
                      LogicalKeyboardKey.control, LogicalKeyboardKey.keyB):
                  const MoveCurserBackwardIntent(),
              LogicalKeySet(
                      LogicalKeyboardKey.control, LogicalKeyboardKey.keyA):
                  const MoveCurserStartIntent(),
              LogicalKeySet(
                      LogicalKeyboardKey.control, LogicalKeyboardKey.keyE):
                  const MoveCurserEndIntent(),
            },
            child: Observer(
                builder: (_) => ListView(
                      children: store.children
                          .map((noteStore) => NoteItem(noteStore))
                          .toList(),
                    )),
          ),
        ));
    // });
  }
}

class NoteItem extends StatelessWidget {
  final NoteStore store;

  const NoteItem(this.store, {Key? key}) : super(key: key);

  // note.content = "abcd";

  @override
  Widget build(BuildContext context) {
    print('NoteItem build ${store.id}');
    return GestureDetector(
        onTap: () {
          store.topicStore.setEditingNoteId(store.id);
        },
        child: Actions(
            actions: <Type, Action<Intent>>{
              NewNextNoteIntent: NewNextNoteAction(store),
              NewChildNoteIntent: NewChildNoteAction(store),
              IndentNoteIntent: IndentNoteAction(store),
              UnIndentNoteIntent: UnIndentNoteAction(store),
              MoveFocusPrevIntent: MoveFocusPrevAction(store),
              MoveFocusNextIntent: MoveFocusNextAction(store),
              MoveCurserForewardIntent:
                  MoveCurserForewardAction(store.editingController),
              MoveCurserBackwardIntent:
                  MoveCurserBackwardAction(store.editingController),
              MoveCurserStartIntent:
                  MoveCurserStartAction(store.editingController),
              MoveCurserEndIntent: MoveCurserEndAction(store.editingController),
            },
            child: Observer(
                builder: (_) => Container(
                    color: Colors.grey[50],

                    // padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Colors.grey[150],
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 10,
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: store.status == NoteStatus.editing
                                      ? TextField(
                                          controller: store.editingController,
                                          onChanged: (val) {
                                            store.updateContent(val);
                                          },
                                          autofocus: true,
                                        )
                                      : Text(
                                          store.content,
                                        )),
                            ],
                          ),
                        ),
                        Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: Observer(
                              builder: (_) => Column(
                                children: store.children
                                    .map((noteStore) => NoteItem(noteStore))
                                    .toList(),
                              ),
                            ))
                      ],
                    )))));
  }
}
