import 'package:hive/hive.dart';

class UserProfile {
  final String id;
  String fullName;
  String emailAddress;
  String phoneNumber;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.emailAddress,
    required this.phoneNumber,
  });
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 3;

  @override
  UserProfile read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return UserProfile(
      id: f[0] as String,
      fullName: f[1] as String,
      emailAddress: f[2] as String,
      phoneNumber: f[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.emailAddress)
      ..writeByte(3)
      ..write(obj.phoneNumber);
  }
}
