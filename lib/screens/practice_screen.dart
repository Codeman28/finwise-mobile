// practice_screen.dart
// ---------------------------------------------------------------------------
// "Luyện tập" - interactive simulators, one per toolkit lesson. Each turns a
// classroom activity from the PDF into something you can touch:
//
//   wallet   Ví thử nghiệm (missions with pretend money)   - Bài 2
//   growth   Lãi kép                                        - Bài 1
//   payslip  Đọc phiếu lương                                - Bài 3
//   business Kế hoạch kinh doanh                            - Bài 4
//   needwant Cần hay Muốn?                                  - Bài 5
//   loan     Mua xe trả góp                                 - Bài 6
//   bean     Trò chơi Hạt đậu                               - Bài 7
//   debt     Bẫy nợ thẻ tín dụng                            - Bài 8
//   rule72   Quy tắc 72                                     - Bài 9
//   scam     Thám tử chống lừa đảo                          - Bài 10
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'sims/bean_game.dart';
import 'sims/business_sim.dart';
import 'sims/debt_sim.dart';
import 'sims/growth_sim.dart';
import 'sims/loan_sim.dart';
import 'sims/needwant_game.dart';
import 'sims/payslip_sim.dart';
import 'sims/rule72_game.dart';
import 'sims/scam_game.dart';
import 'sims/wallet_sim.dart';

/// Everything the list needs to know about one simulator.
class SimInfo {
  const SimInfo(this.id, this.title, this.subtitle, this.icon, this.lesson, this.builder);

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final int lesson;
  final Widget Function(AppState state) builder;
}

final List<SimInfo> sims = [
  SimInfo('wallet', 'Ví thử nghiệm', 'Nhiệm vụ quản lý tiền với tiền ảo', Icons.account_balance_wallet_rounded, 2,
      (s) => WalletSim(state: s)),
  SimInfo('bean', 'Trò chơi Hạt đậu', '20 hạt đậu = cả tháng lương. Chia sao cho khéo?', Icons.grain_rounded, 7,
      (s) => BeanGame(state: s)),
  SimInfo('needwant', 'Cần hay Muốn?', 'Phân loại nhanh 12 món đồ quen thuộc', Icons.swipe_rounded, 5,
      (s) => NeedWantGame(state: s)),
  SimInfo('scam', 'Thám tử chống lừa đảo', 'Nhận diện chiêu lừa và thói quen an toàn', Icons.shield_rounded, 10,
      (s) => ScamGame(state: s)),
  SimInfo('growth', 'Lãi kép', 'Xem tiền lớn lên qua từng năm', Icons.auto_graph_rounded, 1, (s) => GrowthSim(state: s)),
  SimInfo('rule72', 'Quy tắc 72', 'Bao lâu thì tiền nhân đôi?', Icons.timer_rounded, 9, (s) => Rule72Game(state: s)),
  SimInfo('loan', 'Mua xe trả góp', 'Kỳ hạn dài hơn thì rẻ hay đắt hơn?', Icons.two_wheeler_rounded, 6,
      (s) => LoanSim(state: s)),
  SimInfo('debt', 'Bẫy nợ thẻ tín dụng', 'Trả tối thiểu thì bao giờ hết nợ?', Icons.credit_card_off_rounded, 8,
      (s) => DebtSim(state: s)),
  SimInfo('payslip', 'Đọc phiếu lương', 'Từ lương gộp đến lương thực nhận', Icons.receipt_rounded, 3,
      (s) => PayslipSim(state: s)),
  SimInfo('business', 'Kế hoạch kinh doanh', 'Tính lợi nhuận và điểm hòa vốn', Icons.storefront_rounded, 4,
      (s) => BusinessSim(state: s)),
];

SimInfo? _find(String id) {
  for (final sim in sims) {
    if (sim.id == id) {
      return sim;
    }
  }
  return null;
}

/// Name of a simulator, used by the lesson result page.
String simTitle(String id) => _find(id)?.title ?? 'Luyện tập';

/// Opens a simulator full-screen.
void openSim(BuildContext context, AppState state, String id) {
  final sim = _find(id);
  if (sim == null) {
    return;
  }
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => sim.builder(state)));
}

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final done = sims.where((s) => state.completedMissions.contains(s.id)).length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: pagePadding,
        children: [
          const SizedBox(height: Gaps.sm),
          Text('Luyện tập', style: text.headlineMedium),
          const SizedBox(height: 4),
          Text('Thực hành với tiền ảo - sai ở đây không mất đồng nào.', style: text.bodySmall),
          const SizedBox(height: Gaps.lg),
          _SandboxBanner(done: done, total: sims.length),
          const SizedBox(height: Gaps.lg),
          // Two columns on normal phones, one column on very narrow screens.
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 330 ? 1 : 2;
              final tileWidth = (constraints.maxWidth - Gaps.md * (columns - 1)) / columns;
              return Wrap(
                spacing: Gaps.md,
                runSpacing: Gaps.md,
                children: [
                  for (var i = 0; i < sims.length; i++)
                    SizedBox(
                      width: tileWidth,
                      child: FadeSlideIn(
                        delayIndex: i,
                        child: _SimTile(
                          sim: sims[i],
                          done: state.completedMissions.contains(sims[i].id),
                          onTap: () => openSim(context, state, sims[i].id),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Private components
// ===========================================================================

class _SandboxBanner extends StatelessWidget {
  const _SandboxBanner({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    return FinCard(
      gradient: LinearGradient(
        colors: [fin.coral, Color.lerp(fin.coral, fin.red, 0.5)!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Row(
        children: [
          const Text('🧪', style: TextStyle(fontSize: 38)),
          const SizedBox(width: Gaps.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Phòng thí nghiệm tiền bạc',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('Đã hoàn thành $done/$total thử thách',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                const SizedBox(height: Gaps.sm),
                SoftProgressBar(value: done / total, color: Colors.white, track: Colors.white.withValues(alpha: 0.25), height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SimTile extends StatelessWidget {
  const _SimTile({required this.sim, required this.done, required this.onTap});

  final SimInfo sim;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    return FinCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Gaps.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBubble(icon: sim.icon, color: fin.green, background: fin.greenSoft, size: 42),
              const SizedBox(width: Gaps.sm),
              Expanded(
                child: Align(
                  alignment: Alignment.topRight,
                  child: done
                      ? Icon(Icons.verified_rounded, color: fin.green)
                      : Text('Bài ${sim.lesson}', style: text.labelSmall, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gaps.md),
          Text(sim.title, style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(sim.subtitle, style: text.bodySmall, maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
