import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get.dart';
import 'package:notes/store/note.dart';
import 'package:notes/store/topic.dart';

class NewNextNoteIntent extends Intent {
  const NewNextNoteIntent();
}

class NewChildNoteIntent extends Intent {
  const NewChildNoteIntent();
}

class NewNextNoteAction extends Action<NewNextNoteIntent> {
  NewNextNoteAction(this.noteStore);

  final NoteStore noteStore;

  @override
  Object? invoke(covariant NewNextNoteIntent intent) {
    noteStore.addNextNote("");
    print("next note");
  }
}

class NewChildNoteAction extends Action<NewChildNoteIntent> {
  NewChildNoteAction(this.noteStore);

  final NoteStore noteStore;

  @override
  Object? invoke(covariant NewChildNoteIntent intent) {
    noteStore.addChildNote("");
    print("child note");
  }
}

class IndentNoteIntent extends Intent {
  const IndentNoteIntent();
}

class UnIndentNoteIntent extends Intent {
  const UnIndentNoteIntent();
}

class IndentNoteAction extends Action<IndentNoteIntent> {
  IndentNoteAction(this.noteStore);

  final NoteStore noteStore;

  @override
  Object? invoke(covariant IndentNoteIntent intent) {
    noteStore.toChild();
    print("indent");
  }
}

class UnIndentNoteAction extends Action<UnIndentNoteIntent> {
  UnIndentNoteAction(this.noteStore);

  final NoteStore noteStore;

  @override
  Object? invoke(covariant UnIndentNoteIntent intent) {
    noteStore.toParent();
    print("unindent");
  }
}

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
                                      ? TextFormField(
                                          initialValue: store.content,
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
