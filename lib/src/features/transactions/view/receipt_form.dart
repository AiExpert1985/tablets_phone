// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:search_choices/search_choices.dart';
// import 'package:tablets/src/features/transactions/repository/customer_repository_provider.dart';

// class ReceiptForm extends ConsumerWidget {
//   const ReceiptForm({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       child: const Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [],
//       ),
//     );
//   }
// }

// class CustomerNameSelection extends StatelessWidget {
//   const CustomerNameSelection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: SearchChoices.single(
//         fieldDecoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(4), // Rounded corners
//             border: Border.all(color: Colors.grey)),
//         items: selectionValues
//             .map(
//               (item) => DropdownMenuItem(
//                 value: item,
//                 child: Text(item['name']),
//               ),
//             )
//             .toList(),
//         value: selectedValue,
//         hint: Text(
//           selectionLabel ?? '',
//           style: const TextStyle(color: Colors.red),
//           textAlign: TextAlign.center,
//         ),
//         searchHint: Text(
//           selectionLabel ?? '',
//           style: const TextStyle(color: Colors.red),
//           textAlign: TextAlign.center,
//         ),
//         onChanged: (value) {
//           selectedValue = value;
//         },

//         isExpanded: true,
//         // padding is the only way I found to reduce the width of the search dialog
//         dropDownDialogPadding: const EdgeInsets.symmetric(
//           vertical: 120,
//           horizontal: 700,
//         ),
//         closeButton: const SizedBox.shrink(),
//       ),
//     );
//   }
// }

// List<Map<String, dynamic>> getSalesmanCustomers(
//     List<Map<String, dynamic>> customers, String salesmanDbRef) {
//   List<Map<String, dynamic>> salesmanCustomers = [];
//   for (var customer in customers) {
//     if (customer['salesmanDbRef']) {
//       salesmanCustomers.add(customer);
//     }
//   }
//   return salesmanCustomers;
// }

// Future<List<Map<String, dynamic>>> customers(WidgetRef ref) async {
//   final customerRepo = ref.read(customerRepositoryProvider);

//   return customerRepo.fetchItemListAsMaps();
// }
