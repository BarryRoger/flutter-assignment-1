import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/auth_scope.dart';
import '../../models/auth_requests.dart';
import '../../utils/form_validators.dart';
import '../widgets/custom_text_field.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import '../home/student_dashboard_page.dart';

/// شاشة تسجيل الدخول (LoginPage)
/// تطبق شروط التحقق الصارمة للنماذج وفق التكليف الفصلي
class LoginPage extends StatefulWidget {
  final AuthController? controller;

  const LoginPage({super.key, this.controller});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // مفتاح النموذج للتحقق من الحقول
  final _formKey = GlobalKey<FormState>();

  // متحكمات حقول الإدخال
  late final TextEditingController _identifierController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  AuthController _getController(BuildContext context) {
    return widget.controller ?? AuthScope.of(context);
  }

  /// تنفيذ عملية تسجيل الدخول وفحص النموذج
  Future<void> _handleLogin(AuthController controller) async {
    // إخفاء لوحة المفاتيح
    FocusScope.of(context).unfocus();

    // فحص النموذج عبر GlobalKey<FormState>
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = LoginRequest(
      identifier: _identifierController.text,
      password: _passwordController.text,
      rememberMe: controller.rememberMe,
    );

    final success = await controller.login(request);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(controller.successMessage ?? 'تم تسجيل الدخول بنجاح'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF15803D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // الانتقال للوحة تحكم الطالب
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentDashboardPage(controller: controller),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(controller.errorMessage ?? 'تعذر تسجيل الدخول'),
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

  /// تعبئة سريعة للبيانات التجريبية لتسهيل تقييم التكليف
  void _fillMockCredentials(AuthController controller) {
    setState(() {
      _identifierController.text = '441012345';
      _passwordController.text = 'Password123';
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _getController(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // شعار وعنوان البوابة الأكاديمية
                    _buildHeader(theme),
                    const SizedBox(height: 28),

                    // بطاقة الحقول
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. حقل المعرف الأكاديمي أو البريد
                            CustomTextField(
                              controller: _identifierController,
                              label: 'المعرف الأكاديمي أو البريد الجامعي',
                              hint: 'أدخل الرقم الأكاديمي أو البريد الرسمي',
                              prefixIcon: Icons.badge_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: FormValidators.validateIdentifier,
                            ),
                            const SizedBox(height: 18),

                            // 2. حقل كلمة المرور مع خاصية إخفاء/إظهار
                            CustomTextField(
                              controller: _passwordController,
                              label: 'كلمة المرور',
                              hint: 'أدخل كلمة المرور الخاصة بك',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: controller.obscureLoginPassword,
                              validator: FormValidators.validateLoginPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureLoginPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: controller.toggleLoginPasswordVisibility,
                                tooltip: controller.obscureLoginPassword
                                    ? 'إظهار كلمة المرور'
                                    : 'إخفاء كلمة المرور',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 3. صندوق تذكرني ورابط نسيت كلمة المرور
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: controller.rememberMe,
                                      activeColor: const Color(0xFF1E3A8A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (val) {
                                        controller.setRememberMe(val ?? false);
                                      },
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        controller.setRememberMe(!controller.rememberMe);
                                      },
                                      child: const Text(
                                        'تذكرني',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ForgotPasswordPage(
                                          controller: controller,
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'نسيت كلمة المرور؟',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // 4. زر تسجيل الدخول مع مؤشر التحميل
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : () => _handleLogin(controller),
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
                                          Icon(Icons.login_rounded, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'تسجيل الدخول',
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
                    const SizedBox(height: 20),

                    // 5. رابط إنشاء حساب جديد
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب جامعي بعد؟',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterPage(controller: controller),
                              ),
                            );
                          },
                          child: const Text(
                            'إنشاء حساب جديد',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // بطاقة مساعدة للتقييم والتجربة السريعة
                    _buildQuickTestCard(controller),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0x1A1E3A8A),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 48,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'بوابة الخدمات الأكاديمية والطلابية',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'سجّل الدخول للوصول إلى سجلك وجدولك الأكاديمي',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTestCard(AuthController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حساب تجريبي للاختبار والتقييم السريع:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'الرقم: 441012345 | كلمة المرور: Password123',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _fillMockCredentials(controller),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'تعبئة تلقائية',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
