import 'package:get/get.dart';
import 'package:purehisab/app/bindings/parties_details_binding.dart';
import '../bindings/splash_binding.dart';
import '../bindings/login_email_binding.dart';
import '../bindings/forgot_password_binding.dart';
import '../bindings/signup_binding.dart';
import '../bindings/navigation_binding.dart';
import '../bindings/create_business_binding.dart';
import '../bindings/add_party_binding.dart';
import '../bindings/contact_list_binding.dart';
import '../bindings/transaction_entry_binding.dart';
import '../bindings/parties_profile_binding.dart';
import '../bindings/business_profile_binding.dart';
import '../bindings/app_lock_binding.dart';
import '../bindings/about_binding.dart';
import '../bindings/privacy_policy_binding.dart';
import '../bindings/terms_conditions_binding.dart';
import '../../screens/splash_screen.dart';
import '../../screens/login_email_screen.dart';
import '../../screens/forgot_password_screen.dart';
import '../../screens/signup_screen.dart';
import '../../screens/main_navigation_screen.dart';
import '../../screens/create_business_screen.dart';
import '../../screens/add_party_screen.dart';
import '../../screens/contact_list_screen.dart';
import '../../screens/parties_detail_screen.dart';
import '../../screens/transaction_entry_screen.dart';
import '../../screens/parties_profile_screen.dart';
import '../../screens/business_profile_screen.dart';
import '../../screens/app_lock_screen.dart';
import '../../screens/about_screen.dart';
import '../../screens/privacy_policy_screen.dart';
import '../../screens/terms_conditions_screen.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = <GetPage>[
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),

    GetPage(
      name: Routes.login,
      page: () => const LoginEmailScreen(),
      binding: LoginEmailBinding(),
    ),

    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),

    GetPage(
      name: Routes.signup,
      page: () => const SignupScreen(),
      binding: SignupBinding(),
    ),

    GetPage(
      name: Routes.home,
      page: () => const MainNavigationScreen(),
      binding: NavigationBinding(),
    ),

    GetPage(
      name: Routes.createBusiness,
      page: () => const CreateBusinessScreen(),
      binding: CreateBusinessBinding(),
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
      name: Routes.partiesDetails,
      page: () => const PartiesDetailScreen(),
      binding: PartiesDetailsBinding(),
    ),

    GetPage(
      name: Routes.transactionEntry,
      page: () => const TransactionEntryScreen(),
      binding: TransactionEntryBinding(),
    ),

    GetPage(
      name: Routes.partiesProfile,
      page: () => const PartiesProfileScreen(),
      binding: PartiesProfileBinding(),
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
  static const forgotPassword = '/forgot-password';
  static const signup = '/signup';
  static const home = '/home';
  static const createBusiness = '/create-business';
  static const addParty = '/add-party';
  static const contactList = '/contact-list';
  static const partiesDetails = '/parties-details';
  static const transactionEntry = '/transaction-entry';
  static const partiesProfile = '/parties-profile';
  static const businessProfile = '/business-profile';
  static const appLock = '/app-lock';
  static const about = '/about';
  static const privacyPolicy = '/privacy-policy';
  static const termsConditions = '/terms-conditions';
}
