// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NsUser.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NsUser _$NsUserFromJson(Map<String, dynamic> json) {
  return NsUser()
    ..id = json['id'] as int? ?? 0
    ..uname = json['uname'] as String
    ..pword = json['pword'] as String? ?? ''
    ..name = json['name'] as String
    ..utype = json['utype'] as String
    ..epf = json['epf'] as String
    ..etype = json['etype'] as int? ?? 0
    ..section = json['section'] as int? ?? 0
    ..loft = json['loft'] as int? ?? 0
    ..contact = json['contact'] as String
    ..img = json['img'] as String? ?? '0'
    ..sectionName = json['sectionName'] as String? ?? '-'
    ..emailAddress = json['emailAddress'] as String? ?? '-';
}

Map<String, dynamic> _$NsUserToJson(NsUser instance) => <String, dynamic>{
      'id': instance.id,
      'uname': instance.uname,
      'pword': instance.pword,
      'name': instance.name,
      'utype': instance.utype,
      'epf': instance.epf,
      'etype': instance.etype,
      'section': instance.section,
      'loft': instance.loft,
      'contact': instance.contact,
      'img': instance.img,
      'sectionName': instance.sectionName,
      'emailAddress': instance.emailAddress,
    };