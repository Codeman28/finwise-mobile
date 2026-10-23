// debt_sim.dart
// ---------------------------------------------------------------------------
// "Bẫy nợ thẻ tín dụng" (Lesson 8). Change the monthly payment and see how
// long the debt lasts and how much interest it costs. If the payment does
// not even cover the monthly interest, the debt never goes away: the trap.
//
// Challenge: 1) see the trap, 2) find a plan that is debt-free in 12 months.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../core/finance.dart';
import '../../core/format.dart';
import '../../data/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'sim_common.dart';

class DebtSim extends StatefulWidget {
  const DebtSim({super.key, required this.state});

  final AppState state;

  @override
  State<DebtSim> createState() => _DebtSimState();
}

class _DebtSimState extends State<DebtSim> {
  double _debt = 20000000;
  double _rate = 30;
  double _payment = 1000000;
  bool _sawTrap = false;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final result = creditCardPayoff(debt: _debt, yearlyRatePercent: _rate, monthlyPayment: _payment);
    final firstMonthInterest = _debt * _rate / 100 / 12;

    if (result.isTrap) {
      _sawTrap = true;
    }
    final fastEnough = !result.isTrap && result.months! <= 12;
    if (_sawTrap && fastEnough) {
      completeMissionAfterBuild(widget.state, 'debt');
    }

    return SimScaffold(
      state: widget.state,
      title: 'Bẫy nợ thẻ tín dụng',
      courseId: 'credit',
      intro: 'Bạn nợ thẻ tín dụng. Mỗi tháng tiền lãi được cộng vào nợ trước, rồi mới trừ đi số bạn trả.',
      children: [
        FinCard(
          child: Column(
            children: [
              LabeledSlider(
                label: 'Dư nợ thẻ',
                value: _debt,
                min: 2000000,
                max: 100000000,
                divisions: 49,
                display: formatVnd(_debt),
                onChanged: (v) => setState(() => _debt = v),
              ),
              LabeledSlider(
                label: 'Lãi suất năm',
                value: _rate,
                min: 10,
                max: 40,
                divisions: 30,
                display: '${_rate.round()}%',
                color: fin.coral,
                onChanged: (v) => setState(() => _rate = v),
              ),
              LabeledSlider(
                label: 'Trả mỗi tháng',
                value: _payment,
                min: 200000,
                max: 10000000,
                divisions: 49,
                display: formatVnd(_payment),
                color: fin.red,
                onChanged: (v) => setState(() => _payment = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gaps.lg),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: result.isTrap
              ? _Verdict(
                  key: const ValueKey('trap'),
                  color: fin.red,
                  icon: Icons.warning_rounded,
                  title: 'BẪY NỢ!',
                  message: 'Số tiền trả (${formatVnd(_payment)}) không đủ trả tiền lãi '
                      '(${formatVnd(firstMonthInterest)}/tháng). Khoản nợ sẽ không bao giờ hết.',
                )
              : _Verdict(
                  key: const ValueKey('ok'),
                  color: fastEnough ? fin.green : fin.coral,
                  icon: fastEnough ? Icons.celebration_rounded : Icons.hourglass_bottom_rounded,
                  title: 'Hết nợ sau ${result.months} tháng',
                  message: 'Tổng tiền lãi phải trả: ${formatVnd(result.totalInterest!)}. '
                      'Mỗi đồng trả thêm đều giúp bạn bớt tiền lãi.',
                ),
        ),
        const SizedBox(height: Gaps.lg),
        Row(
          children: [
            Expanded(child: StatTile(label: 'Lãi tháng đầu', value: formatVndCompact(firstMonthInterest), color: fin.coral)),
            const SizedBox(width: Gaps.sm),
            Expanded(
              child: StatTile(
                label: 'Thời gian',
                value: result.isTrap ? '∞' : '${result.months} tháng',
                color: result.isTrap ? fin.red : fin.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: Gaps.lg),
        FinCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thử thách', style: text.titleMedium),
              const SizedBox(height: Gaps.sm),
              _Task(done: _sawTrap, label: 'Tìm ra mức trả rơi vào "bẫy nợ"'),
              _Task(done: fastEnough, label: 'Tìm mức trả giúp hết nợ trong 12 tháng'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Verdict extends StatelessWidget {
  const _Verdict({super.key, required this.color, required this.icon, required this.title, required this.message});

  final Color color;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gaps.lg),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(Gaps.radius)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(width: Gaps.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(color: Colors.white, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Task extends StatelessWidget {
  const _Task({required this.done, required this.label});

  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              key: ValueKey(done),
              color: done ? fin.green : fin.textMuted,
            ),
          ),
          const SizedBox(width: Gaps.sm),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
