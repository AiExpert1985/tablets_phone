import 'package:flutter_riverpod/flutter_riverpod.dart';

final salesmanCustomersProviderController = StateProvider<List<Map<String, dynamic>>>((ref) {
  return []; // Default color
});
