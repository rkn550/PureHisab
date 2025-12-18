import 'package:get/get.dart';
import 'package:purehisab/app/bindings/create_account_binding.dart';
import 'package:purehisab/screens/login_screen.dart';
import 'package:purehisab/screens/otp_screen.dart';
import 'package:purehisab/screens/splash_screen.dart';
import 'package:purehisab/screens/main_navigation_screen.dart';
import 'package:purehisab/screens/create_account_screen.dart';
import 'package:purehisab/screens/add_party_screen.dart';
import 'package:purehisab/screens/contact_list_screen.dart';
import 'package:purehisab/screens/customer_detail_screen.dart';
import 'package:purehisab/screens/transaction_entry_screen.dart';
import 'package:purehisab/screens/profile_screen.dart';
import 'package:purehisab/screens/business_profile_screen.dart';
import '../bindings/splash_binding.dart';
import '../bindings/login_binding.dart';
import '../bindings/otp_binding.dart';
import '../bindings/navigation_binding.dart';
import '../bindings/add_party_binding.dart';
import '../bindings/contact_list_binding.dart';
import '../bindings/customer_detail_binding.dart';
import '../bindings/transaction_entry_binding.dart';
import '../bindings/profile_binding.dart';
import '../bindings/business_profile_binding.dart';

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
      page: () => const LogInScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.otp,
      page: () => const OtpScreen(),
      binding: OtpBinding(),
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
      arguments: {'mode': 'create'},
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
  ];
}

class Routes {
  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';
  static const home = '/home';
  static const createAccount = '/create-account';
  static const addParty = '/add-party';
  static const contactList = '/contact-list';
  static const customerDetail = '/customer-detail';
  static const transactionEntry = '/transaction-entry';
  static const profile = '/profile';
  static const businessProfile = '/business-profile';
}
