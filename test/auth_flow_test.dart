import 'package:flutter_test/flutter_test.dart';
import 'package:student_auth_system/controllers/auth_controller.dart';
import 'package:student_auth_system/models/auth_requests.dart';
import 'package:student_auth_system/repositories/auth_repository_impl.dart';

void main() {
  group('Auth Flow End-to-End Tests - اختبارات تدفق المصادقة والمستودع والمتحكم', () {
    late AuthRepositoryImpl repository;
    late AuthController controller;

    setUp(() {
      repository = AuthRepositoryImpl(networkLatency: Duration.zero);
      controller = AuthController(repository: repository);
    });

    test('1. تسجيل الدخول ببيانات صحيحة ينجح ويحدث المستخدم الحالي', () async {
      final request = LoginRequest(
        identifier: '441012345',
        password: 'Password123',
        rememberMe: true,
      );

      final success = await controller.login(request);

      expect(success, isTrue);
      expect(controller.isAuthenticated, isTrue);
      expect(controller.currentUser, isNotNull);
      expect(controller.currentUser?.fullName, 'عبدالله أحمد السالم');
      expect(controller.errorMessage, isNull);
    });

    test('2. تسجيل الدخول بكلمة مرور خاطئة يفشل مع رسالة خطأ واضحة', () async {
      final request = const LoginRequest(
        identifier: '441012345',
        password: 'WrongPassword123',
      );

      final success = await controller.login(request);

      expect(success, isFalse);
      expect(controller.isAuthenticated, isFalse);
      expect(controller.errorMessage, isNotNull);
    });

    test('3. إنشاء حساب طالب جديد ينجح ويسمح بعدها بتسجيل الدخول', () async {
      final registerReq = const RegisterRequest(
        fullName: 'سارة خالد المنصور',
        academicId: '442099999',
        universityEmail: 'sara@university.edu.sa',
        password: 'Secret2025',
        agreedToTerms: true,
      );

      final regSuccess = await controller.register(registerReq);
      expect(regSuccess, isTrue);
      expect(controller.successMessage, isNotNull);

      // تجربة تسجيل الدخول بالحساب المنشأ حديثاً
      final loginReq = const LoginRequest(
        identifier: '442099999',
        password: 'Secret2025',
      );
      final loginSuccess = await controller.login(loginReq);
      expect(loginSuccess, isTrue);
      expect(controller.currentUser?.fullName, 'سارة خالد المنصور');
    });

    test('4. رفض إنشاء حساب مكرر بالرقم الأكاديمي', () async {
      final duplicateReq = const RegisterRequest(
        fullName: 'طالب مكرر',
        academicId: '441012345', // مسجل مسبقاً
        universityEmail: 'newemail@university.edu.sa',
        password: 'Password123',
        agreedToTerms: true,
      );

      final success = await controller.register(duplicateReq);
      expect(success, isFalse);
      expect(controller.errorMessage, contains('مسجل مسبقاً'));
    });

    test('5. تدفق استعادة وتحديث كلمة المرور بالكامل', () async {
      // أ) طلب إرسال رمز التحقق
      final forgotReq = const ForgotPasswordRequest(identifier: '441012345');
      final forgotSuccess = await controller.sendPasswordResetCode(forgotReq);
      expect(forgotSuccess, isTrue);

      // ب) تعيين كلمة مرور جديدة
      final resetReq = const ResetPasswordRequest(
        identifier: '441012345',
        otpCode: '123456',
        newPassword: 'NewPassword999',
        confirmPassword: 'NewPassword999',
      );
      final resetSuccess = await controller.resetPassword(resetReq);
      expect(resetSuccess, isTrue);

      // ج) تسجيل الدخول بكلمة المرور الجديدة للتأكد من التحديث
      final loginSuccess = await controller.login(
        const LoginRequest(
          identifier: '441012345',
          password: 'NewPassword999',
        ),
      );
      expect(loginSuccess, isTrue);
    });
  });
}
