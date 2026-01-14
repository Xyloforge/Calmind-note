import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'note_model.g.dart';

@JsonSerializable()
class Note extends Equatable {
  final String id;
  final String title;

  /// Stores the Quill Delta JSON as a string.
  @JsonKey(name: 'content_json')
  final String contentJson;

  @JsonKey(
    name: 'created_at',
    fromJson: _dateTimeFromInt,
    toJson: _dateTimeToInt,
  )
  final DateTime createdAt;

  @JsonKey(
    name: 'updated_at',
    fromJson: _dateTimeFromInt,
    toJson: _dateTimeToInt,
  )
  final DateTime updatedAt;

  @JsonKey(name: 'folder_id')
  final String? folderId;

  @JsonKey(name: 'is_pinned')
  final bool isPinned;

  const Note({
    required this.id,
    required this.title,
    required this.contentJson,
    required this.createdAt,
    required this.updatedAt,
    this.folderId,
    this.isPinned = false,
  });

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);

  Map<String, dynamic> toJson() => _$NoteToJson(this);

  Note copyWith({
    String? id,
    String? title,
    String? contentJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? folderId,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      contentJson: contentJson ?? this.contentJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      folderId: folderId ?? this.folderId,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    contentJson,
    createdAt,
    updatedAt,
    folderId,
    isPinned,
  ];
}

DateTime _dateTimeFromInt(int millis) =>
    DateTime.fromMillisecondsSinceEpoch(millis);
int _dateTimeToInt(DateTime date) => date.millisecondsSinceEpoch;
