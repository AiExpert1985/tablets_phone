import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/common/functions/loading_data.dart';
import 'package:tablets/src/common/functions/reset_transaction_confirmation.dart';
import 'package:tablets/src/common/functions/user_messages.dart';
import 'package:tablets/src/common/values/gaps.dart';
import 'package:tablets/src/common/widgets/loading_spinner.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';

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
            bool userConfirmation = await resetTransactonConfirmation(context, ref);
            if (!userConfirmation) {
              return;
            }
            _setLoading(true);
            // load fresh copy of transations & customers
            await setCustomersProvider(ref, loadFreshData: true);
            await setTranasctionsProvider(ref, loadFreshData: true);
            _setLoading(false);
            if (mounted) {
              successUserMessage(context, 'تمت المزامنة بنجاح');
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
}
