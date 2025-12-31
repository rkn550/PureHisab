import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:purehisab/app/bindings/initial_binding.dart';
import 'package:purehisab/app/flavour/flavour_manager.dart';

import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await _initFirebase();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  runApp(const MyApp());
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (e) {
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final flavour = FlavourManager.currentFlavour;
    return GetMaterialApp(
      title: flavour.appName,
      debugShowCheckedModeBanner: false,

      initialBinding: InitialBinding(),

      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        cardColor: AppColors.surface,
        dividerColor: AppColors.divider,

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
      ),
    );
  }
}
