// growth_sim.dart
// ---------------------------------------------------------------------------
// "Lãi kép" (Lesson 1 & 9): move sliders, watch savings grow year by year.
// Bars are stacked: green = money you put in, coral = interest earned.
// Challenge: find a plan where interest beats the money you deposited.
// ---------------------------------------------------------------------------

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/finance.dart';
import '../../core/format.dart';
import '../../data/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'sim_common.dart';

class GrowthSim extends StatefulWidget {
  const GrowthSim({super.key, required this.state});

  final AppState state;

  @override
  State<GrowthSim> createState() => _GrowthSimState();
}

class _GrowthSimState extends State<GrowthSim> {
  double _start = 5000000;
  double _monthly = 500000;
  double _rate = 6;
  double _years = 10;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final points = compoundGrowth(
      start: _start,
      monthly: _monthly,
      yearlyRatePercent: _rate,
      years: _years.round(),
    );
    final last = points.last;
    final interestWins = last.interest > last.deposited;
    if (interestWins) {
      completeMissionAfterBuild(widget.state, 'growth');
    }

    return SimScaffold(
      state: widget.state,
      title: 'Lãi kép',
      courseId: 'money-works',
      intro: 'Tiền lãi được cộng vào số dư, rồi chính nó lại sinh lãi. Kéo các thanh trượt '
          'để xem thời gian và sự đều đặn quan trọng thế nào.',
      children: [
        FinCard(
          child: Column(
            children: [
              LabeledSlider(
                label: 'Số tiền ban đầu',
                value: _start,
                min: 0,
                max: 100000000,
                divisions: 100,
                display: formatVnd(_start),
                onChanged: (v) => setState(() => _start = v),
              ),
              LabeledSlider(
                label: 'Gửi thêm mỗi tháng',
                value: _monthly,
                min: 0,
                max: 10000000,
                divisions: 40,
                display: formatVnd(_monthly),
                onChanged: (v) => setState(() => _monthly = v),
              ),
              LabeledSlider(
                label: 'Lãi suất mỗi năm',
                value: _rate,
                min: 0,
                max: 12,
                divisions: 24,
                display: '${_rate.toStringAsFixed(1).replaceAll('.', ',')}%',
                color: fin.coral,
                onChanged: (v) => setState(() => _rate = v),
              ),
              LabeledSlider(
                label: 'Số năm',
                value: _years,
                min: 1,
                max: 40,
                divisions: 39,
                display: '${_years.round()} năm',
                color: fin.coral,
                onChanged: (v) => setState(() => _years = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gaps.lg),
        Row(
          children: [
            Expanded(child: StatTile(label: 'Số dư cuối', value: formatVndCompact(last.balance), color: fin.green)),
            const SizedBox(width: Gaps.sm),
            Expanded(child: StatTile(label: 'Bạn gửi vào', value: formatVndCompact(last.deposited), color: fin.text)),
            const SizedBox(width: Gaps.sm),
            Expanded(child: StatTile(label: 'Tiền lãi', value: formatVndCompact(last.interest), color: fin.coral)),
          ],
        ),
        const SizedBox(height: Gaps.lg),
        FinCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Số dư theo thời gian', subtitle: 'Xanh = tiền gửi · Cam = tiền lãi'),
              const SizedBox(height: Gaps.lg),
              SizedBox(height: 180, child: _GrowthChart(points: points)),
            ],
          ),
        ),
        const SizedBox(height: Gaps.lg),
        ScoreBanner(
          emoji: interestWins ? '🚀' : '🎯',
          title: interestWins ? 'Tiền lãi đã vượt tiền gốc!' : 'Thử thách',
          message: interestWins
              ? 'Đây là "quả cầu tuyết" lãi kép. Thời gian dài chính là bí quyết.'
              : 'Tìm một kế hoạch mà tiền lãi nhiều hơn tổng số tiền bạn gửi vào. Gợi ý: tăng số năm.',
          good: interestWins,
        ),
      ],
    );
  }
}

class _GrowthChart extends StatelessWidget {
  const _GrowthChart({required this.points});

  final List<GrowthPoint> points;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    // Show at most ~10 bars so they stay readable (skip years if needed).
    final step = math.max(1, (points.length / 10).ceil());
    final shown = <GrowthPoint>[];
    for (var i = 0; i < points.length; i += step) {
      shown.add(points[i]);
    }
    if (shown.last != points.last) {
      shown.add(points.last);
    }
    final biggest = math.max(1.0, shown.map((p) => p.balance).reduce(math.max));

    return LayoutBuilder(
      builder: (context, constraints) {
        // Leave room below the bars for the year label ("N10") and its gap.
        final maxHeight = constraints.maxHeight - 32;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final p in shown)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      width: 14,
                      height: math.max(0, p.interest) / biggest * maxHeight,
                      decoration: BoxDecoration(
                        color: fin.coral,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      width: 14,
                      height: math.max(2, p.deposited / biggest * maxHeight),
                      color: fin.green,
                    ),
                    const SizedBox(height: 6),
                    Text('N${p.year}', style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
