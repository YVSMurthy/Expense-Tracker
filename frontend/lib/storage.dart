import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/data_security.dart';

class Storage {
  late final DataSecurity _ds;
  late final FlutterSecureStorage _storage;

  Storage() {
    _storage = FlutterSecureStorage();
    _ds = DataSecurity();
  }

  Future<void> set(String key, String text) async {
    final String encryptedText = _ds.encrypt(text);
    await _storage.write(key: key, value: encryptedText);
  }

  Future<String?> get(String key) async {
    final encryptedText = (await _storage.read(key: key));
    return encryptedText != null ? _ds.decrypt(encryptedText) : null;
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}