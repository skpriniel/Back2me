import 'package:hive_flutter/hive_flutter.dart';
import '../models/item.dart';
import '../models/borrower.dart';
import '../models/lending_record.dart';
import '../models/user_profile.dart';

/// Handles Hive initialization and box access. Hive.initFlutter() uses
/// IndexedDB-backed storage in the browser, so the same code path works
/// unmodified on Flutter web as well as mobile/desktop.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const itemsBoxName = 'items';
  static const borrowersBoxName = 'borrowers';
  static const lendingRecordsBoxName = 'lending_records';
  static const userProfileBoxName = 'user_profile';
  static const metaBoxName = 'meta';

  late Box<Item> itemsBox;
  late Box<Borrower> borrowersBox;
  late Box<LendingRecord> lendingRecordsBox;
  late Box<UserProfile> userProfileBox;
  late Box metaBox;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ItemAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(BorrowerAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(LendingRecordAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(UserProfileAdapter());

    itemsBox = await Hive.openBox<Item>(itemsBoxName);
    borrowersBox = await Hive.openBox<Borrower>(borrowersBoxName);
    lendingRecordsBox = await Hive.openBox<LendingRecord>(lendingRecordsBoxName);
    userProfileBox = await Hive.openBox<UserProfile>(userProfileBoxName);
    metaBox = await Hive.openBox(metaBoxName);

    _initialized = true;
  }
}
