// مثال على كيفية استخدام النظام المحدث لمعالجة الأخطاء

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/personal_data_provider.dart';

/// مثال على استخدام النظام المحدث لمعالجة الأخطاء
class PersonalDataFormExample extends StatefulWidget {
  @override
  _PersonalDataFormExampleState createState() => _PersonalDataFormExampleState();
}

class _PersonalDataFormExampleState extends State<PersonalDataFormExample> {
  final _formKey = GlobalKey<FormState>();
  
  // بيانات النموذج
  final Map<String, dynamic> _formData = {};
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('نموذج البيانات الشخصية'),
      ),
      body: Consumer<PersonalDataProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                // عرض رسالة الخطأ المحدثة
                if (provider.errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'خطأ في البيانات',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          provider.errorMessage!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // النموذج
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // الاسم الكامل
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'الاسم الكامل في العراق *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _formData['fullNameIraq'] = value?.trim();
                          },
                        ),
                        SizedBox(height: 16),
                        
                        // اسم الأم
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'اسم الأم *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _formData['motherName'] = value?.trim();
                          },
                        ),
                        SizedBox(height: 16),
                        
                        // طريقة الخروج من الكويت
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'طريقة الخروج من الكويت',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'voluntary_departure',
                              child: Text('المغادرة الطوعية'),
                            ),
                            DropdownMenuItem(
                              value: 'forced_deportation',
                              child: Text('الترحيل القسري'),
                            ),
                            DropdownMenuItem(
                              value: 'land_smuggling',
                              child: Text('التهريب البري'),
                            ),
                            DropdownMenuItem(
                              value: 'before_army_withdrawal',
                              child: Text('قبل انسحاب الجيش'),
                            ),
                          ],
                          onChanged: (value) {
                            _formData['exitMethod'] = value;
                          },
                        ),
                        SizedBox(height: 16),
                        
                        // نوع العمل في الكويت
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'نوع العمل في الكويت',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'civil_employee',
                              child: Text('موظف مدني'),
                            ),
                            DropdownMenuItem(
                              value: 'military_employee',
                              child: Text('موظف عسكري'),
                            ),
                            DropdownMenuItem(
                              value: 'student',
                              child: Text('طالب'),
                            ),
                            DropdownMenuItem(
                              value: 'freelance',
                              child: Text('عمل حر'),
                            ),
                          ],
                          onChanged: (value) {
                            _formData['kuwaitJobType'] = value;
                          },
                        ),
                        SizedBox(height: 16),
                        
                        // عدد أفراد الأسرة
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'عدد أفراد الأسرة',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final number = int.tryParse(value);
                              if (number == null || number < 0) {
                                return 'يرجى إدخال رقم صحيح';
                              }
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value != null && value.isNotEmpty) {
                              _formData['familyMembersCount'] = int.tryParse(value) ?? 0;
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        
                        // عدد البالغين فوق 18
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'عدد البالغين فوق 18 سنة',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final number = int.tryParse(value);
                              if (number == null || number < 0) {
                                return 'يرجى إدخال رقم صحيح';
                              }
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value != null && value.isNotEmpty) {
                              _formData['adultsOver18Count'] = int.tryParse(value) ?? 0;
                            }
                          },
                        ),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                
                // زر الإرسال
                Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _submitForm,
                      child: provider.isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('إرسال البيانات'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  /// إرسال النموذج
  Future<void> _submitForm() async {
    // مسح الأخطاء السابقة
    context.read<PersonalDataProvider>().clearError();
    
    // التحقق من صحة النموذج
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // حفظ البيانات
    _formKey.currentState!.save();
    
    // إضافة البيانات الأساسية المطلوبة للاختبار
    _formData.addAll({
      'currentProvince': 'بغداد',
      'birthDate': '1980-01-01',
      'birthPlace': 'بغداد',
      'phoneNumber': '07901234567',
      'nationalId': '12345678901',
      'nationalIdIssueYear': 2020,
      'nationalIdIssuer': 'الأحوال المدنية',
    });
    
    try {
      // إرسال البيانات
      final success = await context.read<PersonalDataProvider>().submitPersonalData(_formData);
      
      if (success) {
        // نجح الإرسال
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إرسال البيانات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        // فشل الإرسال - سيظهر الخطأ تلقائياً في الواجهة
        // لا حاجة لفعل شيء هنا، الخطأ سيظهر في Consumer
      }
    } catch (e) {
      // خطأ غير متوقع
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ غير متوقع'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/* 
أمثلة على الرسائل التي ستظهر للمستخدم:

1. إذا اختار طريقة خروج غير صحيحة:
"طريقة الخروج من الكويت غير صحيحة. يرجى اختيار من الخيارات المتاحة:
• المغادرة الطوعية
• الترحيل القسري  
• التهريب البري
• قبل انسحاب الجيش"

2. إذا أدخل عدد بالغين أكبر من عدد أفراد الأسرة:
"عدد البالغين فوق 18 سنة لا يمكن أن يتجاوز عدد أفراد الأسرة الإجمالي."

3. إذا لم يملأ حقل مطلوب:
"يرجى إدخال الاسم الكامل في العراق."

4. إذا أدخل تاريخ ميلاد في المستقبل:
"تاريخ الميلاد لا يمكن أن يكون في المستقبل."

5. إذا حاول إرسال البيانات أكثر من مرة:
"لقد تم إرسال البيانات من قبل. لا يمكن إرسال البيانات أكثر من مرة واحدة."
*/
