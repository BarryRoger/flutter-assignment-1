import 'dart:async';
import '../models/auth_requests.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

/// تطبيق مستودع المصادقة مع محاكاة الاتصال بالشبكة (Mock Network Simulation)
class AuthRepositoryImpl implements AuthRepository {
  // محاكاة تأخير الشبكة لإظهار مؤشرات التحميل بشكل واقعي
  final Duration networkLatency;

  // قاعدة بيانات افتراضية في الذاكرة لتخزين المستخدمين المسجلين
  final List<_InternalUserData> _database = [];

  // خريطة لتخزين رموز التحقق المؤقتة (Identifier -> OTP Code)
  final Map<String, String> _resetTokens = {};

  // المستخدم المسجل دخوله حالياً
  UserModel? _currentUser;

  AuthRepositoryImpl({
    this.networkLatency = const Duration(milliseconds: 1200),
  }) {
    _seedDefaultData();
  }

  /// إدراج بيانات طالب افتراضية للاختبار والتقييم الفوري
  void _seedDefaultData() {
    _database.add(
      _InternalUserData(
        user: UserModel(
          id: 'STU-001',
          fullName: 'عبدالله أحمد السالم',
          academicId: '441012345',
          email: 'student@university.edu.sa',
          college: 'كلية علوم الحاسب والمعلومات',
          major: 'علوم الحاسب',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        password: 'Password123',
      ),
    );
  }

  @override
  UserModel? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Future<AuthResult> login(LoginRequest request) async {
    // محاكاة اتصال الخادم
    await Future.delayed(networkLatency);

    final identifier = request.identifier.trim().toLowerCase();
    final password = request.password;

    // البحث عن الطالب بواسطة الرقم الأكاديمي أو البريد الجامعي
    final matchIndex = _database.indexWhere((entry) =>
        entry.user.academicId == identifier ||
        entry.user.email.toLowerCase() == identifier);

    if (matchIndex == -1) {
      return AuthResult.failure(
        message: 'بيانات الاعتماد غير صحيحة، لم يتم العثور على طالب بهذا المعرف.',
      );
    }

    final student = _database[matchIndex];
    if (student.password != password) {
      return AuthResult.failure(
        message: 'كلمة المرور المدخلة غير صحيحة، يرجى المحاولة مرة أخرى.',
      );
    }

    _currentUser = student.user;
    return AuthResult.success(
      message: 'تم تسجيل الدخول بنجاح! أهلاً بك يا ${student.user.fullName}.',
      user: student.user,
    );
  }

  @override
  Future<AuthResult> register(RegisterRequest request) async {
    // محاكاة اتصال الخادم
    await Future.delayed(networkLatency);

    if (!request.agreedToTerms) {
      return AuthResult.failure(
        message: 'يجب الموافقة على اللوائح والشروط الأكاديمية لإتمام التسجيل.',
      );
    }

    final academicId = request.academicId.trim();
    final email = request.universityEmail.trim().toLowerCase();

    // التحقق من عدم تكرار الرقم الأكاديمي
    final duplicateAcademicId = _database.any(
      (entry) => entry.user.academicId == academicId,
    );
    if (duplicateAcademicId) {
      return AuthResult.failure(
        message: 'الرقم الأكاديمي مسجل مسبقاً في النظام.',
      );
    }

    // التحقق من عدم تكرار البريد الجامعي
    final duplicateEmail = _database.any(
      (entry) => entry.user.email.toLowerCase() == email,
    );
    if (duplicateEmail) {
      return AuthResult.failure(
        message: 'البريد الجامعي مسجل مسبقاً لحساب آخر.',
      );
    }

    // إنشاء وحفظ الطالب الجديد
    final newUser = UserModel(
      id: 'STU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      fullName: request.fullName.trim(),
      academicId: academicId,
      email: email,
      college: 'كلية علوم الحاسب والمعلومات',
      major: 'تقنية المعلومات',
      createdAt: DateTime.now(),
    );

    _database.add(_InternalUserData(
      user: newUser,
      password: request.password,
    ));

    return AuthResult.success(
      message: 'تم إنشاء الحساب الأكاديمي بنجاح! يمكنك الآن تسجيل الدخول.',
      user: newUser,
    );
  }

  @override
  Future<AuthResult> sendPasswordResetCode(ForgotPasswordRequest request) async {
    // محاكاة اتصال الخادم
    await Future.delayed(networkLatency);

    final identifier = request.identifier.trim().toLowerCase();

    // التحقق من وجود الحساب
    final studentExists = _database.any((entry) =>
        entry.user.academicId == identifier ||
        entry.user.email.toLowerCase() == identifier);

    if (!studentExists) {
      return AuthResult.failure(
        message: 'لم يتم العثور على أي حساب مسجل بهذا الرقم أو البريد.',
      );
    }

    // توليد رمز تحقق تجريبي (ثابت لتسهيل الاختبار: 123456)
    const mockOtp = '123456';
    _resetTokens[identifier] = mockOtp;

    return AuthResult.success(
      message: 'تم إرسال رمز التحقق بنجاح إلى وسيلة الاتصال المعتمدة. (الرمز التجريبي: 123456)',
    );
  }

  @override
  Future<AuthResult> resetPassword(ResetPasswordRequest request) async {
    // محاكاة اتصال الخادم
    await Future.delayed(networkLatency);

    final otp = request.otpCode.trim();
    final newPassword = request.newPassword;
    final identifier = request.identifier.trim().toLowerCase();

    // فحص صحة الرمز (نقبل 123456 أو الرمز المولد)
    final isValidOtp = otp == '123456' ||
        (identifier.isNotEmpty && _resetTokens[identifier] == otp);

    if (!isValidOtp) {
      return AuthResult.failure(
        message: 'رمز التحقق (OTP) غير صحيح أو منتهي الصلاحية. (جرّب الرمز الافتراضي: 123456)',
      );
    }

    if (request.newPassword != request.confirmPassword) {
      return AuthResult.failure(
        message: 'كلمتا المرور غير متطابقتين.',
      );
    }

    // إذا تم تحديد المعرف، نحدث كلمة المرور في قاعدة البيانات
    if (identifier.isNotEmpty) {
      final index = _database.indexWhere((entry) =>
          entry.user.academicId == identifier ||
          entry.user.email.toLowerCase() == identifier);
      if (index != -1) {
        final current = _database[index];
        _database[index] = _InternalUserData(
          user: current.user,
          password: newPassword,
        );
        _resetTokens.remove(identifier);
      }
    } else if (_database.isNotEmpty) {
      // تحديث آخر مستخدم أو المستخدم الافتراضي
      final current = _database.first;
      _database[0] = _InternalUserData(
        user: current.user,
        password: newPassword,
      );
    }

    return AuthResult.success(
      message: 'تم تحديث كلمة المرور بنجاح! يمكنك الآن تسجيل الدخول بها.',
    );
  }

  @override
  void logout() {
    _currentUser = null;
  }
}

/// فئة مساعدة داخلية لربط كائن المستخدم بكلمة المرور
class _InternalUserData {
  final UserModel user;
  final String password;

  _InternalUserData({
    required this.user,
    required this.password,
  });
}
