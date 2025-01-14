import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalesmanInfo extends StateNotifier<Map<String, dynamic>> {
  SalesmanInfo() : super({}); // Initialize with an empty map

  // Function to add a property to the map
  void addProperty(String key, dynamic value) {
    state = {
      ...state, // Spread the current state
      key: value, // Add the new key-value pair
    };
  }

  // Function to reset the map to an empty state
  void reset() {
    state = {}; // Reset to an empty map
  }

  Map<String, dynamic> get data => state;
}

// Create a provider for the MapStateNotifier
final salesmanInfoProvider = StateNotifierProvider<SalesmanInfo, Map<String, dynamic>>((ref) {
  return SalesmanInfo();
});
