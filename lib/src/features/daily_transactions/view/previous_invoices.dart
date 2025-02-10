import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tablets/src/common/functions/user_messages.dart';
import 'package:tablets/src/common/functions/utils.dart';
import 'package:tablets/src/common/values/gaps.dart';
import 'package:tablets/src/common/widgets/circle.dart';
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
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const Text('القوائم اليومية', style: TextStyle(color: Colors.white, fontSize: 20)),
              VerticalGap.xl,
              ..._buildItemList(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItemList(BuildContext context, WidgetRef ref) {
    List<Widget> invoiceWidgets = [];
    for (int i = 0; i < pendingInvoices.length; i++) {
      final invoice = Transaction.fromMap(pendingInvoices[i]);
      invoiceWidgets.add(_buildTransactionCard(context, ref, i, invoice));
      invoiceWidgets.add(VerticalGap.m);
    }
    return invoiceWidgets;
  }

  Widget _buildTransactionCard(
      BuildContext context, WidgetRef ref, int sequence, Transaction invoice) {
    return Center(
      child: InkWell(
        onTap: () {
          // GoRouter.of(context).pushNamed(AppRoute.cart.name);
        },
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(10.0),
          decoration: const BoxDecoration(
              gradient: itemColorGradient, borderRadius: BorderRadius.all(Radius.circular(6))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircledContainer(child: Text((sequence + 1).toString())),
              HorizontalGap.l,
              SizedBox(
                  width: 140,
                  child: Text(invoice.name, style: const TextStyle(color: Colors.white))),
              const Spacer(),
              SizedBox(
                width: 80,
                child: Text(doubleToStringWithComma(invoice.totalAmount),
                    textAlign: TextAlign.end, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
