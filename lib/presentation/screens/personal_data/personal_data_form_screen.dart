import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/enums.dart';
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
        title: const Text('إدخال البيانات الشخصية'),
        centerTitle: true,
      ),
      body: Form(
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
