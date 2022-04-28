// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message()
  ..self = json['self'] as int
  ..userId = json['userId'] as int
  ..text = json['text'] as String
  ..dnt = json['dnt'] as String
  ..user = json['user'] == null ? null : NsUser.fromJson(json['user'] as Map<String, dynamic>);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'self': instance.self,
      'userId': instance.userId,
      'text': instance.text,
      'dnt': instance.dnt,
      'user': instance.user?.toJson(),
    };
