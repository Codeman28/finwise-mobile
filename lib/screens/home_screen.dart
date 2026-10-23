// home_screen.dart
// ---------------------------------------------------------------------------
// "Tổng quan" - your money at a glance.
//
//   _Header            greeting + date
//   _BalanceCard       total balance (hero), this month's income/spending
//   _WelcomeCard       (only when the wallet is empty) sample data / first add
//   _MonthChart        last 6 months, tap a month to see its numbers
//   _CategoryBreakdown where this month's money went
//   _BudgetWatch       the budgets closest to their limit
//   _RecentActivity    the 5 newest transactions
//   _LearnCard         learning progress + next course
//   _TipCard           tip of the day (from the toolkit)
// ---------------------------------------------------------------------------

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../content/courses.dart';
import '../core/finance.dart';
import '../core/format.dart';
import '../data/app_state.dart';
import '../data/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'lesson_screen.dart';
import 'shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.state, required this.onNavigate, required this.onAdd});

  final AppState state;
  final ValueChanged<int> onNavigate;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthTxns = inMonth(state.txns, now);

    // Each section is a separate widget; `index` staggers their entrance.
    final sections = <Widget>[
      _Header(now: now),
      _BalanceCard(allTxns: state.txns, monthTxns: monthTxns),
      if (state.txns.isEmpty) _WelcomeCard(state: state, onAdd: onAdd),
      if (state.txns.isNotEmpty) ...[
        _MonthChart(history: monthlyHistory(state.txns)),
        _CategoryBreakdown(totals: spendingByCategory(monthTxns)),
        _BudgetWatch(state: state, monthTxns: monthTxns, onSeeAll: () => onNavigate(Tabs.plan)),
        _RecentActivity(txns: state.txnsNewestFirst.take(5).toList(), onSeeAll: () => onNavigate(Tabs.transactions)),
      ],
      _LearnCard(state: state, onOpenLearn: () => onNavigate(Tabs.learn)),
      _TipCard(now: now),
    ];

    return SafeArea(
      bottom: false,
      child: ListView.separated(
        padding: pagePadding,
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: Gaps.lg),
        itemBuilder: (context, index) => FadeSlideIn(delayIndex: index, child: sections[index]),
      ),
    );
  }
}

// ===========================================================================
// Private components
// ===========================================================================

class _Header extends StatelessWidget {
  const _Header({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fin = context.fin;
    return Padding(
      padding: const EdgeInsets.only(top: Gaps.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${weekdayName(now)}, ${formatDate(now)}', style: text.labelMedium),
                const SizedBox(height: 4),
                Text('${greetingFor(now)} 👋', style: text.headlineMedium),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Palette.greenLight, Palette.green]),
              boxShadow: [BoxShadow(color: fin.shadow, blurRadius: 12, offset: const Offset(0, 4))],
            ),
            alignment: Alignment.center,
            child: const Text('F', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

/// Hero card: deep green gradient, decorative circles, big balance.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.allTxns, required this.monthTxns});

  final List<Txn> allTxns;
  final List<Txn> monthTxns;

  @override
  Widget build(BuildContext context) {
    final income = totalIncome(monthTxns);
    final expense = totalExpense(monthTxns);
    final rate = savingsRate(monthTxns);

    return ClipRRect(
      borderRadius: BorderRadius.circular(Gaps.radiusLg),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Palette.greenLight, Palette.green, Color(0xFF00463A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Soft decorative circles give depth without clutter.
            const Positioned(right: -40, top: -50, child: _GlowCircle(size: 170, color: Palette.coral, opacity: 0.35)),
            const Positioned(left: -30, bottom: -60, child: _GlowCircle(size: 150, color: Palette.pink, opacity: 0.18)),
            Padding(
              padding: const EdgeInsets.all(Gaps.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tổng số dư',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: Gaps.sm),
                      _GlassPill(text: 'Tiết kiệm ${formatPercent(rate)}'),
                    ],
                  ),
                  const SizedBox(height: Gaps.sm),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: AnimatedMoney(
                      amount: balanceOf(allTxns),
                      style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: -1),
                    ),
                  ),
                  const SizedBox(height: Gaps.xl),
                  Row(
                    children: [
                      Expanded(child: _FlowStat(label: 'Thu tháng này', amount: income, icon: Icons.north_east_rounded)),
                      const SizedBox(width: Gaps.md),
                      Expanded(child: _FlowStat(label: 'Chi tháng này', amount: expense, icon: Icons.south_west_rounded)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color, required this.opacity});

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)]),
      ),
    );
  }
}

/// Frosted-glass style pill used on top of the green card.
class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class _FlowStat extends StatelessWidget {
  const _FlowStat({required this.label, required this.amount, required this.icon});

  final String label;
  final double amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gaps.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Gaps.radiusSm + 4),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 17),
          ),
          const SizedBox(width: Gaps.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // One line only, so both boxes keep the same height.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(label, maxLines: 1, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AnimatedMoney(
                    amount: amount,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown only when there are no transactions yet.
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.state, required this.onAdd});

  final AppState state;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fin = context.fin;
    return FinCard(
      padding: const EdgeInsets.all(Gaps.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bắt đầu hành trình tài chính ✨', style: text.titleLarge),
          const SizedBox(height: Gaps.sm),
          Text(
            'Ghi lại khoản thu chi đầu tiên, hoặc xem thử ứng dụng với dữ liệu mẫu của một bạn học sinh đi làm thêm.',
            style: text.bodyMedium?.copyWith(color: fin.textMuted),
          ),
          const SizedBox(height: Gaps.lg),
          PrimaryCta(label: 'Thêm giao dịch đầu tiên', icon: Icons.add_rounded, onPressed: onAdd),
          const SizedBox(height: Gaps.sm),
          SizedBox(
            width: double.infinity,
            child: SecondaryButton(
              label: 'Xem với dữ liệu mẫu',
              icon: Icons.auto_awesome_rounded,
              onPressed: () {
                state.loadSampleData();
                showFinSnack(context, 'Đã tải dữ liệu mẫu. Bạn có thể xóa trong mục Kế hoạch → Cài đặt.');
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive bar chart: tap a month to highlight it and read its totals.
class _MonthChart extends StatefulWidget {
  const _MonthChart({required this.history});

  final List<MonthTotals> history;

  @override
  State<_MonthChart> createState() => _MonthChartState();
}

class _MonthChartState extends State<_MonthChart> {
  late int _selected = widget.history.length - 1; // current month

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final history = widget.history;
    final selected = history[_selected.clamp(0, history.length - 1)];

    // The tallest bar fills the chart; the others are in proportion.
    var biggest = 1.0;
    for (final m in history) {
      biggest = math.max(biggest, math.max(m.income, m.expense));
    }

    return FinCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: '6 tháng gần đây', subtitle: 'Chạm vào một tháng để xem chi tiết'),
          const SizedBox(height: Gaps.lg),
          // Summary of the selected month, animated when it changes.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Row(
              key: ValueKey(_selected),
              children: [
                Expanded(child: Text(formatMonth(selected.month), style: text.titleSmall, overflow: TextOverflow.ellipsis)),
                Pill(text: '+${formatVndCompact(selected.income)}', color: fin.green, background: fin.greenSoft),
                const SizedBox(width: 6),
                Pill(text: '-${formatVndCompact(selected.expense)}', color: fin.red, background: fin.redSoft),
              ],
            ),
          ),
          const SizedBox(height: Gaps.lg),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < history.length; i++)
                  Expanded(
                    child: _MonthBars(
                      totals: history[i],
                      biggest: biggest,
                      selected: i == _selected,
                      onTap: () => setState(() => _selected = i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Gaps.md),
          Row(
            children: [
              _LegendDot(color: fin.green, label: 'Thu'),
              const SizedBox(width: Gaps.lg),
              _LegendDot(color: fin.red, label: 'Chi'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthBars extends StatelessWidget {
  const _MonthBars({required this.totals, required this.biggest, required this.selected, required this.onTap});

  final MonthTotals totals;
  final double biggest;
  final bool selected;
  final VoidCallback onTap;

  static const double _maxBarHeight = 118;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final dim = selected ? 1.0 : 0.45;

    Widget bar(double value, Color color) {
      final height = math.max(4.0, value / biggest * _maxBarHeight);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        width: 11,
        height: height,
        decoration: BoxDecoration(
          color: color.withValues(alpha: dim),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [bar(totals.income, fin.green), const SizedBox(width: 3), bar(totals.expense, fin.red)],
          ),
          const SizedBox(height: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? fin.text : fin.textMuted,
            ),
            child: Text('T${totals.month.month}'),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.totals});

  final Map<String, double> totals;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final colors = [fin.green, fin.coral, fin.red, fin.pink, const Color(0xFF3D8C7E), const Color(0xFFF4A393)];

    if (totals.isEmpty) {
      return FinCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Tiền đã đi đâu'),
            const SizedBox(height: Gaps.sm),
            Text('Tháng này chưa có khoản chi nào.', style: text.bodySmall),
          ],
        ),
      );
    }

    final total = totals.values.fold<double>(0, (sum, v) => sum + v);
    final top = totals.entries.take(5).toList();

    return FinCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Tiền đã đi đâu', subtitle: 'Tổng chi tháng này: ${formatVnd(total)}'),
          const SizedBox(height: Gaps.lg),
          // One stacked bar showing every category's share.
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  for (var i = 0; i < top.length; i++)
                    Expanded(
                      // flex must be a whole number: use tenths of a percent
                      flex: math.max(1, (top[i].value / total * 1000).round()),
                      child: Container(color: colors[i % colors.length]),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Gaps.lg),
          for (var i = 0; i < top.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gaps.sm),
              child: Row(
                children: [
                  Icon(Categories.find(top[i].key).icon, size: 18, color: colors[i % colors.length]),
                  const SizedBox(width: Gaps.sm),
                  Expanded(child: Text(top[i].key, style: text.bodyMedium)),
                  Text(formatPercent(top[i].value / total), style: text.bodySmall),
                  const SizedBox(width: Gaps.md),
                  Text(formatVnd(top[i].value), style: text.titleSmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BudgetWatch extends StatelessWidget {
  const _BudgetWatch({required this.state, required this.monthTxns, required this.onSeeAll});

  final AppState state;
  final List<Txn> monthTxns;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final statuses = state.budgets.map((b) => budgetStatus(b, monthTxns)).toList()
      ..sort((a, b) => b.ratio.compareTo(a.ratio)); // closest to the limit first

    return FinCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Theo dõi ngân sách', actionLabel: 'Tất cả', onAction: onSeeAll),
          const SizedBox(height: Gaps.sm),
          if (statuses.isEmpty)
            Text('Chưa có ngân sách. Vào tab Kế hoạch để đặt hạn mức cho từng danh mục.', style: text.bodySmall)
          else
            for (final status in statuses.take(3)) _BudgetRow(status: status),
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.status});

  final BudgetStatus status;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (color, _) = budgetColors(context, status.state);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Gaps.sm),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(status.budget.category, style: text.titleSmall)),
              Text(
                '${formatVndCompact(status.spent)} / ${formatVndCompact(status.limit)}',
                style: text.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SoftProgressBar(value: status.ratio, color: color, height: 8),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.txns, required this.onSeeAll});

  final List<Txn> txns;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return FinCard(
      child: Column(
        children: [
          SectionHeader(title: 'Hoạt động gần đây', actionLabel: 'Xem tất cả', onAction: onSeeAll),
          const SizedBox(height: Gaps.xs),
          for (final txn in txns) TxnTile(txn: txn, showDate: true),
        ],
      ),
    );
  }
}

/// Learning progress ring + the next unfinished course.
class _LearnCard extends StatelessWidget {
  const _LearnCard({required this.state, required this.onOpenLearn});

  final AppState state;
  final VoidCallback onOpenLearn;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final done = courses.where((c) => state.completedLessons.contains(c.id)).length;
    final next = courses.where((c) => !state.completedLessons.contains(c.id)).firstOrNull;

    return FinCard(
      color: fin.coralSoft,
      onTap: next == null ? onOpenLearn : () => openLesson(context, state, next),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(end: done / courses.length),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    color: fin.coral,
                    backgroundColor: fin.surface,
                  ),
                ),
                Text('$done/${courses.length}', style: text.titleSmall),
              ],
            ),
          ),
          const SizedBox(width: Gaps.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(next == null ? 'Bạn đã học xong cả 10 bài! 🎉' : 'Học tiếp', style: text.labelMedium),
                const SizedBox(height: 2),
                Text(
                  next == null ? 'Ôn lại bất kỳ lúc nào' : 'Bài ${next.number}: ${next.title}',
                  style: text.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.play_circle_fill_rounded, color: fin.coral, size: 40),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    // A different tip every day of the year.
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    final tip = dailyTips[dayOfYear % dailyTips.length];

    return FinCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBubble(icon: Icons.lightbulb_rounded, color: fin.coral, background: fin.coralSoft, size: 40),
          const SizedBox(width: Gaps.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mẹo hôm nay', style: text.labelMedium),
                const SizedBox(height: 4),
                Text(tip, style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
