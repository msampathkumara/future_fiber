// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NsUser.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NsUser _$NsUserFromJson(Map<String, dynamic> json) => NsUser()
  ..id = json['id'] as int? ?? 0
  ..uname = json['uname'] as String
  ..pword = json['pword'] as String? ?? ''
  ..name = json['name'] as String
  ..utype = json['utype'] as String? ?? ''
  ..epf = json['epf'] as String? ?? ''
  ..etype = json['etype'] as int? ?? 0
  ..sectionId = json['sectionId'] as int? ?? 0
  ..loft = json['loft'] as int? ?? 0
  ..phone = json['phone'] as String? ?? ''
  ..img = json['img'] as String? ?? '0'
  ..sectionName = json['sectionName'] as String? ?? '-'
  ..emailAddress = json['emailAddress'] as String? ?? '-'
  ..sections = (json['sections'] as List<dynamic>?)
          ?.map((e) => Section.fromJson(e as Map<String, dynamic>))
          .toList() ??
      []
  ..section = json['section'] == null
      ? null
      : Section.fromJson(json['section'] as Map<String, dynamic>)
  ..hasNfc = json['hasNfc'] as int? ?? 0;

Map<String, dynamic> _$NsUserToJson(NsUser instance) => <String, dynamic>{
      'id': instance.id,
      'uname': instance.uname,
      'pword': instance.pword,
      'name': instance.name,
      'utype': instance.utype,
      'epf': instance.epf,
      'etype': instance.etype,
      'sectionId': instance.sectionId,
      'loft': instance.loft,
      'phone': instance.phone,
      'img': instance.img,
      'sectionName': instance.sectionName,
      'emailAddress': instance.emailAddress,
      'sections': instance.sections.map((e) => e.toJson()).toList(),
      'section': instance.section?.toJson(),
      'hasNfc': instance.hasNfc,
    };
