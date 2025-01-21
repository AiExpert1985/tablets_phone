import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tablets/src/common/functions/user_messages.dart';
import 'package:tablets/src/common/functions/utils.dart';
import 'package:tablets/src/common/values/gaps.dart';
import 'package:tablets/src/common/widgets/circle.dart';
import 'package:tablets/src/common/widgets/custom_icons.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';
import 'package:tablets/src/features/transactions/controllers/cart_provider.dart';
import 'package:tablets/src/features/transactions/controllers/form_data_container.dart';
import 'package:tablets/src/features/transactions/model/item.dart';
import 'package:tablets/src/routers/go_router_provider.dart';

class ShoppingCart extends ConsumerWidget {
  const ShoppingCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(cartProvider);
    ref.watch(formDataContainerProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final cartItems = cartNotifier.data;
    final formDataNotifier = ref.read(formDataContainerProvider.notifier);
    final formData = formDataNotifier.data;
    return MainFrame(
      includeBottomNavigation: true,
      child: Center(
        child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: cartItems.isEmpty
                  ? [
                      _buildTransactionInfo(context, formData),
                      SizedBox(
                        width: double.infinity,
                        height: 250,
                        child: Image.asset('assets/images/empty.png', fit: BoxFit.scaleDown),
                      ),
                      VerticalGap.xl,
                      _builAddButton(context, ref)
                    ]
                  : [
                      _buildTransactionInfo(context, formData),
                      VerticalGap.m,
                      Expanded(
                        child: ListView(
                          children: _buildItemList(context, ref, cartItems),
                        ),
                      ),
                      VerticalGap.m,
                      _builAddButton(context, ref)
                    ],
            )),
      ),
    );
  }

  List<Widget> _buildItemList(BuildContext context, WidgetRef ref, List<CartItem> cartItems) {
    List<Widget> items = [];
    for (int i = 0; i < cartItems.length; i++) {
      items.add(_buildItemCard(context, ref, i, cartItems[i]));
    }
    return items;
  }

  Widget _builAddButton(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: const AddItem(),
              onPressed: () {
                final formDataNotifier = ref.read(formDataContainerProvider.notifier);
                if (formDataNotifier.data.isEmpty) {
                  GoRouter.of(context).goNamed(AppRoute.invoice.name);
                } else {
                  GoRouter.of(context).goNamed(AppRoute.items.name);
                }
              }),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo(BuildContext context, Map<String, dynamic> formData) {
    return InkWell(
      onTap: () => GoRouter.of(context).goNamed(AppRoute.invoice.name),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (formData['name'] != null)
              Text(
                formData['name'],
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            if (formData['date'] != null) VerticalGap.l,
            if (formData['date'] != null)
              Text(
                formatDate(formData['date']),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, WidgetRef ref, int sequence, CartItem cartItem) {
    final cartNotifier = ref.read(cartProvider.notifier);
    return Dismissible(
      key: Key(generateRandomString(len: 4)), // Use a unique key for each item
      background: Container(
        color: Colors.red, // Background color when swiping
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        cartNotifier.removeItem(sequence); // Call the method to remove the item
        successUserMessage(context, '${cartItem.name}تم ازالة ');
      },
      child: InkWell(
        onTap: () {
          GoRouter.of(context).pushNamed(AppRoute.add.name, extra: cartItem);
        },
        child: Card(
          color: itemsColor,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircledContainer(child: Text((sequence + 1).toString())),
                    Expanded(
                      child: Text(
                        cartItem.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, color: Colors.yellow),
                        overflow: TextOverflow.visible, // Optional: Control overflow behavior
                      ),
                    ),
                  ],
                ),
                VerticalGap.l,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCell('السعر', cartItem.sellingPrice!),
                    _buildCell('العدد', cartItem.soldQuantity!),
                    _buildCell('الهدية', cartItem.giftQuantity!),
                    _buildCell('المبلغ الكلي', cartItem.totalAmount!),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(String columnName, double columnValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(columnName, style: const TextStyle(color: Colors.white, fontSize: 12)),
        VerticalGap.s,
        Text(doubleToStringWithComma(columnValue),
            style: const TextStyle(color: Colors.white, fontSize: 12))
      ],
    );
  }
}
