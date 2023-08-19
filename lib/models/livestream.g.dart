// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'livestream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Livestream _$LivestreamFromJson(Map<String, dynamic> json) => Livestream(
      livestreamId: json['livestreamId'] as String?,
      displayName: json['displayName'] as String?,
      isDeletable: json['isDeletable'] as bool? ?? true,
    )..isSelectable = json['isSelectable'] as bool?;

Map<String, dynamic> _$LivestreamToJson(Livestream instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('isDeletable', instance.isDeletable);
  writeNotNull('isSelectable', instance.isSelectable);
  writeNotNull('livestreamId', instance.livestreamId);
  writeNotNull('displayName', instance.displayName);
  return val;
}
