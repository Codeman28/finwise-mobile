// plan_screen.dart
// ---------------------------------------------------------------------------
// "Kế hoạch" - Budgets (Ngân sách) and savings Goals (Mục tiêu) in one tab,
// switched with an animated segmented control.
//
//   Budgets: monthly limit per category, coloured progress bars
//            (green = ok, coral = 80%+, red = over), tap a card to edit.
//   Goals:   savings targets with progress, "Thêm tiền" and a monthly plan.
//   Data:    load sample data / clear money data (real wallet only).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../core/finance.dart';
import '../core/format.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key, required this.state, this.embedded = false, this.initialGoals = false});

  final AppState state;
  final bool embedded; // inside the practice sandbox
  final bool initialGoals; // open on the Goals segment

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late bool _showGoals = widget.initialGoals;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.embedded) ...[
          const SizedBox(height: Gaps.sm),
          Text('Kế hoạch', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: Gaps.lg),
        ],
        _Segments(showGoals: _showGoals, onChanged: (value) => setState(() => _showGoals = value)),
        const SizedBox(height: Gaps.lg),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(animation),
              child: child,
            ),
          ),
          child: _showGoals
              ? _GoalsSection(key: const ValueKey('goals'), state: widget.state)
              : _BudgetsSection(key: const ValueKey('budgets'), state: widget.state),
        ),
        if (!widget.embedded) ...[
          const SizedBox(height: Gaps.xl),
          _DataSettings(state: widget.state),
        ],
      ],
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
// Segmented control
// ===========================================================================

class _Segments extends StatelessWidget {
  const _Segments({required this.showGoals, required this.onChanged});

  final bool showGoals;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: fin.surface, borderRadius: BorderRadius.circular(Gaps.radius)),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: showGoals ? Alignment.centerRight : Alignment.centerLeft,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: fin.green, borderRadius: BorderRadius.circular(Gaps.radius - 4)),
              ),
            ),
          ),
          Row(
            children: [
              _SegmentLabel(label: 'Ngân sách', icon: Icons.pie_chart_rounded, active: !showGoals, onTap: () => onChanged(false)),
              _SegmentLabel(label: 'Mục tiêu', icon: Icons.flag_rounded, active: showGoals, onTap: () => onChanged(true)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel({required this.label, required this.icon, required this.active, required this.onTap});

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
        // FittedBox shrinks the label slightly if the phone is very narrow or
        // the user picked a large system font, instead of overflowing.
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Budgets
// ===========================================================================

class _BudgetsSection extends StatelessWidget {
  const _BudgetsSection({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final monthTxns = inMonth(state.txns, DateTime.now());
    final statuses = state.budgets.map((b) => budgetStatus(b, monthTxns)).toList()
      ..sort((a, b) => b.ratio.compareTo(a.ratio));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BudgetSummary(statuses: statuses, income: totalIncome(monthTxns)),
        const SizedBox(height: Gaps.lg),
        if (statuses.isEmpty)
          FinCard(
            child: EmptyState(
              icon: Icons.pie_chart_rounded,
              title: 'Chưa có ngân sách',
              message: 'Ngân sách giúp bạn chi tiêu có chủ đích. Hãy bắt đầu với khoản linh hoạt lớn nhất, như ăn uống.',
              action: PrimaryCta(
                label: 'Đặt ngân sách đầu tiên',
                icon: Icons.add_rounded,
                expanded: false,
                onPressed: () => _showBudgetEditor(context, state),
              ),
            ),
          )
        else ...[
          for (var i = 0; i < statuses.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gaps.md),
              child: FadeSlideIn(
                delayIndex: i,
                child: _BudgetCard(
                  status: statuses[i],
                  onTap: () => _showBudgetEditor(context, state, existing: statuses[i].budget),
                ),
              ),
            ),
          SecondaryButton(
            label: 'Thêm ngân sách',
            icon: Icons.add_rounded,
            onPressed: () => _showBudgetEditor(context, state),
          ),
        ],
        _UnbudgetedHint(state: state, monthTxns: monthTxns),
      ],
    );
  }
}

class _BudgetSummary extends StatelessWidget {
  const _BudgetSummary({required this.statuses, required this.income});

  final List<BudgetStatus> statuses;
  final double income;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final limit = statuses.fold<double>(0, (sum, s) => sum + s.limit);
    final spent = statuses.fold<double>(0, (sum, s) => sum + s.spent);
    final ratio = limit > 0 ? spent / limit : 0.0;
    final overCount = statuses.where((s) => s.state == BudgetState.over).length;

    String message;
    if (statuses.isEmpty) {
      message = 'Đặt hạn mức cho từng danh mục để theo dõi tại đây.';
    } else if (overCount > 0) {
      message = '$overCount ngân sách đã vượt. Hãy tạm dừng vài khoản "muốn".';
    } else {
      message = 'Mọi ngân sách đều trong tầm kiểm soát. Tuyệt vời!';
    }

    return FinCard(
      padding: const EdgeInsets.all(Gaps.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatMonth(DateTime.now()), style: text.labelMedium),
          const SizedBox(height: Gaps.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text('${formatVnd(spent)} / ${formatVnd(limit)}', style: text.headlineSmall),
          ),
          const SizedBox(height: Gaps.md),
          SoftProgressBar(value: ratio, color: ratio > 1 ? fin.red : (ratio >= warningLevel ? fin.coral : fin.green), height: 12),
          const SizedBox(height: Gaps.md),
          Text(message, style: text.bodySmall),
          if (income > 0 && limit > 0) ...[
            const SizedBox(height: 4),
            Text('Tổng ngân sách bằng ${formatPercent(limit / income)} thu nhập tháng này.', style: text.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.status, required this.onTap});

  final BudgetStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (color, soft) = budgetColors(context, status.state);
    const labels = {BudgetState.ok: 'Ổn định', BudgetState.warning: 'Cẩn thận', BudgetState.over: 'Vượt ngân sách'};
    final left = status.remaining >= 0 ? 'Còn ${formatVnd(status.remaining)}' : 'Vượt ${formatVnd(-status.remaining)}';

    return FinCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              IconBubble(icon: Categories.find(status.budget.category).icon, color: color, background: soft),
              const SizedBox(width: Gaps.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(status.budget.category, style: text.titleMedium),
                    const SizedBox(height: 4),
                    Pill(text: labels[status.state]!, color: color, background: soft),
                  ],
                ),
              ),
              Icon(Icons.edit_rounded, size: 18, color: context.fin.textMuted),
            ],
          ),
          const SizedBox(height: Gaps.md),
          SoftProgressBar(value: status.ratio, color: color),
          const SizedBox(height: Gaps.sm),
          Row(
            children: [
              Expanded(child: Text('${formatVnd(status.spent)} / ${formatVnd(status.limit)}', style: text.bodySmall)),
              Text(left, style: text.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnbudgetedHint extends StatelessWidget {
  const _UnbudgetedHint({required this.state, required this.monthTxns});

  final AppState state;
  final List<Txn> monthTxns;

  @override
  Widget build(BuildContext context) {
    final budgeted = state.budgets.map((b) => b.category).toSet();
    final missing = spendingByCategory(monthTxns)
        .entries
        .where((e) => !budgeted.contains(e.key) && e.key != Categories.savings)
        .toList();
    if (missing.isEmpty) {
      return const SizedBox.shrink();
    }
    final fin = context.fin;
    return Padding(
      padding: const EdgeInsets.only(top: Gaps.lg),
      child: FinCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Chi tiêu chưa có ngân sách', subtitle: 'Chạm để đặt hạn mức nhanh'),
            const SizedBox(height: Gaps.md),
            Wrap(
              spacing: Gaps.sm,
              runSpacing: Gaps.sm,
              children: [
                for (final entry in missing)
                  ActionChip(
                    avatar: Icon(Categories.find(entry.key).icon, size: 16, color: fin.coral),
                    label: Text('${entry.key}: ${formatVndCompact(entry.value)}'),
                    onPressed: () => _showBudgetEditor(context, state, presetCategory: entry.key),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet to create or edit a budget.
Future<void> _showBudgetEditor(BuildContext context, AppState state, {Budget? existing, String? presetCategory}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _BudgetEditor(state: state, existing: existing, presetCategory: presetCategory),
  );
}

class _BudgetEditor extends StatefulWidget {
  const _BudgetEditor({required this.state, this.existing, this.presetCategory});

  final AppState state;
  final Budget? existing;
  final String? presetCategory;

  @override
  State<_BudgetEditor> createState() => _BudgetEditorState();
}

class _BudgetEditorState extends State<_BudgetEditor> {
  late String _category = widget.existing?.category ?? widget.presetCategory ?? Categories.budgetable.first;
  late final _limitController = TextEditingController(
    text: widget.existing == null ? '' : formatVnd(widget.existing!.limit, withSymbol: false),
  );

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _save() {
    final limit = parseVnd(_limitController.text);
    if (limit == null) {
      return;
    }
    widget.state.setBudget(_category, limit.toDouble());
    Navigator.pop(context);
    showFinSnack(context, 'Ngân sách $_category: ${formatVnd(limit)}/tháng');
  }

  Future<void> _delete() async {
    final confirmed = await confirmDialog(
      context,
      title: 'Gỡ ngân sách này?',
      message: 'Hạn mức $_category sẽ bị gỡ. Các giao dịch vẫn được giữ.',
      confirmLabel: 'Gỡ',
    );
    if (confirmed && mounted) {
      widget.state.removeBudget(_category);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fin = context.fin;
    final isEditing = widget.existing != null;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, Gaps.lg + keyboard),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEditing ? 'Sửa ngân sách' : 'Đặt ngân sách', style: text.headlineSmall),
            const SizedBox(height: Gaps.lg),
            if (!isEditing) ...[
              Text('Danh mục', style: text.labelMedium),
              const SizedBox(height: Gaps.sm),
              Wrap(
                spacing: Gaps.sm,
                runSpacing: Gaps.sm,
                children: [
                  for (final name in Categories.budgetable)
                    ChoiceChip(
                      avatar: Icon(Categories.find(name).icon, size: 16, color: _category == name ? fin.green : fin.textMuted),
                      label: Text(name),
                      selected: _category == name,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _category = name),
                    ),
                ],
              ),
              const SizedBox(height: Gaps.lg),
            ] else
              Padding(
                padding: const EdgeInsets.only(bottom: Gaps.lg),
                child: Text(_category, style: text.titleLarge),
              ),
            VndField(
              controller: _limitController,
              label: 'Hạn mức mỗi tháng',
              autofocus: true,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: Gaps.xl),
            PrimaryCta(
              label: 'Lưu ngân sách',
              icon: Icons.check_rounded,
              onPressed: parseVnd(_limitController.text) == null ? null : _save,
            ),
            if (isEditing) ...[
              const SizedBox(height: Gaps.sm),
              TextButton(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: fin.red),
                child: const Text('Gỡ ngân sách này'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Goals
// ===========================================================================

class _GoalsSection extends StatelessWidget {
  const _GoalsSection({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final goals = state.goals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (goals.isEmpty)
          FinCard(
            child: EmptyState(
              icon: Icons.flag_rounded,
              title: 'Chưa có mục tiêu',
              message: 'Bạn đang để dành cho điều gì? Laptop, chuyến đi, hay quỹ khẩn cấp?',
              action: PrimaryCta(
                label: 'Tạo mục tiêu',
                icon: Icons.add_rounded,
                expanded: false,
                onPressed: () => _showGoalCreator(context, state),
              ),
            ),
          )
        else ...[
          _GoalsOverview(goals: goals),
          const SizedBox(height: Gaps.lg),
          for (var i = 0; i < goals.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gaps.md),
              child: FadeSlideIn(delayIndex: i, child: _GoalCard(state: state, goal: goals[i])),
            ),
          SecondaryButton(label: 'Tạo mục tiêu mới', icon: Icons.add_rounded, onPressed: () => _showGoalCreator(context, state)),
        ],
      ],
    );
  }
}

class _GoalsOverview extends StatelessWidget {
  const _GoalsOverview({required this.goals});

  final List<Goal> goals;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final saved = goals.fold<double>(0, (sum, g) => sum + g.saved);
    final target = goals.fold<double>(0, (sum, g) => sum + g.target);
    final reached = goals.where((g) => g.saved >= g.target).length;

    return FinCard(
      gradient: LinearGradient(colors: [fin.greenSoft, fin.coralSoft], begin: Alignment.topLeft, end: Alignment.bottomRight),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Đã để dành', style: text.labelMedium),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AnimatedMoney(amount: saved, style: text.headlineSmall),
                ),
                const SizedBox(height: 4),
                Text('trên tổng ${formatVnd(target)}', style: text.bodySmall),
              ],
            ),
          ),
          Pill(text: 'Đạt $reached/${goals.length}', color: fin.green, background: fin.surface, icon: Icons.emoji_events_rounded),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.state, required this.goal});

  final AppState state;
  final Goal goal;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Xóa mục tiêu?',
      message: '"${goal.name}" sẽ bị xóa. Số tiền đã ghi nhận là tiết kiệm vẫn còn trong lịch sử giao dịch.',
    );
    if (confirmed) {
      state.deleteGoal(goal.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final progress = goalProgress(goal);
    final remaining = (goal.target - goal.saved).clamp(0, double.infinity).toDouble();
    final done = remaining == 0;

    return FinCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: fin.surfaceAlt, borderRadius: BorderRadius.circular(14)),
                child: Text(goal.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: Gaps.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name, style: text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('${formatVnd(goal.saved)} / ${formatVnd(goal.target)}', style: text.bodySmall),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Xóa mục tiêu',
                onPressed: () => _delete(context),
                icon: Icon(Icons.delete_outline_rounded, color: fin.textMuted),
              ),
            ],
          ),
          const SizedBox(height: Gaps.md),
          SoftProgressBar(value: progress, color: done ? fin.green : fin.coral, height: 12),
          const SizedBox(height: Gaps.sm),
          Row(
            children: [
              Text(formatPercent(progress), style: text.titleSmall?.copyWith(color: done ? fin.green : fin.coral)),
              const Spacer(),
              if (!done)
                Flexible(
                  child: Text(
                    'Để kịp 12 tháng: ${formatVndCompact(remaining / 12)}/tháng',
                    style: text.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: Gaps.md),
          if (done)
            Pill(text: 'Đã đạt mục tiêu! 🎉', color: fin.green, background: fin.greenSoft)
          else
            SizedBox(
              width: double.infinity,
              child: SecondaryButton(
                label: 'Thêm tiền',
                icon: Icons.savings_rounded,
                onPressed: () => _showContribute(context, state, goal),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> _showContribute(BuildContext context, AppState state, Goal goal) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ContributeSheet(state: state, goal: goal),
  );
}

class _ContributeSheet extends StatefulWidget {
  const _ContributeSheet({required this.state, required this.goal});

  final AppState state;
  final Goal goal;

  @override
  State<_ContributeSheet> createState() => _ContributeSheetState();
}

class _ContributeSheetState extends State<_ContributeSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final amount = parseVnd(_controller.text);
    if (amount == null) {
      return;
    }
    widget.state.contributeToGoal(widget.goal.id, amount.toDouble());
    Navigator.pop(context);
    showFinSnack(context, 'Đã thêm ${formatVnd(amount)} vào "${widget.goal.name}"');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    // Quick amounts make the most common action one tap.
    const quick = [50000, 100000, 200000, 500000];

    return Padding(
      padding: EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, Gaps.lg + keyboard),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${widget.goal.emoji} ${widget.goal.name}', style: text.headlineSmall),
          const SizedBox(height: Gaps.xs),
          Text('Số tiền sẽ được ghi là khoản "Tiết kiệm".', style: text.bodySmall),
          const SizedBox(height: Gaps.lg),
          VndField(controller: _controller, big: true, autofocus: true, onChanged: (_) => setState(() {})),
          const SizedBox(height: Gaps.md),
          Wrap(
            spacing: Gaps.sm,
            children: [
              for (final amount in quick)
                ActionChip(
                  label: Text('+${formatVndCompact(amount)}'),
                  onPressed: () {
                    final current = parseVnd(_controller.text) ?? 0;
                    _controller.text = formatVnd(current + amount, withSymbol: false);
                    setState(() {});
                  },
                ),
            ],
          ),
          const SizedBox(height: Gaps.xl),
          PrimaryCta(
            label: 'Để dành ngay',
            icon: Icons.savings_rounded,
            onPressed: parseVnd(_controller.text) == null ? null : _save,
          ),
        ],
      ),
    );
  }
}

Future<void> _showGoalCreator(BuildContext context, AppState state) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _GoalCreator(state: state),
  );
}

class _GoalCreator extends StatefulWidget {
  const _GoalCreator({required this.state});

  final AppState state;

  @override
  State<_GoalCreator> createState() => _GoalCreatorState();
}

class _GoalCreatorState extends State<_GoalCreator> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  String _emoji = '🎯';

  static const _emojis = ['🎯', '🛟', '💻', '📱', '✈️', '🏍️', '🎓', '🎁', '🏠', '🎸'];

  bool get _valid => _nameController.text.trim().isNotEmpty && parseVnd(_targetController.text) != null;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_valid) {
      return;
    }
    final name = _nameController.text.trim();
    widget.state.addGoal(Goal(name: name, target: parseVnd(_targetController.text)!.toDouble(), emoji: _emoji));
    Navigator.pop(context);
    showFinSnack(context, 'Đã tạo mục tiêu "$name"');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fin = context.fin;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, Gaps.lg + keyboard),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Mục tiêu mới', style: text.headlineSmall),
            const SizedBox(height: Gaps.lg),
            Wrap(
              spacing: Gaps.sm,
              runSpacing: Gaps.sm,
              children: [
                for (final emoji in _emojis)
                  PressableScale(
                    onTap: () => setState(() => _emoji = emoji),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _emoji == emoji ? fin.greenSoft : fin.surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _emoji == emoji ? fin.green : Colors.transparent, width: 2),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Gaps.lg),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Tên mục tiêu', hintText: 'VD: Quỹ khẩn cấp'),
            ),
            const SizedBox(height: Gaps.md),
            VndField(controller: _targetController, label: 'Số tiền cần có', onChanged: (_) => setState(() {})),
            const SizedBox(height: Gaps.xl),
            PrimaryCta(label: 'Tạo mục tiêu', icon: Icons.flag_rounded, onPressed: _valid ? _save : null),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Data settings
// ===========================================================================

class _DataSettings extends StatelessWidget {
  const _DataSettings({required this.state});

  final AppState state;

  Future<void> _clear(BuildContext context) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Xóa toàn bộ dữ liệu tiền?',
      message: 'Mọi giao dịch, ngân sách và mục tiêu sẽ bị xóa. Tiến độ học vẫn được giữ. Không thể hoàn tác.',
      confirmLabel: 'Xóa tất cả',
    );
    if (confirmed && context.mounted) {
      state.resetMoney();
      showFinSnack(context, 'Đã xóa dữ liệu tiền.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return FinCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Cài đặt dữ liệu', subtitle: 'Dữ liệu chỉ lưu trên điện thoại của bạn'),
          const SizedBox(height: Gaps.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.auto_awesome_rounded, color: fin.green),
            title: const Text('Tải dữ liệu mẫu'),
            subtitle: const Text('Thêm 3 tháng giao dịch ví dụ'),
            onTap: () {
              state.loadSampleData();
              showFinSnack(context, 'Đã tải dữ liệu mẫu.');
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_sweep_rounded, color: fin.red),
            title: Text('Xóa dữ liệu tiền', style: TextStyle(color: fin.red)),
            subtitle: const Text('Giữ lại tiến độ học'),
            onTap: () => _clear(context),
          ),
        ],
      ),
    );
  }
}
