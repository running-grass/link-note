import 'package:objectbox/objectbox.dart';

import 'note.dart';

@Entity()
class Topic {
  int id = 0;

  @Unique()
  String name;

  late DateTime created;

  @Index()
  late DateTime updated;

  @Backlink("topicHost")
  final notes = ToMany<Note>();

  // 处理note节点树
  @Transient()
  List<Note>? noteTree;

  Topic({
    required this.name,
    DateTime? created,
    DateTime? updated,
  }) {
    this.created = created ?? DateTime.now();
    this.updated = updated ?? DateTime.now();
  }
}
