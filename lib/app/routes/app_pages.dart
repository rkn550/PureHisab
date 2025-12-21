import 'package:get/get.dart';
import 'package:purehisab/app/bindings/create_account_binding.dart';
import 'package:purehisab/app/bindings/forgot_password_binding.dart';
import 'package:purehisab/app/bindings/login_email_binding.dart';
import 'package:purehisab/app/bindings/signup_binding.dart';
import 'package:purehisab/screens/login_email_screen.dart';
import 'package:purehisab/screens/forgot_password_screen.dart';
import 'package:purehisab/screens/signup_screen.dart';
import 'package:purehisab/screens/splash_screen.dart';
import 'package:purehisab/screens/main_navigation_screen.dart';
import 'package:purehisab/screens/create_account_screen.dart';
import 'package:purehisab/screens/add_party_screen.dart';
import 'package:purehisab/screens/contact_list_screen.dart';
import 'package:purehisab/screens/customer_detail_screen.dart';
import 'package:purehisab/screens/transaction_entry_screen.dart';
import 'package:purehisab/screens/profile_screen.dart';
import 'package:purehisab/screens/business_profile_screen.dart';
import 'package:purehisab/screens/app_lock_screen.dart';
import 'package:purehisab/screens/about_screen.dart';
import 'package:purehisab/screens/privacy_policy_screen.dart';
import 'package:purehisab/screens/terms_conditions_screen.dart';
import '../bindings/splash_binding.dart';
import '../bindings/navigation_binding.dart';
import '../bindings/add_party_binding.dart';
import '../bindings/contact_list_binding.dart';
import '../bindings/customer_detail_binding.dart';
import '../bindings/transaction_entry_binding.dart';
import '../bindings/profile_binding.dart';
import '../bindings/business_profile_binding.dart';
import '../bindings/app_lock_binding.dart';
import '../bindings/about_binding.dart';
import '../bindings/privacy_policy_binding.dart';
import '../bindings/terms_conditions_binding.dart';

class AppPages {
  static const initial = Routes.splash;
  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      // page: () => const LogInScreen(),
      page: () => const LoginEmailScreen(),
      binding: LoginEmailBinding(),
    ),
    // GetPage(
    //   name: Routes.otp,
    //   page: () => const OtpScreen(),
    //   binding: OtpBinding(),
    // ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () {
        final args = Get.arguments;
        if (args != null && args is Map<String, dynamic>) {
          return MainNavigationScreen(
            initialTab: args['initialTab'] as int?,
            arguments: args as Map<String, dynamic>?,
          );
        }
        return const MainNavigationScreen();
      },
      binding: NavigationBinding(),
    ),
    GetPage(
      name: Routes.createAccount,
      page: () => const CreateAccountScreen(),
      binding: CreateAccountBinding(),
    ),
    GetPage(
      name: Routes.signup,
      page: () => const SignupScreen(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: Routes.addParty,
      page: () => const AddPartyScreen(),
      binding: AddPartyBinding(),
    ),
    GetPage(
      name: Routes.contactList,
      page: () => const ContactListScreen(),
      binding: ContactListBinding(),
    ),
    GetPage(
      name: Routes.customerDetail,
      page: () => const CustomerDetailScreen(),
      binding: CustomerDetailBinding(),
    ),
    GetPage(
      name: Routes.transactionEntry,
      page: () => const TransactionEntryScreen(),
      binding: TransactionEntryBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.businessProfile,
      page: () => const BusinessProfileScreen(),
      binding: BusinessProfileBinding(),
    ),
    GetPage(
      name: Routes.appLock,
      page: () => const AppLockScreen(),
      binding: AppLockBinding(),
    ),
    GetPage(
      name: Routes.about,
      page: () => const AboutScreen(),
      binding: AboutBinding(),
    ),
    GetPage(
      name: Routes.privacyPolicy,
      page: () => const PrivacyPolicyScreen(),
      binding: PrivacyPolicyBinding(),
    ),
    GetPage(
      name: Routes.termsConditions,
      page: () => const TermsConditionsScreen(),
      binding: TermsConditionsBinding(),
    ),
  ];
}

class Routes {
  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';
  static const forgotPassword = '/forgot-password';
  static const signup = '/signup';
  static const home = '/home';
  static const createAccount = '/create-account';
  static const addParty = '/add-party';
  static const contactList = '/contact-list';
  static const customerDetail = '/customer-detail';
  static const transactionEntry = '/transaction-entry';
  static const profile = '/profile';
  static const businessProfile = '/business-profile';
  static const appLock = '/app-lock';
  static const about = '/about';
  static const privacyPolicy = '/privacy-policy';
  static const termsConditions = '/terms-conditions';
}
