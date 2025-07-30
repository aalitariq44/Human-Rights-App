import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/personal_data_entity.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/forms/dropdown_field.dart';
import '../../widgets/forms/checkbox_group.dart';
import '../../widgets/forms/date_picker_field.dart';
import '../../providers/personal_data_provider.dart';
import '../../navigation/route_names.dart';

/// شاشة نموذج البيانات الشخصية
class PersonalDataFormScreen extends StatefulWidget {
  const PersonalDataFormScreen({Key? key}) : super(key: key);

  @override
  State<PersonalDataFormScreen> createState() => _PersonalDataFormScreenState();
}

class _PersonalDataFormScreenState extends State<PersonalDataFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _hasExistingData = false;
  Future<void>? _dataCheckFuture;
  
  // Controllers للخطوة الأولى - البيانات الأساسية
  final _fullNameIraqController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _currentProvinceController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  DateTime? _selectedBirthDate;
  
  // Controllers للخطوة الثانية - بيانات البطاقة الوطنية
  final _nationalIdController = TextEditingController();
  final _nationalIdIssuerController = TextEditingController();
  int? _nationalIdIssueYear;
  
  // Controllers للخطوة الثالثة - بيانات الكويت
  final _fullNameKuwaitController = TextEditingController();
  final _kuwaitAddressController = TextEditingController();
  final _kuwaitEducationLevelController = TextEditingController();
  final _familyMembersCountController = TextEditingController();
  final _adultsOver18CountController = TextEditingController();
  
  // متغيرات للخطوة الرابعة - الخيارات
  ExitMethod? _selectedExitMethod;
  List<CompensationType> _selectedCompensationTypes = [];
  KuwaitJobType? _selectedKuwaitJobType;
  KuwaitOfficialStatus? _selectedKuwaitOfficialStatus;
  List<RightsRequestType> _selectedRightsRequestTypes = [];
  
  // متغيرات للخطوة الخامسة - المستمسكات
  bool _hasIraqiAffairsDept = false;
  bool _hasKuwaitImmigration = false;
  bool _hasValidResidence = false;
  bool _hasRedCrossInternational = false;

  @override
  void initState() {
    super.initState();
    // إنشاء Future لفحص البيانات
    _dataCheckFuture = _checkExistingData();
  }

  /// فحص وجود بيانات مسبقة
  Future<void> _checkExistingData() async {
    if (!mounted) return; // التأكد من أن الويدجت لا يزال موجوداً
    
    final personalDataProvider = Provider.of<PersonalDataProvider>(context, listen: false);
    
    try {
      await personalDataProvider.fetchPersonalData();
      
      if (mounted && personalDataProvider.hasData) {
        setState(() {
          _hasExistingData = true;
        });
        _populateFields(personalDataProvider.personalData!);
      }
    } catch (e) {
      // في حالة وجود خطأ في جلب البيانات، نظهر النموذج العادي
      debugPrint('Error fetching existing data: $e');
    }
  }

  /// ملء الحقول بالبيانات الموجودة
  void _populateFields(PersonalDataEntity data) {
    _fullNameIraqController.text = data.fullNameIraq;
    _motherNameController.text = data.motherName;
    _currentProvinceController.text = data.currentProvince;
    _birthPlaceController.text = data.birthPlace;
    _phoneNumberController.text = data.phoneNumber;
    _selectedBirthDate = data.birthDate;
    
    _nationalIdController.text = data.nationalId;
    _nationalIdIssueYear = data.nationalIdIssueYear;
    _nationalIdIssuerController.text = data.nationalIdIssuer;
    
    _fullNameKuwaitController.text = data.fullNameKuwait;
    _kuwaitAddressController.text = data.kuwaitAddress;
    _kuwaitEducationLevelController.text = data.kuwaitEducationLevel;
    _familyMembersCountController.text = data.familyMembersCount.toString();
    _adultsOver18CountController.text = data.adultsOver18Count.toString();
    
    _selectedExitMethod = data.exitMethod;
    _selectedCompensationTypes = List.from(data.compensationTypes);
    _selectedKuwaitJobType = data.kuwaitJobType;
    _selectedKuwaitOfficialStatus = data.kuwaitOfficialStatus;
    _selectedRightsRequestTypes = List.from(data.rightsRequestTypes);
    
    // Note: لا توجد في entity بيانات المستمسكات، لذا سنبقيها false
  }

  @override
  void dispose() {
    // تنظيف Controllers
    _fullNameIraqController.dispose();
    _motherNameController.dispose();
    _currentProvinceController.dispose();
    _birthPlaceController.dispose();
    _phoneNumberController.dispose();
    _nationalIdController.dispose();
    _nationalIdIssuerController.dispose();
    _fullNameKuwaitController.dispose();
    _kuwaitAddressController.dispose();
    _kuwaitEducationLevelController.dispose();
    _familyMembersCountController.dispose();
    _adultsOver18CountController.dispose();
    super.dispose();
  }

  /// التحقق من صحة الخطوة الحالية
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _validateBasicData();
      case 1:
        return _validateNationalIdData();
      case 2:
        return _validateKuwaitData();
      case 3:
        return _validateOptionsData();
      case 4:
        return _validateDocumentsData();
      default:
        return true;
    }
  }

  bool _validateBasicData() {
    return _fullNameIraqController.text.isNotEmpty &&
           _motherNameController.text.isNotEmpty &&
           _currentProvinceController.text.isNotEmpty &&
           _birthPlaceController.text.isNotEmpty &&
           _phoneNumberController.text.isNotEmpty &&
           _selectedBirthDate != null;
  }

  bool _validateNationalIdData() {
    return _nationalIdController.text.isNotEmpty &&
           _nationalIdIssuerController.text.isNotEmpty &&
           _nationalIdIssueYear != null;
  }

  bool _validateKuwaitData() {
    return _fullNameKuwaitController.text.isNotEmpty &&
           _kuwaitAddressController.text.isNotEmpty &&
           _kuwaitEducationLevelController.text.isNotEmpty &&
           _familyMembersCountController.text.isNotEmpty &&
           _adultsOver18CountController.text.isNotEmpty;
  }

  bool _validateOptionsData() {
    return _selectedExitMethod != null &&
           _selectedCompensationTypes.isNotEmpty &&
           _selectedKuwaitJobType != null &&
           _selectedKuwaitOfficialStatus != null &&
           _selectedRightsRequestTypes.isNotEmpty;
  }

  bool _validateDocumentsData() {
    // التحقق من وجود المستمسكات المطلوبة على الأقل
    return _hasIraqiAffairsDept || 
           _hasKuwaitImmigration || 
           _hasValidResidence || 
           _hasRedCrossInternational;
  }

  /// الانتقال للخطوة التالية
  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 4) {
        setState(() {
          _currentStep++;
        });
      } else {
        _submitData();
      }
    } else {
      _showValidationError();
    }
  }

  /// العودة للخطوة السابقة
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  /// إرسال البيانات
  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    final personalDataProvider = Provider.of<PersonalDataProvider>(context, listen: false);
    
    // إنشاء كائن البيانات الشخصية
    final personalData = {
      'fullNameIraq': _fullNameIraqController.text.trim(),
      'motherName': _motherNameController.text.trim(),
      'currentProvince': _currentProvinceController.text.trim(),
      'birthDate': _selectedBirthDate!.toIso8601String(),
      'birthPlace': _birthPlaceController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'nationalId': _nationalIdController.text.trim(),
      'nationalIdIssueYear': _nationalIdIssueYear!,
      'nationalIdIssuer': _nationalIdIssuerController.text.trim(),
      'fullNameKuwait': _fullNameKuwaitController.text.trim(),
      'kuwaitAddress': _kuwaitAddressController.text.trim(),
      'kuwaitEducationLevel': _kuwaitEducationLevelController.text.trim(),
      'familyMembersCount': int.parse(_familyMembersCountController.text),
      'adultsOver18Count': int.parse(_adultsOver18CountController.text),
      'exitMethod': _selectedExitMethod!.name,
      'compensationTypes': _selectedCompensationTypes.map((e) => e.name).toList(),
      'kuwaitJobType': _selectedKuwaitJobType!.name,
      'kuwaitOfficialStatus': _selectedKuwaitOfficialStatus!.name,
      'rightsRequestTypes': _selectedRightsRequestTypes.map((e) => e.name).toList(),
      'hasIraqiAffairsDept': _hasIraqiAffairsDept,
      'hasKuwaitImmigration': _hasKuwaitImmigration,
      'hasValidResidence': _hasValidResidence,
      'hasRedCrossInternational': _hasRedCrossInternational,
    };

    final success = await personalDataProvider.submitPersonalData(personalData);

    if (success && mounted) {
      context.go(RouteNames.personalDataSuccess);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(personalDataProvider.errorMessage ?? 'فشل في إرسال البيانات'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('يرجى إكمال جميع الحقول المطلوبة'),
        backgroundColor: AppColors.warningColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(_hasExistingData ? 'البيانات الشخصية المُرسلة' : 'إدخال البيانات الشخصية'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: 'رجوع',
        ),
      ),
      body: FutureBuilder<void>(
        future: _dataCheckFuture,
        builder: (context, snapshot) {
          // أثناء فحص البيانات الموجودة
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingWidget());
          }
          
          // إذا كانت البيانات موجودة، عرضها للقراءة فقط
          if (_hasExistingData) {
            return _buildReadOnlyView();
          }
          
          // إذا لم تكن البيانات موجودة، عرض النموذج العادي
          return _buildFormView();
        },
      ),
    );
  }

  /// بناء الواجهة للقراءة فقط (عندما تكون البيانات موجودة مسبقاً)
  Widget _buildReadOnlyView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // رسالة حالة البيانات
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryColor),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primaryColor,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'تم إرسال بياناتك بنجاح',
                  style: AppTextStyles.headline3.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'بياناتك قيد المراجعة من قبل الفريق المختص',
                  style: AppTextStyles.bodyText1.copyWith(
                    color: AppColors.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'سيتم التواصل معك عند الانتهاء من المراجعة',
                  style: AppTextStyles.bodyText2.copyWith(
                    color: AppColors.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // عرض البيانات للقراءة فقط
          Expanded(
            child: _buildReadOnlyForm(),
          ),
          
          // زر العودة للرئيسية
          const SizedBox(height: 16),
          CustomButton(
            text: 'العودة للرئيسية',
            onPressed: () => context.go('/'),
            icon: Icons.home,
            isFullWidth: true,
            isOutlined: false,
          ),
        ],
      ),
    );
  }

  /// بناء النموذج للقراءة فقط
  Widget _buildReadOnlyForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReadOnlySection('البيانات الأساسية', [
            _buildReadOnlyField('الاسم الكامل في العراق', _fullNameIraqController.text),
            _buildReadOnlyField('اسم الأم', _motherNameController.text),
            _buildReadOnlyField('المحافظة الحالية', _currentProvinceController.text),
            _buildReadOnlyField('تاريخ الميلاد', _formatDate(_selectedBirthDate)),
            _buildReadOnlyField('مكان الولادة', _birthPlaceController.text),
            _buildReadOnlyField('رقم الهاتف', _phoneNumberController.text),
          ]),
          
          _buildReadOnlySection('بيانات الهوية الوطنية', [
            _buildReadOnlyField('رقم الهوية الوطنية', _nationalIdController.text),
            _buildReadOnlyField('سنة الإصدار', _nationalIdIssueYear?.toString() ?? ''),
            _buildReadOnlyField('جهة الإصدار', _nationalIdIssuerController.text),
          ]),
          
          _buildReadOnlySection('بيانات الكويت السابقة', [
            _buildReadOnlyField('الاسم الكامل في الكويت', _fullNameKuwaitController.text),
            _buildReadOnlyField('العنوان في الكويت', _kuwaitAddressController.text),
            _buildReadOnlyField('مستوى التعليم', _kuwaitEducationLevelController.text),
            _buildReadOnlyField('عدد أفراد الأسرة', _familyMembersCountController.text),
            _buildReadOnlyField('عدد البالغين فوق 18', _adultsOver18CountController.text),
          ]),
          
          _buildReadOnlySection('الخيارات والتفضيلات', [
            _buildReadOnlyField('طريقة الخروج من الكويت', _getExitMethodText(_selectedExitMethod)),
            _buildReadOnlyField('نوع العمل في الكويت', _getJobTypeText(_selectedKuwaitJobType)),
            _buildReadOnlyField('الوضع الرسمي', _getOfficialStatusText(_selectedKuwaitOfficialStatus)),
            _buildReadOnlyField('أنواع التعويض', _getCompensationTypesText(_selectedCompensationTypes)),
            _buildReadOnlyField('أنواع طلبات الحقوق', _getRightsRequestTypesText(_selectedRightsRequestTypes)),
          ]),
        ],
      ),
    );
  }

  /// بناء قسم للقراءة فقط
  Widget _buildReadOnlySection(String title, List<Widget> fields) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...fields,
          ],
        ),
      ),
    );
  }

  /// بناء حقل للقراءة فقط
  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyText2.copyWith(
              color: AppColors.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Text(
              value.isNotEmpty ? value : 'غير محدد',
              style: AppTextStyles.bodyText1.copyWith(
                color: value.isNotEmpty ? AppColors.textPrimaryColor : AppColors.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// الحصول على نص طريقة الخروج
  String _getExitMethodText(ExitMethod? method) {
    if (method == null) return 'غير محدد';
    switch (method) {
      case ExitMethod.voluntaryDeparture:
        return 'المغادرة الطوعية';
      case ExitMethod.forcedDeportation:
        return 'الترحيل القسري';
      case ExitMethod.landSmuggling:
        return 'التهريب البري';
      case ExitMethod.beforeArmyWithdrawal:
        return 'قبل انسحاب الجيش';
    }
  }

  /// الحصول على نص نوع العمل
  String _getJobTypeText(KuwaitJobType? jobType) {
    if (jobType == null) return 'غير محدد';
    switch (jobType) {
      case KuwaitJobType.civilEmployee:
        return 'موظف مدني';
      case KuwaitJobType.militaryEmployee:
        return 'موظف عسكري';
      case KuwaitJobType.student:
        return 'طالب';
      case KuwaitJobType.freelance:
        return 'عمل حر';
    }
  }

  /// الحصول على نص الوضع الرسمي
  String _getOfficialStatusText(KuwaitOfficialStatus? status) {
    if (status == null) return 'غير محدد';
    switch (status) {
      case KuwaitOfficialStatus.resident:
        return 'مقيم';
      case KuwaitOfficialStatus.bidoon:
        return 'بدون';
    }
  }

  /// الحصول على نص أنواع التعويض
  String _getCompensationTypesText(List<CompensationType> types) {
    if (types.isEmpty) return 'غير محدد';
    return types.map((type) {
      switch (type) {
        case CompensationType.governmentJobServices:
          return 'خدمات الوظائف الحكومية';
        case CompensationType.personalFurnitureProperty:
          return 'الأثاث والممتلكات الشخصية';
        case CompensationType.moralCompensation:
          return 'التعويض المعنوي';
        case CompensationType.prisonCompensation:
          return 'تعويض السجن';
      }
    }).join('، ');
  }

  /// الحصول على نص أنواع طلبات الحقوق
  String _getRightsRequestTypesText(List<RightsRequestType> types) {
    if (types.isEmpty) return 'غير محدد';
    return types.map((type) {
      switch (type) {
        case RightsRequestType.pensionSalary:
          return 'راتب التقاعد';
        case RightsRequestType.residentialLand:
          return 'أرض سكنية';
      }
    }).join('، ');
  }

  /// تنسيق التاريخ
  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  /// بناء واجهة النموذج العادي (للإدخال الجديد)
  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // مؤشر التقدم
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: AppColors.primaryLightColor,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepTapped: (step) {
                // السماح بالانتقال للخطوات السابقة فقط
                if (step <= _currentStep) {
                  setState(() {
                    _currentStep = step;
                  });
                }
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    children: [
                      if (details.stepIndex > 0)
                        CustomButton(
                          text: 'السابق',
                          onPressed: _previousStep,
                          isOutlined: true,
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Consumer<PersonalDataProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoading) {
                              return const LoadingWidget();
                            }
                            
                            return CustomButton(
                              text: details.stepIndex == 4 ? 'إرسال البيانات' : 'التالي',
                              onPressed: _nextStep,
                              isFullWidth: true,
                              icon: details.stepIndex == 4 ? Icons.send : Icons.arrow_forward,
                              isOutlined: false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              steps: [
                _buildBasicDataStep(),
                _buildNationalIdStep(),
                _buildKuwaitDataStep(),
                _buildOptionsStep(),
                _buildDocumentsStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// خطوة البيانات الأساسية
  Step _buildBasicDataStep() {
    return Step(
      title: const Text('البيانات الأساسية'),
      content: Column(
        children: [
          CustomTextField(
            controller: _fullNameIraqController,
            labelText: 'الاسم الرباعي واللقب في العراق',
            hintText: 'أدخل اسمك الكامل',
            prefixIcon: Icons.person,
            validator: (value) => value?.isEmpty == true ? 'هذا الحقل مطلوب' : null,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _motherNameController,
            labelText: 'اسم الأم',
            hintText: 'أدخل اسم والدتك',
            prefixIcon: Icons.person_outline,
            validator: (value) => value?.isEmpty == true ? 'هذا الحقل مطلوب' : null,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _currentProvinceController,
            labelText: 'المحافظة الحالية',
            hintText: 'أدخل محافظتك الحالية',
            prefixIcon: Icons.location_on,
            validator: (value) => value?.isEmpty == true ? 'هذا الحقل مطلوب' : null,
          ),
          const SizedBox(height: 16),
          
          DatePickerField(
            labelText: 'تاريخ الميلاد',
            selectedDate: _selectedBirthDate,
            onDateSelected: (date) {
              setState(() {
                _selectedBirthDate = date;
              });
            },
            validator: (date) => date == null ? 'يرجى اختيار تاريخ الميلاد' : null,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _birthPlaceController,
            labelText: 'مكان الميلاد',
            hintText: 'أدخل مكان ميلادك',
            prefixIcon: Icons.place,
            validator: (value) => value?.isEmpty == true ? 'هذا الحقل مطلوب' : null,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _phoneNumberController,
            labelText: 'رقم الهاتف',
            hintText: 'أدخل رقم هاتفك',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone,
            validator: (value) => value?.isEmpty == true ? 'هذا الحقل مطلوب' : null,
          ),
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 
        ? StepState.complete 
        : _currentStep == 0 
          ? StepState.editing 
          : StepState.disabled,
    );
  }

  /// خطوة بيانات البطاقة الوطنية
  Step _buildNationalIdStep() {
    return Step(
      title: const Text('بيانات البطاقة الوطنية'),
      content: Column(
        children: [
          CustomTextField(
            controller: _nationalIdController,
            labelText: 'رقم البطاقة الوطنية',
            hintText: 'أدخل رقم بطاقتك الوطنية',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.credit_card,
            validator: (value) => value?.isEmpty == true ? 'هذا الحقل مطلوب' : null,
          ),
          const SizedBox(height: 16),
          
          DropdownField<int>(
            labelText: 'سنة إصدار البطاقة',
            value: _nationalIdIssueYear,
            items: List.generate(50, (index) => DateTime.now().year - index)
                .map((year) => DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _nationalIdIssueYear = value;
              });
            },
            validator: (value) => value == null ? 'يرجى اختيار سنة الإصدار' : null,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _nationalIdIssuerController,
            labelText: 'جهة الإصدار',
            hintText: 'أدخل الجهة التي أصدرت البطاقة',
            prefixIcon: Icons.business,
            validator: (value) => value?.isEmpty == true ? 'هذا الحقل مطلوب' : null,
          ),
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 
        ? StepState.complete 
        : _currentStep == 1 
          ? StepState.editing 
          : StepState.disabled,
    );
  }

  /// خطوة بيانات الكويت
  Step _buildKuwaitDataStep() {
    return Step(
      title: const Text('بيانات الكويت السابقة'),
      content: Column(
        children: [
          CustomTextField(
            controller: _fullNameKuwaitController,
            labelText: 'الاسم الرباعي واللقب في الكويت سابقاً',
            hintText: 'أدخل اسمك كما كان في الكويت',
            prefixIcon: Icons.person,
            validator: (value) => value?.isEmpty == true ? 'هذا الحقل مطلوب' : null,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _kuwaitAddressController,
            labelText: 'عنوان السكن في الكويت سابقاً',
            hintText: 'أدخل عنوانك السابق في الكويت',
            prefixIcon: Icons.home,
            maxLines: 2,
            validator: (value) => value?.isEmpty == true ? 'هذا الحقل مطلوب' : null,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _kuwaitEducationLevelController,
            labelText: 'التحصيل الدراسي في الكويت',
            hintText: 'أدخل مستواك التعليمي في الكويت',
            prefixIcon: Icons.school,
            validator: (value) => value?.isEmpty == true ? 'هذا الحقل مطلوب' : null,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _familyMembersCountController,
            labelText: 'عدد أفراد الأسرة حال الخروج من الكويت',
            hintText: 'أدخل عدد أفراد أسرتك',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.family_restroom,
            validator: (value) {
              if (value?.isEmpty == true) return 'هذا الحقل مطلوب';
              final number = int.tryParse(value!);
              if (number == null || number <= 0) return 'يرجى إدخال رقم صحيح';
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _adultsOver18CountController,
            labelText: 'عدد من تم الـ18 عام حال الخروج من الكويت',
            hintText: 'أدخل عدد البالغين',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.person_add,
            validator: (value) {
              if (value?.isEmpty == true) return 'هذا الحقل مطلوب';
              final number = int.tryParse(value!);
              if (number == null || number < 0) return 'يرجى إدخال رقم صحيح';
              return null;
            },
          ),
        ],
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 
        ? StepState.complete 
        : _currentStep == 2 
          ? StepState.editing 
          : StepState.disabled,
    );
  }

  /// خطوة الخيارات
  Step _buildOptionsStep() {
    return Step(
      title: const Text('خيارات الخروج والتعويض'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // طريقة الخروج
          Text('طريقة الخروج من دولة الكويت', style: AppTextStyles.subtitle1),
          const SizedBox(height: 8),
          ...ExitMethod.values.map((method) => 
            RadioListTile<ExitMethod>(
              title: Text(method.displayName),
              value: method,
              groupValue: _selectedExitMethod,
              onChanged: (value) {
                setState(() {
                  _selectedExitMethod = value;
                });
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // نوع التعويض
          Text('نوع طلب التعويض (يمكن اختيار أكثر من نوع)', style: AppTextStyles.subtitle1),
          const SizedBox(height: 8),
          CheckboxGroup<CompensationType>(
            options: CompensationType.values,
            selectedValues: _selectedCompensationTypes,
            onChanged: (values) {
              setState(() {
                _selectedCompensationTypes = values;
              });
            },
            getDisplayName: (type) => type.displayName,
          ),
          
          const SizedBox(height: 24),
          
          // طبيعة العمل
          DropdownField<KuwaitJobType>(
            labelText: 'طبيعة العمل في الكويت سابقاً',
            value: _selectedKuwaitJobType,
            items: KuwaitJobType.values.map((type) => 
              DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              ),
            ).toList(),
            onChanged: (value) {
              setState(() {
                _selectedKuwaitJobType = value;
              });
            },
            validator: (value) => value == null ? 'يرجى اختيار طبيعة العمل' : null,
          ),
          
          const SizedBox(height: 16),
          
          // الوضع الرسمي
          DropdownField<KuwaitOfficialStatus>(
            labelText: 'الوضع الرسمي بالكويت',
            value: _selectedKuwaitOfficialStatus,
            items: KuwaitOfficialStatus.values.map((status) => 
              DropdownMenuItem(
                value: status,
                child: Text(status.displayName),
              ),
            ).toList(),
            onChanged: (value) {
              setState(() {
                _selectedKuwaitOfficialStatus = value;
              });
            },
            validator: (value) => value == null ? 'يرجى اختيار الوضع الرسمي' : null,
          ),
          
          const SizedBox(height: 24),
          
          // نوع طلب الحقوق
          Text('نوع طلب الحقوق (يمكن اختيار أكثر من نوع)', style: AppTextStyles.subtitle1),
          const SizedBox(height: 8),
          CheckboxGroup<RightsRequestType>(
            options: RightsRequestType.values,
            selectedValues: _selectedRightsRequestTypes,
            onChanged: (values) {
              setState(() {
                _selectedRightsRequestTypes = values;
              });
            },
            getDisplayName: (type) => type.displayName,
          ),
        ],
      ),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 
        ? StepState.complete 
        : _currentStep == 3 
          ? StepState.editing 
          : StepState.disabled,
    );
  }

  /// خطوة المستمسكات
  Step _buildDocumentsStep() {
    return Step(
      title: const Text('المستمسكات الثبوتية'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حدد المستمسكات التي تملكها (على الأقل واحد مطلوب):',
            style: AppTextStyles.bodyText1,
          ),
          const SizedBox(height: 16),
          
          CheckboxListTile(
            title: const Text('دائرة شؤون العراقي'),
            subtitle: const Text('وثائق من دائرة شؤون العراقي'),
            value: _hasIraqiAffairsDept,
            onChanged: (value) {
              setState(() {
                _hasIraqiAffairsDept = value ?? false;
              });
            },
          ),
          
          CheckboxListTile(
            title: const Text('منفذ الهجرة الكويتية'),
            subtitle: const Text('وثائق من منفذ الهجرة الكويتية'),
            value: _hasKuwaitImmigration,
            onChanged: (value) {
              setState(() {
                _hasKuwaitImmigration = value ?? false;
              });
            },
          ),
          
          CheckboxListTile(
            title: const Text('إقامة سارية المفعول'),
            subtitle: const Text('إقامة كانت سارية المفعول'),
            value: _hasValidResidence,
            onChanged: (value) {
              setState(() {
                _hasValidResidence = value ?? false;
              });
            },
          ),
          
          CheckboxListTile(
            title: const Text('الصليب الأحمر الدولي'),
            subtitle: const Text('وثائق من الصليب الأحمر الدولي'),
            value: _hasRedCrossInternational,
            onChanged: (value) {
              setState(() {
                _hasRedCrossInternational = value ?? false;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          if (!_validateDocumentsData())
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warningColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.warningColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'يرجى اختيار مستمسك واحد على الأقل',
                      style: AppTextStyles.bodyText2.copyWith(
                        color: AppColors.warningColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      isActive: _currentStep >= 4,
      state: _currentStep == 4 ? StepState.editing : StepState.disabled,
    );
  }
}
