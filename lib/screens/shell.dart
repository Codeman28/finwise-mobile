// shell.dart
// ---------------------------------------------------------------------------
// The frame around every screen: bottom navigation with 5 tabs and the
// coral "Thêm" button.
//
// IndexedStack keeps every tab alive, so switching tabs does not lose your
// scroll position. ListenableBuilder rebuilds the tabs whenever AppState
// changes (a transaction added, a lesson completed ...).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/common.dart';
import 'home_screen.dart';
import 'learn_screen.dart';
import 'plan_screen.dart';
import 'practice_screen.dart';
import 'transactions_screen.dart';

/// Tab indexes, named so code reads `Tabs.learn` instead of a magic `3`.
class Tabs {
  Tabs._();
  static const home = 0;
  static const transactions = 1;
  static const plan = 2;
  static const learn = 3;
  static const practice = 4;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.state});

  final AppState state;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = Tabs.home;

  void _goTo(int tab) => setState(() => _tab = tab);

  Future<void> _addTransaction() async {
    final saved = await showAddTransactionSheet(context, widget.state);
    if (saved != null && mounted) {
      showFinSnack(context, 'Đã lưu "${saved.title}"');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        // Only one main call-to-action per screen: while the wallet is empty,
        // the welcome/empty-state card already has its own "add" button, so
        // the floating button stays hidden until the first transaction.
        final onMoneyTab = _tab == Tabs.home || _tab == Tabs.transactions;
        final showFab = onMoneyTab && widget.state.txns.isNotEmpty;

        return Scaffold(
          body: IndexedStack(
            index: _tab,
            children: [
              HomeScreen(state: widget.state, onNavigate: _goTo, onAdd: _addTransaction),
              TransactionsScreen(state: widget.state, onAdd: _addTransaction),
              PlanScreen(state: widget.state),
              LearnScreen(state: widget.state, onNavigate: _goTo),
              PracticeScreen(state: widget.state),
            ],
          ),
          floatingActionButton: AnimatedScale(
            scale: showFab ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: _AddFab(onPressed: showFab ? _addTransaction : null),
          ),
          bottomNavigationBar: _BottomNav(selected: _tab, onSelected: _goTo),
        );
      },
    );
  }
}

// ===========================================================================
// Private components
// ===========================================================================

class _AddFab extends StatelessWidget {
  const _AddFab({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Thêm giao dịch',
      child: PrimaryCta(label: 'Thêm', icon: Icons.add_rounded, expanded: false, onPressed: onPressed),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: fin.shadow, blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: onSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Giao dịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag_rounded),
            label: 'Kế hoạch',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Học',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports_rounded),
            label: 'Luyện tập',
          ),
        ],
      ),
    );
  }
}
