// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Announcement _$AnnouncementFromJson(Map<String, dynamic> json) => Announcement(
  notificationId: json['notificationId'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  severity: (json['severity'] as num).toInt(),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  validTo: json['validTo'] == null
      ? null
      : DateTime.parse(json['validTo'] as String),
);
