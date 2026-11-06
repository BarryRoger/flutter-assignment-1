import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/auth_scope.dart';
import '../../models/auth_requests.dart';
import '../../utils/form_validators.dart';
import '../widgets/custom_text_field.dart';
import 'login_page.dart';

/// شاشة تعيين كلمة المرور الجديدة (ResetPasswordPage)
/// تتضمن إدخال رمز التحقق (6 أرقام)، كلمة المرور الجديدة ومطابقتها، ونافذة تأكيد التحديث
class ResetPasswordPage extends StatefulWidget {
  final AuthController? controller;
  final String initialIdentifier;

  const ResetPasswordPage({
    super.key,
    this.controller,
    this.initialIdentifier = '',
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _otpController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  AuthController _getController(BuildContext context) {
    return widget.controller ?? AuthScope.of(context);
  }

  /// تنفيذ تحديث كلمة المرور وعرض نافذة تأكيد النجاح
  Future<void> _handleResetPassword(AuthController controller) async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = ResetPasswordRequest(
      identifier: widget.initialIdentifier,
      otpCode: _otpController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    final success = await controller.resetPassword(request);

    if (!mounted) return;

    if (success) {
      // عرض نافذة تأكيد نجاح التحديث والتوجيه لشاشة الدخول
      _showSuccessDialog(controller);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(controller.errorMessage ?? 'تعذر تحديث كلمة المرور'),
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

  /// نافذة منبثقة لتأكيد نجاح تعيين كلمة المرور والتوجيه لشاشة الدخول
  void _showSuccessDialog(AuthController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 54,
                color: Color(0xFF15803D),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'تم تحديث كلمة المرور بنجاح!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'أصبح بإمكانك الآن تسجيل الدخول إلى حسابك الأكاديمي باستخدام كلمة المرور الجديدة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF475569),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // إغلاق النافذة
                  // التوجيه إلى شاشة تسجيل الدخول
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginPage(controller: controller),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'التوجه لتسجيل الدخول',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
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
          'تعيين كلمة المرور الجديدة',
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
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // بطاقة تنبيهية حول الرمز
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mark_email_read_rounded, color: Color(0xFF15803D), size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'أدخل رمز التحقق المرسل إليك',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.initialIdentifier.isNotEmpty
                                      ? 'تم الإرسال إلى: ${widget.initialIdentifier}'
                                      : 'الرمز التجريبي الافتراضي: 123456',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // بطاقة الحقول
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
                            // 1. حقل رمز التحقق (OTP): مكون من 6 أرقام رقمية حصراً
                            CustomTextField(
                              controller: _otpController,
                              label: 'رمز التحقق (OTP)',
                              hint: 'أدخل 6 أرقام (مثال: 123456)',
                              prefixIcon: Icons.pin_outlined,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              validator: FormValidators.validateOtp,
                            ),
                            const SizedBox(height: 16),

                            // 2. حقل كلمة المرور الجديدة (مطابقة سياسة الأمان)
                            CustomTextField(
                              controller: _newPasswordController,
                              label: 'كلمة المرور الجديدة',
                              hint: '8 محارف على الأقل مع حرف كبير ورقم',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: controller.obscureResetNewPassword,
                              validator: FormValidators.validateStrongPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureResetNewPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: controller.toggleResetNewPasswordVisibility,
                                tooltip: 'إظهار/إخفاء كلمة المرور',
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 3. حقل تأكيد كلمة المرور الجديدة (مطابقة الحقل السابق)
                            CustomTextField(
                              controller: _confirmPasswordController,
                              label: 'تأكيد كلمة المرور الجديدة',
                              hint: 'أعد إدخال كلمة المرور الجديدة',
                              prefixIcon: Icons.lock_reset_rounded,
                              obscureText: controller.obscureResetConfirmPassword,
                              validator: (val) => FormValidators.validateConfirmPassword(
                                val,
                                _newPasswordController.text,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureResetConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: controller.toggleResetConfirmPasswordVisibility,
                                tooltip: 'إظهار/إخفاء كلمة المرور',
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 4. زر "تحديث كلمة المرور" مع مؤشر التحميل
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : () => _handleResetPassword(controller),
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
                                          Icon(Icons.check_rounded, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'تحديث كلمة المرور',
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

                    // زر إلغاء والعودة للدخول
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginPage(controller: controller),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'إلغاء والعودة لتسجيل الدخول',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
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
}
