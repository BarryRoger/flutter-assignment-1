import 'user_model.dart';

/// نموذج بيانات طلب تسجيل الدخول
class LoginRequest {
  final String identifier; // المعرف الأكاديمي أو البريد الجامعي
  final String password;   // كلمة المرور
  final bool rememberMe;   // خيار تذكرني

  const LoginRequest({
    required this.identifier,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'identifier': identifier.trim(),
      'password': password,
      'rememberMe': rememberMe,
    };
  }
}

/// نموذج بيانات طلب إنشاء حساب طالب جديد
class RegisterRequest {
  final String fullName;          // الاسم الكامل
  final String academicId;        // الرقم الأكاديمي (9-10 أرقام)
  final String universityEmail;   // البريد الجامعي الرسمي
  final String password;          // كلمة المرور المطابقة لسياسة الأمان
  final bool agreedToTerms;       // الموافقة على اللوائح والشروط

  const RegisterRequest({
    required this.fullName,
    required this.academicId,
    required this.universityEmail,
    required this.password,
    required this.agreedToTerms,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName.trim(),
      'academicId': academicId.trim(),
      'universityEmail': universityEmail.trim().toLowerCase(),
      'password': password,
      'agreedToTerms': agreedToTerms,
    };
  }
}

/// نموذج بيانات طلب استعادة كلمة المرور
class ForgotPasswordRequest {
  final String identifier; // البريد الجامعي أو الرقم الأكاديمي

  const ForgotPasswordRequest({
    required this.identifier,
  });

  Map<String, dynamic> toMap() {
    return {
      'identifier': identifier.trim(),
    };
  }
}

/// نموذج بيانات طلب إعادة تعيين كلمة المرور
class ResetPasswordRequest {
  final String identifier;       // المعرف التابع للحساب (لربط العملية)
  final String otpCode;          // رمز التحقق المكون من 6 أرقام
  final String newPassword;      // كلمة المرور الجديدة
  final String confirmPassword;  // تأكيد كلمة المرور الجديدة

  const ResetPasswordRequest({
    this.identifier = '',
    required this.otpCode,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toMap() {
    return {
      'identifier': identifier.trim(),
      'otpCode': otpCode.trim(),
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

/// نتيجة عملية المصادقة
class AuthResult {
  final bool isSuccess;
  final String message;
  final UserModel? user;

  const AuthResult({
    required this.isSuccess,
    required this.message,
    this.user,
  });

  factory AuthResult.success({required String message, UserModel? user}) {
    return AuthResult(
      isSuccess: true,
      message: message,
      user: user,
    );
  }

  factory AuthResult.failure({required String message}) {
    return AuthResult(
      isSuccess: false,
      message: message,
      user: null,
    );
  }
}
