import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/features/transactions/model/transaction.dart';
import 'package:tablets/src/features/transactions/repository/transaction_repository_provider.dart';

void addTransactionToDb(WidgetRef ref, Transaction transaction) {
  final repository = ref.read(transactionRepositoryProvider);
  repository.addItem(transaction);
}

Widget buildScreenTitle(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(10),
    child: const Text(
      'وصل قبض',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.yellow),
    ),
  );
}
