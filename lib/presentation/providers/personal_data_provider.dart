import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/personal_data_entity.dart';
import '../../domain/entities/enums.dart';
import '../../services/encryption_service.dart';

/// موفر البيانات الشخصية
class PersonalDataProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final EncryptionService _encryptionService = EncryptionService.instance;
  
  PersonalDataEntity? _personalData;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  PersonalDataEntity? get personalData => _personalData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _personalData != null;
  
  /// إرسال البيانات الشخصية
  Future<bool> submitPersonalData(Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _setError('المستخدم غير مسجل للدخول. يرجى تسجيل الدخول أولاً.');
        return false;
      }
      
      // تشفير الرقم الوطني
      final encryptedNationalId = await _encryptionService.encrypt(data['nationalId']);
      
      // إعداد البيانات للإرسال وفقاً لهيكل قاعدة البيانات
      final personalDataMap = {
        'user_id': user.id,
        'full_name_iraq': data['fullNameIraq']?.toString().trim(),
        'mother_name': data['motherName']?.toString().trim(),
        'current_province': data['currentProvince']?.toString().trim(),
        'birth_date': data['birthDate']?.toString(),
        'birth_place': data['birthPlace']?.toString().trim(),
        'phone_number': data['phoneNumber']?.toString().trim(),
        'national_id_encrypted': encryptedNationalId,
        'national_id_issue_year': data['nationalIdIssueYear'] is int 
            ? data['nationalIdIssueYear'] 
            : int.tryParse(data['nationalIdIssueYear']?.toString() ?? ''),
        'national_id_issuer': data['nationalIdIssuer']?.toString().trim(),
        'full_name_kuwait': data['fullNameKuwait']?.toString().trim(),
        'kuwait_address': data['kuwaitAddress']?.toString().trim(),
        'kuwait_education_level': data['kuwaitEducationLevel']?.toString().trim(),
        'family_members_count': data['familyMembersCount'] is int 
            ? data['familyMembersCount'] 
            : int.tryParse(data['familyMembersCount']?.toString() ?? '0') ?? 0,
        'adults_over_18_count': data['adultsOver18Count'] is int 
            ? data['adultsOver18Count'] 
            : int.tryParse(data['adultsOver18Count']?.toString() ?? '0') ?? 0,
        'exit_method': data['exitMethod'] != null 
            ? _convertExitMethodToDatabase(data['exitMethod'].toString()) 
            : null,
        'compensation_type': data['compensationTypes'] is List 
            ? (data['compensationTypes'] as List)
                .map((e) => _convertCompensationTypeToDatabase(e.toString()))
                .toList()
            : [],
        'kuwait_job_type': data['kuwaitJobType'] != null 
            ? _convertJobTypeToDatabase(data['kuwaitJobType'].toString()) 
            : null,
        'kuwait_official_status': data['kuwaitOfficialStatus'] != null 
            ? _convertOfficialStatusToDatabase(data['kuwaitOfficialStatus'].toString()) 
            : null,
        'rights_request_type': data['rightsRequestTypes'] is List 
            ? (data['rightsRequestTypes'] as List)
                .map((e) => _convertRightsTypeToDatabase(e.toString()))
                .toList()
            : [],
      };
      
      // التحقق من البيانات المطلوبة
      final requiredFields = [
        'full_name_iraq', 'mother_name', 'current_province', 
        'birth_date', 'birth_place', 'phone_number', 
        'national_id_encrypted', 'national_id_issue_year', 'national_id_issuer'
      ];
      
      for (final field in requiredFields) {
        if (personalDataMap[field] == null || 
            (personalDataMap[field] is String && (personalDataMap[field] as String).isEmpty)) {
          _setError('يرجى ملء جميع البيانات المطلوبة. الحقل المفقود: ${_getFieldArabicName(field)}');
          _setLoading(false);
          return false;
        }
      }
      
      // التحقق من صحة البيانات قبل الإرسال
      final validationError = _validateData(personalDataMap);
      if (validationError != null) {
        _setError(validationError);
        _setLoading(false);
        return false;
      }
      
      // إرسال البيانات إلى Supabase
      final response = await _supabase
          .from('user_personal_data')
          .insert(personalDataMap)
          .select();
      
      if (response.isEmpty) {
        _setError('فشل في حفظ البيانات. يرجى المحاولة مرة أخرى.');
        _setLoading(false);
        return false;
      }
      
      // تحويل البيانات المُستلمة إلى Entity
      _personalData = await _mapToEntity(response.first);
      
      // تسجيل النشاط
      await _logActivity('personal_data_submitted', {
        'personal_data_id': response.first['id'],
      });
      
      _setLoading(false);
      return true;
      
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException: ${e.code} - ${e.message}');
      final errorMessage = _handlePostgrestError(e);
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('General error in submitPersonalData: $e');
      String errorMessage = _handleGeneralError(e);
      
      // إضافة معلومات إضافية لأخطاء specific
      if (e.toString().contains('Bad state: No element')) {
        errorMessage = 'حدث خطأ في معالجة البيانات. يرجى المحاولة مرة أخرى أو التواصل مع الدعم الفني.';
      } else if (e.toString().contains('firstWhere')) {
        errorMessage = 'حدث خطأ في تحويل البيانات. يرجى التأكد من صحة البيانات المدخلة.';
      }
      
      _setError(errorMessage);
      _setLoading(false);
      return false;
    }
  }
  
  /// جلب البيانات الشخصية للمستخدم الحالي
  Future<void> fetchPersonalData() async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _setError('المستخدم غير مسجل الدخول');
        _setLoading(false);
        notifyListeners();
        return;
      }
      
      final response = await _supabase
          .from('user_personal_data')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1);
      
      if (response.isNotEmpty) {
        _personalData = await _mapToEntity(response.first);
      }
      
      _setLoading(false);
      notifyListeners();
      
    } on PostgrestException catch (e) {
      final errorMessage = _handlePostgrestError(e);
      _setError(errorMessage);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      // معالجة خاصة لأخطاء فك التشفير
      if (e.toString().contains('فشل في فك تشفير البيانات') || 
          e.toString().contains('Invalid or corrupted pad block') ||
          e.toString().contains('تالفة أو تم تغيير مفتاح التشفير')) {
        _setError('حدث خطأ في فك تشفير البيانات المحفوظة. يرجى استخدام خيار "حاول مرة أخرى" أو الاتصال بالدعم الفني.');
      } else {
        final errorMessage = _handleGeneralError(e);
        _setError(errorMessage);
      }
      _setLoading(false);
      notifyListeners();
    }
  }
  
  /// إعادة محاولة جلب البيانات مع إعادة تعيين التشفير
  Future<bool> retryWithEncryptionReset() async {
    try {
      _setLoading(true);
      _clearError();
      
      // إعادة تعيين خدمة التشفير
      await _encryptionService.reset();
      
      // محاولة جلب البيانات مرة أخرى
      await fetchPersonalData();
      
      return true;
    } catch (e) {
      _setError('فشل في إعادة تعيين التشفير: $e');
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }
  
  /// تحديث حالة البيانات
  Future<bool> updateDataStatus(String id, DataStatus status) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _supabase
          .from('user_personal_data')
          .update({
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
      
      // تحديث البيانات المحلية
      if (_personalData?.id == id) {
        _personalData = _personalData!.copyWith(
          updatedAt: DateTime.now(),
        );
      }
      
      // تسجيل النشاط
      await _logActivity('data_status_updated', {
        'personal_data_id': id,
      });
      
      _setLoading(false);
      return true;
      
    } on PostgrestException catch (e) {
      final errorMessage = _handlePostgrestError(e);
      _setError(errorMessage);
      _setLoading(false);
      return false;
    } catch (e) {
      final errorMessage = _handleGeneralError(e);
      _setError(errorMessage);
      _setLoading(false);
      return false;
    }
  }
  
  /// تحويل البيانات من الخريطة إلى Entity
  Future<PersonalDataEntity> _mapToEntity(Map<String, dynamic> data) async {
    try {
      // فك تشفير الرقم الوطني
      final decryptedNationalId = await _encryptionService.decrypt(data['national_id_encrypted']);
      
      return PersonalDataEntity(
        id: data['id'],
        userId: data['user_id'],
        fullNameIraq: data['full_name_iraq'],
        motherName: data['mother_name'],
        currentProvince: data['current_province'],
        birthDate: DateTime.parse(data['birth_date']),
        birthPlace: data['birth_place'],
        phoneNumber: data['phone_number'],
        nationalId: decryptedNationalId,
        nationalIdIssueYear: data['national_id_issue_year'],
        nationalIdIssuer: data['national_id_issuer'],
        fullNameKuwait: data['full_name_kuwait'],
        kuwaitAddress: data['kuwait_address'],
        kuwaitEducationLevel: data['kuwait_education_level'],
        familyMembersCount: data['family_members_count'],
        adultsOver18Count: data['adults_over_18_count'],
        exitMethod: data['exit_method'] != null 
            ? _findExitMethodByName(data['exit_method'])
            : null,
        compensationTypes: data['compensation_type'] != null
            ? (data['compensation_type'] as List)
                .map((e) => _findCompensationTypeByName(e.toString()))
                .where((type) => type != null)
                .cast<CompensationType>()
                .toList()
            : [],
        kuwaitJobType: data['kuwait_job_type'] != null
            ? _findKuwaitJobTypeByName(data['kuwait_job_type'])
            : null,
        kuwaitOfficialStatus: data['kuwait_official_status'] != null
            ? _findKuwaitOfficialStatusByName(data['kuwait_official_status'])
            : null,
        rightsRequestTypes: data['rights_request_type'] != null
            ? (data['rights_request_type'] as List)
                .map((e) => _findRightsRequestTypeByName(e.toString()))
                .where((type) => type != null)
                .cast<RightsRequestType>()
                .toList()
            : [],
        createdAt: DateTime.parse(data['created_at']),
        updatedAt: data['updated_at'] != null 
            ? DateTime.parse(data['updated_at']) 
            : null,
      );
    } catch (e) {
      // إذا كانت المشكلة في فك التشفير، قدم حلاً واضحاً
      if (e.toString().contains('فشل في فك تشفير البيانات') || 
          e.toString().contains('Invalid or corrupted pad block') ||
          e.toString().contains('تالفة أو تم تغيير مفتاح التشفير')) {
        throw Exception('حدث خطأ في فك تشفير البيانات المحفوظة. قد يكون السبب تغيير في نظام التشفير.\n\n'
                       'الحلول المقترحة:\n'
                       '• إعادة تشغيل التطبيق\n'
                       '• إعادة إدخال البيانات الشخصية\n'
                       '• الاتصال بالدعم الفني إذا استمرت المشكلة');
      }
      throw Exception('خطأ في معالجة البيانات: $e');
    }
  }

  /// معالجة أخطاء PostgreSQL
  String _handlePostgrestError(PostgrestException e) {
    switch (e.code) {
      case '23505': // Unique violation
        return 'لقد تم إرسال البيانات من قبل. لا يمكن إرسال البيانات أكثر من مرة واحدة.';
      case '23503': // Foreign key violation
        return 'خطأ في ربط البيانات. يرجى المحاولة مرة أخرى.';
      case '23502': // Not null violation
        return _handleNotNullViolation(e.message);
      case '23514': // Check constraint violation
        return _handleCheckConstraintViolation(e.message);
      case '42601': // Syntax error
        return 'خطأ في معالجة البيانات. يرجى المحاولة مرة أخرى.';
      case '404':
        return 'لم يتم العثور على الخدمة المطلوبة. يرجى التأكد من الاتصال بالإنترنت والمحاولة مرة أخرى.';
      default:
        if (e.message.toLowerCase().contains('not found')) {
          return 'خدمة قاعدة البيانات غير متاحة حالياً. يرجى المحاولة مرة أخرى لاحقاً.';
        } else if (e.message.toLowerCase().contains('duplicate')) {
          return 'لقد تم إرسال هذه البيانات من قبل.';
        } else if (e.message.toLowerCase().contains('permission')) {
          return 'ليس لديك صلاحية لتنفيذ هذا الإجراء.';
        } else if (e.message.toLowerCase().contains('timeout')) {
          return 'انتهت مهلة الاتصال. يرجى التأكد من الاتصال بالإنترنت والمحاولة مرة أخرى.';
        }
        return 'حدث خطأ أثناء إرسال البيانات: ${e.message}';
    }
  }
  
  /// معالجة خطأ القيمة المطلوبة
  String _handleNotNullViolation(String message) {
    if (message.contains('full_name_iraq')) {
      return 'يرجى إدخال الاسم الكامل في العراق.';
    } else if (message.contains('mother_name')) {
      return 'يرجى إدخال اسم الأم.';
    } else if (message.contains('current_province')) {
      return 'يرجى اختيار المحافظة الحالية.';
    } else if (message.contains('birth_date')) {
      return 'يرجى إدخال تاريخ الميلاد.';
    } else if (message.contains('birth_place')) {
      return 'يرجى إدخال مكان الولادة.';
    } else if (message.contains('phone_number')) {
      return 'يرجى إدخال رقم الهاتف.';
    } else if (message.contains('national_id_encrypted')) {
      return 'يرجى إدخال رقم الهوية الوطنية.';
    } else if (message.contains('national_id_issue_year')) {
      return 'يرجى إدخال سنة إصدار الهوية الوطنية.';
    } else if (message.contains('national_id_issuer')) {
      return 'يرجى إدخال جهة إصدار الهوية الوطنية.';
    }
    return 'يرجى ملء جميع البيانات المطلوبة.';
  }
  
  /// معالجة خطأ قيود البيانات
  String _handleCheckConstraintViolation(String message) {
    if (message.contains('exit_method')) {
      return 'يرجى اختيار طريقة صحيحة للخروج من الكويت من الخيارات المتاحة:\n' +
             '• المغادرة الطوعية\n' +
             '• الترحيل القسري\n' +
             '• التهريب البري\n' +
             '• قبل انسحاب الجيش';
    } else if (message.contains('compensation_type')) {
      return 'يرجى اختيار نوع تعويض صحيح من الخيارات المتاحة:\n' +
             '• خدمات الوظائف الحكومية\n' +
             '• الأثاث والممتلكات الشخصية\n' +
             '• التعويض المعنوي\n' +
             '• تعويض السجن';
    } else if (message.contains('kuwait_job_type')) {
      return 'يرجى اختيار نوع عمل صحيح في الكويت من الخيارات المتاحة:\n' +
             '• موظف مدني\n' +
             '• موظف عسكري\n' +
             '• طالب\n' +
             '• عمل حر';
    } else if (message.contains('kuwait_official_status')) {
      return 'يرجى اختيار الوضع الرسمي الصحيح في الكويت:\n' +
             '• مقيم\n' +
             '• بدون';
    } else if (message.contains('rights_request_type')) {
      return 'يرجى اختيار نوع طلب حقوق صحيح من الخيارات المتاحة:\n' +
             '• راتب التقاعد\n' +
             '• أرض سكنية';
    } else if (message.contains('family_members_count') || message.contains('adults_over_18_count')) {
      return 'يرجى إدخال عدد صحيح (رقم موجب) لعدد أفراد الأسرة.';
    } else if (message.contains('national_id_issue_year')) {
      return 'يرجى إدخال سنة إصدار صحيحة للهوية الوطنية (مثال: 2020).';
    }
    return 'بعض البيانات المدخلة غير صحيحة. يرجى مراجعة البيانات والتأكد من صحتها.';
  }
  
  /// التحقق من صحة البيانات قبل الإرسال
  String? _validateData(Map<String, dynamic> data) {
    // التحقق من طريقة الخروج من الكويت
    if (data['exit_method'] != null) {
      final exitMethod = data['exit_method'].toString();
      // تحويل من enum name إلى database value إذا لزم الأمر
      final databaseValue = _convertExitMethodToDatabase(exitMethod);
      final validExitMethods = ['voluntary_departure', 'forced_deportation', 'land_smuggling', 'before_army_withdrawal'];
      
      if (!validExitMethods.contains(databaseValue)) {
        return 'طريقة الخروج من الكويت غير صحيحة. يرجى اختيار من الخيارات المتاحة:\n' +
               '• المغادرة الطوعية\n• الترحيل القسري\n• التهريب البري\n• قبل انسحاب الجيش';
      }
      // تحديث القيمة في البيانات
      data['exit_method'] = databaseValue;
    }
    
    // التحقق من نوع العمل في الكويت
    if (data['kuwait_job_type'] != null) {
      final jobType = data['kuwait_job_type'].toString();
      final databaseValue = _convertJobTypeToDatabase(jobType);
      final validJobTypes = ['civil_employee', 'military_employee', 'student', 'freelance'];
      
      if (!validJobTypes.contains(databaseValue)) {
        return 'نوع العمل في الكويت غير صحيح. يرجى اختيار من الخيارات المتاحة:\n' +
               '• موظف مدني\n• موظف عسكري\n• طالب\n• عمل حر';
      }
      data['kuwait_job_type'] = databaseValue;
    }
    
    // التحقق من الوضع الرسمي في الكويت
    if (data['kuwait_official_status'] != null) {
      final status = data['kuwait_official_status'].toString();
      final databaseValue = _convertOfficialStatusToDatabase(status);
      final validStatuses = ['resident', 'bidoon'];
      
      if (!validStatuses.contains(databaseValue)) {
        return 'الوضع الرسمي في الكويت غير صحيح. يرجى اختيار من الخيارات المتاحة:\n' +
               '• مقيم\n• بدون';
      }
      data['kuwait_official_status'] = databaseValue;
    }
    
    // التحقق من أنواع التعويضات
    if (data['compensation_type'] != null && data['compensation_type'] is List) {
      final compensationList = data['compensation_type'] as List;
      final validCompensationTypes = ['government_job_services', 'personal_furniture_property', 'moral_compensation', 'prison_compensation'];
      final convertedList = <String>[];
      
      for (final compensation in compensationList) {
        final databaseValue = _convertCompensationTypeToDatabase(compensation.toString());
        if (!validCompensationTypes.contains(databaseValue)) {
          return 'نوع التعويض "$compensation" غير صحيح. يرجى اختيار من الخيارات المتاحة:\n' +
                 '• خدمات الوظائف الحكومية\n• الأثاث والممتلكات الشخصية\n• التعويض المعنوي\n• تعويض السجن';
        }
        convertedList.add(databaseValue);
      }
      data['compensation_type'] = convertedList;
    }
    
    // التحقق من أنواع طلبات الحقوق
    if (data['rights_request_type'] != null && data['rights_request_type'] is List) {
      final rightsList = data['rights_request_type'] as List;
      final validRightsTypes = ['pension_salary', 'residential_land'];
      final convertedList = <String>[];
      
      for (final rights in rightsList) {
        final databaseValue = _convertRightsTypeToDatabase(rights.toString());
        if (!validRightsTypes.contains(databaseValue)) {
          return 'نوع طلب الحقوق "$rights" غير صحيح. يرجى اختيار من الخيارات المتاحة:\n' +
                 '• راتب التقاعد\n• أرض سكنية';
        }
        convertedList.add(databaseValue);
      }
      data['rights_request_type'] = convertedList;
    }
    
    // التحقق من سنة إصدار الهوية
    if (data['national_id_issue_year'] != null) {
      final currentYear = DateTime.now().year;
      final issueYear = data['national_id_issue_year'];
      if (issueYear is int) {
        if (issueYear < 1950 || issueYear > currentYear) {
          return 'سنة إصدار الهوية الوطنية غير صحيحة. يرجى إدخال سنة بين 1950 و $currentYear.';
        }
      }
    }
    
    // التحقق من عدد أفراد الأسرة
    if (data['family_members_count'] != null) {
      final count = data['family_members_count'];
      if (count is int && count < 0) {
        return 'عدد أفراد الأسرة يجب أن يكون رقماً موجباً أو صفر.';
      }
    }
    
    // التحقق من عدد البالغين فوق 18
    if (data['adults_over_18_count'] != null) {
      final count = data['adults_over_18_count'];
      if (count is int && count < 0) {
        return 'عدد البالغين فوق 18 سنة يجب أن يكون رقماً موجباً أو صفر.';
      }
      
      // التحقق من أن عدد البالغين لا يتجاوز عدد أفراد الأسرة
      final familyCount = data['family_members_count'];
      if (count is int && familyCount is int && count > familyCount) {
        return 'عدد البالغين فوق 18 سنة لا يمكن أن يتجاوز عدد أفراد الأسرة الإجمالي.';
      }
    }
    
    // التحقق من تاريخ الميلاد
    if (data['birth_date'] != null) {
      try {
        final birthDate = DateTime.parse(data['birth_date']);
        final now = DateTime.now();
        final age = now.year - birthDate.year;
        
        if (birthDate.isAfter(now)) {
          return 'تاريخ الميلاد لا يمكن أن يكون في المستقبل.';
        }
        
        if (age > 150) {
          return 'تاريخ الميلاد غير منطقي. يرجى التحقق من التاريخ المدخل.';
        }
        
        if (age < 5) {
          return 'العمر صغير جداً. يرجى التحقق من تاريخ الميلاد.';
        }
      } catch (e) {
        return 'تنسيق تاريخ الميلاد غير صحيح. يرجى إدخال تاريخ صحيح.';
      }
    }
    
    // التحقق من رقم الهاتف
    if (data['phone_number'] != null) {
      final phone = data['phone_number'].toString().trim();
      if (phone.isNotEmpty) {
        // إزالة المسافات والرموز
        final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
        if (cleanPhone.length < 10 || cleanPhone.length > 15) {
          return 'رقم الهاتف غير صحيح. يرجى إدخال رقم هاتف صحيح (10-15 رقم).';
        }
      }
    }
    
    return null; // لا توجد أخطاء
  }
  
  /// تحويل طريقة الخروج من enum إلى قيمة قاعدة البيانات
  String _convertExitMethodToDatabase(String value) {
    switch (value.toLowerCase()) {
      case 'voluntarydeparture':
      case 'voluntary_departure':
        return 'voluntary_departure';
      case 'forceddeportation':
      case 'forced_deportation':
        return 'forced_deportation';
      case 'landsmuggling':
      case 'land_smuggling':
        return 'land_smuggling';
      case 'beforearmywithdrawal':
      case 'before_army_withdrawal':
        return 'before_army_withdrawal';
      default:
        return value; // إرجاع القيمة كما هي إذا لم تطابق
    }
  }
  
  /// تحويل نوع العمل من enum إلى قيمة قاعدة البيانات
  String _convertJobTypeToDatabase(String value) {
    switch (value.toLowerCase()) {
      case 'civilemployee':
      case 'civil_employee':
        return 'civil_employee';
      case 'militaryemployee':
      case 'military_employee':
        return 'military_employee';
      case 'student':
        return 'student';
      case 'freelance':
        return 'freelance';
      default:
        return value;
    }
  }
  
  /// تحويل الوضع الرسمي من enum إلى قيمة قاعدة البيانات
  String _convertOfficialStatusToDatabase(String value) {
    switch (value.toLowerCase()) {
      case 'resident':
        return 'resident';
      case 'bidoon':
        return 'bidoon';
      default:
        return value;
    }
  }
  
  /// تحويل نوع التعويض من enum إلى قيمة قاعدة البيانات
  String _convertCompensationTypeToDatabase(String value) {
    switch (value.toLowerCase()) {
      case 'governmentjobservices':
      case 'government_job_services':
        return 'government_job_services';
      case 'personalfurnitureproperty':
      case 'personal_furniture_property':
        return 'personal_furniture_property';
      case 'moralcompensation':
      case 'moral_compensation':
        return 'moral_compensation';
      case 'prisoncompensation':
      case 'prison_compensation':
        return 'prison_compensation';
      default:
        return value;
    }
  }
  
  /// تحويل نوع طلب الحقوق من enum إلى قيمة قاعدة البيانات
  String _convertRightsTypeToDatabase(String value) {
    switch (value.toLowerCase()) {
      case 'pensionsalary':
      case 'pension_salary':
        return 'pension_salary';
      case 'residentialland':
      case 'residential_land':
        return 'residential_land';
      default:
        return value;
    }
  }
  
  /// معالجة الأخطاء العامة
  String _handleGeneralError(dynamic e) {
    if (e.toString().contains('SocketException')) {
      return 'لا يوجد اتصال بالإنترنت. يرجى التأكد من الاتصال والمحاولة مرة أخرى.';
    } else if (e.toString().contains('TimeoutException')) {
      return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';
    } else if (e.toString().contains('FormatException')) {
      return 'تنسيق البيانات غير صحيح. يرجى مراجعة البيانات المدخلة.';
    } else if (e.toString().contains('AuthException')) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
    }
    return 'حدث خطأ غير متوقع: ${e.toString()}';
  }
  
  /// الحصول على الاسم العربي للحقل
  String _getFieldArabicName(String fieldName) {
    switch (fieldName) {
      case 'full_name_iraq':
        return 'الاسم الكامل في العراق';
      case 'mother_name':
        return 'اسم الأم';
      case 'current_province':
        return 'المحافظة الحالية';
      case 'birth_date':
        return 'تاريخ الميلاد';
      case 'birth_place':
        return 'مكان الولادة';
      case 'phone_number':
        return 'رقم الهاتف';
      case 'national_id_encrypted':
        return 'رقم الهوية الوطنية';
      case 'national_id_issue_year':
        return 'سنة إصدار الهوية';
      case 'national_id_issuer':
        return 'جهة إصدار الهوية';
      default:
        return fieldName;
    }
  }
  
  /// تسجيل النشاط
  Future<void> _logActivity(String action, Map<String, dynamic> details) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      await _supabase.from('activity_logs').insert({
        'user_id': user.id,
        'action': action,
        'details': details,
        'ip_address': 'unknown', // يمكن تحسينه لاحقاً
        'user_agent': 'mobile_app',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // تجاهل أخطاء تسجيل النشاط
      debugPrint('Error logging activity: $e');
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  
  void _clearError() {
    _errorMessage = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  
  void clearError() {
    _clearError();
  }
  
  void clearData() {
    _personalData = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// البحث الآمن عن ExitMethod بالاسم
  ExitMethod? _findExitMethodByName(String name) {
    try {
      // أولاً ابحث بالـ enum name المباشر
      return ExitMethod.values.firstWhere((e) => e.name == name);
    } catch (e) {
      try {
        // ثم ابحث بالتحويل من قاعدة البيانات
        return ExitMethod.values.firstWhere((e) => _convertExitMethodToDatabase(e.name) == name);
      } catch (e2) {
        debugPrint('ExitMethod not found: $name');
        return null;
      }
    }
  }

  /// البحث الآمن عن CompensationType بالاسم
  CompensationType? _findCompensationTypeByName(String name) {
    try {
      // أولاً ابحث بالـ enum name المباشر
      return CompensationType.values.firstWhere((e) => e.name == name);
    } catch (e) {
      try {
        // ثم ابحث بالتحويل من قاعدة البيانات
        return CompensationType.values.firstWhere((e) => _convertCompensationTypeToDatabase(e.name) == name);
      } catch (e2) {
        debugPrint('CompensationType not found: $name');
        return null;
      }
    }
  }

  /// البحث الآمن عن KuwaitJobType بالاسم
  KuwaitJobType? _findKuwaitJobTypeByName(String name) {
    try {
      // أولاً ابحث بالـ enum name المباشر
      return KuwaitJobType.values.firstWhere((e) => e.name == name);
    } catch (e) {
      try {
        // ثم ابحث بالتحويل من قاعدة البيانات
        return KuwaitJobType.values.firstWhere((e) => _convertJobTypeToDatabase(e.name) == name);
      } catch (e2) {
        debugPrint('KuwaitJobType not found: $name');
        return null;
      }
    }
  }

  /// البحث الآمن عن KuwaitOfficialStatus بالاسم
  KuwaitOfficialStatus? _findKuwaitOfficialStatusByName(String name) {
    try {
      // أولاً ابحث بالـ enum name المباشر
      return KuwaitOfficialStatus.values.firstWhere((e) => e.name == name);
    } catch (e) {
      try {
        // ثم ابحث بالتحويل من قاعدة البيانات
        return KuwaitOfficialStatus.values.firstWhere((e) => _convertOfficialStatusToDatabase(e.name) == name);
      } catch (e2) {
        debugPrint('KuwaitOfficialStatus not found: $name');
        return null;
      }
    }
  }

  /// البحث الآمن عن RightsRequestType بالاسم
  RightsRequestType? _findRightsRequestTypeByName(String name) {
    try {
      // أولاً ابحث بالـ enum name المباشر
      return RightsRequestType.values.firstWhere((e) => e.name == name);
    } catch (e) {
      try {
        // ثم ابحث بالتحويل من قاعدة البيانات
        return RightsRequestType.values.firstWhere((e) => _convertRightsTypeToDatabase(e.name) == name);
      } catch (e2) {
        debugPrint('RightsRequestType not found: $name');
        return null;
      }
    }
  }
}
