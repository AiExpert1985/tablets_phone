import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tablets/src/common/functions/user_messages.dart';
import 'package:tablets/src/common/providers/data_loading_provider.dart';
import 'package:tablets/src/common/values/gaps.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';
import 'package:tablets/src/features/home/controller/home_screen_controller.dart';
import 'package:tablets/src/features/transactions/controllers/cart_provider.dart';
import 'package:tablets/src/features/transactions/controllers/customer_db_cache_provider.dart';
import 'package:tablets/src/features/transactions/controllers/form_data_container.dart';
import 'package:tablets/src/routers/go_router_provider.dart';
import 'package:tablets/src/features/transactions/common/common_widgets.dart';
import 'package:tablets/src/common/forms/drop_down_with_search.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(homeScreenStateController.notifier).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final homeScreenState = ref.watch(homeScreenStateController);

    return MainFrame(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNameSelection(context),
          if (homeScreenState.latestReceiptDate != null) ...[
            _buildDebtInfo(homeScreenState),
            _buildSelectionButtons(context),
          ]
        ],
      ),
    );
  }

  Widget _buildDebtInfo(HomeScreenState state) {
    Color infoBgColor = state.isValidUser ? itemsColor : Colors.red;
    return Column(
      children: [
        if (state.totalDebt != null)
          buildTotalAmount(context, state.dueDebt, 'الدين المستحق',
              bgColor: infoBgColor, fontColor: Colors.white),
        VerticalGap.l,
        if (state.totalDebt != null)
          buildTotalAmount(context, state.totalDebt, 'الدين الكلي',
              bgColor: infoBgColor, fontColor: Colors.white),
        VerticalGap.l,
        if (state.latestReceiptDate != null)
          buildTotalAmount(context, state.latestInvoiceDate, 'اخر قائمة',
              bgColor: infoBgColor, fontColor: Colors.white),
        VerticalGap.l,
        if (state.latestInvoiceDate != null)
          buildTotalAmount(context, state.latestReceiptDate, 'اخر تسديد',
              bgColor: infoBgColor, fontColor: Colors.white),
      ],
    );
  }

  Widget _buildSelectionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTransactionSelectionButton(context, 'وصل قبض', AppRoute.receipt.name),
        HorizontalGap.xxl,
        _buildTransactionSelectionButton(context, 'قائمة بيع', AppRoute.items.name),
      ],
    );
  }

  Widget _buildNameSelection(BuildContext context) {
    final formData = ref.watch(formDataContainerProvider);
    final customerDbCache = ref.watch(customerDbCacheProvider);
    final cartItems = ref.watch(cartProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: DropDownWithSearch(
            label: 'الزبون',
            initialValue: formData['name'],
            onOpenFn: (p0) async {
              if (customerDbCache.isEmpty) {
                await ref.read(dataLoadingController.notifier).loadCustomers();
              }
              if (cartItems.isNotEmpty && context.mounted) {
                return await ref
                    .read(homeScreenStateController.notifier)
                    .resetTransactionConfirmation(context);
              }
              return true;
            },
            onChangedFn: (customer) {
              ref.read(homeScreenStateController.notifier).selectCustomer(customer);
            },
            dbCache: ref.read(customerDbCacheProvider.notifier),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionSelectionButton(BuildContext context, String label, String routeName) {
    final formData = ref.watch(formDataContainerProvider);

    return InkWell(
      onTap: () async {
        if (formData.containsKey('name') && formData.containsKey('nameDbRef')) {
          if (context.mounted) {
            GoRouter.of(context).pushNamed(routeName);
            if (routeName == AppRoute.items.name) {
              ref.read(dataLoadingController.notifier).loadProducts();
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
