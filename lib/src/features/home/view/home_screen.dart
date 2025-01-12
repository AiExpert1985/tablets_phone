import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tablets/generated/l10n.dart';
import 'package:tablets/src/common/main_frame.dart';
import 'package:tablets/src/features/login/repository/accounts_repository.dart';
import 'package:tablets/src/features/transactions/controllers/customer_db_cache_provider.dart';
import 'package:tablets/src/features/transactions/repository/customer_repository_provider.dart';
import 'package:tablets/src/routers/go_router_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainFrame(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonContainer(S.of(context).transaction_type_customer_receipt, () async {
              final customersRepository = ref.read(salesmanCustomerDbCacheProvider.notifier);
              if (customersRepository.data.isEmpty) {
                await setSalesmanCustomers(ref);
              }
              if (context.mounted) {
                GoRouter.of(context).pushNamed(AppRoute.receipt.name);
              }
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
  String? salesmanDbRef = await getSalesmanDbRef(ref);
  final customersRepository = ref.read(customerRepositoryProvider);
  final customers = await customersRepository.fetchItemListAsMaps();
  final salesmanCustomers = customers.where((customer) {
    return customer['salesmanDbRef'] == salesmanDbRef;
  }).toList();
  final salesmanCustomersDb = ref.read(salesmanCustomerDbCacheProvider.notifier);
  salesmanCustomersDb.set(salesmanCustomers);
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

Future<String?> getSalesmanDbRef(WidgetRef ref) async {
  final email = FirebaseAuth.instance.currentUser!.email;
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
