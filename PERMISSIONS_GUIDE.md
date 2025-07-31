# صلاحيات التطبيق - دليل شامل

## تم إضافة الصلاحيات المطلوبة ✅

### 📱 Android Permissions (AndroidManifest.xml)

تم إضافة الصلاحيات التالية في ملف:
`android/app/src/main/AndroidManifest.xml`

#### الصلاحيات الأساسية:
```xml
<!-- الكاميرا -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- قراءة الملفات (Android 12+) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

<!-- قراءة وكتابة الملفات (Android قديم) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />

<!-- الإنترنت (Supabase) -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

#### ميزات الأجهزة (اختيارية):
```xml
<!-- الكاميرا كميزة اختيارية -->
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

---

### 🍎 iOS Permissions (Info.plist)

تم إضافة الأوصاف التالية في ملف:
`ios/Runner/Info.plist`

```xml
<!-- الكاميرا -->
<key>NSCameraUsageDescription</key>
<string>يحتاج التطبيق إلى الوصول للكاميرا لتصوير المستندات والوثائق المطلوبة</string>

<!-- معرض الصور (قراءة) -->
<key>NSPhotoLibraryUsageDescription</key>
<string>يحتاج التطبيق إلى الوصول لمعرض الصور لاختيار المستندات والصور المطلوبة</string>

<!-- معرض الصور (كتابة) -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>يحتاج التطبيق إلى حفظ الصور المُلتقطة في معرض الصور</string>

<!-- الميكروفون (للفيديو) -->
<key>NSMicrophoneUsageDescription</key>
<string>يحتاج التطبيق إلى الوصول للميكروفون لتسجيل مقاطع الفيديو (اختياري)</string>
```

---

## 🔧 كيفية عمل طلب الصلاحيات في الكود

### تلقائياً عبر المكتبات:
- **image_picker**: يطلب صلاحية الكاميرا والمعرض تلقائياً
- **file_picker**: يطلب صلاحية الملفات تلقائياً
- **permission_handler**: إدارة متقدمة للصلاحيات

### يدوياً في الكود:
```dart
// في DocumentProvider
Future<File?> pickImageFromGallery() async {
  // طلب إذن الوصول للمعرض
  final status = await Permission.photos.request();
  if (!status.isGranted) {
    _setError('يرجى السماح بالوصول إلى معرض الصور');
    return null;
  }
  // ... باقي الكود
}

Future<File?> takePictureWithCamera() async {
  // طلب إذن الوصول للكاميرا
  final status = await Permission.camera.request();
  if (!status.isGranted) {
    _setError('يرجى السماح بالوصول إلى الكاميرا');
    return null;
  }
  // ... باقي الكود
}
```

---

## 🚀 اختبار الصلاحيات

### 1. بناء التطبيق مرة أخرى:
```bash
flutter clean
flutter pub get
flutter run
```

### 2. اختبار الوظائف:
1. **اختبار الكاميرا**:
   - اذهب لرفع المستندات
   - اختر "تصوير"
   - يجب أن يطلب إذن الكاميرا

2. **اختبار المعرض**:
   - اختر "من المعرض"
   - يجب أن يطلب إذن الوصول للصور

3. **اختبار الملفات**:
   - اختر "ملف PDF"
   - يجب أن يطلب إذن الوصول للملفات

---

## 🔍 استكشاف الأخطاء

### المشكلة: "يرجى السماح بالوصول"
**الحل**:
1. تأكد من إضافة الصلاحيات في AndroidManifest.xml
2. تأكد من إضافة الأوصاف في Info.plist
3. قم ببناء التطبيق مرة أخرى:
   ```bash
   flutter clean
   flutter run
   ```

### المشكلة: "Permission denied"
**الحل**:
1. احذف التطبيق من الجهاز
2. أعد تثبيته بعد إضافة الصلاحيات
3. أو اذهب لإعدادات التطبيق واعط الصلاحيات يدوياً

### المشكلة: الصلاحيات لا تظهر
**الحل**:
1. تحقق من صحة syntax في XML files
2. تأكد من حفظ الملفات
3. قم بـ hot restart (ليس hot reload)

---

## 📋 ملخص الصلاحيات المضافة

| المنصة | الصلاحية | الغرض | مطلوبة |
|--------|----------|--------|--------|
| Android | CAMERA | تصوير المستندات | ✅ |
| Android | READ_MEDIA_IMAGES | قراءة الصور | ✅ |
| Android | READ_EXTERNAL_STORAGE | قراءة الملفات | ✅ |
| Android | INTERNET | Supabase | ✅ |
| iOS | NSCameraUsageDescription | تصوير المستندات | ✅ |
| iOS | NSPhotoLibraryUsageDescription | اختيار الصور | ✅ |

---

## 🎯 النتيجة المتوقعة

بعد إضافة هذه الصلاحيات:
- ✅ لن تظهر رسالة "يرجى السماح بالوصول"
- ✅ ستعمل جميع وظائف رفع المستندات
- ✅ سيطلب التطبيق الصلاحيات عند الحاجة فقط
- ✅ تجربة مستخدم سلسة ومريحة

---

## 📝 ملاحظات مهمة

1. **الصلاحيات تُطلب عند الحاجة**: لا تُطلب جميع الصلاحيات عند فتح التطبيق
2. **رسائل واضحة**: تم استخدام نصوص عربية واضحة لشرح سبب الحاجة للصلاحية
3. **أمان البيانات**: جميع الصلاحيات ضرورية لوظائف المستندات فقط
4. **توافق الإصدارات**: تم مراعاة Android 12+ و iOS المختلفة

الآن يجب أن تعمل جميع وظائف رفع المستندات بدون مشاكل في الصلاحيات! 🎉
