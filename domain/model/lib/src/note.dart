import 'package:objectbox/objectbox.dart';

import 'topic.dart';

enum HostType {
  unknown,
  topic,
  goal,
}

@Entity()
class Note {
  int id = 0;

  String content;

  HostType hostType = HostType.unknown;

  final topicHost = ToOne<Topic>();

  late DateTime created;

  late DateTime updated;

  final parent = ToOne<Note>();

  @Backlink("parent")
  final children = ToMany<Note>();

  int sort;

  // 处理note节点树
  @Transient()
  List<Note>? noteTree;

  Note({
    required this.content,
    required this.sort,
    required dbHostType,
    Topic? topicHost,
    DateTime? created,
    DateTime? updated,
  }) {
    this.created = created ?? DateTime.now();
    this.updated = updated ?? DateTime.now();
    // 设置不同的hostType
    this.dbHostType = dbHostType;
    switch (this.hostType) {
      case HostType.topic:
        if (topicHost != null) {
          this.topicHost.target = topicHost;
        }
        break;
      case HostType.goal:
        throw UnsupportedError("暂时还不支持goal类型");
      default:
        throw ArgumentError();
    }
  }

  void _ensureStableEnumValues() {
    assert(HostType.unknown.index == 0);
    assert(HostType.topic.index == 1);
    assert(HostType.goal.index == 2);
  }

  int get dbHostType {
    _ensureStableEnumValues();
    return hostType.index;
  }

  set dbHostType(int value) {
    _ensureStableEnumValues();
    hostType = value >= 0 && value < HostType.values.length
        ? HostType.values[value]
        : HostType.unknown;
  }
}
