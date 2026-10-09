import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/item.dart';
import '../models/borrower.dart';
import '../models/lending_record.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

/// Single source of truth for the app's data. Wraps the Hive boxes with
/// in-memory lists so widgets can read synchronously and rebuild via
/// ChangeNotifier + AppStateScope whenever something changes.
class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;
  final _random = Random();

  final List<Item> items = [];
  final List<Borrower> borrowers = [];
  final List<LendingRecord> lendingRecords = [];
  UserProfile? profile;

  String _newId(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(9999)}';

  Future<void> load() async {
    items
      ..clear()
      ..addAll(_storage.itemsBox.values);
    borrowers
      ..clear()
      ..addAll(_storage.borrowersBox.values);
    lendingRecords
      ..clear()
      ..addAll(_storage.lendingRecordsBox.values);
    profile = _storage.userProfileBox.values.isNotEmpty ? _storage.userProfileBox.values.first : null;

    final seeded = _storage.metaBox.get('sample_data_seeded', defaultValue: false) as bool;
    if (!seeded && items.isEmpty) {
      seedSampleData();
      await _storage.metaBox.put('sample_data_seeded', true);
    }
    notifyListeners();
  }

  Future<void> saveProfile({required String fullName, required String emailAddress, required String phoneNumber}) async {
    final current = profile;
    final updated = UserProfile(
      id: current?.id ?? 'local-profile',
      fullName: fullName.trim(),
      emailAddress: emailAddress.trim(),
      phoneNumber: phoneNumber.trim(),
    );
    await _storage.userProfileBox.put(updated.id, updated);
    profile = updated;
    notifyListeners();
  }

  // ---------------- Items ----------------

  Item addItem({
    required String name,
    required String category,
    required String description,
    required String condition,
  }) {
    final item = Item(
      id: _newId('item'),
      name: name,
      category: category,
      description: description,
      condition: condition,
      status: ItemStatus.available,
      dateAdded: DateTime.now(),
    );
    items.add(item);
    _storage.itemsBox.put(item.id, item);
    notifyListeners();
    return item;
  }

  void updateItem(
    String id, {
    String? name,
    String? category,
    String? description,
    String? condition,
  }) {
    final item = itemById(id);
    if (item == null) return;
    item.name = name ?? item.name;
    item.category = category ?? item.category;
    item.description = description ?? item.description;
    item.condition = condition ?? item.condition;
    _storage.itemsBox.put(item.id, item);
    notifyListeners();
  }

  /// Returns false (and makes no change) if the item currently has an
  /// active lending record, so item/lending status can never conflict.
  bool deleteItem(String id) {
    if (activeLendingRecordForItem(id) != null) return false;
    items.removeWhere((i) => i.id == id);
    _storage.itemsBox.delete(id);
    notifyListeners();
    return true;
  }

  Item? itemById(String id) {
    for (final i in items) {
      if (i.id == id) return i;
    }
    return null;
  }

  List<Item> get availableItems => items.where((i) => i.status == ItemStatus.available).toList();

  // ---------------- Borrowers ----------------

  Borrower findOrCreateBorrower({
    required String name,
    required String contactNumber,
    String? email,
  }) {
    final normalized = name.trim().toLowerCase();
    for (final b in borrowers) {
      if (b.name.trim().toLowerCase() == normalized) {
        b.contactNumber = contactNumber;
        if (email != null && email.isNotEmpty) b.email = email;
        _storage.borrowersBox.put(b.id, b);
        return b;
      }
    }
    final borrower = Borrower(id: _newId('borrower'), name: name.trim(), contactNumber: contactNumber, email: email);
    borrowers.add(borrower);
    _storage.borrowersBox.put(borrower.id, borrower);
    return borrower;
  }

  Borrower? borrowerById(String id) {
    for (final b in borrowers) {
      if (b.id == id) return b;
    }
    return null;
  }

  // ---------------- Lending records ----------------

  LendingRecord? activeLendingRecordForItem(String itemId) {
    for (final r in lendingRecords) {
      if (r.itemId == itemId && r.status == LendingStatus.active) return r;
    }
    return null;
  }

  List<LendingRecord> recordsForItem(String itemId) {
    final list = lendingRecords.where((r) => r.itemId == itemId).toList();
    list.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
    return list;
  }

  LendingRecord? lendingRecordById(String id) {
    for (final r in lendingRecords) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Creates a new lending record and marks the item as borrowed.
  /// Returns null (and changes nothing) if the item is unavailable,
  /// preventing duplicate active records for the same item.
  LendingRecord? createLendingRecord({
    required String itemId,
    required String borrowerName,
    required String contactNumber,
    String? email,
    required DateTime borrowDate,
    required DateTime expectedReturnDate,
    String? note,
  }) {
    final item = itemById(itemId);
    if (item == null || item.status == ItemStatus.borrowed) return null;

    final borrower = findOrCreateBorrower(name: borrowerName, contactNumber: contactNumber, email: email);
    final record = LendingRecord(
      id: _newId('lend'),
      itemId: itemId,
      borrowerId: borrower.id,
      borrowDate: borrowDate,
      expectedReturnDate: expectedReturnDate,
      note: note,
      status: LendingStatus.active,
    );
    lendingRecords.add(record);
    _storage.lendingRecordsBox.put(record.id, record);

    item.status = ItemStatus.borrowed;
    _storage.itemsBox.put(item.id, item);

    notifyListeners();
    return record;
  }

  /// Edits an active record's borrower/date/note details. Returns false if
  /// the record does not exist or has already been returned.
  bool updateLendingRecord(
    String recordId, {
    required String borrowerName,
    required String contactNumber,
    String? email,
    required DateTime borrowDate,
    required DateTime expectedReturnDate,
    String? note,
  }) {
    final record = lendingRecordById(recordId);
    if (record == null || record.status != LendingStatus.active) return false;

    final borrower = findOrCreateBorrower(name: borrowerName, contactNumber: contactNumber, email: email);
    record
      ..borrowerId = borrower.id
      ..borrowDate = borrowDate
      ..expectedReturnDate = expectedReturnDate
      ..note = note;
    _storage.lendingRecordsBox.put(record.id, record);
    notifyListeners();
    return true;
  }

  /// Marks a record returned, frees up the item, and keeps the completed
  /// record in history rather than deleting it.
  void markReturned(String recordId) {
    final record = lendingRecordById(recordId);
    if (record == null || record.status == LendingStatus.returned) return;
    record
      ..status = LendingStatus.returned
      ..actualReturnDate = DateTime.now();
    _storage.lendingRecordsBox.put(record.id, record);

    final item = itemById(record.itemId);
    if (item != null) {
      item.status = ItemStatus.available;
      _storage.itemsBox.put(item.id, item);
    }
    notifyListeners();
  }

  // ---------------- Derived counts ----------------

  int get ownedCount => items.length;
  int get activeBorrowedCount => lendingRecords.where((r) => r.status == LendingStatus.active).length;
  int get returnedCount => lendingRecords.where((r) => r.status == LendingStatus.returned).length;

  double get returnRate {
    final total = lendingRecords.length;
    if (total == 0) return 1;
    return returnedCount / total;
  }

  LendingRecord? get nextDueSoonRecord {
    final active = lendingRecords.where((r) => r.status == LendingStatus.active).toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => a.expectedReturnDate.compareTo(b.expectedReturnDate));
    return active.first;
  }

  // ---------------- Sample data ----------------

  /// Seeds a small, realistic dataset on first launch only. Kept separate
  /// from normal storage logic and gated by a "seeded" flag in the meta
  /// box so it never overwrites the user's real data.
  void seedSampleData() {
    final laptop = addItem(name: 'Laptop', category: 'Electronics', description: '14" ultrabook, silver.', condition: 'Good');
    final charger = addItem(name: 'Charger', category: 'Electronics', description: '65W Fast USB-C charger.', condition: 'Good');
    final camera = addItem(name: 'Camera', category: 'Electronics', description: 'Mirrorless camera with 18-55mm lens.', condition: 'Good');
    final comb = addItem(name: 'Comb', category: 'Clothing', description: 'Wooden comb.', condition: 'New');
    final mouse = addItem(name: 'Mouse', category: 'Electronics', description: 'Wireless mouse.', condition: 'Fair');
    final powerbank = addItem(name: 'Powerbank', category: 'Electronics', description: '20,000mAh Anker power bank.', condition: 'Good');

    final now = DateTime.now();

    createLendingRecord(
      itemId: laptop.id,
      borrowerName: 'John Mallari',
      contactNumber: '0921 456 7891',
      borrowDate: now.subtract(const Duration(days: 6)),
      expectedReturnDate: now.add(const Duration(days: 3)),
      note: 'Borrowing for university thesis presentation. Please return with charger.',
    );
    createLendingRecord(
      itemId: mouse.id,
      borrowerName: 'Bria Santos',
      contactNumber: '0917 555 2210',
      borrowDate: now.subtract(const Duration(days: 10)),
      expectedReturnDate: now.subtract(const Duration(days: 2)),
    );

    final r1 = createLendingRecord(
      itemId: camera.id,
      borrowerName: 'Kitt Alvarez',
      contactNumber: '0928 111 3344',
      borrowDate: now.subtract(const Duration(days: 20)),
      expectedReturnDate: now.subtract(const Duration(days: 13)),
    );
    if (r1 != null) markReturned(r1.id);

    final r2 = createLendingRecord(
      itemId: comb.id,
      borrowerName: 'Vonn Reyes',
      contactNumber: '0930 222 4455',
      borrowDate: now.subtract(const Duration(days: 30)),
      expectedReturnDate: now.subtract(const Duration(days: 23)),
    );
    if (r2 != null) markReturned(r2.id);

    final r3 = createLendingRecord(
      itemId: charger.id,
      borrowerName: 'Miguel Santos',
      contactNumber: '0925 333 6677',
      borrowDate: now.subtract(const Duration(days: 40)),
      expectedReturnDate: now.subtract(const Duration(days: 33)),
    );
    if (r3 != null) markReturned(r3.id);

    final r4 = createLendingRecord(
      itemId: powerbank.id,
      borrowerName: 'John Mallari',
      contactNumber: '0921 456 7891',
      borrowDate: now.subtract(const Duration(days: 50)),
      expectedReturnDate: now.subtract(const Duration(days: 43)),
    );
    if (r4 != null) markReturned(r4.id);
  }
}
