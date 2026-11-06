import 'package:flutter/material.dart';
import 'controllers/auth_controller.dart';
import 'controllers/auth_scope.dart';
import 'repositories/auth_repository_impl.dart';
import 'views/auth/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة المستودع (Repository) مع محاكاة الاتصال بالشبكة
  final authRepository = AuthRepositoryImpl();

  // 2. حقن المستودع داخل المتحكم (Dependency Injection into Controller)
  final authController = AuthController(repository: authRepository);

  runApp(
    StudentAuthApp(controller: authController),
  );
}

/// تطبيق نظام المصادقة الطلابي
class StudentAuthApp extends StatelessWidget {
  final AuthController controller;

  const StudentAuthApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // توفير المتحكم عبر شجرة العناصر باستخدام AuthScope (مبني على InheritedNotifier الأصلي)
    return AuthScope(
      controller: controller,
      child: MaterialApp(
        title: 'نظام المصادقة الطلابي الأكاديمي',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Segoe UI', // خط نظام قياسي مدعوم افتراضياً
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
            primary: const Color(0xFF1E3A8A),
            secondary: const Color(0xFF2563EB),
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // دعم التوجيه من اليمين إلى اليسار (RTL) للغة العربية الأصيلة
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const LoginPage(),
      ),
    );
  }
}
