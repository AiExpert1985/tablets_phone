import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/generated/l10n.dart';
import 'package:tablets/src/features/transactions/model/transaction.dart';
import 'package:tablets/src/features/transactions/repository/transaction_repository_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonContainer(S.of(context).transaction_type_customer_receipt, () {
              final transaction = getTestTransaction();
              saveTestTransaction(ref, transaction);
            }),
            const SizedBox(height: 40),
            ButtonContainer(S.of(context).transaction_type_customer_invoice, () {}),
          ],
        ),
      ),
    );
  }
}

class ButtonContainer extends StatelessWidget {
  const ButtonContainer(this.label, this.onTap, {super.key});

  final String label;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

Transaction getTestTransaction() {
  return Transaction(
      dbRef: 'sdfsd',
      name: 'test pending transaction',
      imageUrls: ['xfdsfsdf'],
      number: 3243456,
      date: DateTime.now(),
      currency: 'sdfasdf',
      transactionType: 'sfsdfs',
      totalAmount: 34534534,
      transactionTotalProfit: 354,
      isPrinted: false);
}

void saveTestTransaction(WidgetRef ref, Transaction transaction) {
  final repository = ref.read(transactionRepositoryProvider);
  repository.addItem(transaction);
}
