import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/common/forms/edit_box.dart';
import 'package:tablets/src/common/values/constants.dart';
import 'package:tablets/src/common/values/gaps.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';
import 'package:tablets/src/features/transactions/controllers/filtered_products_provider.dart';

class ItemsGrid extends ConsumerStatefulWidget {
  const ItemsGrid({super.key});

  @override
  _ItemsGridState createState() => _ItemsGridState();
}

class _ItemsGridState extends ConsumerState<ItemsGrid> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Watch the filtered products provider
    final filteredItemsNotifier = ref.read(filteredProductsProvider.notifier);
    List<Map<String, dynamic>> filteredProducts = filteredItemsNotifier.data;

    // Filter products based on the search query
    List<Map<String, dynamic>> displayedProducts = _searchQuery.isEmpty
        ? filteredProducts // Show all products if search query is empty
        : filteredProducts.where((product) {
            return product['name'].toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return MainFrame(
      child: Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VerticalGap.xl,
            Expanded(
              child: FormInputField(
                onChangedFn: (value) {
                  setState(() {
                    _searchQuery = value; // Update the search query
                  });
                },
                dataType: FieldDataType.text,
                name: 'product-name',
              ),
            ),
            VerticalGap.xl,
            Expanded(
              child: ListView.builder(
                itemCount: displayedProducts.length,
                itemBuilder: (context, index) {
                  final product = displayedProducts[index];
                  return ListTile(
                    title: Text(product['name']),
                    // Add other product details as needed
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
