import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/auth_scope.dart';
import '../../models/auth_requests.dart';
import '../../utils/form_validators.dart';
import '../widgets/custom_text_field.dart';

/// شاشة إنشاء الحساب الأكاديمي (RegisterPage)
/// تحتوي على التحقق من 5 حقول إلزامية وصندوق الموافقة على الشروط واللوائح
class RegisterPage extends StatefulWidget {
  final AuthController? controller;

  const RegisterPage({super.key, this.controller});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // مفتاح النموذج لفحص كافة الحقول
  final _formKey = GlobalKey<FormState>();

  // متحكمات حقول الإدخال
  late final TextEditingController _fullNameController;
  late final TextEditingController _academicIdController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  // حالة الخطأ لصندوق الشروط
  bool _termsError = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _academicIdController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _academicIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  AuthController _getController(BuildContext context) {
    return widget.controller ?? AuthScope.of(context);
  }

  /// تنفيذ عملية إنشاء الحساب
  Future<void> _handleRegister(AuthController controller) async {
    FocusScope.of(context).unfocus();

    // التحقق من صحة حقول النموذج
    final isFormValid = _formKey.currentState!.validate();

    // التحقق الصارم من صندوق الموافقة على اللوائح والشروط الأكاديمية
    if (!controller.agreedToTerms) {
      setState(() {
        _termsError = true;
      });
    } else {
      setState(() {
        _termsError = false;
      });
    }

    if (!isFormValid || !controller.agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text('يرجى تصحيح الأخطاء والموافقة على اللوائح لإتمام التسجيل'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEAB308),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final request = RegisterRequest(
      fullName: _fullNameController.text,
      academicId: _academicIdController.text,
      universityEmail: _emailController.text,
      password: _passwordController.text,
      agreedToTerms: controller.agreedToTerms,
    );

    final success = await controller.register(request);

    if (!mounted) return;

    if (success) {
      // إظهار رسالة النجاح والرجوع لشاشة الدخول
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(controller.successMessage ?? 'تم إنشاء الحساب بنجاح'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF15803D),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // الرجوع لشاشة تسجيل الدخول
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(controller.errorMessage ?? 'تعذر إنشاء الحساب'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// نافذة منبثقة لقراءة اللوائح الأكاديمية
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.article_rounded, color: Color(0xFF1E3A8A)),
            SizedBox(width: 8),
            Text(
              'اللوائح والشروط الأكاديمية',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. يلتزم الطالب بصحة ودقة كافة البيانات الأكاديمية والشخصية المسجلة.\n'
                '2. تعتبر كلمة المرور ورمز الحساب سرية وشخصية يتحمل الطالب مسؤوليتها.\n'
                '3. يمنع منعاً باتاً مشاركة الحساب أو استخدامه لأغراض غير أكاديمية.\n'
                '4. يخضع استخدام المنصة لقواعد السلوك والانضباط الطلابي المعتمدة في الجامعة.',
                style: TextStyle(fontSize: 13.5, height: 1.6, color: Color(0xFF334155)),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('فهمت ذلك'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _getController(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
          tooltip: 'رجوع',
        ),
        title: const Text(
          'إنشاء حساب طالب جديد',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // وصف تعريفي
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFF1E3A8A), size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'يرجى تعبئة كافة الحقول بدقة وفق سجل القبول والتسجيل الجامعي الخاص بك.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF334155),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // بطاقة حقول التسجيل
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. حقل الاسم الكامل (≥ 3 محارف)
                            CustomTextField(
                              controller: _fullNameController,
                              label: 'الاسم الكامل للطالب',
                              hint: 'أدخل اسمك الثلاثي أو الرباعي',
                              prefixIcon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.name,
                              validator: FormValidators.validateFullName,
                            ),
                            const SizedBox(height: 16),

                            // 2. حقل الرقم الأكاديمي (أرقام حصراً، 9-10 خانات)
                            CustomTextField(
                              controller: _academicIdController,
                              label: 'الرقم الأكاديمي',
                              hint: 'أدخل رقمك الجامعي (مثال: 441012345)',
                              prefixIcon: Icons.badge_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: FormValidators.validateAcademicId,
                            ),
                            const SizedBox(height: 16),

                            // 3. حقل البريد الجامعي (Regex قياسي)
                            CustomTextField(
                              controller: _emailController,
                              label: 'البريد الجامعي الرسمي',
                              hint: 'student@university.edu.sa',
                              prefixIcon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: FormValidators.validateUniversityEmail,
                            ),
                            const SizedBox(height: 16),

                            // 4. حقل كلمة المرور (سياسة أمان قوية: ≥ 8 محارف + رقم + حرف كبير)
                            CustomTextField(
                              controller: _passwordController,
                              label: 'كلمة المرور',
                              hint: '8 محارف على الأقل، تشمل حرفاً كبيراً ورقماً',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: controller.obscureRegisterPassword,
                              validator: FormValidators.validateStrongPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureRegisterPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: controller.toggleRegisterPasswordVisibility,
                                tooltip: 'إظهار/إخفاء كلمة المرور',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 5. حقل تأكيد كلمة المرور (مطابقة تامة 100%)
                            CustomTextField(
                              controller: _confirmPasswordController,
                              label: 'تأكيد كلمة المرور',
                              hint: 'أعد كتابة كلمة المرور للتأكيد',
                              prefixIcon: Icons.lock_reset_rounded,
                              obscureText: controller.obscureRegisterConfirmPassword,
                              validator: (val) => FormValidators.validateConfirmPassword(
                                val,
                                _passwordController.text,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureRegisterConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: controller.toggleRegisterConfirmPasswordVisibility,
                                tooltip: 'إظهار/إخفاء كلمة المرور',
                              ),
                            ),
                            const SizedBox(height: 18),

                            // 6. صندوق الموافقة على اللوائح والشروط الأكاديمية
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: _termsError
                                    ? const Color(0xFFFEF2F2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: _termsError
                                    ? Border.all(color: const Color(0xFFF87171))
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                        value: controller.agreedToTerms,
                                        activeColor: const Color(0xFF1E3A8A),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        onChanged: (val) {
                                          final isChecked = val ?? false;
                                          controller.setAgreedToTerms(isChecked);
                                          if (isChecked && _termsError) {
                                            setState(() {
                                              _termsError = false;
                                            });
                                          }
                                        },
                                      ),
                                      Expanded(
                                        child: Wrap(
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            const Text(
                                              'أوافق وأتعهد بالالتزام بكافة ',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _showTermsDialog,
                                              child: const Text(
                                                'اللوائح والشروط الأكاديمية',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2563EB),
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_termsError)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 44, bottom: 4),
                                      child: Text(
                                        'يجب الموافقة على اللوائح والشروط لإكمال التسجيل',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 7. زر إنشاء الحساب مع مؤشر التحميل
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : () => _handleRegister(controller),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 1,
                                ),
                                child: controller.isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.person_add_alt_1_rounded, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'إنشاء الحساب الأكاديمي',
                                            style: TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // رابط الرجوع لتسجيل الدخول
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'لديك حساب مسجل بالفعل؟',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
