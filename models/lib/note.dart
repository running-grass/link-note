import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:json_annotation/json_annotation.dart';

import 'primTypeDefs.dart';

part 'note.g.dart';

enum HostType {
  topic,
  goal,
}

@JsonSerializable()
class Note {
  NoteId noteId;

  String heading;

  HostType hostType;

  String hostId;

  DateTime created;

  DateTime updated;

  NoteId? parentId;

  int sort;

  Note({
    required this.noteId,
    required this.heading,
    required this.hostType,
    required this.hostId,
    required this.created,
    required this.updated,
    required this.parentId,
    required this.sort,
  });
}

@Collection<Note>('notes')
final NoteCollectionReference noteRef = NoteCollectionReference();
