import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';
import 'package:tablets/src/features/transactions/model/product.dart';

class AddItem extends ConsumerWidget {
  const AddItem(this.product, {super.key});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainFrame(
      child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(product.name),
            ],
          )),
    );
  }
}
