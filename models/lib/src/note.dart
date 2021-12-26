import 'package:objectbox/objectbox.dart';

enum HostType {
  unknown,
  topic,
  goal,
}

@Entity()
class Note {
  int id = 0;

  String heading;

  HostType hostType = HostType.unknown;

  int hostId;

  late DateTime created;

  late DateTime updated;

  final parent = ToOne<Note>();

  @Backlink("parent")
  final children = ToMany<Note>();

  int sort;

  Note({
    required this.heading,
    required this.hostId,
    required this.sort,
    DateTime? created,
    DateTime? updated,
  }) {
    this.created = created ?? DateTime.now();
    this.updated = updated ?? DateTime.now();
  }

  void _ensureStableEnumValues() {
    assert(HostType.unknown == 0);
    assert(HostType.topic == 1);
    assert(HostType.goal == 2);
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
