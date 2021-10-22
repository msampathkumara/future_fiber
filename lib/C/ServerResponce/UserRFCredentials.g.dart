// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserRFCredentials.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRFCredentials _$UserRFCredentialsFromJson(Map<String, dynamic> json) =>
    UserRFCredentials()
      ..uid = json['uid'] as int?
      ..uname = json['uname'] as String?
      ..pword = json['pword'] as String?;

Map<String, dynamic> _$UserRFCredentialsToJson(UserRFCredentials instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'uname': instance.uname,
      'pword': instance.pword,
    };
