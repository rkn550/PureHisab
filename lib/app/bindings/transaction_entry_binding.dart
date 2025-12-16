import 'package:get/get.dart';
import '../../controllers/transaction_entry_controller.dart';

class TransactionEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionEntryController>(() => TransactionEntryController());
  }
}
