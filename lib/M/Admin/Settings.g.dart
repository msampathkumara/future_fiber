// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings()
  ..erpNotWorking = json['erpNotWorking'] as int
  ..otpAdminEmails = (json['otpAdminEmails'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [];

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'erpNotWorking': instance.erpNotWorking,
      'otpAdminEmails': instance.otpAdminEmails,
    };
