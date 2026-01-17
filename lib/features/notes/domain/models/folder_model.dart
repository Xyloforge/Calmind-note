import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'folder_model.g.dart';

@JsonSerializable()
class Folder extends Equatable {
  final String id;
  final String name;

  @JsonKey(
    name: 'created_at',
    fromJson: _dateTimeFromInt,
    toJson: _dateTimeToInt,
  )
  final DateTime createdAt;

  const Folder({required this.id, required this.name, required this.createdAt});

  factory Folder.fromJson(Map<String, dynamic> json) => _$FolderFromJson(json);

  Map<String, dynamic> toJson() => _$FolderToJson(this);

  Folder copyWith({String? id, String? name, DateTime? createdAt}) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt];
}

DateTime _dateTimeFromInt(int millis) =>
    DateTime.fromMillisecondsSinceEpoch(millis);
int _dateTimeToInt(DateTime date) => date.millisecondsSinceEpoch;
