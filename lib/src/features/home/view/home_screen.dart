import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tablets/src/common/functions/reset_transaction_confirmation.dart';
import 'package:tablets/src/common/functions/user_messages.dart';
import 'package:tablets/src/common/providers/data_loading_provider.dart';
import 'package:tablets/src/common/values/gaps.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';
import 'package:tablets/src/features/transactions/controllers/cart_provider.dart';
import 'package:tablets/src/features/transactions/controllers/customer_db_cache_provider.dart';
import 'package:tablets/src/features/transactions/controllers/form_data_container.dart';
import 'package:tablets/src/routers/go_router_provider.dart';
import 'package:tablets/src/features/transactions/common/common_widgets.dart';
import 'package:tablets/src/common/forms/drop_down_with_search.dart';
import 'package:tablets/src/features/transactions/common/customer_debt_info.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  num? totalDebt;
  num? dueDebt;
  dynamic latestReceiptDate;
  dynamic latestInvoiceDate;
  bool isValidUser = true;

  @override
  void initState() {
    super.initState();
    // in case we return to home after selecting a customer, then we want to display its debt info
    final formData = ref.read(formDataContainerProvider);
    final customerSelectedName = formData['name'];
    if (customerSelectedName != null) {
      final customerDbCache = ref.read(customerDbCacheProvider.notifier);
      final customer = customerDbCache.getItemByProperty('name', customerSelectedName);
      _setCustomerDebtVariables(customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(formDataContainerProvider);
    ref.watch(customerDbCacheProvider);
    final formDataNotifier = ref.read(formDataContainerProvider.notifier);
    final customerDbCache = ref.read(customerDbCacheProvider.notifier);

    return MainFrame(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (customerDbCache.data.isNotEmpty) _buildNameSelection(context, formDataNotifier),
              if (formDataNotifier.data.containsKey('name')) ...[
                _buildDebtInfo(),
                _buildSelectionButtons(),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDebtInfo() {
    Color infoBgColor = isValidUser ? itemsColor : Colors.red;
    return Column(
      children: [
        if (totalDebt != null)
          buildTotalAmount(context, dueDebt, 'الدين المستحق',
              bgColor: infoBgColor, fontColor: Colors.white),
        VerticalGap.l,
        if (totalDebt != null)
          buildTotalAmount(context, totalDebt, 'الدين الكلي',
              bgColor: infoBgColor, fontColor: Colors.white),
        VerticalGap.l,
        if (latestReceiptDate != null)
          buildTotalAmount(context, latestInvoiceDate, 'اخر قائمة',
              bgColor: infoBgColor, fontColor: Colors.white),
        VerticalGap.l,
        if (latestInvoiceDate != null)
          buildTotalAmount(context, latestReceiptDate, 'اخر تسديد',
              bgColor: infoBgColor, fontColor: Colors.white),
      ],
    );
  }

  Widget _buildSelectionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTransactionSelectionButton(context, 'وصل قبض', AppRoute.receipt.name),
        _buildTransactionSelectionButton(context, 'قائمة بيع', AppRoute.items.name),
      ],
    );
  }

  Widget _buildNameSelection(BuildContext context, MapStateNotifier formDataNotifier) {
    final salesmanCustomersDb = ref.read(customerDbCacheProvider.notifier);
    final formDataNotifier = ref.read(formDataContainerProvider.notifier);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // const FormFieldLabel('الزبون'),
        // HorizontalGap.l,
        Expanded(
          child: DropDownWithSearch(
            label: 'الزبون',
            initialValue: formDataNotifier.data['name'],
            onChangedFn: (customer) async {
              if (cartNotifier.data.isNotEmpty) {
                // if there is open transaction, the we need to get user confirmation reseting
                bool userConfiramtion = await resetTransactonConfirmation(context, ref);
                if (!userConfiramtion) {
                  setState(() {}); // to reload screen which restore previous name
                  return;
                }
              }
              formDataNotifier.addProperty('name', customer['name']);
              formDataNotifier.addProperty('nameDbRef', customer['dbRef']);
              formDataNotifier.addProperty('sellingPriceType', customer['sellingPriceType']);
              // load transactions of selected customer, to be used for calculating debt
              await ref.read(loadingProvider.notifier).setTranasctionsProvider();
              _setCustomerDebtVariables(customer);
            },
            dbCache: salesmanCustomersDb,
          ),
        ),
        // HorizontalGap.l,
        // _buildLoadCustomersButton(),
      ],
    );
  }

  void _setCustomerDebtVariables(Map<String, dynamic> customer) {
    // now process customer data, and debt data
    num paymentDurationLimit = customer['paymentDurationLimit'];
    // now calculating debt
    final customerDebtInfo = getCustomerDebtInfo(ref, customer['dbRef'], paymentDurationLimit);
    // set customer debt info
    totalDebt = customerDebtInfo['totalDebt'];
    dueDebt = customerDebtInfo['dueDebt'];
    latestReceiptDate = customerDebtInfo['lastReceiptDate'] ?? 'لا يوجد';
    latestInvoiceDate = customerDebtInfo['latestInvoiceDate'] ?? 'لا يوجد';
    _validateCustomer(paymentDurationLimit, customer['creditLimit']);
  }

// customer is invalid, if he has debt, and exceeded max number of days (debt limit)
  void _validateCustomer(num paymentDurationLimit, num creditLimit) {
    if (totalDebt == null || dueDebt == null) return;
    // if customer has zero debt, then he is a valid suer
    if (totalDebt! <= 0) {
      isValidUser = true;
      return;
    }
    if (totalDebt! >= creditLimit) {
      isValidUser = false;
      return;
    }
    if (dueDebt! > 0) {
      isValidUser = false;
      return;
    }
  }

  Widget _buildTransactionSelectionButton(BuildContext context, String label, String routeName) {
    final formDataNotifier = ref.read(formDataContainerProvider.notifier);

    return InkWell(
      onTap: () async {
        if (formDataNotifier.data.containsKey('name') &
            formDataNotifier.data.containsKey('nameDbRef')) {
          if (context.mounted) {
            GoRouter.of(context).pushNamed(routeName);
          }
        } else if (context.mounted) {
          failureUserMessage(context, 'يرجى اختيار اسم الزبون');
        }
      },
      child: Container(
        width: 140,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          color: itemsColor,
        ),
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
