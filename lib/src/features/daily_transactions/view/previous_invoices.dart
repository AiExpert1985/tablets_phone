import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tablets/src/common/functions/user_messages.dart';
import 'package:tablets/src/common/functions/utils.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';
import 'package:tablets/src/features/transactions/model/transaction.dart';
import 'package:tablets/src/features/transactions/repository/pending_transaction_repository_provider.dart';
import 'package:tablets/src/routers/go_router_provider.dart';

class PreviousInvoices extends ConsumerWidget {
  const PreviousInvoices(this.pendingInvoices, {super.key});

  final List<Map<String, dynamic>> pendingInvoices;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainFrame(
      child: SingleChildScrollView(
        child: Column(
          children: _buildItemList(context, ref),
        ),
      ),
    );
  }

  List<Widget> _buildItemList(BuildContext context, WidgetRef ref) {
    List<Widget> invoiceWidgets = [];
    for (int i = 0; i < pendingInvoices.length; i++) {
      final invoice = Transaction.fromMap(pendingInvoices[i]);
      invoiceWidgets.add(_buildTransactionCard(context, ref, i, invoice));
    }
    return invoiceWidgets;
  }

  Widget _buildTransactionCard(
      BuildContext context, WidgetRef ref, int sequence, Transaction invoice) {
    final pendingTransactionsRepo = ref.read(pendingTransactionRepositoryProvider);
    return Dismissible(
      key: Key(generateRandomString(len: 4)), // Use a unique key for each item
      background: Container(
        color: Colors.red, // Background color when swiping
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        pendingTransactionsRepo.deleteItem(invoice); // Call the method to remove the item
        successUserMessage(context, 'تم ازالة ${invoice.name}');
      },
      child: Center(
        child: InkWell(
          onTap: () {
            GoRouter.of(context).pushNamed(AppRoute.cart.name);
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: const BoxDecoration(
                gradient: itemColorGradient, borderRadius: BorderRadius.all(Radius.circular(6))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(invoice.name)],
            ),
          ),
        ),
      ),
    );
  }
}
