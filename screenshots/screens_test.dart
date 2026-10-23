// Screenshot "tests": render each main screen at iPhone-like size and save
// a PNG. Useful for design reviews and store listings.

import 'package:finwise/app.dart';
import 'package:finwise/content/courses.dart';
import 'package:finwise/data/app_state.dart';
import 'package:finwise/data/storage.dart';
import 'package:finwise/screens/lesson_screen.dart';
import 'package:finwise/screens/sims/bean_game.dart';
import 'package:finwise/screens/sims/loan_sim.dart';
import 'package:finwise/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const phone = Size(390, 844);

void setPhone(WidgetTester tester) {
  tester.view.physicalSize = phone * 2;
  tester.view.devicePixelRatio = 2;
}

Future<void> shoot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await expectLater(find.byType(MaterialApp).first, matchesGoldenFile('goldens/$name.png'));
}

/// Storage that already contains the sample data.
Future<MemoryStorage> sampleStorage() async {
  final storage = MemoryStorage();
  AppState(storage: storage).loadSampleData();
  await Future<void>.delayed(Duration.zero);
  return storage;
}

void main() {
  testWidgets('01 welcome', (tester) async {
    setPhone(tester);
    await tester.pumpWidget(FinWiseApp(storage: MemoryStorage()));
    await shoot(tester, '01_welcome');
  });

  for (final (index, tab) in [(2, 'Tổng quan'), (3, 'Giao dịch'), (4, 'Kế hoạch'), (5, 'Học'), (6, 'Luyện tập')]) {
    testWidgets('0$index $tab', (tester) async {
      setPhone(tester);
      final storage = await tester.runAsync(sampleStorage);
      await tester.pumpWidget(FinWiseApp(storage: storage!));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tab).last);
      await shoot(tester, '0${index}_tab');
    });
  }

  testWidgets('07 add sheet', (tester) async {
    setPhone(tester);
    final storage = await tester.runAsync(sampleStorage);
    await tester.pumpWidget(FinWiseApp(storage: storage!));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '85000');
    await shoot(tester, '07_add_sheet');
  });

  testWidgets('08 lesson card and quiz', (tester) async {
    setPhone(tester);
    final state = AppState();
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: LessonScreen(state: state, course: courses[6])));
    await shoot(tester, '08_lesson_intro');
    await tester.tap(find.text('Bắt đầu học'));
    await shoot(tester, '09_lesson_card');
  });

  testWidgets('10 simulators', (tester) async {
    setPhone(tester);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: BeanGame(state: AppState())));
    await shoot(tester, '10_bean_game');
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: LoanSim(state: AppState())));
    await shoot(tester, '11_loan_sim');
  });

  testWidgets('12 dark home', (tester) async {
    setPhone(tester);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final storage = await tester.runAsync(sampleStorage);
    await tester.pumpWidget(FinWiseApp(storage: storage!));
    await shoot(tester, '12_dark_home');
  });
}
