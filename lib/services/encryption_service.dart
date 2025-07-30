import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// خدمة التشفير للبيانات الحساسة
class EncryptionService {
  static const String _keyName = 'encryption_key';
  static const _storage = FlutterSecureStorage();
  
  late final Encrypter _encrypter;
  late final IV _iv;
  
  EncryptionService() {
    _initEncryption();
  }
  
  /// تهيئة التشفير
  Future<void> _initEncryption() async {
    try {
      // الحصول على المفتاح أو إنشاء واحد جديد
      final key = await _getOrCreateKey();
      
      // إنشاء المُشفر
      _encrypter = Encrypter(AES(key));
      
      // إنشاء IV ثابت (في التطبيق الحقيقي يُفضل استخدام IV عشوائي لكل تشفير)
      _iv = IV.fromSecureRandom(16);
      
    } catch (e) {
      throw Exception('فشل في تهيئة خدمة التشفير: $e');
    }
  }
  
  /// الحصول على المفتاح أو إنشاء واحد جديد
  Future<Key> _getOrCreateKey() async {
    try {
      // محاولة الحصول على المفتاح المخزن
      String? storedKey = await _storage.read(key: _keyName);
      
      if (storedKey != null) {
        // فك تشفير المفتاح المخزن
        final keyBytes = base64Decode(storedKey);
        return Key(Uint8List.fromList(keyBytes));
      } else {
        // إنشاء مفتاح جديد
        final key = Key.fromSecureRandom(32); // 256-bit key
        
        // تخزين المفتاح مشفراً
        final keyBase64 = base64Encode(key.bytes);
        await _storage.write(key: _keyName, value: keyBase64);
        
        return key;
      }
    } catch (e) {
      throw Exception('فشل في الحصول على مفتاح التشفير: $e');
    }
  }
  
  /// تشفير النص
  Future<String> encrypt(String plainText) async {
    try {
      if (plainText.isEmpty) return plainText;
      
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('فشل في تشفير البيانات: $e');
    }
  }
  
  /// فك تشفير النص
  Future<String> decrypt(String encryptedText) async {
    try {
      if (encryptedText.isEmpty) return encryptedText;
      
      final encrypted = Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      throw Exception('فشل في فك تشفير البيانات: $e');
    }
  }
  
  /// تشفير البيانات الثنائية
  Future<Uint8List> encryptBytes(Uint8List data) async {
    try {
      final encrypted = _encrypter.encryptBytes(data, iv: _iv);
      return encrypted.bytes;
    } catch (e) {
      throw Exception('فشل في تشفير البيانات الثنائية: $e');
    }
  }
  
  /// فك تشفير البيانات الثنائية
  Future<Uint8List> decryptBytes(Uint8List encryptedData) async {
    try {
      final encrypted = Encrypted(encryptedData);
      final decryptedBytes = _encrypter.decryptBytes(encrypted, iv: _iv);
      return Uint8List.fromList(decryptedBytes);
    } catch (e) {
      throw Exception('فشل في فك تشفير البيانات الثنائية: $e');
    }
  }
  
  /// إنشاء hash للبيانات (للتحقق من التكامل)
  String createHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// التحقق من صحة hash
  bool verifyHash(String data, String hash) {
    final computedHash = createHash(data);
    return computedHash == hash;
  }
  
  /// مسح المفتاح المخزن (للأمان)
  Future<void> clearStoredKey() async {
    try {
      await _storage.delete(key: _keyName);
    } catch (e) {
      throw Exception('فشل في مسح مفتاح التشفير: $e');
    }
  }
  
  /// إعادة تعيين خدمة التشفير
  Future<void> reset() async {
    try {
      await clearStoredKey();
      await _initEncryption();
    } catch (e) {
      throw Exception('فشل في إعادة تعيين خدمة التشفير: $e');
    }
  }
}
