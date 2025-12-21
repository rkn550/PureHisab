import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purehisab/firebase_options.dart';
import 'package:purehisab/controllers/app_lifecycle_controller.dart';
import 'package:purehisab/data/services/app_lock_service.dart';
import 'package:purehisab/data/services/auth_service.dart';
import 'package:purehisab/data/services/business_repo.dart';
import 'package:purehisab/data/services/party_repo.dart';
import 'package:purehisab/data/services/transaction_repo.dart';
import 'package:purehisab/data/services/reminder_notification_service.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  _initServices();
  runApp(const MyApp());
}

void _initServices() {
  Get.put(AppLifecycleController());
  Get.put(AppLockService(), permanent: true);
  Get.put(AuthService(), permanent: true);
  Get.put(BusinessRepository(), permanent: true);
  Get.put(PartyRepository(), permanent: true);
  Get.put(TransactionRepository(), permanent: true);
  Get.put(ReminderNotificationService(), permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PureHisab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.surface,
        dividerColor: AppColors.divider,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: .circular(12),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),
      ),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
