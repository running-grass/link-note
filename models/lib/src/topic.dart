import 'package:objectbox/objectbox.dart';

@Entity()
class Topic {
  int id = 0;

  @Unique()
  String name;

  late DateTime created;

  @Index()
  late DateTime updated;

  Topic({
    required this.name,
    DateTime? created,
    DateTime? updated,
  }) {
    this.created = created ?? DateTime.now();
    this.updated = updated ?? DateTime.now();
  }
}
