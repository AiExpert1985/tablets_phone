import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tablets/generated/l10n.dart';
import 'package:tablets/src/common/functions/debug_print.dart';
import 'package:tablets/src/common/functions/dialog_delete_confirmation.dart';
import 'package:tablets/src/routers/go_router_provider.dart';

// these colors are taken from Omar caffee mobile web app, given by Mahmood
const bgColor = Color(0xFF573419);
const itemsColor = Color(0xFF9C551F);
const mainFrameIconsColor = Color.fromARGB(255, 233, 219, 90);
const double mainIconSize = 25;
const double iconNameFontSize = 18;
// const mainFrameIconsColor = Color.fromARGB(103, 255, 235, 59);

class MainFrame extends ConsumerWidget {
  const MainFrame({required this.child, this.includeBottomNavigation = true, super.key});

  final Widget child;
  final bool includeBottomNavigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(25.0),
              color: bgColor,
              child: child,
            ),
          ),
        ],
      ),
      bottomNavigationBar: includeBottomNavigation ? _buildBottomNavigation(context, ref) : null,
    );
  }

  Widget _buildBottomNavigation(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      onTap: (index) async {
        switch (index) {
          case 0:
            GoRouter.of(context).goNamed(AppRoute.home.name);
            break;

          case 1:
            GoRouter.of(context).goNamed(AppRoute.cart.name);
            break;

          case 2:
            GoRouter.of(context).pushNamed(AppRoute.settings.name);
            break;

          default:
            errorPrint('Error or repeated URI');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'المشتريات',
        ), // Cart Icon
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الاعدادات'),
      ],
      backgroundColor: itemsColor,
      selectedItemColor: mainFrameIconsColor,
      unselectedItemColor: mainFrameIconsColor,
      selectedFontSize: iconNameFontSize,
      unselectedFontSize: iconNameFontSize,
      iconSize: mainIconSize,
    );
  }
}

PreferredSizeWidget customAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: itemsColor,
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
          color: mainFrameIconsColor,
          size: mainIconSize,
        ),
        label: Text(
          S.of(context).logout,
          style: const TextStyle(color: mainFrameIconsColor, fontSize: iconNameFontSize),
        ),
      ),
    ],
  );
}
