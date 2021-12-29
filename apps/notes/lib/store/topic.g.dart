// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$TopicStore on _TopicStore, Store {
  Computed<String>? _$topicNameComputed;

  @override
  String get topicName =>
      (_$topicNameComputed ??= Computed<String>(() => super.topicName,
              name: '_TopicStore.topicName'))
          .value;
  Computed<List<Note>>? _$childrenComputed;

  @override
  List<Note> get children =>
      (_$childrenComputed ??= Computed<List<Note>>(() => super.children,
              name: '_TopicStore.children'))
          .value;

  final _$_topicAtom = Atom(name: '_TopicStore._topic');

  @override
  Topic get _topic {
    _$_topicAtom.reportRead();
    return super._topic;
  }

  @override
  set _topic(Topic value) {
    _$_topicAtom.reportWrite(value, super._topic, () {
      super._topic = value;
    });
  }

  final _$_TopicStoreActionController = ActionController(name: '_TopicStore');

  @override
  dynamic loadTopic() {
    final _$actionInfo = _$_TopicStoreActionController.startAction(
        name: '_TopicStore.loadTopic');
    try {
      return super.loadTopic();
    } finally {
      _$_TopicStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic updateName(dynamic newName) {
    final _$actionInfo = _$_TopicStoreActionController.startAction(
        name: '_TopicStore.updateName');
    try {
      return super.updateName(newName);
    } finally {
      _$_TopicStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
topicName: ${topicName},
children: ${children}
    ''';
  }
}
