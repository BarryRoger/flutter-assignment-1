import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_auth_system/controllers/auth_controller.dart';
import 'package:student_auth_system/main.dart';
import 'package:student_auth_system/repositories/auth_repository_impl.dart';

void main() {
  testWidgets('StudentAuthApp smoke and UI render test', (WidgetTester tester) async {
    final repository = AuthRepositoryImpl(networkLatency: Duration.zero);
    final controller = AuthController(repository: repository);

    await tester.pumpWidget(StudentAuthApp(controller: controller));
    await tester.pumpAndSettle();

    // التحقق من ظهور العناصر الأساسية لشاشة تسجيل الدخول
    expect(find.text('بوابة الخدمات الأكاديمية والطلابية'), findsOneWidget);
    expect(find.text('المعرف الأكاديمي أو البريد الجامعي'), findsOneWidget);
    expect(find.text('كلمة المرور'), findsOneWidget);
    expect(find.text('تذكرني'), findsOneWidget);
    expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('إنشاء حساب جديد'), findsOneWidget);

    // التحقق من وجود حقول الإدخال والأيقونات
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(Checkbox), findsOneWidget);
  });
}
