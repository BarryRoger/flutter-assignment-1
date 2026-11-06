import 'package:flutter_test/flutter_test.dart';
import 'package:student_auth_system/utils/form_validators.dart';

void main() {
  group('FormValidators Unit Tests - اختبارات دوال التحقق من النماذج', () {
    test('1. validateIdentifier - التحقق من المعرف أو البريد', () {
      expect(FormValidators.validateIdentifier(null), isNotNull);
      expect(FormValidators.validateIdentifier(''), isNotNull);
      expect(FormValidators.validateIdentifier('1234'), isNotNull); // أقل من 5
      expect(FormValidators.validateIdentifier('12345'), isNull);   // 5 خانات
      expect(FormValidators.validateIdentifier('student@univ.edu'), isNull);
    });

    test('2. validateLoginPassword - التحقق من كلمة مرور تسجيل الدخول', () {
      expect(FormValidators.validateLoginPassword(null), isNotNull);
      expect(FormValidators.validateLoginPassword(''), isNotNull);
      expect(FormValidators.validateLoginPassword('12345'), isNotNull); // أقل من 6
      expect(FormValidators.validateLoginPassword('123456'), isNull);   // 6 محارف
    });

    test('3. validateFullName - التحقق من الاسم الكامل', () {
      expect(FormValidators.validateFullName(null), isNotNull);
      expect(FormValidators.validateFullName(''), isNotNull);
      expect(FormValidators.validateFullName('علي'), isNull); // 3 محارف
      expect(FormValidators.validateFullName('عبدالله أحمد'), isNull);
    });

    test('4. validateAcademicId - التحقق من الرقم الأكاديمي (أرقام حصراً، 9-10 خانات)', () {
      expect(FormValidators.validateAcademicId(null), isNotNull);
      expect(FormValidators.validateAcademicId(''), isNotNull);
      expect(FormValidators.validateAcademicId('44101234'), isNotNull); // 8 أرقام (أقل من 9)
      expect(FormValidators.validateAcademicId('44101234567'), isNotNull); // 11 رقم (أكثر من 10)
      expect(FormValidators.validateAcademicId('44101234a'), isNotNull); // يحتوي حرف
      expect(FormValidators.validateAcademicId('441012345'), isNull); // 9 أرقام صحيح
      expect(FormValidators.validateAcademicId('4410123456'), isNull); // 10 أرقام صحيح
    });

    test('5. validateUniversityEmail - التحقق من البريد الجامعي بالـ Regex القياسي', () {
      expect(FormValidators.validateUniversityEmail(null), isNotNull);
      expect(FormValidators.validateUniversityEmail(''), isNotNull);
      expect(FormValidators.validateUniversityEmail('invalid_email'), isNotNull);
      expect(FormValidators.validateUniversityEmail('student@'), isNotNull);
      expect(FormValidators.validateUniversityEmail('student@univ.edu.sa'), isNull);
    });

    test('6. validateStrongPassword - سياسة الأمان القوية (≥8 محارف + رقم + حرف كبير)', () {
      expect(FormValidators.validateStrongPassword(null), isNotNull);
      expect(FormValidators.validateStrongPassword('short'), isNotNull);
      expect(FormValidators.validateStrongPassword('lowercase123'), isNotNull); // بدون حرف كبير
      expect(FormValidators.validateStrongPassword('UPPERCASEONLY'), isNotNull); // بدون رقم
      expect(FormValidators.validateStrongPassword('Pass1'), isNotNull); // أقل من 8 محارف
      expect(FormValidators.validateStrongPassword('Password123'), isNull); // صحيح تماماً
    });

    test('7. validateConfirmPassword - مطابقة كلمة المرور 100%', () {
      expect(FormValidators.validateConfirmPassword('Password123', 'Password123'), isNull);
      expect(FormValidators.validateConfirmPassword('Mismatch123', 'Password123'), isNotNull);
    });

    test('8. validateOtp - رمز التحقق 6 أرقام حصراً', () {
      expect(FormValidators.validateOtp(null), isNotNull);
      expect(FormValidators.validateOtp('12345'), isNotNull); // 5 أرقام
      expect(FormValidators.validateOtp('1234567'), isNotNull); // 7 أرقام
      expect(FormValidators.validateOtp('12345a'), isNotNull); // يحتوي حرف
      expect(FormValidators.validateOtp('123456'), isNull); // 6 أرقام صحيح
    });
  });
}
