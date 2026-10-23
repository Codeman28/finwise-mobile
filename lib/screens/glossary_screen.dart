// glossary_screen.dart
// ---------------------------------------------------------------------------
// "Từ điển tài chính" - searchable list of terms. Tap a term to expand it.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../content/glossary.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _query = '';

  List<GlossaryTerm> get _visible {
    final needle = _query.trim().toLowerCase();
    final sorted = List<GlossaryTerm>.of(glossary)..sort((a, b) => a.term.compareTo(b.term));
    if (needle.isEmpty) {
      return sorted;
    }
    return sorted.where((t) {
      final haystack = '${t.term} ${t.english} ${t.meaning}'.toLowerCase();
      return haystack.contains(needle);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      appBar: AppBar(title: const Text('Từ điển tài chính')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, Gaps.md),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Tìm thuật ngữ (VD: lãi kép, APR)',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'Không tìm thấy',
                      message: 'Thử một từ khóa khác bằng tiếng Việt hoặc tiếng Anh.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, Gaps.xl),
                      itemCount: visible.length,
                      separatorBuilder: (_, _) => const SizedBox(height: Gaps.sm),
                      itemBuilder: (context, index) => _TermTile(term: visible[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermTile extends StatelessWidget {
  const _TermTile({required this.term});

  final GlossaryTerm term;

  @override
  Widget build(BuildContext context) {
    final fin = context.fin;
    final text = Theme.of(context).textTheme;
    return FinCard(
      padding: EdgeInsets.zero,
      child: Theme(
        // Remove ExpansionTile's default divider lines.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(),
          tilePadding: const EdgeInsets.symmetric(horizontal: Gaps.lg, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(Gaps.lg, 0, Gaps.lg, Gaps.lg),
          iconColor: fin.green,
          collapsedIconColor: fin.textMuted,
          title: Text(term.term, style: text.titleMedium),
          subtitle: Text(term.english, style: text.bodySmall),
          children: [
            Align(alignment: Alignment.centerLeft, child: Text(term.meaning, style: text.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
