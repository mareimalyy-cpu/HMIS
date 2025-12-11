import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'generated/local_storage.g.dart';

final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage.instance;
});

@collection
class StorageItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  late String value;
}

class LocalStorage {
  LocalStorage._internal();
  static final LocalStorage instance = LocalStorage._internal();

  Isar? _isar;

  Future<void> init() async {
    if (_isar != null) return; // Prevent multiple openings

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([StorageItemSchema], directory: dir.path);
  }

  Isar get isar {
    if (_isar == null) {
      throw Exception("Isar not initialized. Call init() first.");
    }
    return _isar!;
  }

  /// ADD or EDIT a key-value pair
  Future<void> add(String key, String value) async {
    final item = StorageItem()
      ..key = key
      ..value = value;

    await isar.writeTxn(() async {
      await isar.storageItems.put(item);
    });
  }

  /// GET value by key
  Future<String?> get(String key) async {
    final item = await isar.storageItems.filter().keyEqualTo(key).findFirst();
    return item?.value;
  }

  /// DELETE by key
  Future<void> delete(String key) async {
    await isar.writeTxn(() async {
      await isar.storageItems.filter().keyEqualTo(key).deleteAll();
    });
  }
}
