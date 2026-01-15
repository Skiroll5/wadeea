// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'افتقاد القديسة رفقة';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get register => 'انشاء حساب';

  @override
  String get waitActivation => 'في انتظار تفعيل الحساب من المسئول';

  @override
  String get classes => 'الفصول';

  @override
  String get students => 'المخدومين';

  @override
  String get attendance => 'الغياب';
}
