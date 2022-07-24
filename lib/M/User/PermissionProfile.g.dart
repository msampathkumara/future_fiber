// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PermissionProfile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PermissionProfile _$PermissionProfileFromJson(Map<String, dynamic> json) => PermissionProfile()
  ..id = json['id'] as int? ?? 0
  ..name = json['name'] as String? ?? ''
  ..permissions = (json['permissions'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [];

Map<String, dynamic> _$PermissionProfileToJson(PermissionProfile instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'permissions': instance.permissions,
    };
