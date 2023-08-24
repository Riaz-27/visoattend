import 'package:encrypt/encrypt.dart';

class EncryptionService {

  String decryptWithAES(String key, String encryptedBase64) {
    key = key.substring(0, 16);
    final encryptedData = Encrypted.fromBase64(encryptedBase64);
    final cipherKey = Key.fromUtf8(key);
    final encryptService =
        Encrypter(AES(cipherKey, mode: AESMode.cbc)); //Using AES CBC encryption
    final initVector =
        IV.fromUtf8(key.substring(0, 16)); //Here the IV is generated from key.

    return encryptService.decrypt(encryptedData, iv: initVector);
  }

  String encryptWithAES(String key, String plainText) {
    key = key.substring(0, 16);
    final cipherKey = Key.fromUtf8(key);
    final encryptService = Encrypter(AES(cipherKey, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(key.substring(0, 16));

    Encrypted encryptedData = encryptService.encrypt(plainText, iv: initVector);
    return encryptedData.base64;
  }
}
