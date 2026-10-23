// rule72_game.dart
// ---------------------------------------------------------------------------
// "Quy tắc 72" (Lesson 9). Two parts, like the toolkit's activity:
//   1. Explorer: pick an interest rate, see "72 ÷ rate" next to the exact
//      answer - the rule is a surprisingly good shortcut.
//   2. Game: the toolkit's 10 rates. Pick the right number of years.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/finance.dart';
import '../../data/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'sim_common.dart';

/// "7,2" style number: comma decimal, no trailing ",0".
String _years(double value) {
  final rounded = (value * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) {
    return rounded.round().toString();
  }
  return rounded.toStringAsFixed(1).replaceAll('.', ',');
}

class Rule72Game extends StatefulWidget {
  const Rule72Game({super.key, required this.state});

  final AppState state;

  @override
  State<Rule72Game> createState() => _Rule72GameState();
}

class _Rule72GameState extends State<Rule72Game> {
  // The 10 rates from the toolkit's Rule of 72 game.
  static const _rates = [1.0, 2.0, 12.0, 10.0, 36.0, 6.0, 9.0, 5.0, 15.0, 8.0];

  double _explorerRate = 8;
  int _round = 0;
  int _score = 0;
  int? _picked; // index of the picked option this round

  bool get _finished => _round >= _rates.length;

  /// Three options: the right answer plus two plausible wrong ones.
  List<double> _optionsFor(double rate) {
    final right = ruleOf72(rate);
    final options = [right, right * 2, right / 2];
    // Rotate by the round number so the right answer isn't always first.
    final shift = _round % 3;
    return [...options.sublist(shift), ...options.sublist(0, shift)];
  }

  void _pick(int index, List<double> options, double rate) {
    if (_picked != null) {
      return;
    }
    final correct = options[index] == ruleOf72(rate);
    correct ? HapticFeedback.lightImpact() : HapticFeedback.vibrate();
    setState(() {
      _picked = index;
      if (correct) {
        _score++;
      }
    });
  }

  void _nextRound() {
    setState(() {
      _round++;
      _picked = null;
    });
    if (_finished && _score >= 8) {
      widget.state.completeMission('rule72');
    }
  }

  void _restart() {
    setState(() {
      _round = 0;
      _score = 0;
      _picked = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;

    return SimScaffold(
      state: widget.state,
      title: 'Quy tắc 72',
      courseId: 'investing',
      intro: 'Số năm để tiền nhân đôi ≈ 72 ÷ lãi suất năm. Không cần máy tính!',
      children: [
        FinCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Khám phá'),
              LabeledSlider(
                label: 'Lãi suất mỗi năm',
                value: _explorerRate,
                min: 1,
                max: 24,
                divisions: 23,
                display: '${_explorerRate.round()}%',
                onChanged: (v) => setState(() => _explorerRate = v),
              ),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Theo quy tắc 72',
                      value: '${_years(ruleOf72(_explorerRate.roundToDouble()))} năm',
                      color: fin.green,
                    ),
                  ),
                  const SizedBox(width: Gaps.sm),
                  Expanded(
                    child: StatTile(
                      label: 'Tính chính xác',
                      value: '${_years(exactDoublingYears(_explorerRate.roundToDouble()))} năm',
                      color: fin.coral,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Gaps.lg),
        if (_finished)
          Column(
            children: [
              ScoreBanner(
                emoji: _score >= 8 ? '🏆' : '📈',
                title: 'Bạn đúng $_score/${_rates.length} câu',
                message: _score >= 8 ? 'Xuất sắc! Bạn tính nhẩm như chuyên gia.' : 'Đạt 8 câu trở lên để hoàn thành thử thách.',
                good: _score >= 8,
              ),
              const SizedBox(height: Gaps.md),
              SecondaryButton(label: 'Chơi lại', icon: Icons.refresh_rounded, onPressed: _restart),
            ],
          )
        else
          _RoundCard(
            round: _round,
            total: _rates.length,
            rate: _rates[_round],
            options: _optionsFor(_rates[_round]),
            picked: _picked,
            onPick: (i, options) => _pick(i, options, _rates[_round]),
            onNext: _nextRound,
            scoreText: 'Điểm: $_score',
            textTheme: text,
          ),
      ],
    );
  }
}

class _RoundCard extends StatelessWidget {
  const _RoundCard({
    required this.round,
    required this.total,
    required this.rate,
    required this.options,
    required this.picked,
    required this.onPick,
    required this.onNext,
    required this.scoreText,
    required this.textTheme,
  });

  final int round;
  final int total;
  final double rate;
  final List<double> options;
  final int? picked;
  final void Function(int index, List<double> options) onPick;
  final VoidCallback onNext;
  final String scoreText;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final right = ruleOf72(rate);

    return FinCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Câu ${round + 1}/$total', style: textTheme.labelMedium),
              const Spacer(),
              Pill(text: scoreText, color: fin.green, background: fin.greenSoft),
            ],
          ),
          const SizedBox(height: Gaps.md),
          Text('Lãi suất ${rate.round()}%/năm. Bao nhiêu năm thì tiền nhân đôi?', style: textTheme.titleLarge),
          const SizedBox(height: Gaps.lg),
          Row(
            children: [
              for (var i = 0; i < options.length; i++) ...[
                if (i > 0) const SizedBox(width: Gaps.sm),
                Expanded(
                  child: _AnswerButton(
                    label: '${_years(options[i])} năm',
                    state: picked == null
                        ? 0
                        : options[i] == right
                            ? 1
                            : (picked == i ? -1 : 0),
                    onTap: picked == null ? () => onPick(i, options) : null,
                  ),
                ),
              ],
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: picked == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: Gaps.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('72 ÷ ${rate.round()} = ${_years(right)} năm', style: textTheme.titleSmall, textAlign: TextAlign.center),
                        const SizedBox(height: Gaps.md),
                        PrimaryCta(
                          label: round == total - 1 ? 'Xem kết quả' : 'Câu tiếp theo',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: onNext,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// state: 0 = neutral, 1 = correct, -1 = wrong
class _AnswerButton extends StatelessWidget {
  const _AnswerButton({required this.label, required this.state, required this.onTap});

  final String label;
  final int state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final background = state == 1 ? fin.greenSoft : (state == -1 ? fin.redSoft : fin.surfaceAlt);
    final border = state == 1 ? fin.green : (state == -1 ? fin.red : Colors.transparent);
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(Gaps.radiusSm + 2),
          border: Border.all(color: border, width: 2),
        ),
        child: Text(label, style: Theme.of(context).textTheme.titleSmall),
      ),
    );
  }
}
