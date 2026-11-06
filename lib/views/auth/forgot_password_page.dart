import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/auth_scope.dart';
import '../../models/auth_requests.dart';
import '../../utils/form_validators.dart';
import '../widgets/custom_text_field.dart';
import 'reset_password_page.dart';

/// شاشة استعادة كلمة المرور (ForgotPasswordPage)
/// تتضمن بطاقة توجيهية، حقل المعرف، إرسال رمز التحقق مع SnackBar أخضر، والانتقال التلقائي لشاشة إعادة التعيين
class ForgotPasswordPage extends StatefulWidget {
  final AuthController? controller;

  const ForgotPasswordPage({super.key, this.controller});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _identifierController;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  AuthController _getController(BuildContext context) {
    return widget.controller ?? AuthScope.of(context);
  }

  /// إرسال رمز التحقق والانتقال التلقائي لشاشة تعيين كلمة المرور
  Future<void> _handleSendResetCode(AuthController controller) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final identifier = _identifierController.text.trim();
    final request = ForgotPasswordRequest(identifier: identifier);

    final success = await controller.sendPasswordResetCode(request);

    if (!mounted) return;

    if (success) {
      // إظهار SnackBar أخضر وفق المتطلبات
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  controller.successMessage ??
                      'تم إرسال رمز التحقق بنجاح إلى وسيلة الاتصال المسجلة.',
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF15803D), // أخضر
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // الانتقال التلقائي لشاشة تعيين كلمة المرور
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(
            controller: controller,
            initialIdentifier: identifier,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(controller.errorMessage ?? 'تعذر إرسال رمز التحقق'),
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
          'استعادة كلمة المرور',
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. بطاقة توجيهية أعلى الشاشة توضح آلية إرسال رمز التحقق
                    _buildGuidanceCard(),
                    const SizedBox(height: 24),

                    // بطاقة الإدخال
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
                            // 2. حقل البريد أو الرقم الأكاديمي مع التحقق
                            CustomTextField(
                              controller: _identifierController,
                              label: 'البريد الجامعي أو الرقم الأكاديمي',
                              hint: 'أدخل الرقم الأكاديمي أو البريد المسجل',
                              prefixIcon: Icons.mark_email_read_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: FormValidators.validateIdentifier,
                            ),
                            const SizedBox(height: 24),

                            // 3. زر "إرسال رمز التحقق" مع مؤشر التحميل
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : () => _handleSendResetCode(controller),
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
                                          Icon(Icons.send_rounded, size: 18),
                                          SizedBox(width: 8),
                                          Text(
                                            'إرسال رمز التحقق',
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

                    // 4. زر العودة لتسجيل الدخول
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text(
                        'العودة لتسجيل الدخول',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E3A8A),
                        side: const BorderSide(color: Color(0xFF1E3A8A), width: 1.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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

  /// البطاقة التوجيهية في أعلى الشاشة
  Widget _buildGuidanceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: Color(0xFF1E40AF),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'آلية استعادة الحساب الأكاديمي',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'أدخل بريدك الجامعي المعتمد أو رقمك الأكاديمي المسجل. '
                  'سيقوم النظام فوراً بإرسال رمز تحقق سري (OTP) مكوّن من 6 أرقام للتحقق من هويتك وتمكينك من إعادة تعيين كلمة المرور.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF334155),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
