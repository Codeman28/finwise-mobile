// transactions_screen.dart
// ---------------------------------------------------------------------------
// "Giao dịch" - every income and expense, newest first, grouped by day.
//
//   * Search box + filter chips (Tất cả / Khoản thu / Khoản chi)
//   * Swipe a row to the left to delete it, with "Hoàn tác" (undo)
//   * Friendly empty states for "no data yet" and "no search results"
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/finance.dart';
import '../core/format.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

enum _Filter { all, income, expense }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key, required this.state, required this.onAdd, this.embedded = false});

  final AppState state;
  final VoidCallback onAdd;

  /// true inside the Practice sandbox: no big page title, no own scrolling.
  final bool embedded;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _Filter _filter = _Filter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(Txn txn) {
    if (_filter == _Filter.income && !txn.isIncome) {
      return false;
    }
    if (_filter == _Filter.expense && txn.isIncome) {
      return false;
    }
    final needle = _query.trim().toLowerCase();
    if (needle.isEmpty) {
      return true;
    }
    final haystack = '${txn.note} ${txn.category}'.toLowerCase();
    return haystack.contains(needle);
  }

  /// Groups the visible transactions by calendar day, newest day first.
  List<(DateTime, List<Txn>)> _groupByDay(List<Txn> txns) {
    final groups = <(DateTime, List<Txn>)>[];
    for (final txn in txns) {
      final day = DateTime(txn.date.year, txn.date.month, txn.date.day);
      if (groups.isNotEmpty && groups.last.$1 == day) {
        groups.last.$2.add(txn);
      } else {
        groups.add((day, [txn]));
      }
    }
    return groups;
  }

  void _delete(Txn txn) {
    HapticFeedback.mediumImpact();
    widget.state.deleteTxn(txn.id);
    showFinSnack(
      context,
      'Đã xóa "${txn.title}"',
      actionLabel: 'Hoàn tác',
      onAction: () => widget.state.addTxn(txn), // put it back
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.state.txnsNewestFirst.where(_matches).toList();
    final groups = _groupByDay(visible);

    final header = <Widget>[
      if (!widget.embedded) ...[
        const SizedBox(height: Gaps.sm),
        Text('Giao dịch', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: Gaps.lg),
      ],
      _SearchBox(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
      ),
      const SizedBox(height: Gaps.md),
      _FilterChips(selected: _filter, onSelected: (f) => setState(() => _filter = f)),
      const SizedBox(height: Gaps.lg),
      if (visible.isNotEmpty) _TotalsStrip(txns: visible),
    ];

    Widget body;
    if (widget.state.txns.isEmpty) {
      body = EmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'Chưa có giao dịch nào',
        message: 'Ghi lại khoản thu hoặc chi đầu tiên - chỉ mất vài giây.',
        action: PrimaryCta(label: 'Thêm giao dịch', icon: Icons.add_rounded, expanded: false, onPressed: widget.onAdd),
      );
    } else if (visible.isEmpty) {
      body = const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Không tìm thấy',
        message: 'Thử từ khóa khác hoặc đổi bộ lọc.',
      );
    } else {
      body = Column(
        children: [
          for (final (day, txns) in groups) _DayGroup(day: day, txns: txns, onDelete: _delete),
        ],
      );
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [...header, body],
    );

    if (widget.embedded) {
      return content;
    }
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(padding: pagePadding, child: content),
    );
  }
}

// ===========================================================================
// Private components
// ===========================================================================

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Tìm theo ghi chú hoặc danh mục',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Xóa tìm kiếm',
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final _Filter selected;
  final ValueChanged<_Filter> onSelected;

  @override
  Widget build(BuildContext context) {
    const labels = {_Filter.all: 'Tất cả', _Filter.income: 'Khoản thu', _Filter.expense: 'Khoản chi'};
    return Wrap(
      spacing: Gaps.sm,
      children: [
        for (final entry in labels.entries)
          ChoiceChip(
            label: Text(entry.value),
            selected: selected == entry.key,
            showCheckmark: false,
            onSelected: (_) => onSelected(entry.key),
            labelStyle: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w700,
              color: selected == entry.key ? context.fin.green : context.fin.textMuted,
            ),
          ),
      ],
    );
  }
}

class _TotalsStrip extends StatelessWidget {
  const _TotalsStrip({required this.txns});

  final List<Txn> txns;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gaps.sm),
      child: Wrap(
        spacing: Gaps.sm,
        runSpacing: Gaps.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('${txns.length} giao dịch', style: Theme.of(context).textTheme.bodySmall),
          Pill(text: 'Thu ${formatVnd(totalIncome(txns))}', color: fin.green, background: fin.greenSoft),
          Pill(text: 'Chi ${formatVnd(totalExpense(txns))}', color: fin.red, background: fin.redSoft),
        ],
      ),
    );
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.day, required this.txns, required this.onDelete});

  final DateTime day;
  final List<Txn> txns;
  final ValueChanged<Txn> onDelete;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dayTotal = totalIncome(txns) - totalExpense(txns);

    return Padding(
      padding: const EdgeInsets.only(top: Gaps.md),
      child: FinCard(
        padding: const EdgeInsets.fromLTRB(Gaps.lg, Gaps.md, Gaps.lg, Gaps.sm),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text(formatRelativeDay(day), style: text.labelMedium)),
                Text(formatVnd(dayTotal, showPlus: true), style: text.labelMedium),
              ],
            ),
            const SizedBox(height: Gaps.xs),
            for (final txn in txns) _SwipeToDelete(txn: txn, onDelete: onDelete),
          ],
        ),
      ),
    );
  }
}

/// Wraps a row so it can be swiped left to delete.
class _SwipeToDelete extends StatelessWidget {
  const _SwipeToDelete({required this.txn, required this.onDelete});

  final Txn txn;
  final ValueChanged<Txn> onDelete;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return Dismissible(
      key: ValueKey(txn.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(txn),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: Gaps.lg),
        decoration: BoxDecoration(color: fin.redSoft, borderRadius: BorderRadius.circular(Gaps.radiusSm)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Xóa', style: TextStyle(color: fin.red, fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            Icon(Icons.delete_rounded, color: fin.red),
          ],
        ),
      ),
      child: TxnTile(txn: txn),
    );
  }
}
