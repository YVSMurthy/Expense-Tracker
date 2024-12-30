import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DataSecurity {
  late final Key _key;
  late final IV _iv;


  DataSecurity() {
    final encryptionKey = dotenv.env['ENCRYPTION_KEY'];
    final ivKey = dotenv.env['IV'];

    _key = Key.fromUtf8(encryptionKey!);
    _iv = IV.fromUtf8(ivKey!);
  }

  String encrypt(String text) {
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(text, iv: _iv);
    return encrypted.base64;
  }

  String decrypt(String ciphertext) {
    final encrypter = Encrypter(AES(_key));
    final decrypted = encrypter.decrypt64(ciphertext, iv: _iv);
    return decrypted;
  }
}