import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tablets/generated/l10n.dart';
import 'package:tablets/src/common/functions/debug_print.dart';
import 'package:tablets/src/common/functions/dialog_delete_confirmation.dart';
import 'package:tablets/src/common/providers/data_loading_provider.dart';
import 'package:tablets/src/common/widgets/main_drawer.dart';
import 'package:tablets/src/features/transactions/controllers/form_data_container.dart';
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
    ref.watch(loadingProvider);
    return Scaffold(
      appBar: AppBar(backgroundColor: itemsColor),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              color: bgColor,
              child: LoadingWrapper(
                  child: Container(padding: const EdgeInsets.all(25.0), child: child)),
            ),
          ),
        ],
      ),
      endDrawer: const MainDrawer(),
      bottomNavigationBar: includeBottomNavigation ? _buildBottomNavigation(context, ref) : null,
    );
  }

  Widget _buildBottomNavigation(BuildContext context, WidgetRef ref) {
    final formDataNotifier = ref.read(formDataContainerProvider.notifier);
    return BottomNavigationBar(
      onTap: (index) async {
        switch (index) {
          case 0:
            if (GoRouter.of(context).state.path != '/home') {
              ref.read(loadingProvider.notifier).loadCustomers();
              GoRouter.of(context).pushNamed(AppRoute.home.name);
            }
            break;

          case 1:
            if (GoRouter.of(context).state.path != '/cart' &&
                formDataNotifier.data['name'] != null) {
              GoRouter.of(context).pushNamed(AppRoute.cart.name);
            }
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

PreferredSizeWidget customAppBar(BuildContext context, WidgetRef ref) {
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
