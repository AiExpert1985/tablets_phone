import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/common/db_repository.dart';

final customerRepositoryProvider = Provider<DbRepository>((ref) => DbRepository('customers'));

// final transactionStreamProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
//   final transactionRepository = ref.watch(transactionRepositoryProvider);
//   return transactionRepository.watchItemListAsMaps();
// });
