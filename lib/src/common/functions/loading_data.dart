import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/features/home/controller/last_access_provider.dart';
import 'package:tablets/src/features/home/controller/salesman_info_provider.dart';
import 'package:tablets/src/features/login/repository/accounts_repository.dart';
import 'package:tablets/src/features/transactions/controllers/customer_db_cache_provider.dart';
import 'package:tablets/src/features/transactions/controllers/products_db_cache_provider.dart';
import 'package:tablets/src/features/transactions/controllers/transaction_db_cache_provider.dart';
import 'package:tablets/src/features/transactions/repository/customer_repository_provider.dart';
import 'package:tablets/src/features/transactions/repository/products_repository_provider.dart';
import 'package:tablets/src/features/transactions/repository/transactions_repository_provider.dart';

// we only set customers once a day, in case there is update, user can press refresh to synch data with
// fire store (the loadFreshData = true in this case)
Future<void> setCustomersProvider(WidgetRef ref, {bool loadFreshData = false}) async {
  final customerDbCache = ref.read(customerDbCacheProvider.notifier);
  final lastAccessNotifier = ref.read(lastAccessProvider.notifier);
  final oneDayPassed = lastAccessNotifier.hasOneDayPassed();
  if (customerDbCache.data.isEmpty || oneDayPassed || loadFreshData) {
    final salesmanInfoNotifier = ref.read(salesmanInfoProvider.notifier);
    final email = FirebaseAuth.instance.currentUser!.email;
    final repository = ref.read(accountsRepositoryProvider);
    final accounts = await repository.fetchItemListAsMaps();
    var matchingAccounts = accounts.where((account) => account['email'] == email);
    if (matchingAccounts.isNotEmpty) {
      final dbRef = matchingAccounts.first['dbRef'];
      salesmanInfoNotifier.setDbRef(dbRef);
      final name = matchingAccounts.first['name'];
      salesmanInfoNotifier.setName(name);
    }
    final salesmanDbRef = salesmanInfoNotifier.dbRef;
    final customersRepository = ref.read(customerRepositoryProvider);
    final customers = await customersRepository.fetchItemListAsMaps(
        filterKey: 'salesmanDbRef', filterValue: salesmanDbRef);
    customerDbCache.set(customers);
  }
}

// note that we don't store copy of products (unlike customers and transactions)
// the reason is that customers are rarely changed, and transactions of customers for one saleman are
// not changed during the day (because they are mostly changed by salesman visit)
Future<void> setProductsProvider(WidgetRef ref) async {
  final productsRepository = ref.read(productsRepositoryProvider);
  final products = await productsRepository.fetchItemListAsMaps();
  final dbCache = ref.read(productsDbCacheProvider.notifier);
  dbCache.set(products);
}

// we keep a copy of transaction data, because it is expensive in loading (about 1000 document)
// which makes loading slow, and cost money in firebase, I update the cache once a day
// loadingFreshData is used for refresh button, which salesman might need if the customer data where updated
// during the day, because in our app, the data is only updated onces a day at the first app access
Future<void> setTranasctionsProvider(WidgetRef ref, {bool loadFreshData = false}) async {
  final transactionsDbCache = ref.read(transactionDbCacheProvider.notifier);
  final lastAccessNotifier = ref.read(lastAccessProvider.notifier);
  final oneDayPassed = lastAccessNotifier.hasOneDayPassed();
  if (transactionsDbCache.data.isEmpty || oneDayPassed || loadFreshData) {
    final transactionRepository = ref.read(transactionRepositoryProvider);
    final transactions = await transactionRepository.fetchItemListAsMaps();
    transactionsDbCache.set(transactions);
    lastAccessNotifier.setLastAccessDate();
  }
}
