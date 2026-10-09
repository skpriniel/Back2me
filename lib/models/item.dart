import 'package:hive/hive.dart';

enum ItemStatus { available, borrowed }

class Item {
  final String id;
  String name;
  String category;
  String description;
  String condition;
  ItemStatus status;
  final DateTime dateAdded;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.condition,
    required this.status,
    required this.dateAdded,
  });
}

/// Manual Hive TypeAdapter (no build_runner / code generation required).
class ItemAdapter extends TypeAdapter<Item> {
  @override
  final int typeId = 0;

  @override
  Item read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{for (int i = 0; i < n; i++) reader.readByte(): reader.read()};
    return Item(
      id: f[0] as String,
      name: f[1] as String,
      category: f[2] as String,
      description: f[3] as String,
      condition: f[4] as String,
      status: ItemStatus.values[f[5] as int],
      dateAdded: f[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Item obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.condition)
      ..writeByte(5)
      ..write(obj.status.index)
      ..writeByte(6)
      ..write(obj.dateAdded);
  }
}

const List<String> kItemCategories = [
  'Electronics',
  'Books',
  'Tools',
  'Sports Equipment',
  'Clothing',
  'Others',
];

const List<String> kItemConditions = ['New', 'Good', 'Fair', 'Worn'];
