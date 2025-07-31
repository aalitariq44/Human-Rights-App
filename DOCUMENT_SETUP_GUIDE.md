# إرشادات تشغيل ميزة رفع المستندات

## الخطوة 1: إعداد قاعدة البيانات

### تشغيل SQL Script
1. افتح Supabase Dashboard
2. اذهب إلى SQL Editor
3. انسخ والصق محتويات الملف: `database/create_documents_table.sql`
4. اضغط على RUN لتشغيل السكريبت
5. تأكد من ظهور رسائل النجاح:
   ```
   ✅ تم إنشاء جدول المستندات بنجاح
   ✅ تم تطبيق سياسات الأمان (RLS)
   ✅ تم إنشاء الفهارس والمحفزات
   ✅ تم إنشاء Views والدوال المساعدة
   ```

### تشغيل Storage Bucket Script
1. في نفس SQL Editor
2. انسخ والصق الأمر الذي زودتني به (Bucket setup)
3. اضغط على RUN
4. تأكد من إنشاء Bucket بنجاح

## الخطوة 2: تحديث التبعيات

```bash
cd "c:\Users\athraa\Desktop\Human Rights App\hoqoqi"
flutter pub get
```

## الخطوة 3: إعداد الأذونات

### Android (android/app/src/main/AndroidManifest.xml)
تأكد من وجود الأذونات التالية:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS (ios/Runner/Info.plist)
أضف الأذونات التالية:

```xml
<key>NSCameraUsageDescription</key>
<string>يحتاج التطبيق إلى الوصول للكاميرا لتصوير المستندات</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>يحتاج التطبيق إلى الوصول لمعرض الصور لاختيار المستندات</string>
```

## الخطوة 4: تشغيل التطبيق

```bash
flutter run
```

## الخطوة 5: اختبار الميزة

### اختبار رفع المستندات
1. سجل دخول إلى التطبيق
2. اذهب إلى الشاشة الرئيسية
3. اضغط على "رفع المستندات"
4. اختر نوع المستند
5. اختر طريقة الرفع (معرض/كاميرا/PDF)
6. ارفع المستند
7. تحقق من ظهوره في قائمة المستندات

### اختبار عرض المستندات  
1. من الشاشة الرئيسية
2. اضغط على "عرض المستندات"
3. تحقق من عرض الإحصائيات
4. تحقق من عرض المستندات مجمعة حسب النوع
5. جرب خيارات الإدارة (عرض، حذف)

## استكشاف الأخطاء

### خطأ في الأذونات
```
يرجى السماح بالوصول إلى الكاميرا/المعرض
```
**الحل**: تأكد من إضافة الأذونات في AndroidManifest.xml و Info.plist

### خطأ في رفع الملف
```
فشل في رفع المستند: StorageException
```
**الحل**: 
1. تحقق من تشغيل Bucket SQL script
2. تحقق من صحة Supabase configuration
3. تحقق من اتصال الإنترنت

### خطأ في قاعدة البيانات
```
relation "documents" does not exist
```
**الحل**: تأكد من تشغيل create_documents_table.sql في Supabase

### خطأ في حجم الملف
```
حجم الملف كبير جداً
```
**الحل**: 
- الصور: حد أقصى 5 MB
- PDF: حد أقصى 10 MB

### خطأ في نوع الملف
```
نوع الملف غير مدعوم
```
**الحل**: استخدم فقط JPG, PNG, PDF

## إعدادات متقدمة

### تخصيص أحجام الملفات
في `DocumentStorageService`:
```dart
// تغيير الحد الأقصى للصور (بالبايت)
const maxImageSize = 5 * 1024 * 1024; // 5 MB

// تغيير الحد الأقصى للـ PDF (بالبايت)  
const maxDocumentSize = 10 * 1024 * 1024; // 10 MB
```

### تخصيص جودة ضغط الصور
في `DocumentStorageService`:
```dart
final compressedFile = await FlutterImageCompress.compressAndGetFile(
  // تغيير الجودة (0-100)
  quality: 85,
  // تغيير الدقة
  minWidth: 800,
  minHeight: 800,
);
```

## مراقبة النظام

### فحص Storage في Supabase
1. اذهب إلى Storage في Supabase Dashboard
2. افتح bucket "user-documents"
3. تحقق من بنية المجلدات:
   ```
   user-documents/
   └── {user-id}/
       ├── profile/
       └── official-documents/
   ```

### فحص قاعدة البيانات
```sql
-- عرض إحصائيات المستندات
SELECT * FROM user_documents_stats;

-- عرض جميع المستندات
SELECT * FROM documents ORDER BY created_at DESC;

-- فحص المستندات الكبيرة
SELECT * FROM large_files;
```

## نصائح للأداء

1. **استخدم WiFi**: لرفع الملفات الكبيرة
2. **ضغط الصور**: سيتم تلقائياً للصور
3. **تحسين الشبكة**: تأكد من اتصال مستقر
4. **مساحة التخزين**: راقب استخدام Storage في Supabase

## الدعم الفني

إذا واجهت أي مشاكل:
1. تحقق من console logs في Flutter
2. راجع Storage logs في Supabase
3. تحقق من Database logs في Supabase
4. راجع ملف `DOCUMENT_UPLOAD_FEATURE.md` للتفاصيل الفنية
