import 'package:flutter/widgets.dart';
import 'auth_controller.dart';

/// توفير كائن المتحكم [AuthController] عبر شجرة الواجهات
/// بالاعتماد الحصري على فئة فلاتر الأصلية [InheritedNotifier] بدون حزم خارجية
class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  /// قراءة المتحكم مع إعادة بناء الواجهة تلقائياً عند تغيير الحالات
  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'لم يتم العثور على AuthScope في سياق الواجهة');
    return scope!.notifier!;
  }
}
