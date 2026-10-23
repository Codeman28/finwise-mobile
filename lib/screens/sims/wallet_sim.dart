// wallet_sim.dart
// ---------------------------------------------------------------------------
// "Ví thử nghiệm" - a sandbox wallet with pretend money.
//
// How it works:
//   1. We create a SECOND AppState with no storage (nothing is ever saved).
//   2. A mission's setup() fills it with a starting situation.
//   3. The REAL Transactions and Plan screens are shown with this sandbox
//      state, so practice looks and feels exactly like the real app.
//   4. Each task is a small function that checks the sandbox; the checklist
//      re-runs them after every change and ticks itself off live.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/finance.dart';
import '../../core/format.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/add_transaction_sheet.dart';
import '../../widgets/common.dart';
import '../plan_screen.dart';
import '../transactions_screen.dart';

// ===========================================================================
// Missions (data + check functions)
// ===========================================================================

typedef _Check = bool Function(AppState s);

class _Task {
  const _Task(this.label, this.check);
  final String label;
  final _Check check;
}

class _Mission {
  const _Mission({
    required this.id,
    required this.title,
    required this.intro,
    required this.tip,
    required this.setup,
    required this.tasks,
    this.startOnPlan = false,
    this.startOnGoals = false,
  });

  final String id;
  final String title;
  final String intro;
  final String tip;
  final void Function(AppState s) setup;
  final List<_Task> tasks;
  final bool startOnPlan;
  final bool startOnGoals;
}

// --- helpers used by the setups and checks --------------------------------

void _income(AppState s, double amount, String category, String note) {
  s.addTxn(Txn(date: DateTime.now(), amount: amount, isIncome: true, category: category, note: note));
}

void _expense(AppState s, double amount, String category, String note) {
  s.addTxn(Txn(date: DateTime.now(), amount: amount, isIncome: false, category: category, note: note));
}

List<Txn> _expenses(AppState s) => s.txns.where((t) => !t.isIncome).toList();

/// Share of income spent in a 50/30/20 group.
double _share(AppState s, SpendGroup group) {
  final income = totalIncome(s.txns);
  if (income <= 0) {
    return 0;
  }
  return spendingByGroup(s.txns)[group]! / income;
}

Goal? _emergencyGoal(AppState s) {
  for (final goal in s.goals) {
    final name = goal.name.toLowerCase();
    if (name.contains('khẩn cấp') || name.contains('khan cap') || name.contains('dự phòng')) {
      return goal;
    }
  }
  return null;
}

final _missions = <_Mission>[
  _Mission(
    id: 'track',
    title: 'Ghi chép tuần đầu',
    intro: 'Bạn vừa nhận 3.000.000 ₫ tiền tiêu vặt. Hãy ghi lại vài khoản chi trong tuần.',
    tip: 'Nhấn "Thêm giao dịch" bên dưới. Thử dùng nhiều danh mục khác nhau.',
    setup: (s) => _income(s, 3000000, 'Tiền tiêu vặt', 'Tiền tiêu vặt tháng này'),
    tasks: [
      _Task('Ghi ít nhất 3 khoản chi', (s) => _expenses(s).length >= 3),
      _Task('Dùng ít nhất 2 danh mục khác nhau', (s) => _expenses(s).map((t) => t.category).toSet().length >= 2),
      _Task('Giữ số dư lớn hơn 0 ₫', (s) => balanceOf(s.txns) > 0),
    ],
  ),
  _Mission(
    id: 'first-budget',
    title: 'Ngân sách đầu tiên',
    intro: 'Lương 6.500.000 ₫, đã trả 2.500.000 ₫ tiền phòng. Lên kế hoạch cho phần còn lại.',
    tip: 'Tiền phòng không có ngân sách nhưng vẫn phải tính: tổng các ngân sách tối đa 4.000.000 ₫.',
    startOnPlan: true,
    setup: (s) {
      _income(s, 6500000, 'Lương', 'Lương part-time');
      _expense(s, 2500000, 'Nhà ở', 'Tiền phòng trọ');
    },
    tasks: [
      _Task('Tạo ngân sách "Ăn uống"', (s) => s.budgets.any((b) => b.category == 'Ăn uống')),
      _Task('Có ngân sách cho ít nhất 3 danh mục', (s) => s.budgets.length >= 3),
      _Task('Tiền phòng + mọi ngân sách không vượt thu nhập', (s) {
        if (s.budgets.isEmpty) {
          return false;
        }
        final budgeted = s.budgets.fold<double>(0, (sum, b) => sum + b.limit);
        final categories = s.budgets.map((b) => b.category).toSet();
        final unbudgeted = _expenses(s).where((t) => !categories.contains(t.category)).fold<double>(0, (sum, t) => sum + t.amount);
        return budgeted + unbudgeted <= totalIncome(s.txns);
      }),
    ],
  ),
  _Mission(
    id: '503020',
    title: 'Quy tắc 50/30/20',
    intro: 'Thu nhập 8.000.000 ₫. Các khoản CẦN đã trả xong (đúng 50%). Giờ hãy dành cho niềm vui và tiết kiệm.',
    tip: '20% của 8.000.000 ₫ là 1.600.000 ₫. Chi vào danh mục "Tiết kiệm", hoặc thêm tiền vào một mục tiêu.',
    setup: (s) {
      _income(s, 8000000, 'Lương', 'Lương tháng');
      _expense(s, 3000000, 'Nhà ở', 'Tiền phòng');
      _expense(s, 900000, 'Ăn uống', 'Đi chợ');
      _expense(s, 100000, 'Đi lại', 'Xe buýt');
    },
    tasks: [
      _Task('Khoản CẦN tối đa 50% thu nhập', (s) => _share(s, SpendGroup.need) <= 0.5),
      _Task('Chi một chút cho khoản MUỐN', (s) => spendingByGroup(s.txns)[SpendGroup.want]! > 0),
      _Task('Khoản MUỐN tối đa 30%', (s) => _share(s, SpendGroup.want) <= 0.3),
      _Task('Tiết kiệm ít nhất 20%', (s) => _share(s, SpendGroup.savings) >= 0.2),
    ],
  ),
  _Mission(
    id: 'emergency',
    title: 'Quỹ khẩn cấp',
    intro: 'Thu nhập 8.000.000 ₫, chi phí thiết yếu 5.000.000 ₫/tháng. Hãy tự bảo vệ trước bất ngờ.',
    tip: 'Mục tiêu nên đủ 3 tháng chi phí thiết yếu (15.000.000 ₫). 10% thu nhập là 800.000 ₫.',
    startOnPlan: true,
    startOnGoals: true,
    setup: (s) {
      _income(s, 8000000, 'Lương', 'Lương tháng');
      _expense(s, 3000000, 'Nhà ở', 'Tiền phòng');
      _expense(s, 1500000, 'Ăn uống', 'Ăn uống cả tháng');
      _expense(s, 300000, 'Đi lại', 'Xăng xe');
      _expense(s, 200000, 'Hóa đơn', 'Điện nước');
    },
    tasks: [
      _Task('Tạo mục tiêu tên có chữ "khẩn cấp"', (s) => _emergencyGoal(s) != null),
      _Task('Mục tiêu đủ 3 tháng chi phí thiết yếu', (s) {
        final goal = _emergencyGoal(s);
        return goal != null && goal.target >= 3 * spendingByGroup(s.txns)[SpendGroup.need]!;
      }),
      _Task('Bỏ vào ít nhất 10% thu nhập', (s) {
        final goal = _emergencyGoal(s);
        return goal != null && goal.saved >= 0.1 * totalIncome(s.txns);
      }),
    ],
  ),
];

// ===========================================================================
// Screen
// ===========================================================================

class WalletSim extends StatefulWidget {
  const WalletSim({super.key, required this.state});

  /// The REAL app state - only used to remember which missions are done.
  final AppState state;

  @override
  State<WalletSim> createState() => _WalletSimState();
}

class _WalletSimState extends State<WalletSim> {
  int _missionIndex = 0;
  int _resetCount = 0; // bumps widget keys so embedded screens start fresh
  late AppState _sandbox;
  late bool _showPlan;
  bool _celebrated = false;

  _Mission get _mission => _missions[_missionIndex];

  @override
  void initState() {
    super.initState();
    _startMission(0);
  }

  @override
  void dispose() {
    _sandbox.dispose();
    super.dispose();
  }

  void _startMission(int index) {
    _missionIndex = index;
    _sandbox = AppState(); // no storage = pretend money, never saved
    _mission.setup(_sandbox);
    _showPlan = _mission.startOnPlan;
    _celebrated = widget.state.completedMissions.contains('wallet:${_mission.id}');
    _resetCount++;
  }

  void _switchMission(int index) {
    final old = _sandbox;
    setState(() => _startMission(index));
    old.dispose();
  }

  void _checkCompletion(List<bool> results) {
    final allDone = results.isNotEmpty && results.every((ok) => ok);
    if (!allDone || _celebrated) {
      return;
    }
    _celebrated = true;
    // Save progress after this frame (we are inside build right now).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.state.completeMission('wallet:${_mission.id}');
      widget.state.completeMission('wallet');
      HapticFeedback.heavyImpact();
      if (mounted) {
        showFinSnack(context, 'Hoàn thành nhiệm vụ "${_mission.title}"! 🎉');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví thử nghiệm'),
        actions: [
          IconButton(
            tooltip: 'Làm lại nhiệm vụ',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () => _switchMission(_missionIndex),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _sandbox,
        builder: (context, _) {
          final results = [for (final task in _mission.tasks) task.check(_sandbox)];
          _checkCompletion(results);

          return SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, 120),
              children: [
                const _SandboxBadge(),
                const SizedBox(height: Gaps.md),
                _MissionPicker(
                  selected: _missionIndex,
                  doneIds: widget.state.completedMissions,
                  onSelect: _switchMission,
                ),
                const SizedBox(height: Gaps.md),
                _MissionCard(mission: _mission, results: results, balance: balanceOf(_sandbox.txns)),
                const SizedBox(height: Gaps.lg),
                PrimaryCta(
                  label: 'Thêm giao dịch (tiền ảo)',
                  icon: Icons.add_rounded,
                  onPressed: () => showAddTransactionSheet(context, _sandbox),
                ),
                const SizedBox(height: Gaps.lg),
                _ViewSwitch(showPlan: _showPlan, onChanged: (v) => setState(() => _showPlan = v)),
                const SizedBox(height: Gaps.lg),
                if (_showPlan)
                  PlanScreen(
                    key: ValueKey('plan-$_resetCount'),
                    state: _sandbox,
                    embedded: true,
                    initialGoals: _mission.startOnGoals,
                  )
                else
                  TransactionsScreen(
                    key: ValueKey('tx-$_resetCount'),
                    state: _sandbox,
                    embedded: true,
                    onAdd: () => showAddTransactionSheet(context, _sandbox),
                  ),
                const SizedBox(height: Gaps.lg),
                Text('Mọi thứ ở đây là giả lập và không ảnh hưởng tới ví thật của bạn.',
                    style: text.bodySmall, textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ===========================================================================
// Private components
// ===========================================================================

class _SandboxBadge extends StatelessWidget {
  const _SandboxBadge();

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gaps.md, vertical: Gaps.sm),
      decoration: BoxDecoration(color: fin.coral, borderRadius: BorderRadius.circular(Gaps.radiusSm)),
      child: const Row(
        children: [
          Icon(Icons.science_rounded, color: Colors.white, size: 18),
          SizedBox(width: Gaps.sm),
          Expanded(
            child: Text('CHẾ ĐỘ THỬ NGHIỆM · chỉ dùng tiền ảo',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }
}

class _MissionPicker extends StatelessWidget {
  const _MissionPicker({required this.selected, required this.doneIds, required this.onSelect});

  final int selected;
  final Set<String> doneIds;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _missions.length,
        separatorBuilder: (_, _) => const SizedBox(width: Gaps.sm),
        itemBuilder: (context, i) {
          final done = doneIds.contains('wallet:${_missions[i].id}');
          return ChoiceChip(
            avatar: done ? Icon(Icons.check_circle_rounded, size: 18, color: fin.green) : null,
            label: Text(_missions[i].title),
            selected: i == selected,
            showCheckmark: false,
            onSelected: (_) => onSelect(i),
          );
        },
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission, required this.results, required this.balance});

  final _Mission mission;
  final List<bool> results;
  final double balance;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final doneCount = results.where((ok) => ok).length;
    final allDone = doneCount == results.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      decoration: BoxDecoration(
        color: allDone ? fin.greenSoft : fin.surface,
        borderRadius: BorderRadius.circular(Gaps.radius),
        boxShadow: [BoxShadow(color: fin.shadow, blurRadius: 24, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(Gaps.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(allDone ? 'Hoàn thành nhiệm vụ! 🎉' : mission.title, style: text.titleLarge)),
              Pill(text: 'Số dư ảo ${formatVndCompact(balance)}', color: fin.green, background: fin.surfaceAlt),
            ],
          ),
          const SizedBox(height: Gaps.sm),
          Text(mission.intro, style: text.bodyMedium),
          const SizedBox(height: Gaps.md),
          for (var i = 0; i < mission.tasks.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      results[i] ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      key: ValueKey(results[i]),
                      color: results[i] ? fin.green : fin.textMuted,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: Gaps.sm),
                  Expanded(
                    child: Text(
                      mission.tasks[i].label,
                      style: text.bodyMedium?.copyWith(
                        fontWeight: results[i] ? FontWeight.w700 : FontWeight.w400,
                        color: results[i] ? fin.green : fin.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: Gaps.sm),
          SoftProgressBar(value: doneCount / results.length, color: fin.green, height: 8),
          const SizedBox(height: Gaps.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_rounded, color: fin.coral, size: 18),
              const SizedBox(width: Gaps.sm),
              Expanded(child: Text(mission.tip, style: text.bodySmall?.copyWith(color: fin.text))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewSwitch extends StatelessWidget {
  const _ViewSwitch({required this.showPlan, required this.onChanged});

  final bool showPlan;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(value: false, label: Text('Giao dịch'), icon: Icon(Icons.receipt_long_rounded)),
        ButtonSegment(value: true, label: Text('Kế hoạch'), icon: Icon(Icons.flag_rounded)),
      ],
      selected: {showPlan},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
