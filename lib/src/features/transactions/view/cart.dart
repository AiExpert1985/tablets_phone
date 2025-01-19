import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tablets/src/common/functions/debug_print.dart';
import 'package:tablets/src/common/values/gaps.dart';
import 'package:tablets/src/common/widgets/custom_icons.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';
import 'package:tablets/src/features/transactions/controllers/cart_provider.dart';
import 'package:tablets/src/features/transactions/controllers/form_data_container.dart';
import 'package:tablets/src/routers/go_router_provider.dart';

class ShoppingCart extends ConsumerWidget {
  const ShoppingCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final itemsData = cartNotifier.data;
    return MainFrame(
      includeBottomNavigation: true,
      child: Center(
        child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: itemsData.isEmpty
                  ? [
                      SizedBox(
                        width: double.infinity,
                        height: 250,
                        child: Image.asset('assets/images/empty.png', fit: BoxFit.scaleDown),
                      ),
                      VerticalGap.xl,
                      _builAddButton(context, ref)
                    ]
                  : [..._buildItemList(itemsData), VerticalGap.xl, _builAddButton(context, ref)],
            )),
      ),
    );
  }

  List<Widget> _buildItemList(List<Map<String, dynamic>> itemsData) {
    List<Widget> items = [];
    for (var itemData in itemsData) {
      items.add(
        Container(
          padding: const EdgeInsets.all(5),
          child: Text(
            itemData['name'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    return items;
  }

  Widget _builAddButton(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: const AddItem(),
              onPressed: () {
                final formDataNotifier = ref.read(formDataContainerProvider.notifier);
                tempPrint(formDataNotifier.data);
                if (formDataNotifier.data.isEmpty) {
                  tempPrint('hi');
                  GoRouter.of(context).goNamed(AppRoute.invoice.name);
                } else {
                  GoRouter.of(context).goNamed(AppRoute.items.name);
                }
              }),
        ],
      ),
    );
  }
}
