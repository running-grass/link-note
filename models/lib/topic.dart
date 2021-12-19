import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:json_annotation/json_annotation.dart';

import 'primTypeDefs.dart';

part 'topic.g.dart';

@JsonSerializable()
class Topic {
  TopicId topicId;

  String topicName;

  DateTime created;

  DateTime updated;

  Topic({
    required this.topicId,
    required this.topicName,
    required this.created,
    required this.updated,
  });
}

@Collection<Topic>('topics')
final TopicCollectionReference topicRef = TopicCollectionReference();
