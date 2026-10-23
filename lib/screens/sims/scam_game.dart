// scam_game.dart
// ---------------------------------------------------------------------------
// "Thám tử chống lừa đảo" (Lesson 10), two rounds from the toolkit:
//   Round 1 - Jeena's urgent message: choose what she should do.
//   Round 2 - "Security at Home and Online" quiz show: for each habit,
//             decide NÊN (do it) or KHÔNG NÊN (don't). Adapted for Vietnam
//             (OTP, Zalo links, fake bank calls ...).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'sim_common.dart';

class _Habit {
  const _Habit(this.text, this.recommended, this.why);
  final String text;
  final bool recommended;
  final String why;
}

const _habits = [
  _Habit('Đăng xuất và đóng trình duyệt ngay sau khi giao dịch online.', true, 'Giảm nguy cơ người khác dùng phiên đăng nhập của bạn.'),
  _Habit('Đọc mã OTP cho "nhân viên ngân hàng" gọi đến để xác minh.', false, 'Ngân hàng không bao giờ hỏi OTP. Đây là chiêu lừa phổ biến nhất.'),
  _Habit('Không bấm vào link lạ gửi qua SMS, Zalo hay Messenger.', true, 'Link lạ có thể dẫn tới trang web giả mạo để lấy thông tin.'),
  _Habit('Cập nhật hệ điều hành và ứng dụng thường xuyên.', true, 'Bản cập nhật vá các lỗ hổng bảo mật.'),
  _Habit('Để thẻ ATM và giấy ghi mã PIN trong cùng ví.', false, 'Mất ví là mất luôn tiền trong tài khoản.'),
  _Habit('Xé hủy giấy tờ tài chính cũ trước khi vứt.', true, 'Kẻ gian có thể lục rác để lấy thông tin cá nhân.'),
  _Habit('Cài ứng dụng theo hướng dẫn của người lạ qua điện thoại.', false, 'Ứng dụng lạ có thể chiếm quyền điều khiển điện thoại của bạn.'),
  _Habit('Chỉ nhập thông tin thẻ trên trang có "https" và ổ khóa.', true, 'Kết nối được mã hóa - nhưng vẫn cần kiểm tra đúng tên miền.'),
  _Habit('Nhận "việc nhẹ lương cao" cần nộp tiền cọc trước.', false, 'Việc thật không bao giờ bắt bạn nộp tiền để được làm.'),
  _Habit('Bật xác thực 2 lớp cho email và mạng xã hội.', true, 'Kẻ gian có mật khẩu cũng khó đăng nhập được.'),
];

class ScamGame extends StatefulWidget {
  const ScamGame({super.key, required this.state});

  final AppState state;

  @override
  State<ScamGame> createState() => _ScamGameState();
}

class _ScamGameState extends State<ScamGame> {
  int? _jeenaChoice; // round 1 answer
  int _habitIndex = 0;
  int _habitScore = 0;
  bool? _habitCorrect;

  bool get _jeenaDone => _jeenaChoice != null;
  bool get _finished => _habitIndex >= _habits.length;

  void _answerHabit(bool saysRecommended) {
    if (_habitCorrect != null) {
      return;
    }
    final correct = saysRecommended == _habits[_habitIndex].recommended;
    correct ? HapticFeedback.lightImpact() : HapticFeedback.vibrate();
    setState(() {
      _habitCorrect = correct;
      if (correct) {
        _habitScore++;
      }
    });
  }

  void _nextHabit() {
    setState(() {
      _habitIndex++;
      _habitCorrect = null;
    });
    if (_finished && _habitScore >= 8 && _jeenaChoice == 1) {
      widget.state.completeMission('scam');
    }
  }

  void _restart() {
    setState(() {
      _jeenaChoice = null;
      _habitIndex = 0;
      _habitScore = 0;
      _habitCorrect = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimScaffold(
      state: widget.state,
      title: 'Thám tử chống lừa đảo',
      courseId: 'staying-safe',
      intro: 'Vòng 1: giúp Jeena xử lý tin nhắn khẩn cấp. Vòng 2: thói quen nào NÊN, thói quen nào KHÔNG NÊN?',
      children: [
        _JeenaRound(choice: _jeenaChoice, onChoose: (i) => setState(() => _jeenaChoice = i)),
        if (_jeenaDone) ...[
          const SizedBox(height: Gaps.xl),
          if (!_finished)
            _HabitRound(
              index: _habitIndex,
              score: _habitScore,
              habit: _habits[_habitIndex],
              correct: _habitCorrect,
              onAnswer: _answerHabit,
              onNext: _nextHabit,
            )
          else ...[
            ScoreBanner(
              emoji: _habitScore >= 8 && _jeenaChoice == 1 ? '🕵️' : '🛡️',
              title: 'Vòng 2: đúng $_habitScore/${_habits.length}',
              message: _habitScore >= 8 && _jeenaChoice == 1
                  ? 'Bạn là thám tử thực thụ! Kẻ gian khó mà lừa được bạn.'
                  : 'Cần chọn đúng ở vòng 1 và đạt 8 điểm ở vòng 2 để hoàn thành.',
              good: _habitScore >= 8 && _jeenaChoice == 1,
            ),
            const SizedBox(height: Gaps.md),
            SecondaryButton(label: 'Chơi lại', icon: Icons.refresh_rounded, onPressed: _restart),
          ],
        ],
      ],
    );
  }
}

class _JeenaRound extends StatelessWidget {
  const _JeenaRound({required this.choice, required this.onChoose});

  final int? choice;
  final ValueChanged<int> onChoose;

  static const _options = [
    ('Bấm link và điền thông tin để tài khoản không bị khóa.', false,
        'Đây là lừa đảo giả mạo (phishing). Jeena vừa trao thông tin tài chính cho kẻ gian.'),
    ('Không bấm link. Tự gọi tổng đài in trên thẻ hoặc mở app chính thức để kiểm tra.', true,
        'Chuẩn! Chỉ liên hệ qua kênh bạn biết chắc là thật. Không phản hồi tin nhắn thúc giục.'),
    ('Bấm link, nếu trang trông "giống thật" thì mới điền.', false,
        'Trang giả thường giống hệt trang thật. Jeena đã mất tiền và tốn rất nhiều thời gian để xử lý.'),
  ];

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The scam message, styled like a phone notification.
        FinCard(
          color: fin.surfaceAlt,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBubble(icon: Icons.sms_rounded, color: Colors.white, background: fin.red, size: 40),
              const SizedBox(width: Gaps.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NGAN HANG · Tin nhắn', style: text.labelSmall),
                    const SizedBox(height: 4),
                    Text(
                      'KHẨN CẤP: Tài khoản của quý khách có giao dịch bất thường và sẽ bị KHÓA trong 24h. '
                      'Xác minh ngay tại: http://nganhang-xacminh.vip',
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gaps.md),
        Text('Jeena nên làm gì?', style: text.titleLarge),
        const SizedBox(height: Gaps.md),
        for (var i = 0; i < _options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: Gaps.sm),
            child: _OptionCard(
              label: _options[i].$1,
              state: choice == null ? 0 : (_options[i].$2 ? 1 : (choice == i ? -1 : 0)),
              explanation: choice == i || (choice != null && _options[i].$2) ? _options[i].$3 : null,
              onTap: choice == null ? () => onChoose(i) : null,
            ),
          ),
      ],
    );
  }
}

class _HabitRound extends StatelessWidget {
  const _HabitRound({
    required this.index,
    required this.score,
    required this.habit,
    required this.correct,
    required this.onAnswer,
    required this.onNext,
  });

  final int index;
  final int score;
  final _Habit habit;
  final bool? correct;
  final ValueChanged<bool> onAnswer;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Vòng 2 · ${index + 1}/${_habits.length}', style: text.labelMedium),
            const Spacer(),
            Pill(text: 'Điểm: $score', color: fin.green, background: fin.greenSoft),
          ],
        ),
        const SizedBox(height: Gaps.md),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: FinCard(
            key: ValueKey(index),
            padding: const EdgeInsets.all(Gaps.xl),
            child: Column(
              children: [
                Text(habit.text, style: text.titleLarge, textAlign: TextAlign.center),
                if (correct != null) ...[
                  const SizedBox(height: Gaps.md),
                  Pill(
                    text: correct! ? 'Chính xác!' : 'Chưa đúng · ${habit.recommended ? "NÊN" : "KHÔNG NÊN"}',
                    color: correct! ? fin.green : fin.red,
                    background: correct! ? fin.greenSoft : fin.redSoft,
                  ),
                  const SizedBox(height: Gaps.sm),
                  Text(habit.why, style: text.bodyMedium, textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: Gaps.lg),
        if (correct == null)
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: fin.green, minimumSize: const Size(0, 56)),
                  onPressed: () => onAnswer(true),
                  icon: const Icon(Icons.thumb_up_rounded),
                  label: const FittedBox(fit: BoxFit.scaleDown, child: Text('NÊN')),
                ),
              ),
              const SizedBox(width: Gaps.md),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: fin.red, minimumSize: const Size(0, 56)),
                  onPressed: () => onAnswer(false),
                  icon: const Icon(Icons.block_rounded),
                  label: const FittedBox(fit: BoxFit.scaleDown, child: Text('KHÔNG NÊN')),
                ),
              ),
            ],
          )
        else
          PrimaryCta(
            label: index == _habits.length - 1 ? 'Xem kết quả' : 'Tiếp theo',
            icon: Icons.arrow_forward_rounded,
            onPressed: onNext,
          ),
      ],
    );
  }
}

/// state: 0 = neutral, 1 = correct, -1 = wrong
class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.label, required this.state, required this.explanation, required this.onTap});

  final String label;
  final int state;
  final String? explanation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final border = state == 1 ? fin.green : (state == -1 ? fin.red : fin.border);
    final background = state == 1 ? fin.greenSoft : (state == -1 ? fin.redSoft : fin.surface);
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.all(Gaps.lg),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(Gaps.radius),
          border: Border.all(color: border, width: state == 0 ? 1.2 : 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: text.titleSmall),
            if (explanation != null) ...[
              const SizedBox(height: Gaps.sm),
              Text(explanation!, style: text.bodySmall?.copyWith(color: fin.text)),
            ],
          ],
        ),
      ),
    );
  }
}
