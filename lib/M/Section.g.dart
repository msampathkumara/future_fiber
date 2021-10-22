// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Section _$SectionFromJson(Map<String, dynamic> json) => Section()
  ..id = json['id'] as int? ?? 0
  ..sectionTitle = json['sectionTitle'] as String? ?? '-'
  ..factory = json['factory'] as String? ?? '-'
  ..loft = json['loft'] as String? ?? '-';

Map<String, dynamic> _$SectionToJson(Section instance) => <String, dynamic>{
      'id': instance.id,
      'sectionTitle': instance.sectionTitle,
      'factory': instance.factory,
      'loft': instance.loft,
    };
