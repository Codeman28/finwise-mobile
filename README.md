# FinWise Mobile: quản lý tiền & học tài chính (iOS + Android)

A Flutter app for Vietnamese high-school and university students:

* **Real money management**: income and expenses, monthly budgets, savings goals, and a dashboard.
* **Financial-literacy academy**: 10 courses in Vietnamese, adapted from the *High School Toolkit* (Hands on Banking®) PDF. Every example uses VND.
* **Practice lab**: 10 interactive simulators, each built from one of the toolkit's classroom activities, plus a sandbox wallet with pretend money.

One codebase runs on **Android 7.0+ (API 24)** and **iOS 13+**, in light and dark mode, and handles small phones and large system font sizes.

---

## 1. Design rationale (Step 1)

| Decision | Why |
|---|---|
| **Palette**: green `#005B4C` (trust, income), coral `#FD7B64` (CTA only), red `#DB444E` (spending/over budget), pink `#F9BCC5` and blush `#F1E7E9` (soft backgrounds) | Money apps need to feel calm and trustworthy. Coral is reserved for the one main action per screen, so the eye always knows what to do next. |
| **Be Vietnam Pro** font (bundled, SIL OFL) | It was designed for Vietnamese diacritics (ă, ơ, ư, ệ …), which many Latin fonts render badly. Heavy weights are used for numbers and headings, regular weight for reading. |
| **Hero balance card** with a deep-green gradient, soft glow circles and frosted "glass" pills | The number people check most is the biggest, most beautiful thing on the home screen. |
| **Micro-interactions**: press-to-shrink on every tappable card, count-up money (`TweenAnimationBuilder`), animated bars (`AnimatedContainer`), sliding toggles (`AnimatedAlign`), `Hero` course icons, staggered fade-in lists, haptics | They make the app feel alive and give instant feedback, which matters a lot for motivating teenagers. |
| **One primary CTA per screen** | On an empty wallet the welcome card's button is the CTA and the floating "Thêm" button stays hidden until there is data. |
| **Edge cases** | A splash screen while loading; an error screen with "Thử lại" and "Bắt đầu lại" if saved data is damaged; friendly empty states on every list; undo after swipe-to-delete. |
| **Learning as swipeable cards + instant-feedback quiz** | Short cards fit a phone, and immediate right/wrong feedback keeps learners engaged (Duolingo-style). |

## 2. Component breakdown (Step 2)

```
lib/
├── main.dart                     start-up (edge-to-edge system UI)
├── app.dart                      MaterialApp, vi_VN locale, light/dark theme, loading/error/ready states
├── theme/app_theme.dart          Palette, spacing (Gaps), FinColors (light+dark), text hierarchy
├── core/
│   ├── format.dart               1.500.000 ₫, 24/09/2026, "Tháng 9/2026", greetings
│   └── finance.dart              pure maths: totals, budgets, compound interest, loans, debt, payslip
├── data/
│   ├── models.dart               Txn, Budget, Goal, categories (need/want/savings)
│   ├── app_state.dart            ChangeNotifier wallet: add/delete/save, sample data, sandbox mode
│   └── storage.dart              shared_preferences (PhoneStorage) / MemoryStorage for tests
├── content/
│   ├── courses.dart              10 Vietnamese courses + quizzes (from the PDF)
│   └── glossary.dart             "Từ điển tài chính" (from the PDF glossary)
├── widgets/
│   ├── common.dart               FinCard, PressableScale, PrimaryCta, AnimatedMoney, SoftProgressBar,
│   │                             EmptyState, ErrorState, TxnTile, VndField (live dots), dialogs
│   └── add_transaction_sheet.dart  _KindToggle, _CategoryPicker, _DateRow
└── screens/
    ├── shell.dart                bottom NavigationBar (5 tabs) + coral FAB
    ├── home_screen.dart          _Header, _BalanceCard, _MonthChart, _CategoryBreakdown, _BudgetWatch …
    ├── transactions_screen.dart  search, filter chips, day groups, swipe-to-delete + undo
    ├── plan_screen.dart          Ngân sách | Mục tiêu segments, editors, data settings
    ├── learn_screen.dart         course path, progress, glossary entry
    ├── lesson_screen.dart        intro → cards → quiz → result (PageView)
    ├── glossary_screen.dart      searchable dictionary
    ├── practice_screen.dart      simulator gallery
    └── sims/                     wallet, bean game, need/want, scam detective, compound growth,
                                  rule of 72, vehicle loan, credit-card trap, payslip, business plan
```

Every screen keeps its UI split into small private widgets (`_BalanceCard`, `_StatTile` …) at the bottom of the file. Interactivity uses `StatefulWidget` + `setState`, and app-wide data uses one `ChangeNotifier` (`AppState`).

### Courses (adapted from the toolkit, localised for Vietnam)

| # | Course | Practice simulator |
|---|---|---|
| 1 | Tiền hoạt động thế nào? | Lãi kép |
| 2 | Bộ công cụ quản lý tiền (tài khoản, thẻ, sao kê) | Ví thử nghiệm |
| 3 | Tìm việc và nhận lương (SMART, phỏng vấn, BHXH/BHYT/BHTN) | Đọc phiếu lương |
| 4 | Khởi nghiệp | Kế hoạch kinh doanh |
| 5 | Mua sắm thông minh | Cần hay Muốn? |
| 6 | Tiết kiệm để mua xe | Mua xe trả góp |
| 7 | Hiểu và lập ngân sách | Trò chơi Hạt đậu |
| 8 | Tín dụng căn bản (5 chữ C, CIC) | Bẫy nợ thẻ tín dụng |
| 9 | Đầu tư căn bản (quy tắc 72, VN-Index) | Quy tắc 72 |
| 10 | An toàn tài chính (OTP, phishing) | Thám tử chống lừa đảo |

US-specific details were replaced with Vietnamese ones: Ngân hàng Nhà nước instead of the US Treasury, bank transfers and QR payments instead of cheques, BHXH on payslips, CIC instead of FICO, and motorbikes as well as cars.

---

## 3. Build & run

Prerequisites: Flutter 3.47+ (Dart 3.13+). For Android you also need the Android SDK; for iOS you need a Mac with Xcode.

```bash
flutter pub get
flutter analyze                 # static checks
flutter test                    # 22 unit + widget tests
flutter run                     # on a connected phone / emulator
```

**Android APK**
```bash
flutter build apk --release     # -> build/app/outputs/flutter-apk/app-release.apk (all phones, ~52 MB)
flutter build apk --release --split-per-abi   # smaller per-CPU APKs; most phones use arm64-v8a (~18 MB)
```
The APK is signed with the debug key. That's fine for installing on your own phones, but create your own keystore before publishing to Google Play.

**iOS** (Mac only)
```bash
open ios/Runner.xcworkspace     # choose your Team under Signing & Capabilities
flutter build ipa               # or run from Xcode on an iPhone
```

**App icons**: `python tool/make_icons.py` regenerates all Android and iOS icons (needs Pillow).
**Screenshots**: `flutter test screenshots --update-goldens` writes PNGs to `screenshots/goldens/`.

---

*Học liệu mang tính giáo dục, không phải lời khuyên tài chính cá nhân. Thuế TNCN trong mô phỏng phiếu lương là ước tính minh họa; the constants are at the top of `lib/core/finance.dart`.*
