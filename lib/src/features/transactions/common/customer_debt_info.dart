import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/common/functions/debug_print.dart';
import 'package:tablets/src/common/values/constants.dart';
import 'package:tablets/src/features/transactions/controllers/customer_db_cache_provider.dart';
import 'package:tablets/src/features/transactions/controllers/transaction_db_cache_provider.dart';

Map<String, dynamic> getCustomerDbetInfo(WidgetRef ref, String customerDbRef) {
  Map<String, dynamic> customerDebtInfo = {};
  final transactionsDbCache = ref.read(transactionDbCacheProvider.notifier);
  final transactions = transactionsDbCache.data;
  final customerDbCache = ref.read(salesmanCustomerDbCacheProvider.notifier);
  final customerData = customerDbCache.getItemByDbRef(customerDbRef);
  final initialDebt = customerData['initialCredit'];
  tempPrint('initialDebt = $initialDebt');
  double totalDebt = initialDebt;
  for (var transaction in transactions) {
    if (transaction['nameDbRef'] == null || transaction['nameDbRef'] != customerDbRef) continue;
    if (transaction['transactionType'] == TransactionType.customerInvoice.name) {
      tempPrint(transaction['name']);
      tempPrint(transaction['totalAmount']);
      totalDebt += transaction['totalAmount'] ?? 0;
    } else if (transaction['transactionType'] == TransactionType.customerReceipt.name ||
        transaction['transactionType'] == TransactionType.customerReturn.name) {
      tempPrint(TransactionType.customerReturn.name);
      tempPrint(transaction['totalAmount']);
      totalDebt -= transaction['totalAmount'] ?? 0;
    }
  }
  customerDebtInfo['totalDebt'] = totalDebt;
  return customerDebtInfo;
}
