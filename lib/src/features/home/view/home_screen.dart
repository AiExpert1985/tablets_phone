import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/generated/l10n.dart';
import 'package:tablets/src/common/custom_icons.dart';
import 'package:tablets/src/common/debug_print.dart';
import 'package:tablets/src/common/dialog_delete_confirmation.dart';
import 'package:tablets/src/features/login/repository/accounts_repository.dart';
import 'package:tablets/src/features/transactions/controllers/customers_provider.dart';
import 'package:tablets/src/features/transactions/model/transaction.dart';
import 'package:tablets/src/features/transactions/repository/customer_repository_provider.dart';
import 'package:tablets/src/features/transactions/repository/transaction_repository_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          TextButton.icon(
            onPressed: () async {
              final confiramtion = await showDeleteConfirmationDialog(
                  context: context,
                  messagePart1: "",
                  messagePart2: S.of(context).alert_before_signout);
              if (confiramtion != null) {
                FirebaseAuth.instance.signOut();
              }
            }, //signout(ref),
            icon: const LocaleAwareLogoutIcon(),
            label: Text(
              S.of(context).logout,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonContainer(S.of(context).transaction_type_customer_receipt, () {
              setSalesmanCustomers(ref);
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

Future<void> setSalesmanCustomers(WidgetRef ref) async {
  String? salesmanDbRef = await saveSalesmanDbRef(ref);
  final customersRepository = ref.read(customerRepositoryProvider);
  final customers = await customersRepository.fetchItemListAsMaps();
  final salesmanCustomers = customers.where((customer) {
    return customer['salesmanDbRef'] == salesmanDbRef;
  }).toList();
  tempPrint(salesmanCustomers.length);
  final salesmanCustomersProvider = ref.read(salesmanCustomersProviderController.notifier);
  salesmanCustomersProvider.state = salesmanCustomers;
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

Future<String?> saveSalesmanDbRef(WidgetRef ref) async {
  final email = FirebaseAuth.instance.currentUser!.email;
  tempPrint(email);
  final repository = ref.read(accountsRepositoryProvider);
  final accounts = await repository.fetchItemListAsMaps();
  var matchingAccounts = accounts.where((account) => account['email'] == email);
  String? salesmanDbRef;
  if (matchingAccounts.isNotEmpty) {
    salesmanDbRef = matchingAccounts.first['dbRef'];
  } else {
    salesmanDbRef = null; // or some default value
  }
  return salesmanDbRef;
}
