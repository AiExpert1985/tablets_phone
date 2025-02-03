import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/common/functions/dialog_delete_confirmation.dart';
import 'package:tablets/src/features/transactions/controllers/cart_provider.dart';
import 'package:tablets/src/features/transactions/controllers/form_data_container.dart';

// show confirmation box to user, if he selects yes, then formData and cart will be both cleared
// and true is returned, if no selected, no action taken, and returns false
Future<bool> resetTransactonConfirmation(BuildContext context, WidgetRef ref) async {
  // first reset both formData, and cart
  final formDataNotifier = ref.read(formDataContainerProvider.notifier);
  final cartNotifier = ref.read(cartProvider.notifier);

  final formData = formDataNotifier.data;
  // when back to home, all data is erased, user receives confirmation box
  final confirmation = await showDeleteConfirmationDialog(
    context: context,
    messagePart1: "",
    messagePart2: 'سوف يتم حذف قائمة ${formData['name']} ',
  );
  if (confirmation != null) {
    formDataNotifier.reset();
    cartNotifier.reset();
    return true;
  }
  return false;
}
