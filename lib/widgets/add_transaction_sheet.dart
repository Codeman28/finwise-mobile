// add_transaction_sheet.dart
// ---------------------------------------------------------------------------
// The bottom sheet that adds an income or an expense.
//
// Layout (top to bottom):
//   [ Khoản chi | Khoản thu ]     <- animated toggle
//   1.500.000 ₫                   <- big amount, dots added while typing
//   category chips                <- tap one (icons make them easy to scan)
//   note + date                   <- optional details
//   [ Lưu giao dịch ]             <- coral CTA, disabled until the amount is valid
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/format.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Opens the sheet. Returns the saved transaction, or null if cancelled.
Future<Txn?> showAddTransactionSheet(BuildContext context, AppState state, {bool startAsIncome = false}) {
  return showModalBottomSheet<Txn>(
    context: context,
    isScrollControlled: true, // lets the sheet grow above the keyboard
    useSafeArea: true,
    builder: (_) => _AddTransactionSheet(state: state, startAsIncome: startAsIncome),
  );
}

class _AddTransactionSheet extends StatefulWidget {
  const _AddTransactionSheet({required this.state, required this.startAsIncome});

  final AppState state;
  final bool startAsIncome;

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late bool _isIncome = widget.startAsIncome;
  late String _category = _categories.first.name;
  DateTime _date = DateTime.now();

  List<CategoryInfo> get _categories => _isIncome ? Categories.income : Categories.expense;

  /// The typed amount, or null while it is empty/invalid.
  int? get _amount => parseVnd(_amountController.text);

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _switchKind(bool isIncome) {
    if (isIncome == _isIncome) {
      return;
    }
    setState(() {
      _isIncome = isIncome;
      _category = _categories.first.name; // categories differ per kind
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Chọn ngày giao dịch',
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day, 12));
    }
  }

  void _save() {
    final amount = _amount;
    if (amount == null) {
      return;
    }
    final txn = Txn(
      date: _date,
      amount: amount.toDouble(),
      isIncome: _isIncome,
      category: _category,
      note: _noteController.text.trim(),
    );
    widget.state.addTxn(txn);
    HapticFeedback.mediumImpact();
    Navigator.pop(context, txn);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    // Push content above the on-screen keyboard.
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, Gaps.lg + keyboard),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Thêm giao dịch', style: text.headlineSmall),
            const SizedBox(height: Gaps.lg),
            _KindToggle(isIncome: _isIncome, onChanged: _switchKind),
            const SizedBox(height: Gaps.lg),
            VndField(
              controller: _amountController,
              autofocus: true,
              big: true,
              onChanged: (_) => setState(() {}), // refresh the button state
            ),
            const SizedBox(height: Gaps.lg),
            Text('Danh mục', style: text.labelMedium),
            const SizedBox(height: Gaps.sm),
            _CategoryPicker(
              categories: _categories,
              selected: _category,
              isIncome: _isIncome,
              onSelected: (name) => setState(() => _category = name),
            ),
            const SizedBox(height: Gaps.lg),
            TextField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ghi chú (không bắt buộc) - VD: Ăn trưa với Lan',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
            ),
            const SizedBox(height: Gaps.md),
            _DateRow(date: _date, onTap: _pickDate),
            const SizedBox(height: Gaps.xl),
            PrimaryCta(
              label: _amount == null ? 'Nhập số tiền để lưu' : 'Lưu ${formatVnd(_amount!)}',
              icon: Icons.check_rounded,
              onPressed: _amount == null ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Private components
// ===========================================================================

/// Two-segment switch with a sliding highlight (AnimatedAlign).
class _KindToggle extends StatelessWidget {
  const _KindToggle({required this.isIncome, required this.onChanged});

  final bool isIncome;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final highlight = isIncome ? fin.green : fin.red;

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: fin.surfaceAlt, borderRadius: BorderRadius.circular(Gaps.radius)),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: isIncome ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                decoration: BoxDecoration(color: highlight, borderRadius: BorderRadius.circular(Gaps.radius - 4)),
              ),
            ),
          ),
          Row(
            children: [
              _KindOption(label: 'Khoản chi', icon: Icons.south_west_rounded, active: !isIncome, onTap: () => onChanged(false)),
              _KindOption(label: 'Khoản thu', icon: Icons.north_east_rounded, active: isIncome, onTap: () => onChanged(true)),
            ],
          ),
        ],
      ),
    );
  }
}

class _KindOption extends StatelessWidget {
  const _KindOption({required this.label, required this.icon, required this.active, required this.onTap});

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : context.fin.textMuted;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(fontFamily: AppTheme.fontFamily, color: color, fontWeight: FontWeight.w700, fontSize: 15),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wrap of tappable category chips; the selected one is filled.
class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.categories,
    required this.selected,
    required this.isIncome,
    required this.onSelected,
  });

  final List<CategoryInfo> categories;
  final String selected;
  final bool isIncome;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final accent = isIncome ? fin.green : fin.red;
    return Wrap(
      spacing: Gaps.sm,
      runSpacing: Gaps.sm,
      children: [
        for (final category in categories)
          _CategoryChip(
            info: category,
            selected: category.name == selected,
            accent: accent,
            onTap: () => onSelected(category.name),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.info, required this.selected, required this.accent, required this.onTap});

  final CategoryInfo info;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final foreground = selected ? Colors.white : fin.text;
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? accent : fin.surfaceAlt,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(info.icon, size: 17, color: selected ? Colors.white : accent),
            const SizedBox(width: 6),
            Text(info.name, style: TextStyle(color: foreground, fontWeight: FontWeight.w600, fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: fin.surfaceAlt, borderRadius: BorderRadius.circular(Gaps.radiusSm)),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: fin.green),
            const SizedBox(width: Gaps.md),
            Expanded(child: Text('${formatRelativeDay(date)} · ${formatDate(date)}')),
            Icon(Icons.chevron_right_rounded, color: fin.textMuted),
          ],
        ),
      ),
    );
  }
}
