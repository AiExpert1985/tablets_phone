import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/common/widgets/image_titled.dart';
import 'package:tablets/src/features/transactions/controllers/filtered_items_provider.dart';

class ItemsGrid extends ConsumerWidget {
  const ItemsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(filteredItemsProvider);
    final filteredItemsNotifier = ref.read(filteredItemsProvider.notifier);
    final filteredItems = filteredItemsNotifier.data;
    return GridView.builder(
      itemCount: filteredItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (ctx, index) {
        final itemScreenData = filteredItems[index];
        return InkWell(
          hoverColor: const Color.fromARGB(255, 173, 170, 170),
          child: TitledImage(
            imageUrl: itemScreenData['coverImageUrl'],
            title: itemScreenData['name'],
          ),
        );
      },
    );
  }
}
