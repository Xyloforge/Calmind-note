// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Folder _$FolderFromJson(Map<String, dynamic> json) => Folder(
  id: json['id'] as String,
  name: json['name'] as String,
  createdAt: _dateTimeFromInt((json['created_at'] as num).toInt()),
);

Map<String, dynamic> _$FolderToJson(Folder instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'created_at': _dateTimeToInt(instance.createdAt),
};
