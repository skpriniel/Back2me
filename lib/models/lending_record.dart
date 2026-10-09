import 'package:hive/hive.dart';
import '../utils/app_date_utils.dart';

enum LendingStatus { active, returned }

class LendingRecord {
  final String id;
  String itemId;
  String borrowerId;
  DateTime borrowDate;
  DateTime expectedReturnDate;
  DateTime? actualReturnDate;
  String? note;
  LendingStatus status;

  LendingRecord({
    required this.id,
    required this.itemId,
    required this.borrowerId,
    required this.borrowDate,
    required this.expectedReturnDate,
    this.actualReturnDate,
    this.note,
    this.status = LendingStatus.active,
  });

  /// Derived, not stored: overdue is computed from the expected return
  /// date and "now" so a stale flag can never be saved to disk.
  bool get isOverdue => status == LendingStatus.active && AppDateUtils.isPastToday(expectedReturnDate);
}

class LendingRecordAdapter extends TypeAdapter<LendingRecord> {
  @override
  final int typeId = 2;

  @override
  LendingRecord read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return LendingRecord(
      id: f[0] as String,
      itemId: f[1] as String,
      borrowerId: f[2] as String,
      borrowDate: f[3] as DateTime,
      expectedReturnDate: f[4] as DateTime,
      actualReturnDate: f[5] as DateTime?,
      note: f[6] as String?,
      status: LendingStatus.values[f[7] as int],
    );
  }

  @override
  void write(BinaryWriter writer, LendingRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemId)
      ..writeByte(2)
      ..write(obj.borrowerId)
      ..writeByte(3)
      ..write(obj.borrowDate)
      ..writeByte(4)
      ..write(obj.expectedReturnDate)
      ..writeByte(5)
      ..write(obj.actualReturnDate)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.status.index);
  }
}
