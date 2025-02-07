import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/common/classes/db_cache.dart';
import 'package:tablets/src/common/classes/db_repository.dart';
import 'package:tablets/src/common/values/gaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tablets/src/features/home/controller/last_access_provider.dart';
import 'package:tablets/src/features/home/controller/salesman_info_provider.dart';
import 'package:tablets/src/features/login/repository/accounts_repository.dart';
import 'package:tablets/src/features/transactions/controllers/customer_db_cache_provider.dart';
import 'package:tablets/src/features/transactions/controllers/products_db_cache_provider.dart';
import 'package:tablets/src/features/transactions/controllers/transaction_db_cache_provider.dart';
import 'package:tablets/src/features/transactions/repository/customer_repository_provider.dart';
import 'package:tablets/src/features/transactions/repository/products_repository_provider.dart';
import 'package:tablets/src/features/transactions/repository/transactions_repository_provider.dart';

// Create a provider for the LoadingNotifier

final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
  final customerDbCache = ref.read(customerDbCacheProvider.notifier);
  final transactionsDbCache = ref.read(transactionDbCacheProvider.notifier);
  final productDbCache = ref.read(productsDbCacheProvider.notifier);
  final productsRepository = ref.read(productsRepositoryProvider);
  final customersRepository = ref.read(customerRepositoryProvider);
  final accountsRepository = ref.read(accountsRepositoryProvider);
  final transactionRepository = ref.read(transactionRepositoryProvider);
  final lastAccessNotifier = ref.read(lastAccessProvider.notifier);
  final salesmanInfoNotifier = ref.read(salesmanInfoProvider.notifier);
  return LoadingNotifier(
    customerDbCache,
    transactionsDbCache,
    productDbCache,
    productsRepository,
    customersRepository,
    accountsRepository,
    transactionRepository,
    lastAccessNotifier,
    salesmanInfoNotifier,
  ); // Pass the ref to the LoadingNotifier
});

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier(
      this._customerDbCache,
      this._transactionsDbCache,
      this._productDbCache,
      this._productsRepository,
      this._customersRepository,
      this._accountsRepository,
      this._transactionRepository,
      this._lastAccessNotifier,
      this._salesmanInfoNotifier)
      : super(false); // Initial state is not loading

  final DbCache _customerDbCache;
  final DbCache _transactionsDbCache;
  final DbCache _productDbCache;
  final DbRepository _productsRepository;
  final DbRepository _customersRepository;
  final DbRepository _accountsRepository;
  final DbRepository _transactionRepository;
  final LastAccessNotifier _lastAccessNotifier;
  final SalesmanInfo _salesmanInfoNotifier;

  void startLoading() {
    state = true; // Set loading to true
  }

  void stopLoading() {
    state = false; // Set loading to false
  }

  // we only set customers once a day, in case there is update, user can press refresh to synch data with
  // fire store (the loadFreshData = true in this case)
  Future<void> loadCustomers({bool loadFreshData = false}) async {
    startLoading();
    final oneDayPassed = _lastAccessNotifier.hasOneDayPassed();
    if (_customerDbCache.data.isEmpty || oneDayPassed || loadFreshData) {
      String? salesmanDbRef = _salesmanInfoNotifier.dbRef;
      final customers = await _customersRepository.fetchItemListAsMaps(
          filterKey: 'salesmanDbRef', filterValue: salesmanDbRef);
      _customerDbCache.set(customers);
    }
    stopLoading();
  }

  Future<void> setSalesmanInfo() async {
    startLoading();
    final email = FirebaseAuth.instance.currentUser!.email;
    final accounts = await _accountsRepository.fetchItemListAsMaps();
    var matchingAccounts = accounts.where((account) => account['email'] == email);
    if (matchingAccounts.isNotEmpty) {
      final dbRef = matchingAccounts.first['dbRef'];
      _salesmanInfoNotifier.setDbRef(dbRef);
      final name = matchingAccounts.first['name'];
      _salesmanInfoNotifier.setName(name);
    }
    stopLoading();
  }

// note that we don't store copy of products (unlike customers and transactions)
// the reason is that customers are rarely changed, and transactions of customers for one saleman are
// not changed during the day (because they are mostly changed by salesman visit)
  Future<void> loadProducts() async {
    startLoading();
    final products = await _productsRepository.fetchItemListAsMaps();
    _productDbCache.set(products);
    stopLoading();
  }

// we keep a copy of transaction data, because it is expensive in loading (about 1000 document)
// which makes loading slow, and cost money in firebase, I update the cache once a day
// loadingFreshData is used for refresh button, which salesman might need if the customer data where updated
// during the day, because in our app, the data is only updated onces a day at the first app access
  Future<void> loadTransactions({bool loadFreshData = false}) async {
    startLoading();
    final oneDayPassed = _lastAccessNotifier.hasOneDayPassed();
    if (_transactionsDbCache.data.isEmpty || oneDayPassed || loadFreshData) {
      final transactions = await _transactionRepository.fetchItemListAsMaps();
      _transactionsDbCache.set(transactions);
      _lastAccessNotifier.setLastAccessDate();
    }
    stopLoading();
  }
}

// LoadingWrapper widget with a dark background and spinner
class LoadingWrapper extends ConsumerWidget {
  final Widget child;

  const LoadingWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);

    return Stack(
      children: [
        child, // The main content
        if (isLoading) ...[
          // Dark background with opacity
          Container(
            padding: const EdgeInsets.all(0),
            color: Colors.black54, // Semi-transparent black
          ),
          const Center(
            child: LoadingSpinner(
              text: 'جاري تحميل البيانات',
            ),
          ),
        ],
      ],
    );
  }
}

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({this.text, super.key, this.fontColor = Colors.white});
  final String? text;
  final Color fontColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Colors.white),
        if (text != null) ...[
          VerticalGap.xl,
          Text(
            text!,
            style: TextStyle(color: fontColor, fontSize: 14),
          ),
        ]
      ],
    );
  }
}
