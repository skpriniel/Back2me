import 'package:hive/hive.dart';

class Borrower {
  final String id;
  String name;
  String contactNumber;
  String? email;

  Borrower({
    required this.id,
    required this.name,
    required this.contactNumber,
    this.email,
  });
}

class BorrowerAdapter extends TypeAdapter<Borrower> {
  @override
  final int typeId = 1;

  @override
  Borrower read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return Borrower(
      id: f[0] as String,
      name: f[1] as String,
      contactNumber: f[2] as String,
      email: f[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Borrower obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.contactNumber)
      ..writeByte(3)
      ..write(obj.email);
  }
}
