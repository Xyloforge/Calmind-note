// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
  id: json['id'] as String,
  title: json['title'] as String,
  contentJson: json['content_json'] as String,
  createdAt: _dateTimeFromInt((json['created_at'] as num).toInt()),
  updatedAt: _dateTimeFromInt((json['updated_at'] as num).toInt()),
  folderId: json['folder_id'] as String?,
  isPinned: json['is_pinned'] == 1,
);

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content_json': instance.contentJson,
  'created_at': _dateTimeToInt(instance.createdAt),
  'updated_at': _dateTimeToInt(instance.updatedAt),
  'folder_id': instance.folderId,
  'is_pinned': instance.isPinned ? 1 : 0,
};
