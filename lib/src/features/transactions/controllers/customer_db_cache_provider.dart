import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/common/db_cache.dart';

final salesmanCustomerDbCacheProvider =
    StateNotifierProvider<DbCache, List<Map<String, dynamic>>>((ref) {
  return DbCache();
});
