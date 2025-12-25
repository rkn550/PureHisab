import 'package:get/get.dart';
import 'package:purehisab/data/services/transaction_repo.dart';
import '../../controllers/transaction_entry_controller.dart';

class TransactionEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TransactionRepository>(TransactionRepository());
    Get.lazyPut<TransactionEntryController>(() => TransactionEntryController());
  }
}
