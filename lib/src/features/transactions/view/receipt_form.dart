import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/generated/l10n.dart';
import 'package:tablets/src/common/forms/date_picker.dart';
import 'package:tablets/src/common/values/constants.dart';
import 'package:tablets/src/common/functions/debug_print.dart';
import 'package:tablets/src/common/forms/drop_down_with_search.dart';
import 'package:tablets/src/common/forms/edit_box.dart';
import 'package:tablets/src/common/values/gaps.dart';
import 'package:tablets/src/common/widgets/custom_icons.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';
import 'package:tablets/src/features/transactions/controllers/customer_db_cache_provider.dart';
import 'package:tablets/src/features/transactions/model/transaction.dart';
import 'package:tablets/src/features/transactions/repository/transaction_repository_provider.dart';

class ReceiptForm extends ConsumerWidget {
  const ReceiptForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainFrame(
        child: Center(
            child: Container(
                padding: const EdgeInsets.all(12.0),
                width: 500,
                child: Column(
                  children: [
                    _buildScreenTitle(context, ref),
                    VerticalGap.xl,
                    _buildNameSelection(context, ref),
                    VerticalGap.xl,
                    _buildReceiptNumber(context, ref),
                    VerticalGap.xl,
                    _buildDate(context, ref),
                    VerticalGap.xl,
                    _buildReceivedAmount(context, ref),
                    VerticalGap.xl,
                    _buildDiscountAmount(context, ref),
                    VerticalGap.xl,
                    _buildReceiptTotalAmount(context, ref),
                    const Spacer(),
                    _buildButtons(context, ref),
                  ],
                ))));
  }

  Widget _buildScreenTitle(BuildContext context, WidgetRef ref) {
    return Container(
        padding: const EdgeInsets.all(40),
        child: const Text(
          'قبض زبون',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        ));
  }

  Widget _buildNameSelection(BuildContext context, WidgetRef ref) {
    final salesmanCustomersDb = ref.read(salesmanCustomerDbCacheProvider.notifier);

    return DropDownWithSearch(
      onChangedFn: (customer) {},
      dbCache: salesmanCustomersDb,
      label: S.of(context).customer,
    );
  }

  Widget _buildReceivedAmount(BuildContext context, WidgetRef ref) {
    return FormInputField(
        onChangedFn: (value) {
          tempPrint(value);
        },
        dataType: FieldDataType.num,
        name: 'subtotal');
  }

  Widget _buildDiscountAmount(BuildContext context, WidgetRef ref) {
    return FormInputField(
        onChangedFn: (value) {
          tempPrint(value);
        },
        dataType: FieldDataType.num,
        name: 'discount');
  }

  Widget _buildReceiptNumber(BuildContext context, WidgetRef ref) {
    return FormInputField(
        onChangedFn: (value) {
          tempPrint(value);
        },
        dataType: FieldDataType.num,
        name: 'number');
  }

  Widget _buildReceiptTotalAmount(BuildContext context, WidgetRef ref) {
    return FormInputField(
        onChangedFn: (value) {
          tempPrint(value);
        },
        dataType: FieldDataType.num,
        isReadOnly: true,
        name: 'total');
  }

  Widget _buildDate(BuildContext context, WidgetRef ref) {
    return FormDatePickerField(
        onChangedFn: (date) {
          tempPrint(date);
        },
        name: 'date');
  }

  Widget _buildButtons(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const ApproveIcon(),
            onPressed: () {},
          ),
          IconButton(
            icon: const CancelIcon(),
            onPressed: () => {},
          ),
        ],
      ),
    );
  }
}

void addTransactionToDb(WidgetRef ref, Transaction transaction) {
  final repository = ref.read(transactionRepositoryProvider);
  repository.addItem(transaction);
}

class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(2),
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black)));
  }
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
