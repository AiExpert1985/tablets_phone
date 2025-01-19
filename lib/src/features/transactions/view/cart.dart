import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';
import 'package:tablets/src/features/transactions/controllers/cart_provider.dart';

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
              children: _buildItemList(itemsData),
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
}
