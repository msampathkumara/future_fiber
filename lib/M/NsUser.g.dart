// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NsUser.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NsUserAdapter extends TypeAdapter<NsUser> {
  @override
  final int typeId = 6;

  @override
  NsUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NsUser()
      ..id = fields[0] == null ? 0 : fields[0] as int
      ..uname = fields[1] == null ? '' : fields[1] as String
      ..pword = fields[2] == null ? '' : fields[2] as String
      ..name = fields[3] == null ? '' : fields[3] as String
      ..utype = fields[4] == null ? '' : fields[4] as String
      ..epf = fields[5] == null ? '' : fields[5] as String
      ..etype = fields[6] == null ? 0 : fields[6] as int
      ..sectionId = fields[7] == null ? 0 : fields[7] as int
      ..loft = fields[8] == null ? 0 : fields[8] as int
      ..phone = fields[9] == null ? '' : fields[9] as String
      ..img = fields[10] == null ? '' : fields[10] as String
      ..sectionName = fields[11] == null ? '' : fields[11] as String
      ..emailAddress = fields[12] == null ? '' : fields[12] as String
      ..sections = fields[13] == null ? [] : (fields[13] as List).cast<Section>()
      ..address = fields[14] == null ? '' : fields[14] as String
      ..hasNfc = fields[15] == null ? 0 : fields[15] as int
      ..deactivate = fields[16] == null ? 0 : fields[16] as int
      ..permissions = fields[17] == null ? [] : (fields[17] as List).cast<String>()
      ..upon = fields[18] == null ? 0 : fields[18] as int
      ..emails = fields[19] == null ? [] : (fields[19] as List).cast<Email>()
      ..nic = fields[20] as String?
      ..uptime = fields[101] == null ? 0 : fields[101] as int;
  }

  @override
  void write(BinaryWriter writer, NsUser obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.uname)
      ..writeByte(2)
      ..write(obj.pword)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.utype)
      ..writeByte(5)
      ..write(obj.epf)
      ..writeByte(6)
      ..write(obj.etype)
      ..writeByte(7)
      ..write(obj.sectionId)
      ..writeByte(8)
      ..write(obj.loft)
      ..writeByte(9)
      ..write(obj.phone)
      ..writeByte(10)
      ..write(obj.img)
      ..writeByte(11)
      ..write(obj.sectionName)
      ..writeByte(12)
      ..write(obj.emailAddress)
      ..writeByte(13)
      ..write(obj.sections)
      ..writeByte(14)
      ..write(obj.address)
      ..writeByte(15)
      ..write(obj.hasNfc)
      ..writeByte(16)
      ..write(obj.deactivate)
      ..writeByte(17)
      ..write(obj.permissions)
      ..writeByte(18)
      ..write(obj.upon)
      ..writeByte(19)
      ..write(obj.emails)
      ..writeByte(20)
      ..write(obj.nic)
      ..writeByte(101)
      ..write(obj.uptime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NsUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NsUser _$NsUserFromJson(Map<String, dynamic> json) => NsUser()
  ..uptime = json['uptime'] as int? ?? 0
  ..id = json['id'] as int? ?? 0
  ..uname = json['uname'] as String? ?? ''
  ..pword = json['pword'] as String? ?? ''
  ..name = json['name'] as String
  ..utype = json['utype'] as String? ?? ''
  ..epf = json['epf'] as String? ?? ''
  ..etype = json['etype'] as int? ?? 0
  ..sectionId = json['sectionId'] as int? ?? 0
  ..loft = json['loft'] as int? ?? 0
  ..phone = json['phone'] as String? ?? ''
  ..img = json['img'] as String? ?? ''
  ..sectionName = json['sectionName'] as String? ?? '-'
  ..emailAddress = json['emailAddress'] as String? ?? '-'
  ..sections = (json['sections'] as List<dynamic>?)?.map((e) => Section.fromJson(e as Map<String, dynamic>)).toList() ?? []
  ..address = json['address'] as String? ?? ''
  ..hasNfc = json['hasNfc'] as int? ?? 0
  ..deactivate = json['deactivate'] as int? ?? 0
  ..permissions = (json['permissions'] as List<dynamic>?)?.map((e) => e as String).toList() ?? []
  ..upon = json['upon'] as int? ?? 0
  ..emails = (json['emails'] as List<dynamic>?)?.map((e) => Email.fromJson(e as Map<String, dynamic>)).toList() ?? []
  ..nic = json['nic'] as String?
  ..password = json['password'] as String?;

Map<String, dynamic> _$NsUserToJson(NsUser instance) => <String, dynamic>{
      'uptime': instance.uptime,
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
      'address': instance.address,
      'hasNfc': instance.hasNfc,
      'deactivate': instance.deactivate,
      'permissions': instance.permissions,
      'upon': instance.upon,
      'emails': instance.emails.map((e) => e.toJson()).toList(),
      'nic': instance.nic,
      'password': instance.password,
    };
