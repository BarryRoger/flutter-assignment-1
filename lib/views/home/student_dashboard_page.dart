import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/auth_scope.dart';
import '../auth/login_page.dart';

/// شاشة لوحة تحكم الطالب (StudentDashboardPage)
/// تظهر عند نجاح عملية تسجيل الدخول وتستعرض بيانات الطالب الأكاديمية
class StudentDashboardPage extends StatelessWidget {
  final AuthController? controller;

  const StudentDashboardPage({super.key, this.controller});

  AuthController _getController(BuildContext context) {
    return controller ?? AuthScope.of(context);
  }

  void _handleLogout(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من البوابة الأكاديمية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              authController.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginPage(controller: authController),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('تأكيد الخروج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = _getController(context);
    final user = authController.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'بوابة الطالب الأكاديمية',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'تسجيل الخروج',
            onPressed: () => _handleLogout(context, authController),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بطاقة الهوية الأكاديمية للطالب
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF93C5FD), width: 2),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 54,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user?.fullName ?? 'طالب جامعي',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'طالب منتظم - مقيّد',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.badge_outlined,
                        title: 'الرقم الأكاديمي',
                        value: user?.academicId ?? 'غير متوفر',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.alternate_email_rounded,
                        title: 'البريد الجامعي',
                        value: user?.email ?? 'غير متوفر',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.school_outlined,
                        title: 'الكلية والبرنامج',
                        value: '${user?.college} - ${user?.major}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ملخص حالة المصادقة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_user_rounded, color: Color(0xFF1E40AF), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'حالة جلسة المصادقة الحالية',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'خيار تذكرني: ${authController.rememberMe ? "مفعّل (تم حفظ الجلسة)" : "غير مفعّل"}\n'
                      'الهندسة المعمارية: نمط MVC المعزز بنمط المستودع (Repository Pattern)\n'
                      'إدارة الحالة: ChangeNotifier الأصلية من Flutter بدون حزم خارجية.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF334155),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // زر تسجيل الخروج
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogout(context, authController),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'تسجيل الخروج من النظام',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1E3A8A)),
        const SizedBox(width: 10),
        Text(
          '$title: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
