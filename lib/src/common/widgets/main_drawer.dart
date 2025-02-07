import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/common/functions/dialog_delete_confirmation.dart';
import 'package:tablets/src/common/providers/data_loading_provider.dart';
import 'package:tablets/src/common/values/gaps.dart';
import 'package:tablets/src/features/home/controller/salesman_info_provider.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      width: 250,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB76A45),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            const MainDrawerHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('القوائم'),
                      leading: const Icon(Icons.view_list_outlined),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('الوصولات'),
                      leading: const Icon(Icons.view_list),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('مزامنة البيانات'),
                      leading: const Icon(Icons.refresh),
                      onTap: () async {
                        Navigator.pop(context);
                        ref.read(dataLoadingController.notifier).loadCustomers(loadFreshData: true);
                        ref
                            .read(dataLoadingController.notifier)
                            .loadTransactions(loadFreshData: true);
                      },
                    ),
                    ListTile(
                      title: const Text('حول التطبيق'),
                      leading: const Icon(Icons.info_outline),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    ListTile(
                      title: const Text('تسجيل خروج'),
                      leading: const Icon(Icons.logout),
                      onTap: () async {
                        Navigator.pop(context);
                        final confiramtion = await showDeleteConfirmationDialog(
                            context: context,
                            messagePart1: '',
                            messagePart2: 'هل ترغب بالخروج من البرنامج؟');
                        if (confiramtion != null) {
                          FirebaseAuth.instance.signOut();
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MainDrawerHeader extends ConsumerWidget {
  const MainDrawerHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesmanInfo = ref.watch(salesmanInfoProvider);

    return SizedBox(
      height: 250,
      child: DrawerHeader(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB76A45), // Replace with your itemsColor
              Color(0xFF573419), // Replace with your bgColor
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: 170,
              child: Image.asset('assets/images/logo.png', fit: BoxFit.scaleDown),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('المندوب', style: TextStyle(fontSize: 16, color: Colors.white)),
                HorizontalGap.s,
                Text(salesmanInfo?.name ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
            VerticalGap.m,
          ],
        ),
      ),
    );
  }
}

class DrawerItems extends StatelessWidget {
  const DrawerItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.pop(context); // Close the drawer
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {
            Navigator.pop(context); // Close the drawer
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () {
            Navigator.pop(context); // Close the drawer
          },
        ),
        const Spacer(), // This will push the next widget to the bottom
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
            Navigator.pop(context); // Close the drawer
          },
        ),
      ],
    );
  }
}
