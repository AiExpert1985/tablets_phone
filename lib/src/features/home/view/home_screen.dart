import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tablets/src/common/functions/dialog_delete_confirmation.dart';
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
    // load salesman Info
    ref.read(loadingProvider.notifier).setSalesmanInfo();
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
    final formDataNotifier = ref.read(formDataContainerProvider.notifier);

    return MainFrame(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNameSelection(context, formDataNotifier),
          if (formDataNotifier.data.containsKey('name')) ...[
            _buildDebtInfo(),
            _buildSelectionButtons(),
          ]
        ],
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTransactionSelectionButton(context, 'وصل قبض', AppRoute.receipt.name),
        HorizontalGap.xxl,
        _buildTransactionSelectionButton(context, 'قائمة بيع', AppRoute.items.name),
      ],
    );
  }

  Widget _buildNameSelection(BuildContext context, MapStateNotifier formDataNotifier) {
    final salesmanCustomersDb = ref.read(customerDbCacheProvider.notifier);
    final formDataNotifier = ref.read(formDataContainerProvider.notifier);
    final cartNotifier = ref.read(cartProvider.notifier);
    final dataLoader = ref.read(loadingProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: DropDownWithSearch(
            label: 'الزبون',
            initialValue: formDataNotifier.data['name'],
            onOpenFn: (p0) async {
              // I created opOpenFn for on purpose, which it to load customers when the are not previously loaded
              if (salesmanCustomersDb.data.isEmpty) {
                // we must await here, otherwise dropdown will open without items
                await dataLoader.loadCustomers();
              }
              if (cartNotifier.data.isNotEmpty && context.mounted) {
                // if there is open transaction, the we need to get user confirmation reseting
                return await resetTransactonConfirmation(context, ref);
              }
              return true;
            },
            onChangedFn: (customer) async {
              formDataNotifier.addProperty('name', customer['name']);
              formDataNotifier.addProperty('nameDbRef', customer['dbRef']);
              formDataNotifier.addProperty('sellingPriceType', customer['sellingPriceType']);
              // load transactions of selected customer, to be used for calculating debt
              ref.read(loadingProvider.notifier).loadTransactions();
              _setCustomerDebtVariables(customer);
            },
            dbCache: salesmanCustomersDb,
          ),
        ),
      ],
    );
  }

  // show confirmation box to user, if he selects yes, then formData and cart will be both cleared
// and true is returned, if no selected, no action taken, and returns false
  Future<bool> resetTransactonConfirmation(BuildContext context, WidgetRef ref) async {
    // first reset both formData, and cart
    final formDataNotifier = ref.read(formDataContainerProvider.notifier);
    final cartNotifier = ref.read(cartProvider.notifier);

    final formData = formDataNotifier.data;
    if (formData['name'] == null) {
      formDataNotifier.reset();
      cartNotifier.reset();
      return true;
    }
    // when back to home, all data is erased, user receives confirmation box
    final confirmation = await showDeleteConfirmationDialog(
      context: context,
      messagePart1: "",
      messagePart2: 'سوف يتم حذف قائمة ${formData['name']} ؟',
    );
    if (confirmation != null) {
      formDataNotifier.reset();
      cartNotifier.reset();
      return true;
    }
    return false;
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
            if (routeName == AppRoute.items.name) {
              // if we are preparing an invoice, load the items
              ref.read(loadingProvider.notifier).loadProducts();
            }
          }
        } else if (context.mounted) {
          failureUserMessage(context, 'يرجى اختيار اسم الزبون');
        }
      },
      child: Container(
        width: 115,
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
