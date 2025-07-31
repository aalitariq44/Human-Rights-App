import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';

/// شاشة المساعدة والدعم
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int _selectedCategoryIndex = 0;

  final List<HelpCategory> _categories = [
    HelpCategory(
      title: 'عن التطبيق',
      icon: Icons.info_outline,
      color: AppColors.primary,
      items: [
        HelpItem(
          question: 'ما هو تطبيق حقوقي؟',
          answer: 'تطبيق "حقوقي" هو منصة رقمية تابعة لمؤسسة حقوق الإنسان، مخصص لخدمة العراقيين الذين كانوا يقيمون في الكويت وخرجوا منها لأسباب مختلفة. يهدف التطبيق إلى مساعدة هؤلاء الأشخاص في:'
              '\n\n• تسجيل بياناتهم الشخصية ومعلومات إقامتهم السابقة في الكويت'
              '\n• رفع المستندات والوثائق الثبوتية المطلوبة'
              '\n• تقديم طلبات التعويض عن الأضرار المختلفة'
              '\n• متابعة حالة طلباتهم ومراجعتها'
              '\n• الحصول على المساعدة القانونية والإرشادات اللازمة',
        ),
        HelpItem(
          question: 'من يمكنه استخدام هذا التطبيق؟',
          answer: 'يمكن لجميع العراقيين الذين كانوا يقيمون في الكويت (بصفة مقيم أو بدون) وخرجوا منها استخدام هذا التطبيق، سواء كان خروجهم:'
              '\n\n• مغادرة طوعية'
              '\n• إبعاد قسري'
              '\n• تهريب عن طريق البر'
              '\n• قبل انسحاب الجيش'
              '\n\nكما يشمل أفراد عائلاتهم المتضررين.',
        ),
        HelpItem(
          question: 'ما هي أهداف المؤسسة؟',
          answer: 'تهدف مؤسسة حقوق الإنسان إلى:'
              '\n\n• الدفاع عن حقوق العراقيين المتضررين من ظروف الكويت'
              '\n• توثيق الأضرار والانتهاكات التي تعرضوا لها'
              '\n• السعي للحصول على التعويضات المستحقة'
              '\n• تقديم المساعدة القانونية والاستشارات'
              '\n• رفع الوعي بقضايا حقوق الإنسان'
              '\n• التواصل مع الجهات الدولية المعنية',
        ),
      ],
    ),
    HelpCategory(
      title: 'البيانات الشخصية',
      icon: Icons.person_outline,
      color: AppColors.success,
      items: [
        HelpItem(
          question: 'ما هي البيانات المطلوب إدخالها؟',
          answer: 'يتطلب التطبيق إدخال البيانات التالية:'
              '\n\n📋 البيانات الأساسية:'
              '\n• الاسم الرباعي واللقب في العراق'
              '\n• اسم الأم'
              '\n• المحافظة الحالية'
              '\n• تاريخ ومكان الميلاد'
              '\n• رقم الهاتف'
              '\n\n🆔 بيانات البطاقة الوطنية:'
              '\n• رقم البطاقة الوطنية'
              '\n• سنة الإصدار'
              '\n• جهة الإصدار'
              '\n\n🇰🇼 بيانات الكويت السابقة:'
              '\n• الاسم كما كان في الكويت'
              '\n• عنوان السكن السابق'
              '\n• المستوى التعليمي'
              '\n• عدد أفراد الأسرة وقت الخروج'
              '\n• عدد البالغين فوق 18 سنة',
        ),
        HelpItem(
          question: 'لماذا يتم تشفير بياناتي؟',
          answer: 'نحن نحرص على حماية بياناتك الشخصية بأعلى معايير الأمان:'
              '\n\n🔒 التشفير المتقدم:'
              '\n• يتم تشفير الرقم الوطني قبل إرساله'
              '\n• تشفير جميع البيانات الحساسة'
              '\n• استخدام خوارزميات تشفير معتمدة دولياً'
              '\n\n🛡 الحماية الإضافية:'
              '\n• تخزين البيانات في خوادم آمنة'
              '\n• عدم مشاركة البيانات مع أطراف ثالثة'
              '\n• إمكانية الوصول فقط للموظفين المخولين'
              '\n• نسخ احتياطية محمية',
        ),
        HelpItem(
          question: 'هل يمكنني تعديل بياناتي بعد الإرسال؟',
          answer: 'حالياً، لا يمكن تعديل البيانات بعد إرسالها مباشرة من التطبيق. ولكن:'
              '\n\n📞 للتعديل:'
              '\n• تواصل مع فريق الدعم'
              '\n• اذكر سبب التعديل'
              '\n• قدم الوثائق المؤيدة للتغيير'
              '\n\n⏰ مدة المراجعة:'
              '\n• يتم مراجعة طلبات التعديل خلال 3-5 أيام عمل'
              '\n• ستحصل على إشعار بقبول أو رفض التعديل'
              '\n\n💡 نصيحة:'
              '\n• راجع بياناتك جيداً قبل الإرسال'
              '\n• تأكد من صحة جميع المعلومات',
        ),
      ],
    ),
    HelpCategory(
      title: 'المستندات والوثائق',
      icon: Icons.description_outlined,
      color: AppColors.warning,
      items: [
        HelpItem(
          question: 'ما هي المستندات المطلوبة؟',
          answer: 'المستندات المطلوبة تشمل:'
              '\n\n📋 المستندات الأساسية (مطلوبة):'
              '\n• الصورة الشخصية'
              '\n• وثيقة من دائرة شؤون العراقي'
              '\n• وثيقة من منفذ الهجرة الكويتية'
              '\n• إقامة سارية المفعول (إن وجدت)'
              '\n• وثائق الصليب الأحمر الدولي'
              '\n\n📄 مستندات إضافية (حسب الحالة):'
              '\n• عقود العمل السابقة'
              '\n• كشوف الراتب'
              '\n• وثائق الممتلكات'
              '\n• تقارير طبية'
              '\n• شهادات دراسية',
        ),
        HelpItem(
          question: 'ما هي أنواع الملفات المدعومة؟',
          answer: 'التطبيق يدعم الأنواع التالية من الملفات:'
              '\n\n🖼 الصور:'
              '\n• JPG, JPEG, PNG'
              '\n• الحد الأقصى للحجم: 5 ميجابايت'
              '\n• دقة موصى بها: 1080x1920 أو أعلى'
              '\n\n📄 المستندات:'
              '\n• PDF فقط'
              '\n• الحد الأقصى للحجم: 10 ميجابايت'
              '\n• يفضل ملفات واضحة وقابلة للقراءة'
              '\n\n💡 نصائح للحصول على أفضل جودة:'
              '\n• استخدم إضاءة جيدة عند التصوير'
              '\n• تأكد من وضوح النص والتفاصيل'
              '\n• اجعل المستند مسطحاً ومستقيماً',
        ),
        HelpItem(
          question: 'كيف أحل مشكلة فشل رفع المستند؟',
          answer: 'إذا فشل رفع المستند، جرب الحلول التالية:'
              '\n\n🔧 الحلول السريعة:'
              '\n• تأكد من اتصالك بالإنترنت'
              '\n• تحقق من حجم الملف (أقل من 5-10 MB)'
              '\n• تأكد من نوع الملف المدعوم'
              '\n• أعد تشغيل التطبيق'
              '\n\n📱 حلول متقدمة:'
              '\n• امسح ذاكرة التخزين المؤقت للتطبيق'
              '\n• تأكد من وجود مساحة تخزين كافية'
              '\n• جرب الرفع في وقت آخر'
              '\n• استخدم شبكة واي فاي مستقرة'
              '\n\n🆘 إذا استمرت المشكلة:'
              '\n• استخدم أداة التشخيص المدمجة'
              '\n• تواصل مع فريق الدعم الفني',
        ),
      ],
    ),
    HelpCategory(
      title: 'التعويضات والحقوق',
      icon: Icons.gavel_outlined,
      color: AppColors.info,
      items: [
        HelpItem(
          question: 'ما هي أنواع التعويضات المتاحة؟',
          answer: 'يمكنك طلب التعويض عن الأضرار التالية:'
              '\n\n💼 تعويضات الوظيفة:'
              '\n• خدمات الوظائف الحكومية'
              '\n• رواتب غير مدفوعة'
              '\n• مكافآت وعلاوات مستحقة'
              '\n• حقوق التقاعد'
              '\n\n🏠 تعويضات الممتلكات:'
              '\n• الأثاث والممتلكات الشخصية'
              '\n• العقارات والأراضي'
              '\n• المركبات'
              '\n• الودائع البنكية'
              '\n\n⚖ تعويضات أخرى:'
              '\n• التعويض المعنوي عن المعاناة'
              '\n• تعويض السجن بلا تهمة'
              '\n• العلاج الطبي والنفسي'
              '\n• مصاريف العودة والسفر',
        ),
        HelpItem(
          question: 'ما هي أنواع الحقوق التي يمكنني المطالبة بها؟',
          answer: 'يمكنك المطالبة بالحقوق التالية:'
              '\n\n💰 الحقوق المالية:'
              '\n• راتب التقاعد المستحق'
              '\n• المكافآت المالية'
              '\n• التعويض عن الأضرار'
              '\n\n🏘 الحقوق العينية:'
              '\n• قطعة أرض سكنية'
              '\n• مسكن بديل'
              '\n• تسهيلات الإسكان'
              '\n\n⚕ الحقوق الصحية:'
              '\n• العلاج الطبي المجاني'
              '\n• الرعاية الصحية النفسية'
              '\n• برامج التأهيل'
              '\n\n🎓 الحقوق التعليمية:'
              '\n• منح دراسية للأبناء'
              '\n• تكملة التعليم المتوقف'
              '\n• التدريب المهني',
        ),
        HelpItem(
          question: 'ما هي مراحل معالجة الطلب؟',
          answer: 'يمر طلبك بالمراحل التالية:'
              '\n\n1️⃣ المرحلة الأولى - الاستقبال:'
              '\n• استلام البيانات والمستندات'
              '\n• التحقق من اكتمال المعلومات'
              '\n• إرسال إشعار بالاستلام'
              '\n\n2️⃣ المرحلة الثانية - المراجعة:'
              '\n• دراسة الحالة من قبل المختصين'
              '\n• التحقق من صحة الوثائق'
              '\n• تقييم الأضرار والحقوق'
              '\n\n3️⃣ المرحلة الثالثة - القرار:'
              '\n• اتخاذ قرار بقبول أو رفض الطلب'
              '\n• تحديد نوع ومقدار التعويض'
              '\n• إشعار المتقدم بالقرار'
              '\n\n4️⃣ المرحلة الرابعة - التنفيذ:'
              '\n• تنفيذ قرار التعويض'
              '\n• متابعة الإجراءات اللازمة'
              '\n• إنهاء الملف',
        ),
      ],
    ),
    HelpCategory(
      title: 'المشاكل الشائعة',
      icon: Icons.help_outline,
      color: AppColors.error,
      items: [
        HelpItem(
          question: 'لا أستطيع تسجيل الدخول للتطبيق',
          answer: 'لحل مشكلة تسجيل الدخول:'
              '\n\n🔐 تحقق من البيانات:'
              '\n• تأكد من صحة البريد الإلكتروني'
              '\n• تحقق من كلمة المرور'
              '\n• تأكد من تأكيد البريد الإلكتروني'
              '\n\n📧 مشاكل البريد الإلكتروني:'
              '\n• تحقق من صندوق الرسائل الواردة'
              '\n• اطلع على مجلد الرسائل المهملة'
              '\n• أعد إرسال رسالة التأكيد'
              '\n\n🔄 إعادة تعيين كلمة المرور:'
              '\n• استخدم خيار "نسيت كلمة المرور"'
              '\n• اتبع التعليمات في البريد المرسل'
              '\n• أنشئ كلمة مرور قوية جديدة',
        ),
        HelpItem(
          question: 'التطبيق يتوقف أو يعمل ببطء',
          answer: 'لحل مشاكل الأداء:'
              '\n\n🔄 حلول سريعة:'
              '\n• أعد تشغيل التطبيق'
              '\n• أعد تشغيل الهاتف'
              '\n• تأكد من قوة الإنترنت'
              '\n• أغلق التطبيقات الأخرى'
              '\n\n💾 تنظيف البيانات:'
              '\n• امسح ذاكرة التطبيق المؤقتة'
              '\n• احذف الملفات المؤقتة'
              '\n• تأكد من وجود مساحة تخزين كافية'
              '\n\n📱 تحديث التطبيق:'
              '\n• تحقق من وجود تحديثات'
              '\n• حدث نظام التشغيل'
              '\n• أعد تثبيت التطبيق إذا لزم الأمر',
        ),
        HelpItem(
          question: 'لا أحصل على إشعارات التطبيق',
          answer: 'لتفعيل الإشعارات:'
              '\n\n🔔 إعدادات التطبيق:'
              '\n• ادخل إعدادات التطبيق'
              '\n• فعل خيار الإشعارات'
              '\n• اختر أنواع الإشعارات المطلوبة'
              '\n\n📱 إعدادات الهاتف:'
              '\n• ادخل إعدادات الهاتف'
              '\n• ابحث عن "الإشعارات"'
              '\n• تأكد من تفعيل إشعارات تطبيق حقوقي'
              '\n\n🔋 توفير البطارية:'
              '\n• استثن التطبيق من وضع توفير البطارية'
              '\n• اسمح للتطبيق بالعمل في الخلفية'
              '\n• تحقق من إعدادات النوم للتطبيق',
        ),
      ],
    ),
    HelpCategory(
      title: 'التواصل والدعم',
      icon: Icons.support_agent_outlined,
      color: AppColors.info,
      items: [
        HelpItem(
          question: 'كيف يمكنني التواصل مع فريق الدعم؟',
          answer: 'يمكنك الوصول إلينا بعدة طرق:'
              '\n\n📞 الهاتف:'
              '\n• الخط الساخن: 1234-567-890'
              '\n• ساعات العمل: 8:00 ص - 4:00 م'
              '\n• من الأحد إلى الخميس'
              '\n\n📧 البريد الإلكتروني:'
              '\n• support@hoqoqi.org'
              '\n• info@humanrights-iraq.org'
              '\n• نرد خلال 24 ساعة'
              '\n\n🏢 المكتب الرئيسي:'
              '\n• العنوان: بغداد - الكرادة'
              '\n• مواعيد الزيارة: 9:00 ص - 2:00 م'
              '\n• يفضل الحجز المسبق'
              '\n\n💬 وسائل التواصل الاجتماعي:'
              '\n• فيسبوك: Human Rights Organization'
              '\n• تلغرام: @HoqoqiSupport'
              '\n• واتساب: 964-770-123-4567',
        ),
        HelpItem(
          question: 'ما هي ساعات عمل فريق الدعم؟',
          answer: 'أوقات تواجد فريق الدعم:'
              '\n\n⏰ الدعم الهاتفي:'
              '\n• الأحد - الخميس: 8:00 ص - 4:00 م'
              '\n• الجمعة: 9:00 ص - 12:00 م'
              '\n• السبت: مغلق'
              '\n\n💻 الدعم الإلكتروني:'
              '\n• البريد الإلكتروني: 24/7'
              '\n• الرد خلال 24 ساعة في أيام العمل'
              '\n• الرد خلال 48 ساعة في العطل'
              '\n\n🏢 الزيارات الشخصية:'
              '\n• الأحد - الخميس: 9:00 ص - 2:00 م'
              '\n• يرجى الحجز المسبق'
              '\n• إحضار الوثائق المطلوبة'
              '\n\n🚨 الحالات الطارئة:'
              '\n• خط الطوارئ: 964-780-999-8888'
              '\n• متاح 24/7 للحالات العاجلة فقط',
        ),
        HelpItem(
          question: 'هل يمكنني الحصول على استشارة قانونية؟',
          answer: 'نعم، نوفر الاستشارات القانونية:'
              '\n\n⚖ الاستشارات المجانية:'
              '\n• استشارة أولية مجانية (30 دقيقة)'
              '\n• تقييم أولي للحالة'
              '\n• إرشادات عامة حول الحقوق'
              '\n\n👨‍💼 الاستشارات المتخصصة:'
              '\n• محامون متخصصون في حقوق الإنسان'
              '\n• خبراء في القانون الدولي'
              '\n• مستشارون قانونيون معتمدون'
              '\n\n📅 كيفية الحجز:'
              '\n• اتصل على رقم الدعم'
              '\n• احجز موعداً مسبقاً'
              '\n• أحضر جميع الوثائق ذات الصلة'
              '\n\n💡 ما نقدمه:'
              '\n• تقييم قوة الحالة القانونية'
              '\n• شرح الحقوق والواجبات'
              '\n• خطة عمل للمتابعة'
              '\n• إرشادات للخطوات التالية',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text(
          'المساعدة والدعم',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.home),
        ),
      ),
      body: Column(
        children: [
          // شريط الفئات العلوي
          _buildCategoryTabs(),
          
          // المحتوى
          Expanded(
            child: _buildContent(),
          ),
          
          // أزرار الاتصال السريع
          _buildQuickContactButtons(),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = index == _selectedCategoryIndex;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? category.color : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? category.color : AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 18,
                    color: isSelected ? Colors.white : category.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    final selectedCategory = _categories[_selectedCategoryIndex];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: selectedCategory.items.length,
      itemBuilder: (context, index) {
        final item = selectedCategory.items[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: selectedCategory.color.withOpacity(0.1),
              radius: 20,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: selectedCategory.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              item.question,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedCategory.color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    item.answer,
                    style: AppTextStyles.bodyMedium.copyWith(
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickContactButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_support,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'هل تحتاج مساعدة فورية؟',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
            Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'اتصل بنا',
                  onPressed: () => _makePhoneCall(),
                  icon: Icons.phone,
                  variant: ButtonVariant.filled,
                  isOutlined: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'راسلنا',
                  onPressed: () => _sendEmail(),
                  icon: Icons.email,
                  variant: ButtonVariant.outline,
                  isOutlined: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _makePhoneCall() {
    // تنفيذ الاتصال الهاتفي
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم فتح تطبيق الهاتف للاتصال...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _sendEmail() {
    // تنفيذ إرسال البريد الإلكتروني
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم فتح تطبيق البريد الإلكتروني...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// نماذج البيانات للمساعدة
class HelpCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<HelpItem> items;

  HelpCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class HelpItem {
  final String question;
  final String answer;

  HelpItem({
    required this.question,
    required this.answer,
  });
}
