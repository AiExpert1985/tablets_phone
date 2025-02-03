import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/common/functions/dialog_delete_confirmation.dart';
import 'package:tablets/src/common/functions/loading_data.dart';
import 'package:tablets/src/common/functions/user_messages.dart';
import 'package:tablets/src/common/values/gaps.dart';
import 'package:tablets/src/common/widgets/loading_spinner.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';
import 'package:tablets/src/features/transactions/controllers/cart_provider.dart';
import 'package:tablets/src/features/transactions/controllers/form_data_container.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false; // Loading state

  @override
  Widget build(BuildContext context) {
    return MainFrame(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (!_isLoading) _buildRefreshTransactoinsButton(),
              if (_isLoading) const LoadingSpinner('جاري مزامنة البيانات')
            ],
          ),
        ),
      ),
    );
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading; // Update loading state
    });
  }

  Widget _buildRefreshTransactoinsButton() {
    return Column(
      children: [
        IconButton(
          onPressed: () async {
            // first reset both formData, and cart
            final formDataNotifier = ref.read(formDataContainerProvider.notifier);
            final cartNotifier = ref.read(cartProvider.notifier);

            final formData = formDataNotifier.data;
            // when back to home, all data is erased, user receives confirmation box
            final confirmation = await showDeleteConfirmationDialog(
              context: context,
              messagePart1: "",
              messagePart2: 'سوف يتم حذف قائمة ${formData['name']} عند العودة للواجهة الرئيسية',
            );
            if (confirmation != null) {
              // then start loading data
              _setLoading(true);
              formDataNotifier.reset();
              cartNotifier.reset();
              // await setCustomersProvider(ref);
              await setTranasctionsProvider(ref,
                  loadFreshData: true); // load fresh copy of transations
              _setLoading(false); // Set loading to false after data is loaded
              if (mounted) {
                successUserMessage(context, 'تمت المزامنة بنجاح');
              }
            }
          },
          icon: const Icon(
            Icons.refresh,
            color: Colors.white,
            size: 30,
          ),
        ),
        VerticalGap.m,
        const Text('مزامنة البيانات', style: TextStyle(color: Colors.white, fontSize: 18))
      ],
    );
  }

  void resetTransactions(BuildContext context, WidgetRef ref) async {}
}
