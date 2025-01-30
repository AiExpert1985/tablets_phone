import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tablets/src/common/functions/loading_data.dart';
import 'package:tablets/src/common/functions/user_messages.dart';
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
  bool _isLoading = false; // Loading state

  @override
  Widget build(BuildContext context) {
    ref.watch(formDataContainerProvider);
    final formDataNotifier = ref.read(formDataContainerProvider.notifier);

    return MainFrame(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNameSelection(context, formDataNotifier),
              if (formDataNotifier.data.containsKey('name')) _buildDebtInfo(),
              if (formDataNotifier.data.containsKey('name')) _buildSelectionButtons(),
              if (_isLoading) _buildLoadingIndicator()
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
          buildTotalAmount(context, dueDebt, 'الدين المستحق', bgColor: infoBgColor),
        VerticalGap.l,
        if (totalDebt != null)
          buildTotalAmount(context, totalDebt, 'الدين الكلي', bgColor: infoBgColor),
        VerticalGap.l,
        if (latestReceiptDate != null)
          buildTotalAmount(context, latestInvoiceDate, 'اخر قائمة', bgColor: infoBgColor),
        VerticalGap.l,
        if (latestInvoiceDate != null)
          buildTotalAmount(context, latestReceiptDate, 'اخر تسديد', bgColor: infoBgColor),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Column(children: [
      CircularProgressIndicator(),
      VerticalGap.xl,
      Text('مزامنة البيانات', style: TextStyle(color: Colors.white, fontSize: 14))
    ]);
  }

  Widget _buildSelectionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTransactionSelectionButton(context, ref, 'وصل قبض', AppRoute.receipt.name),
        const SizedBox(width: 50),
        _buildTransactionSelectionButton(context, ref, 'قائمة بيع', AppRoute.items.name,
            loadProducts: true),
      ],
    );
  }

  Widget _buildNameSelection(BuildContext context, MapStateNotifier formDataNotifier) {
    final salesmanCustomersDb = ref.read(salesmanCustomerDbCacheProvider.notifier);
    final formDataNotifier = ref.read(formDataContainerProvider.notifier);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FormFieldLabel('الزبون'),
        HorizontalGap.l,
        Expanded(
          child: DropDownWithSearch(
            initialValue: formDataNotifier.data['name'],
            onChangedFn: (customer) async {
              // we reset form data because customer has been changed
              formDataNotifier.reset();
              // we also reset cart context
              cartNotifier.reset();
              // now process customer data, and debt data
              num paymentDurationLimit = customer['paymentDurationLimit'];
              formDataNotifier.addProperty('name', customer['name']);
              formDataNotifier.addProperty('nameDbRef', customer['dbRef']);
              formDataNotifier.addProperty('sellingPriceType', customer['sellingPriceType']);
              // load transactions of selected customer, to be used for calculating debt
              _setLoading(true);
              await setTranasctionsProvider(ref, customer['dbRef']);
              _setLoading(false);
              // now calculating debt
              final customerDebtInfo =
                  getCustomerDbetInfo(ref, customer['dbRef'], paymentDurationLimit);
              // set customer debt info
              totalDebt = customerDebtInfo['totalDebt'];
              dueDebt = customerDebtInfo['dueDebt'];
              latestReceiptDate = customerDebtInfo['lastReceiptDate'] ?? 'لا يوجد';
              latestInvoiceDate = customerDebtInfo['latestInvoiceDate'] ?? 'لا يوجد';
              _validateCustomer(paymentDurationLimit, customer['creditLimit']);
            },
            dbCache: salesmanCustomersDb,
          ),
        ),
        HorizontalGap.l,
        _buildLoadCustomersButton(ref),
      ],
    );
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

  Widget _buildLoadCustomersButton(WidgetRef ref) {
    return IconButton(
        onPressed: () async {
          _setLoading(true); // Set loading to true
          await setCustomersProvider(ref);
          _setLoading(false); // Set loading to false after data is loaded
        },
        icon: const Icon(
          Icons.refresh,
          color: Colors.white,
        ));
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading; // Update loading state
    });
  }

  Widget _buildTransactionSelectionButton(
      BuildContext context, WidgetRef ref, String label, String routeName,
      {bool loadProducts = false}) {
    final formDataNotifier = ref.read(formDataContainerProvider.notifier);

    return InkWell(
      onTap: () async {
        // load products if the button pressed is invoice
        if (loadProducts) {
          await setProductsProvider(ref);
        }
        if (formDataNotifier.data.containsKey('name') &
            formDataNotifier.data.containsKey('nameDbRef')) {
          if (context.mounted) {
            GoRouter.of(context).goNamed(routeName);
          }
        } else if (context.mounted) {
          failureUserMessage(context, 'يرجى اختيار اسم الزبون');
        }
      },
      child: Container(
        width: 150,
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
