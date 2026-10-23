// learn_screen.dart
// ---------------------------------------------------------------------------
// "Học" - the course catalogue.
//
//   _ProgressHeader  how many of the 10 courses are done
//   _GlossaryCard    opens the searchable finance dictionary
//   _CourseTile      one per course; the icon "flies" into the lesson (Hero)
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../content/courses.dart';
import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'glossary_screen.dart';
import 'lesson_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key, required this.state, required this.onNavigate});

  final AppState state;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: pagePadding,
        children: [
          const SizedBox(height: Gaps.sm),
          Text('Học tài chính', style: text.headlineMedium),
          const SizedBox(height: 4),
          Text('10 bài ngắn, mỗi bài kết thúc bằng câu hỏi nhanh và một trò chơi thực hành.', style: text.bodySmall),
          const SizedBox(height: Gaps.lg),
          _ProgressHeader(done: state.completedLessons.length.clamp(0, courses.length)),
          const SizedBox(height: Gaps.md),
          const _GlossaryCard(),
          const SizedBox(height: Gaps.xl),
          const SectionHeader(title: 'Lộ trình của bạn'),
          const SizedBox(height: Gaps.md),
          for (var i = 0; i < courses.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gaps.md),
              child: FadeSlideIn(
                delayIndex: i,
                child: _CourseTile(
                  course: courses[i],
                  done: state.completedLessons.contains(courses[i].id),
                  onTap: () => openLesson(context, state, courses[i]),
                ),
              ),
            ),
          const SizedBox(height: Gaps.sm),
          Text(courseSource, style: text.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Colour pair (strong, soft) for a course's tone.
(Color, Color) toneColors(BuildContext context, CourseTone tone) {
  final fin = context.fin;
  switch (tone) {
    case CourseTone.green:
      return (fin.green, fin.greenSoft);
    case CourseTone.coral:
      return (fin.coral, fin.coralSoft);
    case CourseTone.red:
      return (fin.red, fin.redSoft);
    case CourseTone.pink:
      return (Palette.red, Palette.pink.withValues(alpha: 0.45));
  }
}

// ===========================================================================
// Private components
// ===========================================================================

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.done});

  final int done;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final ratio = done / courses.length;
    return FinCard(
      gradient: const LinearGradient(
        colors: [Palette.greenLight, Palette.green],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.all(Gaps.xl),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  done == courses.length ? 'Hoàn thành lộ trình! 🎓' : 'Tiến độ học tập',
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '$done/${courses.length} bài',
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: Gaps.md),
                SoftProgressBar(value: ratio, color: fin.coral, track: Colors.white.withValues(alpha: 0.2)),
              ],
            ),
          ),
          const SizedBox(width: Gaps.lg),
          const Text('📚', style: TextStyle(fontSize: 46)),
        ],
      ),
    );
  }
}

class _GlossaryCard extends StatelessWidget {
  const _GlossaryCard();

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    return FinCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GlossaryScreen())),
      child: Row(
        children: [
          IconBubble(icon: Icons.menu_book_rounded, color: fin.coral, background: fin.coralSoft),
          const SizedBox(width: Gaps.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Từ điển tài chính', style: text.titleMedium),
                Text('Tra nhanh APR, lãi kép, cổ tức, CIC...', style: text.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: fin.textMuted),
        ],
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.course, required this.done, required this.onTap});

  final Course course;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    final (strong, soft) = toneColors(context, course.tone);

    return FinCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Gaps.md),
      child: Row(
        children: [
          Hero(
            tag: 'course-icon-${course.id}',
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(18)),
              child: Icon(course.icon, color: strong, size: 30),
            ),
          ),
          const SizedBox(width: Gaps.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BÀI ${course.number} · ${course.minutes} PHÚT', style: text.labelSmall),
                const SizedBox(height: 2),
                Text(course.title, style: text.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(course.subtitle, style: text.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: Gaps.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: done
                ? Icon(Icons.check_circle_rounded, key: const ValueKey('done'), color: fin.green, size: 28)
                : Icon(Icons.play_circle_outline_rounded, key: const ValueKey('todo'), color: fin.textMuted, size: 28),
          ),
        ],
      ),
    );
  }
}
