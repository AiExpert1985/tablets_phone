import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/generated/l10n.dart';
import 'package:tablets/src/common/drop_down_with_search.dart';
import 'package:tablets/src/common/main_frame.dart';
import 'package:tablets/src/features/transactions/controllers/customer_db_cache_provider.dart';
import 'package:tablets/src/features/transactions/model/transaction.dart';
import 'package:tablets/src/features/transactions/repository/transaction_repository_provider.dart';

class ReceiptForm extends ConsumerWidget {
  const ReceiptForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainFrame(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [buildCustomerNameSelection(context, ref)],
    ));
  }
}

Widget buildCustomerNameSelection(BuildContext context, WidgetRef ref) {
  final salesmanCustomersDb = ref.read(salesmanCustomerDbCacheProvider.notifier);

  return Center(
    child: Container(
      padding: const EdgeInsets.all(12.0),
      width: 300,
      child: DropDownWithSearch(
        onChangedFn: (customer) {},
        dbCache: salesmanCustomersDb,
        label: S.of(context).customer,
      ),
    ),
  );
}

void addTransactionToDb(WidgetRef ref, Transaction transaction) {
  final repository = ref.read(transactionRepositoryProvider);
  repository.addItem(transaction);
}



// Transaction getTestTransaction() {
//   return Transaction(
//       dbRef: 'sdfsd',
//       name: 'test pending transaction',
//       imageUrls: ['xfdsfsdf'],
//       number: 3243456,
//       date: DateTime.now(),
//       currency: 'sdfasdf',
//       transactionType: 'sfsdfs',
//       totalAmount: 34534534,
//       transactionTotalProfit: 354,
//       isPrinted: false);
// }
