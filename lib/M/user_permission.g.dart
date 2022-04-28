// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_permission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPermission _$UserPermissionFromJson(Map<String, dynamic> json) => UserPermission()
  ..description = json['description'] as String? ?? ''
  ..uptime = json['uptime'] as int? ?? 0
  ..id = json['id'] as int? ?? 0
  ..name = json['name'] as String? ?? ''
  ..category = json['category'] as String? ?? ''
  ..permit = json['permit'] as int? ?? 0;

Map<String, dynamic> _$UserPermissionToJson(UserPermission instance) => <String, dynamic>{
      'description': instance.description,
      'uptime': instance.uptime,
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'permit': instance.permit,
    };
