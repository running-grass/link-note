import 'package:flutter/widgets.dart';
import 'package:entity/entity.dart';

// 下一个同级新行
class NewNextNoteIntent extends Intent {
  const NewNextNoteIntent();
}

class NewNextNoteAction extends Action<NewNextNoteIntent> {
  NewNextNoteAction(this.noteStore);

  final NoteStore noteStore;

  @override
  Object? invoke(covariant NewNextNoteIntent intent) {
    noteStore.addNextNote("");
    // print("next note");
  }
}

// 添加一个子级别空行
class NewChildNoteIntent extends Intent {
  const NewChildNoteIntent();
}

class NewChildNoteAction extends Action<NewChildNoteIntent> {
  NewChildNoteAction(this.noteStore);

  final NoteStore noteStore;

  @override
  Object? invoke(covariant NewChildNoteIntent intent) {
    noteStore.addChildNote("");
    // print("child note");
  }
}

// 移动到前节点的元素末尾
class IndentNoteIntent extends Intent {
  const IndentNoteIntent();
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

// 移动到父节点的后继元素
class UnIndentNoteIntent extends Intent {
  const UnIndentNoteIntent();
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

// 焦点移动到下一个
class MoveFocusNextIntent extends Intent {
  const MoveFocusNextIntent();
}

class MoveFocusNextAction extends Action<MoveFocusNextIntent> {
  MoveFocusNextAction(this.noteStore);

  final NoteStore noteStore;

  @override
  Object? invoke(covariant MoveFocusNextIntent intent) {
    noteStore.moveFoucsNext();
  }
}

// 焦点移动到上一个
class MoveFocusPrevIntent extends Intent {
  const MoveFocusPrevIntent();
}

class MoveFocusPrevAction extends Action<MoveFocusPrevIntent> {
  MoveFocusPrevAction(this.noteStore);

  final NoteStore noteStore;

  @override
  Object? invoke(covariant MoveFocusPrevIntent intent) {
    noteStore.moveFoucsPrev();
  }
}

// 移动光标向前么移动
class MoveCurserForewardIntent extends Intent {
  const MoveCurserForewardIntent();
}

class MoveCurserForewardAction extends Action<MoveCurserForewardIntent> {
  MoveCurserForewardAction(this.editingController);

  final TextEditingController editingController;

  @override
  Object? invoke(covariant MoveCurserForewardIntent intent) {
    TextSelection selection = editingController.selection;
    var end = selection.end;
    if (end != -1 && end < editingController.text.length) {
      editingController.selection =
          TextSelection(baseOffset: end + 1, extentOffset: end + 1);
    }
  }
}

// 移动光标向后么移动
class MoveCurserBackwardIntent extends Intent {
  const MoveCurserBackwardIntent();
}

class MoveCurserBackwardAction extends Action<MoveCurserBackwardIntent> {
  MoveCurserBackwardAction(this.editingController);

  final TextEditingController editingController;

  @override
  Object? invoke(covariant MoveCurserBackwardIntent intent) {
    TextSelection selection = editingController.selection;
    var end = selection.end;
    if (end != -1 && end > 0) {
      editingController.selection =
          TextSelection(baseOffset: end - 1, extentOffset: end - 1);
    }
  }
}

// 移动光标到行首
class MoveCurserStartIntent extends Intent {
  const MoveCurserStartIntent();
}

class MoveCurserStartAction extends Action<MoveCurserStartIntent> {
  MoveCurserStartAction(this.editingController);

  final TextEditingController editingController;

  @override
  Object? invoke(covariant MoveCurserStartIntent intent) {
    editingController.selection =
        const TextSelection(baseOffset: 0, extentOffset: 0);
  }
}

// 移动光标到行首
class MoveCurserEndIntent extends Intent {
  const MoveCurserEndIntent();
}

class MoveCurserEndAction extends Action<MoveCurserEndIntent> {
  MoveCurserEndAction(this.editingController);

  final TextEditingController editingController;

  @override
  Object? invoke(covariant MoveCurserEndIntent intent) {
    var len = editingController.text.length;
    editingController.selection =
        TextSelection(baseOffset: len, extentOffset: len);
  }
}
