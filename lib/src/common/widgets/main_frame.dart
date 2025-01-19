import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tablets/generated/l10n.dart';
import 'package:tablets/src/common/functions/dialog_delete_confirmation.dart';
import 'package:tablets/src/routers/go_router_provider.dart';

class MainFrame extends ConsumerWidget {
  const MainFrame({required this.child, this.includeBottomNavigation = false, super.key});

  final Widget child;
  final bool includeBottomNavigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: customAppBar(context),
      body: child,
      bottomNavigationBar: includeBottomNavigation ? _buildBottomNavigation(context) : null,
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return BottomNavigationBar(
      onTap: (index) {
        if (index == 0) {
          GoRouter.of(context).pushNamed(AppRoute.cart.name);
        } else {
          GoRouter.of(context).pushNamed(AppRoute.home.name);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'المشتريات'), // Cart Icon
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
      ],
    );
  }
}

PreferredSizeWidget customAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.primary,
    actions: [
      TextButton.icon(
        onPressed: () async {
          final confiramtion = await showDeleteConfirmationDialog(
              context: context, messagePart1: "", messagePart2: S.of(context).alert_before_signout);
          if (confiramtion != null) {
            FirebaseAuth.instance.signOut();
          }
        }, //signout(ref),
        icon: const Icon(
          Icons.do_disturb_on_outlined,
          color: Colors.red,
        ),
        label: Text(
          S.of(context).logout,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    ],
  );
}
