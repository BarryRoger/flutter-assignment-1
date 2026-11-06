import 'package:flutter/foundation.dart';
import '../models/auth_requests.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// متحكم المصادقة (Controller) وفق نمط MVC
/// يرث من [ChangeNotifier] لإدارة حالات الشاشات وتحديث واجهة المستخدم بنمط Reactive بدون حزم خارجية
class AuthController extends ChangeNotifier {
  final AuthRepository repository;

  AuthController({required this.repository});

  // ===== الحالات الأساسية (State) =====
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // خيارات واجهة المستخدم
  bool _rememberMe = false;
  bool _agreedToTerms = false;
  String _lastResetIdentifier = '';

  // حالات إخفاء/إظهار كلمات المرور (Obscure Toggles)
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureRegisterConfirmPassword = true;
  bool _obscureResetNewPassword = true;
  bool _obscureResetConfirmPassword = true;

  // ===== دوال القراءة (Getters) =====
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  UserModel? get currentUser => repository.currentUser;
  bool get isAuthenticated => repository.isAuthenticated;

  bool get rememberMe => _rememberMe;
  bool get agreedToTerms => _agreedToTerms;
  String get lastResetIdentifier => _lastResetIdentifier;

  bool get obscureLoginPassword => _obscureLoginPassword;
  bool get obscureRegisterPassword => _obscureRegisterPassword;
  bool get obscureRegisterConfirmPassword => _obscureRegisterConfirmPassword;
  bool get obscureResetNewPassword => _obscureResetNewPassword;
  bool get obscureResetConfirmPassword => _obscureResetConfirmPassword;

  // ===== إدارة خيارات الواجهة (UI State Mutations) =====

  void toggleLoginPasswordVisibility() {
    _obscureLoginPassword = !_obscureLoginPassword;
    notifyListeners();
  }

  void toggleRegisterPasswordVisibility() {
    _obscureRegisterPassword = !_obscureRegisterPassword;
    notifyListeners();
  }

  void toggleRegisterConfirmPasswordVisibility() {
    _obscureRegisterConfirmPassword = !_obscureRegisterConfirmPassword;
    notifyListeners();
  }

  void toggleResetNewPasswordVisibility() {
    _obscureResetNewPassword = !_obscureResetNewPassword;
    notifyListeners();
  }

  void toggleResetConfirmPasswordVisibility() {
    _obscureResetConfirmPassword = !_obscureResetConfirmPassword;
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void setAgreedToTerms(bool value) {
    _agreedToTerms = value;
    notifyListeners();
  }

  void setLastResetIdentifier(String identifier) {
    _lastResetIdentifier = identifier;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // ===== عمليات المصادقة الرئيسية (Auth Operations) =====

  /// 1. تنفيذ تسجيل الدخول
  Future<bool> login(LoginRequest request) async {
    _setLoading(true);
    _clearStatus();

    try {
      final result = await repository.login(request);
      if (result.isSuccess) {
        _successMessage = result.message;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع أثناء تسجيل الدخول: $e';
      _setLoading(false);
      return false;
    }
  }

  /// 2. إنشاء حساب طالب جديد
  Future<bool> register(RegisterRequest request) async {
    _setLoading(true);
    _clearStatus();

    try {
      final result = await repository.register(request);
      if (result.isSuccess) {
        _successMessage = result.message;
        _agreedToTerms = false; // إعادة تعيين الصندوق
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع أثناء إنشاء الحساب: $e';
      _setLoading(false);
      return false;
    }
  }

  /// 3. إرسال رمز استعادة كلمة المرور
  Future<bool> sendPasswordResetCode(ForgotPasswordRequest request) async {
    _setLoading(true);
    _clearStatus();

    try {
      final result = await repository.sendPasswordResetCode(request);
      if (result.isSuccess) {
        _successMessage = result.message;
        _lastResetIdentifier = request.identifier;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع أثناء إرسال رمز التحقق: $e';
      _setLoading(false);
      return false;
    }
  }

  /// 4. إعادة تعيين كلمة المرور الجديدة
  Future<bool> resetPassword(ResetPasswordRequest request) async {
    _setLoading(true);
    _clearStatus();

    try {
      final effectiveRequest = ResetPasswordRequest(
        identifier: request.identifier.isNotEmpty
            ? request.identifier
            : _lastResetIdentifier,
        otpCode: request.otpCode,
        newPassword: request.newPassword,
        confirmPassword: request.confirmPassword,
      );

      final result = await repository.resetPassword(effectiveRequest);
      if (result.isSuccess) {
        _successMessage = result.message;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result.message;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع أثناء إعادة تعيين كلمة المرور: $e';
      _setLoading(false);
      return false;
    }
  }

  /// تسجيل الخروج
  void logout() {
    repository.logout();
    _clearStatus();
    notifyListeners();
  }

  // ===== دوال مساعدة خاصة =====
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearStatus() {
    _errorMessage = null;
    _successMessage = null;
  }
}
