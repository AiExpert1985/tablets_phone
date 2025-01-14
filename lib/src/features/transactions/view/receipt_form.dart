import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/common/forms/date_picker.dart';
import 'package:tablets/src/common/values/constants.dart';
import 'package:tablets/src/common/functions/debug_print.dart';
import 'package:tablets/src/common/forms/drop_down_with_search.dart';
import 'package:tablets/src/common/forms/edit_box.dart';
import 'package:tablets/src/common/values/gaps.dart';
import 'package:tablets/src/common/widgets/custom_icons.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';
import 'package:tablets/src/features/transactions/controllers/customer_db_cache_provider.dart';
import 'package:tablets/src/features/transactions/controllers/form_data_container.dart';
import 'package:tablets/src/features/transactions/model/transaction.dart';
import 'package:tablets/src/features/transactions/repository/transaction_repository_provider.dart';

class ReceiptForm extends ConsumerWidget {
  const ReceiptForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formDataNotifier = ref.read(formDataContainerProvider.notifier);
    final totalTextEditingController = TextEditingController(text: '0');
    return MainFrame(
        child: Center(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                width: 400,
                child: Column(
                  children: [
                    VerticalGap.xl,
                    _buildScreenTitle(context, ref),
                    VerticalGap.xl,
                    _buildNameSelection(context, ref, formDataNotifier),
                    VerticalGap.xl,
                    _buildReceiptNumber(context, ref, formDataNotifier),
                    VerticalGap.xl,
                    _buildDate(context, ref, formDataNotifier),
                    VerticalGap.xl,
                    _buildReceivedAmount(
                        context, ref, formDataNotifier, totalTextEditingController),
                    VerticalGap.xl,
                    _buildDiscountAmount(
                        context, ref, formDataNotifier, totalTextEditingController),
                    VerticalGap.xl,
                    _buildReceiptTotalAmount(
                        context, ref, formDataNotifier, totalTextEditingController),
                    const Spacer(),
                    _buildButtons(context, ref, formDataNotifier),
                  ],
                ))));
  }

  Widget _buildScreenTitle(BuildContext context, WidgetRef ref) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: const Text(
          'قبض زبون',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        ));
  }

  Widget _buildNameSelection(
      BuildContext context, WidgetRef ref, MapStateNotifier formDataNotifier) {
    final salesmanCustomersDb = ref.read(salesmanCustomerDbCacheProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FormFieldLabel('الزبون'),
        HorizontalGap.xl,
        Expanded(
          child: DropDownWithSearch(
            onChangedFn: (customer) {
              formDataNotifier.addProperty('name', customer['name']);
            },
            dbCache: salesmanCustomersDb,
          ),
        ),
      ],
    );
  }

  Widget _buildReceivedAmount(BuildContext context, WidgetRef ref,
      MapStateNotifier formDataNotifier, TextEditingController totalEditingController) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const FormFieldLabel('التسديد'),
      HorizontalGap.xl,
      Expanded(
        child: FormInputField(
          onChangedFn: (value) {
            formDataNotifier.addProperty('subTotalAmount', value);
            final discount = formDataNotifier.data['discount'] ?? 0;
            final total = value + discount;
            formDataNotifier.addProperty('totalAmount', total);
            totalEditingController.text = total;
          },
          dataType: FieldDataType.num,
          name: 'subtotal',
        ),
      )
    ]);
  }

  Widget _buildDiscountAmount(BuildContext context, WidgetRef ref,
      MapStateNotifier formDataNotifier, TextEditingController totalEditingController) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const FormFieldLabel('الخصم'),
      HorizontalGap.xl,
      Expanded(
        child: FormInputField(
          onChangedFn: (value) {
            formDataNotifier.addProperty('discount', value);
            final subtotal = formDataNotifier.data['subTotalAmount'] ?? 0;
            final total = value + subtotal;
            formDataNotifier.addProperty('totalAmount', total);
            totalEditingController.text = total;
          },
          dataType: FieldDataType.num,
          name: 'discount',
        ),
      )
    ]);
  }

  Widget _buildReceiptNumber(
      BuildContext context, WidgetRef ref, MapStateNotifier formDataNotifier) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const FormFieldLabel('رقم الوصل'),
      HorizontalGap.xl,
      Expanded(
        child: FormInputField(
          onChangedFn: (value) {
            formDataNotifier.addProperty('number', value);
          },
          dataType: FieldDataType.num,
          name: 'number',
        ),
      )
    ]);
  }

  Widget _buildReceiptTotalAmount(BuildContext context, WidgetRef ref,
      MapStateNotifier formDataNotifier, TextEditingController totalEditingController) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const FormFieldLabel('المجموع'),
      HorizontalGap.xl,
      Expanded(
        child: FormInputField(
          controller: totalEditingController,
          onChangedFn: (value) {},
          dataType: FieldDataType.num,
          isReadOnly: true,
          name: 'total',
        ),
      )
    ]);
  }

  Widget _buildDate(BuildContext context, WidgetRef ref, MapStateNotifier formDataNotifier) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const FormFieldLabel('التاريخ'),
      HorizontalGap.xl,
      Expanded(
          child: FormDatePickerField(
              initialValue: DateTime.now(),
              onChangedFn: (date) {
                formDataNotifier.addProperty('date', date);
              },
              name: 'date'))
    ]);
  }

  Widget _buildButtons(BuildContext context, WidgetRef ref, MapStateNotifier formDataNotifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const ApproveIcon(),
            onPressed: () {
              tempPrint(formDataNotifier.data);
            },
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
        width: 90,
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
