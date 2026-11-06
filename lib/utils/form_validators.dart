/// كلاس يحتوي على دوال التحقق النقية (Pure Validation Functions)
/// المستخدمة في جميع نماذج النظام وفقاً لمعايير التكليف الفصلي
class FormValidators {
  // منع إنشاء كائن من هذا الكلاس لأنه يحتوي على دوال ثابتة فقط
  FormValidators._();

  // تعبير نمطي قياسي للبريد الإلكتروني
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  // تعبير نمطي للأرقام فقط
  static final RegExp _digitsOnlyRegExp = RegExp(r'^[0-9]+$');

  // تعبير نمطي لسياسة الأمان القوية لكلمة المرور (≥ 8 محارف + رقم + حرف كبير)
  static final RegExp _hasDigitRegExp = RegExp(r'[0-9]');
  static final RegExp _hasUppercaseRegExp = RegExp(r'[A-Z]');

  /// 1. التحقق من حقل المعرف الأكاديمي أو البريد (تسجيل الدخول / استعادة الحساب)
  /// - لا يمكن أن يكون فارغاً
  /// - صيغة صحيحة بطول لا يقل عن 5 خانات
  static String? validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال المعرف الأكاديمي أو البريد الجامعي';
    }
    final trimmed = value.trim();
    if (trimmed.length < 5) {
      return 'يجب ألا يقل المعرف أو البريد عن 5 خانات';
    }
    return null;
  }

  /// 2. التحقق من كلمة مرور تسجيل الدخول
  /// - غير فارغة
  /// - لا تقل عن 6 محارف
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'يجب أن تتكون كلمة المرور من 6 محارف على الأقل';
    }
    return null;
  }

  /// 3. التحقق من الاسم الكامل للطالب
  /// - غير فارغ
  /// - لا يقل عن 3 محارف
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال الاسم الكامل للطالب';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'يجب ألا يقل الاسم عن 3 محارف';
    }
    return null;
  }

  /// 4. التحقق من الرقم الأكاديمي
  /// - أرقام حصراً
  /// - يتراوح طوله بين 9 و 10 خانات
  static String? validateAcademicId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال الرقم الأكاديمي';
    }
    final trimmed = value.trim();
    if (!_digitsOnlyRegExp.hasMatch(trimmed)) {
      return 'يجب أن يحتوي الرقم الأكاديمي على أرقام فقط دون مسافات أو رموز';
    }
    if (trimmed.length < 9 || trimmed.length > 10) {
      return 'يجب أن يتكون الرقم الأكاديمي من 9 إلى 10 خانات رقمية';
    }
    return null;
  }

  /// 5. التحقق من البريد الجامعي
  /// - غير فارغ
  /// - مطابقة دقيقة لصيغة الـ Regex القياسية للبريد
  static String? validateUniversityEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال البريد الجامعي';
    }
    final trimmed = value.trim();
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'يرجى إدخال بريد إلكتروني بصيغة صحيحة (مثال: student@univ.edu.sa)';
    }
    return null;
  }

  /// 6. التحقق من كلمة المرور القوية (عند إنشاء الحساب وتحديث كلمة المرور)
  /// - سياسة أمان قوية:
  ///   - 8 محارف على الأقل
  ///   - رقم واحد على الأقل
  ///   - حرف كبير واحد على الأقل (Uppercase)
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 8) {
      return 'يجب أن لا تقل كلمة المرور عن 8 محارف';
    }
    if (!_hasDigitRegExp.hasMatch(value)) {
      return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل (0-9)';
    }
    if (!_hasUppercaseRegExp.hasMatch(value)) {
      return 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل (A-Z)';
    }
    return null;
  }

  /// 7. التحقق من مطابقة كلمة المرور مع حقل التأكيد
  /// - مطابقة تامة 100%
  static String? validateConfirmPassword(String? confirmValue, String? originalPassword) {
    if (confirmValue == null || confirmValue.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }
    if (confirmValue != originalPassword) {
      return 'كلمة المرور وتأكيدها غير متطابقين تماماً';
    }
    return null;
  }

  /// 8. التحقق من رمز التحقق (OTP)
  /// - مكون من 6 أرقام رقمية حصراً
  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال رمز التحقق (OTP)';
    }
    final trimmed = value.trim();
    if (!_digitsOnlyRegExp.hasMatch(trimmed)) {
      return 'رمز التحقق يجب أن يحتوي على أرقام فقط';
    }
    if (trimmed.length != 6) {
      return 'يجب أن يتكون رمز التحقق من 6 أرقام تماماً';
    }
    return null;
  }
}
