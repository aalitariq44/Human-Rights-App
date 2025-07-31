import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// خدمة التشفير للبيانات الحساسة
class EncryptionService {
  static const String _keyName = 'encryption_key';
  static const _storage = FlutterSecureStorage();
  
  static EncryptionService? _instance;
  late final Encrypter _encrypter;
  late final IV _iv;
  bool _isInitialized = false;
  
  EncryptionService._();
  
  static EncryptionService get instance {
    _instance ??= EncryptionService._();
    return _instance!;
  }
  
  /// تهيئة خدمة التشفير (يُستدعى مرة واحدة في بداية التطبيق)
  static Future<void> initialize() async {
    await instance._initEncryption();
  }
  
  /// تهيئة التشفير
  Future<void> _initEncryption() async {
    if (_isInitialized) return;
    
    try {
      // الحصول على المفتاح أو إنشاء واحد جديد
      final key = await _getOrCreateKey();
      
      // إنشاء المُشفر
      _encrypter = Encrypter(AES(key));
      
      // إنشاء IV ثابت (مستخدم نفس IV لضمان استقرار فك التشفير)
      _iv = await _getOrCreateIV();
      
      _isInitialized = true;
      
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
  
  /// الحصول على IV أو إنشاء واحد جديد
  Future<IV> _getOrCreateIV() async {
    const String ivName = 'encryption_iv';
    try {
      // محاولة الحصول على IV المخزن
      String? storedIV = await _storage.read(key: ivName);
      
      if (storedIV != null) {
        // فك تشفير IV المخزن
        final ivBytes = base64Decode(storedIV);
        return IV(Uint8List.fromList(ivBytes));
      } else {
        // إنشاء IV جديد
        final iv = IV.fromSecureRandom(16);
        
        // تخزين IV
        final ivBase64 = base64Encode(iv.bytes);
        await _storage.write(key: ivName, value: ivBase64);
        
        return iv;
      }
    } catch (e) {
      throw Exception('فشل في الحصول على IV التشفير: $e');
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
      // معالجة خاصة لأخطاء فك التشفير الشائعة
      if (e.toString().contains('Invalid or corrupted pad block') ||
          e.toString().contains('pad block') ||
          e.toString().contains('BadPaddingException')) {
        throw Exception('فشل في فك تشفير البيانات: البيانات المشفرة تالفة أو تم تغيير مفتاح التشفير. يرجى إعادة إدخال البيانات.');
      } else if (e.toString().contains('Invalid argument(s)')) {
        throw Exception('فشل في فك تشفير البيانات: تنسيق البيانات المشفرة غير صحيح.');
      } else {
        throw Exception('فشل في فك تشفير البيانات: $e');
      }
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
  
  /// مسح المفتاح والـ IV المخزنين (للأمان)
  Future<void> clearStoredKey() async {
    const String ivName = 'encryption_iv';
    try {
      await _storage.delete(key: _keyName);
      await _storage.delete(key: ivName);
    } catch (e) {
      throw Exception('فشل في مسح مفتاح التشفير: $e');
    }
  }
  
  /// إعادة تعيين خدمة التشفير
  Future<void> reset() async {
    try {
      await clearStoredKey();
      _isInitialized = false;
      await _initEncryption();
    } catch (e) {
      throw Exception('فشل في إعادة تعيين خدمة التشفير: $e');
    }
  }
}
