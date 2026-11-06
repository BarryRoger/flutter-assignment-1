import '../models/auth_requests.dart';
import '../models/user_model.dart';

/// العقد التجريدي لمستودع المصادقة (AuthRepository Interface)
/// يحدد كافة العمليات الأساسية لنظام المصادقة دون الارتباط بطريقة التنفيذ (Mock, Firebase, REST API)
abstract class AuthRepository {
  /// تسجيل الدخول عبر المعرف وكلمة المرور
  Future<AuthResult> login(LoginRequest request);

  /// إنشاء حساب طالب جديد
  Future<AuthResult> register(RegisterRequest request);

  /// إرسال رمز التحقق (OTP) لاستعادة كلمة المرور
  Future<AuthResult> sendPasswordResetCode(ForgotPasswordRequest request);

  /// إعادة تعيين كلمة المرور الجديدة عبر رمز التحقق
  Future<AuthResult> resetPassword(ResetPasswordRequest request);

  /// الحصول على بيانات الطالب المسجل حالياً
  UserModel? get currentUser;

  /// التحقق من حالة تسجيل الدخول
  bool get isAuthenticated;

  /// تسجيل الخروج
  void logout();
}
