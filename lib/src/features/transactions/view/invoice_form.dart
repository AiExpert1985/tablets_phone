import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tablets/src/common/forms/date_picker.dart';
import 'package:tablets/src/common/forms/drop_down_with_search.dart';
import 'package:tablets/src/common/functions/user_messages.dart';
import 'package:tablets/src/common/values/gaps.dart';
import 'package:tablets/src/common/widgets/custom_icons.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';
import 'package:tablets/src/features/transactions/controllers/customer_db_cache_provider.dart';
import 'package:tablets/src/features/transactions/controllers/form_data_container.dart';
import 'package:tablets/src/features/transactions/common/common_widgets.dart';
import 'package:tablets/src/routers/go_router_provider.dart';

class InvoiceForm extends ConsumerStatefulWidget {
  const InvoiceForm({super.key});

  @override
  ConsumerState<InvoiceForm> createState() => _ReceiptFormState();
}

class _ReceiptFormState extends ConsumerState<InvoiceForm> {
  double total = 0.0; // Initialize total to 0

  @override
  Widget build(BuildContext context) {
    final formDataNotifier = ref.read(formDataContainerProvider.notifier);
    ref.watch(formDataContainerProvider);

    return MainFrame(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          width: 400,
          child: Column(
            children: [
              VerticalGap.xl,
              _buildScreenTitle(context),
              VerticalGap.xl,
              _buildNameSelection(context, formDataNotifier),
              VerticalGap.xl,
              _buildDate(context, formDataNotifier),
              const Spacer(),
              _buildButtons(context, formDataNotifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreenTitle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: const Text(
        'قائمة زبون',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }

  Widget _buildNameSelection(BuildContext context, MapStateNotifier formDataNotifier) {
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
              formDataNotifier.addProperty('nameDbRef', customer['dbRef']);
              formDataNotifier.addProperty('sellingPriceType', customer['sellingPriceType']);
            },
            dbCache: salesmanCustomersDb,
          ),
        ),
      ],
    );
  }

  Widget _buildDate(BuildContext context, MapStateNotifier formDataNotifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FormFieldLabel('التاريخ'),
        HorizontalGap.xl,
        Expanded(
          child: FormDatePickerField(
            onChangedFn: (date) {
              formDataNotifier.addProperty('date', date);
            },
            name: 'date',
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context, MapStateNotifier formDataNotifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const AddItems(),
            onPressed: () {
              if (formDataNotifier.data.containsKey('date') &
                  formDataNotifier.data.containsKey('name') &
                  formDataNotifier.data.containsKey('nameDbRef')) {
                GoRouter.of(context).pushNamed(AppRoute.items.name);
              } else {
                failureUserMessage(context, 'يرجى ملئ جميع الحقول بصورة صحيحة');
              }
            },
          ),
          IconButton(
            icon: const CancelIcon(),
            onPressed: () {
              formDataNotifier.reset();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
