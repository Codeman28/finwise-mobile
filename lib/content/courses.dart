// courses.dart
// ---------------------------------------------------------------------------
// The 10 courses, adapted into Vietnamese (with VND examples) from the
// "High School Toolkit" (Hands on Banking®) lesson plans:
//
//   1 Tiền hoạt động thế nào        6 Tiết kiệm để mua xe
//   2 Bộ công cụ quản lý tiền        7 Hiểu và lập ngân sách
//   3 Tìm việc và nhận lương         8 Tín dụng căn bản
//   4 Khởi nghiệp                    9 Đầu tư căn bản
//   5 Mua sắm thông minh            10 An toàn tài chính
//
// US-specific details were localised for Vietnam (State Bank of Vietnam,
// bank transfers / QR payments, BHXH on payslips, the CIC credit bureau,
// VN-Index ...). This file is pure DATA - screens draw it automatically.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

/// Which palette colour a course uses for its cover.
enum CourseTone { green, coral, red, pink }

/// One swipeable card inside a lesson.
class LessonCard {
  const LessonCard({
    required this.title,
    required this.body,
    this.bullets = const [],
    this.example,
    this.tip,
  });

  final String title;
  final String body;
  final List<String> bullets;
  final String? example; // shown in a "Ví dụ" box
  final String? tip; // shown in a "Mẹo" box
}

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int answer; // index of the correct option
  final String explanation;
}

class Course {
  const Course({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tone,
    required this.minutes,
    required this.objectives,
    required this.cards,
    required this.quiz,
    this.simId,
  });

  final String id;
  final int number;
  final String title;
  final String subtitle;
  final IconData icon;
  final CourseTone tone;
  final int minutes;
  final List<String> objectives;
  final List<LessonCard> cards;
  final List<QuizQuestion> quiz;

  /// Id of the matching simulator in the "Luyện tập" tab (optional).
  final String? simId;
}

/// Passing mark: at least 3 of 4 answers right.
const double passRatio = 0.75;

const courseSource =
    'Nội dung được biên soạn lại bằng tiếng Việt từ bộ giáo án "High School Toolkit" '
    '(chương trình Hands on Banking®), có điều chỉnh cho bối cảnh Việt Nam. '
    'Mang tính giáo dục, không phải lời khuyên tài chính cá nhân.';

const List<Course> courses = [
  // =========================================================================
  Course(
    id: 'money-works',
    number: 1,
    title: 'Tiền hoạt động thế nào?',
    subtitle: 'Từ trao đổi hàng hóa đến đồng tiền, lãi suất và lạm phát.',
    icon: Icons.currency_exchange_rounded,
    tone: CourseTone.green,
    minutes: 6,
    simId: 'growth',
    objectives: [
      'Hiểu tiền đến từ đâu và vận hành ra sao',
      'Nắm các khái niệm: giá trị, lãi suất, lạm phát, tài sản, nợ',
    ],
    cards: [
      LessonCard(
        title: 'Trước khi có tiền: đổi hàng',
        body: 'Ngày xưa, con người trao đổi trực tiếp hàng hóa và dịch vụ với nhau - '
            'gọi là đổi hàng (barter). Người nông dân cần bàn ghế có thể đổi rau quả '
            'lấy công của người thợ mộc.',
        bullets: [
          'Khó khăn: phải tìm được người vừa CÓ thứ mình cần, vừa CẦN thứ mình có.',
          'Khó định giá: một bộ bàn ghế dùng nhiều năm đổi được bao nhiêu rau ăn hằng ngày?',
        ],
        tip: 'Hãy thử nghĩ: nếu hôm nay phải đổi hàng, bạn sẽ đổi kỹ năng gì của mình?',
      ),
      LessonCard(
        title: 'Tiền là gì?',
        body: 'Tiền là phương tiện để LƯU GIỮ, ĐO LƯỜNG và TRAO ĐỔI giá trị. '
            'Một thứ có "giá trị" khi nó hữu ích, đáng mong muốn.',
        bullets: [
          'Ở Việt Nam, Ngân hàng Nhà nước Việt Nam là cơ quan duy nhất phát hành tiền đồng (VND).',
          'Khi một người tiêu tiền, một người khác nhận được tiền - tiền luôn luân chuyển trong nền kinh tế.',
          'Tiền đi qua tay cá nhân, doanh nghiệp và các tổ chức tài chính như ngân hàng.',
        ],
      ),
      LessonCard(
        title: 'Lãi suất: tiền sinh ra tiền',
        body: 'Khi gửi tiền vào ngân hàng, ngân hàng trả thêm cho bạn một khoản gọi là '
            'TIỀN LÃI - để được sử dụng tiền của bạn trong một thời gian.',
        bullets: [
          'Có tài khoản tiết kiệm: bạn NHẬN lãi.',
          'Đi vay: bạn TRẢ lãi cho người cho vay.',
        ],
        example: 'Gửi 10.000.000 ₫ với lãi 5%/năm: sau 1 năm bạn có khoảng 10.500.000 ₫.',
      ),
      LessonCard(
        title: 'Vì sao 1 đồng hôm nay đáng giá hơn 1 đồng ngày mai?',
        body: 'Vì đồng tiền bạn có hôm nay có thể đem đầu tư hoặc gửi để sinh lãi theo '
            'thời gian. Lãi lại sinh lãi - đó là LÃI KÉP.',
        tip: 'Mở "Luyện tập → Lãi kép" để xem tiền của bạn lớn lên qua từng năm.',
      ),
      LessonCard(
        title: 'Năm từ khóa cần nhớ',
        body: 'Đây là những từ bạn sẽ gặp suốt hành trình tài chính:',
        bullets: [
          'Lạm phát: giá cả hàng hóa, dịch vụ nói chung tăng lên (mà chất lượng không tăng).',
          'Tài sản: bất cứ thứ gì có giá trị mà bạn sở hữu (tiền mặt, xe, nhà, cổ phiếu).',
          'Nợ phải trả: số tiền bạn đang nợ người khác.',
          'Tăng giá trị: giá trị tăng lên theo thời gian (ví dụ: đất đai).',
          'Mất giá / khấu hao: giá trị giảm dần theo thời gian (ví dụ: xe máy, điện thoại).',
        ],
      ),
    ],
    quiz: [
      QuizQuestion(
        question: 'Tiền là phương tiện để lưu giữ, đo lường và trao đổi ______.',
        options: ['giá trị', 'sản phẩm', 'đồng xu', 'niềm vui'],
        answer: 0,
        explanation: 'Tiền dùng để lưu giữ, đo lường và trao đổi GIÁ TRỊ.',
      ),
      QuizQuestion(
        question: 'Ở Việt Nam, cơ quan nào phát hành tiền đồng?',
        options: ['Bộ Tài chính', 'Ngân hàng Nhà nước Việt Nam', 'Các ngân hàng thương mại', 'Kho bạc tỉnh'],
        answer: 1,
        explanation: 'Ngân hàng Nhà nước Việt Nam là cơ quan duy nhất phát hành tiền.',
      ),
      QuizQuestion(
        question: 'Khi gửi tiền tiết kiệm, khoản tiền ngân hàng trả thêm cho bạn gọi là gì?',
        options: ['Tiền thưởng', 'Tiền lãi', 'Phí dịch vụ', 'Tiền phạt'],
        answer: 1,
        explanation: 'Tiền lãi là khoản ngân hàng trả để được dùng tiền của bạn một thời gian.',
      ),
      QuizQuestion(
        question: '"Giá cả hàng hóa và dịch vụ nói chung tăng lên" được gọi là gì?',
        options: ['Khấu hao', 'Tăng giá trị', 'Lạm phát', 'Tài sản'],
        answer: 2,
        explanation: 'Đó là lạm phát - cùng một số tiền sẽ mua được ít hàng hơn.',
      ),
    ],
  ),

  // =========================================================================
  Course(
    id: 'money-toolkit',
    number: 2,
    title: 'Bộ công cụ quản lý tiền',
    subtitle: 'Tài khoản ngân hàng, thẻ ATM và cách đọc sao kê.',
    icon: Icons.account_balance_rounded,
    tone: CourseTone.coral,
    minutes: 6,
    simId: 'wallet',
    objectives: [
      'Hiểu lợi ích của tài khoản ngân hàng',
      'Nhận biết các phần trên thẻ ATM/ghi nợ',
      'Biết cách đọc sao kê tài khoản',
    ],
    cards: [
      LessonCard(
        title: 'Vì sao nên có tài khoản ngân hàng?',
        body: 'Quản lý tiền rất dễ nếu bạn có đúng công cụ. Ngân hàng giúp tiền của bạn '
            'an toàn, dễ theo dõi và tiết kiệm thời gian. Hãy nghĩ tới một "mối quan hệ lâu dài" '
            'và so sánh để chọn ngân hàng phù hợp.',
        bullets: [
          'Tài khoản thanh toán: nạp, rút, chuyển khoản, quét mã QR hằng ngày.',
          'Tài khoản tiết kiệm: để dành cho mục tiêu hoặc quỹ khẩn cấp, có lãi.',
        ],
      ),
      LessonCard(
        title: 'Nạp và chuyển tiền',
        body: 'Ở Việt Nam, hầu hết giao dịch hằng ngày là chuyển khoản nhanh 24/7 và quét mã '
            'QR. Khi nhận tiền, bạn chỉ cần đưa số tài khoản hoặc mã QR của mình.',
        bullets: [
          'Luôn kiểm tra TÊN người nhận trước khi xác nhận chuyển tiền.',
          'Ghi nội dung chuyển khoản rõ ràng để sau này dễ tra cứu.',
          'Séc (check) rất ít dùng ở Việt Nam, nhưng vẫn có ở một số doanh nghiệp.',
        ],
      ),
      LessonCard(
        title: 'Giải phẫu một chiếc thẻ ATM / ghi nợ',
        body: 'Thẻ ghi nợ trừ tiền trực tiếp từ tài khoản thanh toán của bạn.',
        bullets: [
          'Số thẻ (16-19 chữ số): khác với số tài khoản.',
          'Ngày hết hạn: sau ngày này thẻ không dùng được nữa.',
          'Logo NAPAS/Visa/Mastercard: cho biết thẻ dùng được ở đâu.',
          'Mã CVV/CVC (mặt sau): dùng khi mua online - TUYỆT ĐỐI không chia sẻ.',
          'Số hotline: gọi ngay khi mất thẻ để khóa thẻ.',
        ],
        tip: 'Mã PIN và mã OTP chỉ mình bạn biết. Ngân hàng không bao giờ hỏi chúng.',
      ),
      LessonCard(
        title: 'Đọc sao kê tài khoản',
        body: 'Sao kê là "bảng điểm" của tài khoản trong một khoảng thời gian.',
        bullets: [
          'Kỳ sao kê: từ ngày nào đến ngày nào.',
          'Số dư đầu kỳ và cuối kỳ.',
          'Các khoản tiền vào (ghi có) và tiền ra (ghi nợ).',
          'Phí dịch vụ, nếu có.',
        ],
        example: 'Số dư đầu kỳ 3.200.000 ₫ + tiền vào 6.500.000 ₫ - tiền ra 5.150.000 ₫ '
            '= số dư cuối kỳ 4.550.000 ₫.',
        tip: 'Mỗi tháng hãy so sao kê với ghi chép của bạn - trang Giao dịch trong FinWise giúp việc này.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question: 'Tài khoản nào phù hợp nhất để để dành cho quỹ khẩn cấp?',
        options: ['Tài khoản thanh toán', 'Tài khoản tiết kiệm', 'Ví điện tử để mua sắm', 'Tiền mặt trong ví'],
        answer: 1,
        explanation: 'Tài khoản tiết kiệm giữ tiền an toàn và còn sinh lãi.',
      ),
      QuizQuestion(
        question: 'Mã CVV ở mặt sau thẻ dùng để làm gì?',
        options: ['Rút tiền ở ATM', 'Xác nhận khi mua hàng online', 'Đăng nhập app ngân hàng', 'Gọi hotline'],
        answer: 1,
        explanation: 'CVV xác nhận bạn đang cầm thẻ khi mua online - không bao giờ chia sẻ nó.',
      ),
      QuizQuestion(
        question: 'Trước khi bấm chuyển khoản, bạn cần kiểm tra điều gì nhất?',
        options: ['Màu của ứng dụng', 'Tên người nhận', 'Giờ trong ngày', 'Số dư của người nhận'],
        answer: 1,
        explanation: 'Kiểm tra tên người nhận giúp tránh chuyển nhầm hoặc bị lừa.',
      ),
      QuizQuestion(
        question: 'Số dư cuối kỳ được tính như thế nào?',
        options: [
          'Đầu kỳ + tiền vào - tiền ra',
          'Đầu kỳ - tiền vào + tiền ra',
          'Chỉ cộng các khoản tiền vào',
          'Bằng hạn mức thẻ',
        ],
        answer: 0,
        explanation: 'Cuối kỳ = số dư đầu kỳ + tiền vào - tiền ra.',
      ),
    ],
  ),

  // =========================================================================
  Course(
    id: 'get-the-job',
    number: 3,
    title: 'Tìm việc và nhận lương',
    subtitle: 'Học vấn, phỏng vấn, mục tiêu SMART và đọc phiếu lương.',
    icon: Icons.work_rounded,
    tone: CourseTone.pink,
    minutes: 7,
    simId: 'payslip',
    objectives: [
      'Hiểu học vấn ảnh hưởng tới khả năng kiếm tiền',
      'Biết các bước tìm việc và phỏng vấn',
      'Đọc được phiếu lương: lương gộp, các khoản trừ, thực nhận',
    ],
    cards: [
      LessonCard(
        title: 'Khả năng kiếm tiền',
        body: 'Nhiều bạn trẻ đi làm thêm để có tiền riêng và tự lập. Nhưng hãy nghĩ cả '
            'tương lai: trình độ học vấn và kỹ năng ảnh hưởng lớn đến số tiền bạn có thể '
            'kiếm được - gọi là khả năng kiếm tiền.',
        bullets: [
          'Liệt kê kỹ năng, sở thích, kinh nghiệm của bạn.',
          'Tìm công việc hợp với điểm mạnh: bơi giỏi → cứu hộ bể bơi; giỏi toán → gia sư.',
          'Điền hồ sơ ứng tuyển cẩn thận và đầy đủ - đó là bước đầu để được phỏng vấn.',
        ],
      ),
      LessonCard(
        title: 'Đặt mục tiêu SMART',
        body: 'Một mục tiêu tốt phải Cụ thể - Đo được - Khả thi - Thực tế - Có thời hạn.',
        example: 'Mục tiêu chung: "Mình muốn có việc làm hè."\n'
            'Mục tiêu SMART: "Là người bơi giỏi, mình sẽ làm cứu hộ ở bể bơi gần nhà, '
            'chiều thứ Hai-thứ Sáu từ 13h-17h, trong kỳ nghỉ hè."',
      ),
      LessonCard(
        title: '5 bước để phỏng vấn thành công',
        body: 'Phỏng vấn là cơ hội tạo ấn tượng tốt và tìm hiểu nhà tuyển dụng.',
        bullets: [
          'Chuẩn bị kỹ và đến sớm khoảng 10 phút.',
          'Kết nối: chào hỏi, giao tiếp bằng mắt, mỉm cười.',
          'Lắng nghe kỹ và thể hiện sự quan tâm đến công việc.',
          'Trả lời rõ ràng, ngắn gọn, nêu ví dụ cụ thể.',
          'Cảm ơn khi ra về và gửi lời cảm ơn ngay sau đó.',
        ],
        tip: 'Chỉ bàn về lương khi nhà tuyển dụng nhắc đến con số trước.',
      ),
      LessonCard(
        title: 'Lương theo giờ, lương tháng, hoa hồng',
        body: 'Có nhiều cách được trả công: lương theo giờ, lương cố định mỗi tháng, và hoa '
            'hồng (thưởng thêm khi bán được nhiều). Hãy hiểu rõ mình được trả thế nào, bao '
            'nhiêu và khi nào - rồi kiểm tra số tiền có đúng không.',
      ),
      LessonCard(
        title: 'Đọc phiếu lương',
        body: 'Phiếu lương cho biết bạn kiếm được bao nhiêu và bị trừ những gì.',
        bullets: [
          'Lương gộp (gross): toàn bộ số tiền bạn kiếm được trong kỳ.',
          'BHXH 8% + BHYT 1,5% + BHTN 1% = 10,5%: bảo hiểm bắt buộc người lao động đóng.',
          'Thuế thu nhập cá nhân: chỉ áp dụng khi thu nhập vượt mức giảm trừ gia cảnh.',
          'Lương thực nhận (net): số tiền thật sự về tài khoản của bạn.',
        ],
        tip: 'Khi lập ngân sách, luôn dùng lương THỰC NHẬN - đó là số tiền bạn thật sự có.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question: 'Khi lập ngân sách, bạn nên dựa vào con số nào?',
        options: ['Lương gộp', 'Lương thực nhận', 'Lương của bạn bè', 'Lương mong muốn'],
        answer: 1,
        explanation: 'Lương thực nhận là số tiền bạn thật sự có để chi tiêu.',
      ),
      QuizQuestion(
        question: 'Chữ "T" trong mục tiêu SMART nghĩa là gì?',
        options: ['Thú vị', 'Có thời hạn', 'Tốn ít tiền', 'Tự do'],
        answer: 1,
        explanation: 'SMART: Cụ thể, Đo được, Khả thi, Thực tế, Có thời hạn.',
      ),
      QuizQuestion(
        question: 'Tổng tỷ lệ BHXH + BHYT + BHTN người lao động đóng là bao nhiêu?',
        options: ['5%', '8%', '10,5%', '21,5%'],
        answer: 2,
        explanation: '8% + 1,5% + 1% = 10,5% lương đóng bảo hiểm.',
      ),
      QuizQuestion(
        question: 'Khi nào nên bàn về mức lương trong buổi phỏng vấn?',
        options: [
          'Ngay câu đầu tiên',
          'Sau khi nhà tuyển dụng nhắc đến con số',
          'Không bao giờ',
          'Khi đang giới thiệu bản thân',
        ],
        answer: 1,
        explanation: 'Hãy để nhà tuyển dụng nêu con số trước, rồi mới thảo luận.',
      ),
    ],
  ),

  // =========================================================================
  Course(
    id: 'entrepreneur',
    number: 4,
    title: 'Khởi nghiệp',
    subtitle: 'Biến sở thích thành ý tưởng kinh doanh và lập kế hoạch.',
    icon: Icons.rocket_launch_rounded,
    tone: CourseTone.green,
    minutes: 6,
    simId: 'business',
    objectives: [
      'Biết cần gì để trở thành người khởi nghiệp thành công',
      'Nhận ra kỹ năng, sở thích có thể kiếm tiền',
      'Lập một kế hoạch kinh doanh đơn giản',
    ],
    cards: [
      LessonCard(
        title: 'Làm chủ có dễ không?',
        body: 'Tự kinh doanh thường tốn nhiều thời gian, sức lực và tài năng hơn đi làm thuê. '
            'Nó có thể cần bỏ vốn và có rủi ro - nhưng cũng rất đáng giá khi bạn được làm '
            'điều mình thích.',
        tip: 'Trước khi mở kinh doanh riêng, hãy thử làm việc (hoặc tình nguyện) ở một nơi tương tự.',
      ),
      LessonCard(
        title: 'Sở thích - Kỹ năng - Tài năng',
        body: 'Ý tưởng tốt thường bắt đầu từ chính bạn.',
        bullets: [
          'Sở thích: bạn thích làm gì?',
          'Kỹ năng: bạn làm tốt việc gì?',
          'Tài năng: mọi người hay khen bạn điều gì?',
          'Chọn tối đa 3 ý tưởng có thể sinh lời để phân tích tiếp.',
        ],
        example: 'Thích vẽ + giỏi thiết kế + được khen khéo tay → bán sticker, móc khóa handmade.',
      ),
      LessonCard(
        title: 'Kế hoạch kinh doanh 1 trang',
        body: 'Kế hoạch kinh doanh là tấm bản đồ biến ý tưởng thành việc kinh doanh có lãi.',
        bullets: [
          'Tên: dễ đọc, dễ nhớ.',
          'Ý tưởng: sản phẩm hay dịch vụ? Điều gì làm bạn khác biệt?',
          'Khách hàng: là ai, cần gì, tìm họ ở đâu?',
          'Đối thủ: họ bán giá bao nhiêu, có gì đặc biệt?',
          'Tiếp thị: mạng xã hội, bạn bè, hội chợ trường...',
          'Ngân sách: chi phí, giá bán, lợi nhuận mỗi sản phẩm.',
        ],
      ),
      LessonCard(
        title: 'Lợi nhuận và điểm hòa vốn',
        body: 'Lợi nhuận mỗi sản phẩm = giá bán - chi phí làm ra sản phẩm đó. Điểm hòa vốn '
            'là số sản phẩm cần bán để bù lại chi phí ban đầu.',
        example: 'Bỏ 600.000 ₫ mua dụng cụ. Mỗi móc khóa tốn 15.000 ₫, bán 45.000 ₫ '
            '→ lãi 30.000 ₫/cái → cần bán 20 cái để hòa vốn.',
        tip: 'Thử ngay trong "Luyện tập → Kế hoạch kinh doanh".',
      ),
    ],
    quiz: [
      QuizQuestion(
        question: 'Lợi nhuận trên mỗi sản phẩm được tính thế nào?',
        options: ['Giá bán + chi phí', 'Giá bán - chi phí', 'Chi phí - giá bán', 'Giá bán × số lượng'],
        answer: 1,
        explanation: 'Lợi nhuận mỗi sản phẩm = giá bán - chi phí làm ra nó.',
      ),
      QuizQuestion(
        question: 'Chi phí ban đầu 300.000 ₫, lãi 15.000 ₫/sản phẩm. Cần bán bao nhiêu để hòa vốn?',
        options: ['10', '15', '20', '30'],
        answer: 2,
        explanation: '300.000 ÷ 15.000 = 20 sản phẩm.',
      ),
      QuizQuestion(
        question: 'Nên làm gì trước khi tự mở kinh doanh?',
        options: [
          'Vay thật nhiều tiền',
          'Làm việc ở một nơi tương tự để học kinh nghiệm',
          'Bỏ qua phần tìm hiểu đối thủ',
          'Đặt giá thấp nhất có thể',
        ],
        answer: 1,
        explanation: 'Kinh nghiệm thực tế giúp giảm rủi ro rất nhiều.',
      ),
      QuizQuestion(
        question: 'Phần nào KHÔNG thuộc kế hoạch kinh doanh cơ bản?',
        options: ['Khách hàng mục tiêu', 'Đối thủ cạnh tranh', 'Màu sơn nhà bạn', 'Ngân sách dự kiến'],
        answer: 2,
        explanation: 'Kế hoạch gồm ý tưởng, khách hàng, đối thủ, tiếp thị, ngân sách, thời gian.',
      ),
    ],
  ),

  // =========================================================================
  Course(
    id: 'savvy-shopper',
    number: 5,
    title: 'Mua sắm thông minh',
    subtitle: 'Cần hay muốn, chống mua bốc đồng và so sánh giá.',
    icon: Icons.shopping_cart_checkout_rounded,
    tone: CourseTone.coral,
    minutes: 5,
    simId: 'needwant',
    objectives: [
      'Phân biệt nhu cầu (cần) và mong muốn (muốn)',
      'Áp dụng mẹo so sánh giá khi quyết định mua',
    ],
    cards: [
      LessonCard(
        title: 'Cần hay muốn?',
        body: 'Khoản CẦN là thứ bắt buộc để sống, học và làm việc: ăn uống cơ bản, chỗ ở, '
            'đi lại. Khoản MUỐN làm cuộc sống vui hơn nhưng không có vẫn ổn: trà sữa, quần áo '
            'mới chưa cần, game.',
        tip: 'Chơi "Luyện tập → Cần hay Muốn?" để luyện phản xạ.',
      ),
      LessonCard(
        title: 'Chống mua bốc đồng: 4 câu hỏi',
        body: 'Trước khi trả tiền, hãy tự hỏi:',
        bullets: [
          'Mình có thật sự cần nó không?',
          'Mình có cần nó NGAY HÔM NAY không?',
          'Nếu không mua bây giờ thì sao?',
          'Có cách nào rẻ hơn không?',
        ],
        example: 'Rafael muốn giảm tiền điện thoại: anh so sánh nhiều nhà mạng, các gói cước '
            'và đọc kỹ hợp đồng trước khi đăng ký - thay vì chọn gói đầu tiên thấy quảng cáo.',
      ),
      LessonCard(
        title: 'Mẹo tiết kiệm hằng ngày',
        body: 'Những thói quen nhỏ, cộng dồn thành khoản tiền lớn:',
        bullets: [
          'Nấu ăn ở nhà; lập danh sách trước khi đi chợ; đừng đi siêu thị khi đang đói.',
          'Mang ít tiền mặt, mua sắm theo ngân sách, chờ đợt giảm giá.',
          'Dùng thẻ học sinh - sinh viên để được giảm giá.',
          'Đọc kỹ hợp đồng gói cước, theo dõi dung lượng, trả hóa đơn đúng hạn.',
        ],
      ),
      LessonCard(
        title: 'Bỏ bớt cái nhỏ, để dành cái đáng giá',
        body: 'Bớt vài món nhỏ không cần thiết để dành cho một thứ bạn thật sự trân trọng.',
        example: 'Bớt 2 ly trà sữa mỗi tuần (khoảng 70.000 ₫) → sau 3 tháng có khoảng '
            '840.000 ₫ cho một chuyến đi cùng bạn bè.',
        bullets: [
          'Với món đồ lớn: so sánh giá, đọc đánh giá, hỏi người quen, hiểu chế độ bảo hành và đổi trả.',
          'Luôn giữ hóa đơn.',
        ],
      ),
    ],
    quiz: [
      QuizQuestion(
        question: 'Món nào thường là khoản CẦN?',
        options: ['Ly trà sữa thứ ba trong tuần', 'Tiền điện nước', 'Skin game mới', 'Giày phiên bản giới hạn'],
        answer: 1,
        explanation: 'Điện nước là thiết yếu; các món còn lại là mong muốn.',
      ),
      QuizQuestion(
        question: 'Câu hỏi nào giúp chống mua bốc đồng?',
        options: [
          'Bạn bè mình có chưa?',
          'Mình có cần nó ngay hôm nay không?',
          'Nó có đang hot không?',
          'Có trả góp 0% không?',
        ],
        answer: 1,
        explanation: 'Hỏi "có cần ngay hôm nay không" giúp bạn dừng lại và suy nghĩ.',
      ),
      QuizQuestion(
        question: 'Khi nào KHÔNG nên đi siêu thị?',
        options: ['Khi có danh sách mua', 'Khi đang đói', 'Khi có khuyến mãi', 'Vào cuối tuần'],
        answer: 1,
        explanation: 'Đi mua khi đói dễ khiến bạn mua nhiều đồ không cần thiết.',
      ),
      QuizQuestion(
        question: 'Mua món đồ lớn, việc nào quan trọng nhất?',
        options: ['Mua ngay kẻo hết', 'So sánh giá và chất lượng ở nhiều nơi', 'Chọn món đắt nhất', 'Không cần giữ hóa đơn'],
        answer: 1,
        explanation: 'So sánh giúp tiết kiệm tiền và chọn được giá trị tốt nhất.',
      ),
    ],
  ),

  // =========================================================================
  Course(
    id: 'buy-vehicle',
    number: 6,
    title: 'Tiết kiệm để mua xe',
    subtitle: 'Trả trước, khoản vay, lãi suất và tổng chi phí thật sự.',
    icon: Icons.two_wheeler_rounded,
    tone: CourseTone.red,
    minutes: 6,
    simId: 'loan',
    objectives: [
      'Hiểu các chi phí tài chính khi mua xe',
      'Áp dụng cách ra quyết định để tiết kiệm và mua xe',
    ],
    cards: [
      LessonCard(
        title: 'Có thật sự cần xe không?',
        body: 'Xe mang lại tiện lợi nhưng cũng là trách nhiệm và chi phí lớn. Trước khi mua, '
            'hãy tự hỏi: mình có thể đi xe buýt, xe đạp hay đi chung không?',
        bullets: [
          'Nhu cầu đi lại hiện tại và vài năm tới là gì?',
          'An toàn và tiết kiệm xăng có quan trọng không?',
          'Mình có thể chi trả đều đặn bao nhiêu mỗi tháng?',
        ],
      ),
      LessonCard(
        title: 'Xe mới hay xe cũ?',
        body: 'Mọi chiếc xe đều mất giá theo thời gian. Xe mới có thể mất giá đáng kể ngay khi '
            'lăn bánh khỏi đại lý. Một chiếc xe cũ còn tốt, được thợ uy tín kiểm tra kỹ, có '
            'thể giúp bạn tiết kiệm nhiều.',
      ),
      LessonCard(
        title: 'Mua trả góp hoạt động thế nào?',
        body: 'Bạn trả trước một phần (tiền trả trước), phần còn lại vay và trả đều mỗi tháng '
            'trong một kỳ hạn, kèm TIỀN LÃI.',
        bullets: [
          'Kỳ hạn càng dài: tiền trả mỗi tháng thấp hơn, nhưng TỔNG tiền lãi cao hơn.',
          'Người cho vay thường tính lãi suất cao hơn cho kỳ hạn dài hơn.',
          'Hãy "đi chợ" khoản vay trước khi đi chọn xe: so sánh lãi suất, phí, kỳ hạn.',
        ],
        example: 'Xe máy giá 45.000.000 ₫, trả trước 10.000.000 ₫, vay 35.000.000 ₫:\n'
            '• 12 tháng, lãi 12%/năm → khoảng 3.110.000 ₫/tháng, tổng lãi ~2,3 triệu.\n'
            '• 36 tháng, lãi 16%/năm → khoảng 1.230.000 ₫/tháng, tổng lãi ~9,3 triệu.',
      ),
      LessonCard(
        title: 'Chi phí sau khi mua',
        body: 'Ngoài tiền trả góp, còn xăng, bảo hiểm, bảo dưỡng, sửa chữa, gửi xe. Hãy đưa '
            'tất cả vào ngân sách hằng tháng.',
        tip: 'Cảnh giác với quảng cáo "không cần chứng minh thu nhập, duyệt ngay" - lãi suất thường rất cao.',
      ),
      LessonCard(
        title: 'Mẹo thương lượng',
        body: 'Thân thiện nhưng kiên định. Quyết định mức giá tối đa trước, không tiết lộ số '
            'tiền bạn sẵn sàng trả mỗi tháng, và luôn sẵn sàng rời đi nếu thấy không ổn.',
        bullets: [
          'Đọc kỹ hợp đồng, không ký khi còn chỗ trống.',
          'Cân nhắc kỹ các gói "phụ kiện", bảo hiểm, bảo hành mở rộng.',
          'Giữ một bản hợp đồng có chữ ký của cả hai bên.',
        ],
      ),
    ],
    quiz: [
      QuizQuestion(
        question: 'Vì sao tổng chi phí trả góp luôn cao hơn giá xe?',
        options: ['Do thuế', 'Vì phải trả thêm tiền lãi', 'Vì xe tăng giá', 'Vì phí gửi xe'],
        answer: 1,
        explanation: 'Bạn trả lại số tiền vay CỘNG với tiền lãi.',
      ),
      QuizQuestion(
        question: 'Kéo dài kỳ hạn vay sẽ làm điều gì?',
        options: [
          'Giảm cả tiền tháng và tổng lãi',
          'Giảm tiền mỗi tháng nhưng tăng tổng lãi',
          'Tăng tiền mỗi tháng',
          'Không thay đổi gì',
        ],
        answer: 1,
        explanation: 'Trả lâu hơn = mỗi tháng nhẹ hơn nhưng tổng lãi phải trả nhiều hơn.',
      ),
      QuizQuestion(
        question: 'Nên làm gì TRƯỚC khi đi chọn xe?',
        options: ['Chọn màu xe', 'So sánh các khoản vay', 'Mua bảo hiểm', 'Đặt cọc ngay'],
        answer: 1,
        explanation: 'Biết mình vay được bao nhiêu, lãi thế nào giúp chọn xe trong khả năng.',
      ),
      QuizQuestion(
        question: 'Chi phí nào thường bị quên khi mua xe?',
        options: ['Giá xe', 'Bảo dưỡng, xăng, bảo hiểm', 'Tiền trả trước', 'Tên xe'],
        answer: 1,
        explanation: 'Chi phí vận hành hằng tháng cũng phải có trong ngân sách.',
      ),
    ],
  ),

  // =========================================================================
  Course(
    id: 'budgets',
    number: 7,
    title: 'Hiểu và lập ngân sách',
    subtitle: 'Kế hoạch chi tiêu, thứ tự ưu tiên và 3 loại chi phí.',
    icon: Icons.pie_chart_rounded,
    tone: CourseTone.pink,
    minutes: 6,
    simId: 'bean',
    objectives: [
      'Giải thích mục đích của ngân sách',
      'Nắm các chiến lược lập ngân sách cơ bản',
      'Tự lập ngân sách để đạt một mục tiêu tài chính',
    ],
    cards: [
      LessonCard(
        title: 'Ngân sách là gì?',
        body: 'Ngân sách (kế hoạch chi tiêu) là bản kế hoạch viết ra: tiền sẽ đi đâu. Nó giúp '
            'bạn sống trong khả năng của mình và đạt mục tiêu tài chính.',
        bullets: [
          'Thu nhập: tiền vào trong một khoảng thời gian.',
          'Chi phí: tiền ra trong khoảng thời gian đó.',
          'Điều chỉnh thói quen để để dành cho việc bất ngờ.',
        ],
      ),
      LessonCard(
        title: 'Thứ tự trả tiền hợp lý',
        body: 'Để thu nhập đủ cả tháng, hãy chi theo thứ tự:',
        bullets: [
          '1. Trả các hóa đơn hằng tháng.',
          '2. Bỏ tiền vào tiết kiệm.',
          '3. Để riêng tiền chi tiêu hằng ngày, hằng tuần.',
          '4. Để riêng cho các khoản lớn sắp tới.',
          '5. Để dành cho mục tiêu lớn trong tương lai.',
          '6. Khi thu nhập tăng, hãy tăng phần tiết kiệm.',
        ],
      ),
      LessonCard(
        title: '3 loại chi phí',
        body: 'Phân loại giúp bạn biết nên cắt giảm ở đâu.',
        bullets: [
          'Cố định: đều đặn, không đổi - tiền phòng, trả góp.',
          'Linh hoạt: đều đặn nhưng bạn kiểm soát được mức chi - ăn uống, xăng.',
          'Tùy ý: bạn chọn chi - xem phim, trà sữa với bạn bè.',
        ],
        tip: 'Khi thiếu tiền, hãy cắt khoản TÙY Ý trước, rồi đến LINH HOẠT.',
      ),
      LessonCard(
        title: 'Trò chơi Hạt đậu',
        body: 'Bạn có 20 hạt đậu = toàn bộ thu nhập. Mỗi lựa chọn (ở đâu, đi lại thế nào, ăn '
            'uống, giải trí...) tốn một số hạt. Bất ngờ: bị giảm thu nhập, mất 10 hạt - bạn '
            'phải sắp xếp lại!',
        tip: 'Chơi ngay trong "Luyện tập → Trò chơi Hạt đậu".',
      ),
      LessonCard(
        title: 'Ngân sách là kế hoạch sống',
        body: 'Khi chi phí thay đổi hoặc có việc khẩn cấp, ngân sách cũng phải thay đổi. Hãy '
            'luôn chừa một ít tiền dự phòng mỗi tháng cho những điều bất ngờ.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question: 'Tiền phòng trọ hằng tháng thuộc loại chi phí nào?',
        options: ['Cố định', 'Linh hoạt', 'Tùy ý', 'Không phải chi phí'],
        answer: 0,
        explanation: 'Tiền phòng lặp lại và không đổi - là chi phí cố định.',
      ),
      QuizQuestion(
        question: 'Đi xem phim với bạn bè là loại chi phí nào?',
        options: ['Cố định', 'Linh hoạt', 'Tùy ý', 'Bắt buộc'],
        answer: 2,
        explanation: 'Đó là khoản bạn tự chọn chi - chi phí tùy ý.',
      ),
      QuizQuestion(
        question: 'Khi thu nhập tăng, bạn nên làm gì theo bài học?',
        options: ['Tăng chi tiêu tùy ý', 'Tăng phần tiết kiệm', 'Bỏ ngân sách', 'Vay thêm'],
        answer: 1,
        explanation: 'Thu nhập tăng là cơ hội tăng tiết kiệm.',
      ),
      QuizQuestion(
        question: 'Vì sao nên chừa một ít tiền dự phòng mỗi tháng?',
        options: [
          'Để mua sắm thêm',
          'Cho những chi phí bất ngờ',
          'Để khoe với bạn bè',
          'Không cần thiết',
        ],
        answer: 1,
        explanation: 'Chi phí bất ngờ luôn có thể xảy ra - dự phòng giúp bạn không phải đi vay.',
      ),
    ],
  ),

  // =========================================================================
  Course(
    id: 'credit',
    number: 8,
    title: 'Tín dụng căn bản',
    subtitle: 'Vay tiền, lịch sử tín dụng và 5 chữ C của người cho vay.',
    icon: Icons.credit_card_rounded,
    tone: CourseTone.red,
    minutes: 6,
    simId: 'debt',
    objectives: [
      'Hiểu các thuật ngữ tín dụng',
      'Biết lợi ích và rủi ro của tín dụng',
      'Nắm 5 chữ C người cho vay dùng để đánh giá bạn',
    ],
    cards: [
      LessonCard(
        title: 'Tín dụng là gì?',
        body: 'Tín dụng là khả năng vay tiền. Người cho vay kiếm tiền bằng cách thu thêm tiền '
            'lãi và phí ngoài số tiền cho vay.',
        bullets: [
          'Người cho vay chỉ cho vay khi TIN bạn trả được - gọi là xây dựng tín dụng.',
          'Mỗi lần vay và trả đúng hẹn, bạn xây dựng lịch sử tín dụng tốt.',
          'Ở Việt Nam, lịch sử vay nợ được ghi nhận tại Trung tâm Thông tin Tín dụng Quốc gia (CIC).',
        ],
      ),
      LessonCard(
        title: 'Lợi ích và rủi ro',
        body: 'Tín dụng giúp bạn đạt mục tiêu - nhưng luôn đi kèm rủi ro.',
        bullets: [
          '✓ Lịch sử tốt giúp dễ vay mua nhà, mua xe, đôi khi dễ thuê nhà hơn.',
          '✓ Linh hoạt khi cần khoản lớn hơn số tiền đang có.',
          '✗ Chi tiêu quá tay, trả chậm → mất phí phạt và lãi cao.',
          '✗ Điểm tín dụng xấu → khó vay lần sau, hoặc phải chịu lãi cao hơn.',
        ],
        tip: 'Giữ khoản phải trả nợ hằng tháng không quá 10% thu nhập hằng tháng.',
      ),
      LessonCard(
        title: 'Chi phí của một khoản vay',
        body: 'Chi phí vay phụ thuộc vào 3 thứ: số tiền vay (gốc), thời gian trả (kỳ hạn) '
            'và lãi suất.',
        example: 'Nợ thẻ tín dụng 20.000.000 ₫, lãi 30%/năm: tháng đầu tiền lãi khoảng 500.000 ₫. '
            'Nếu chỉ trả 500.000 ₫/tháng, khoản nợ gần như không bao giờ giảm!',
        tip: 'Thử trong "Luyện tập → Bẫy nợ thẻ tín dụng".',
      ),
      LessonCard(
        title: '5 chữ C của tín dụng',
        body: 'Người cho vay đánh giá bạn qua 5 yếu tố:',
        bullets: [
          'Character - Tư cách: bạn có ổn định, đáng tin (thời gian làm việc, nơi ở)?',
          'Capacity - Năng lực trả nợ: thu nhập so với các khoản nợ hiện có.',
          'Capital - Vốn: tài sản, tiền tiết kiệm bạn có.',
          'Collateral - Tài sản đảm bảo: thứ người cho vay có thể thu nếu bạn không trả.',
          'Conditions - Điều kiện: mục đích vay, tình hình kinh tế.',
        ],
      ),
    ],
    quiz: [
      QuizQuestion(
        question: 'Tín dụng là gì?',
        options: ['Tiền được tặng', 'Khả năng vay tiền', 'Một loại thuế', 'Tiền lương'],
        answer: 1,
        explanation: 'Tín dụng là khả năng vay tiền dựa trên niềm tin rằng bạn sẽ trả.',
      ),
      QuizQuestion(
        question: 'Chữ C nào nói về thu nhập so với các khoản nợ của bạn?',
        options: ['Character', 'Capacity', 'Collateral', 'Conditions'],
        answer: 1,
        explanation: 'Capacity - năng lực trả nợ.',
      ),
      QuizQuestion(
        question: 'Điều gì giúp xây dựng lịch sử tín dụng tốt?',
        options: ['Vay thật nhiều', 'Trả đúng hạn và đủ', 'Chỉ trả tối thiểu', 'Mở nhiều thẻ'],
        answer: 1,
        explanation: 'Trả đúng hạn, đủ số tiền là cách xây dựng uy tín.',
      ),
      QuizQuestion(
        question: 'Khoản trả nợ hằng tháng nên tối đa khoảng bao nhiêu % thu nhập?',
        options: ['10%', '30%', '50%', '80%'],
        answer: 0,
        explanation: 'Theo bài học, nên giữ ở mức khoảng 10% thu nhập hằng tháng.',
      ),
    ],
  ),

  // =========================================================================
  Course(
    id: 'investing',
    number: 9,
    title: 'Đầu tư căn bản',
    subtitle: 'Tiết kiệm và đầu tư, rủi ro - lợi nhuận, quy tắc 72.',
    icon: Icons.trending_up_rounded,
    tone: CourseTone.green,
    minutes: 7,
    simId: 'rule72',
    objectives: [
      'Phân biệt có tiền và xây dựng tài sản',
      'Hiểu mối quan hệ rủi ro - lợi nhuận',
      'Nắm thuật ngữ và các loại đầu tư cơ bản',
    ],
    cards: [
      LessonCard(
        title: 'Tiết kiệm là món quà cho chính bạn',
        body: 'Tiết kiệm là chìa khóa của độc lập tài chính. Tài sản (tiết kiệm, bất động sản, '
            'khoản đầu tư) không đến sau một đêm - mà là thói quen bền bỉ qua nhiều năm.',
        tip: 'Tự động hóa: đặt lệnh chuyển tiền vào tiết kiệm ngay ngày nhận lương.',
      ),
      LessonCard(
        title: 'Tiết kiệm khác đầu tư thế nào?',
        body: 'Đầu tư là đặt tiền tiết kiệm vào những thứ bạn tin sẽ tăng giá trị theo thời gian: '
            'cổ phiếu, trái phiếu, bất động sản...',
        bullets: [
          'Khác biệt lớn nhất: đầu tư LUÔN có rủi ro.',
          'Giá tăng: bạn có thể lời nhiều hơn gửi tiết kiệm. Giá giảm: có thể mất một phần hoặc toàn bộ.',
          'Rủi ro càng cao, lợi nhuận tiềm năng càng cao - và ngược lại.',
          'Không bao giờ đầu tư số tiền bạn không thể chịu mất.',
        ],
      ),
      LessonCard(
        title: 'Cổ phiếu và trái phiếu',
        body: 'Mua CỔ PHIẾU là sở hữu một phần công ty; bạn có thể nhận cổ tức khi công ty có lãi. '
            'TRÁI PHIẾU giống như cho doanh nghiệp hoặc Nhà nước vay, nhận lãi cố định.',
        bullets: [
          'Giá cổ phiếu dao động mạnh hơn trái phiếu hay tiền gửi.',
          'Ở Việt Nam, VN-Index đo xu hướng chung của cổ phiếu trên sàn HOSE.',
          'Lời khi bán cao hơn giá mua gọi là lãi vốn; lỗ gọi là lỗ vốn.',
          'Đầu tư đều đặn một số tiền cố định (bình quân giá) giúp giảm rủi ro mua đúng đỉnh.',
        ],
      ),
      LessonCard(
        title: 'Quy tắc 72',
        body: 'Muốn biết bao lâu tiền nhân đôi? Lấy 72 chia cho lãi suất hằng năm.',
        example: 'Lãi 8%/năm: 72 ÷ 8 = 9 năm để tiền tăng gấp đôi.\n'
            'Lãi 6%/năm: 72 ÷ 6 = 12 năm.\nLãi 4%/năm: 72 ÷ 4 = 18 năm.',
        tip: 'Chơi "Luyện tập → Quy tắc 72" để tính nhẩm siêu nhanh.',
      ),
    ],
    quiz: [
      QuizQuestion(
        question: 'Theo quy tắc 72, lãi 12%/năm thì bao lâu tiền nhân đôi?',
        options: ['4 năm', '6 năm', '8 năm', '12 năm'],
        answer: 1,
        explanation: '72 ÷ 12 = 6 năm.',
      ),
      QuizQuestion(
        question: 'Điểm khác biệt lớn nhất giữa tiết kiệm và đầu tư?',
        options: ['Đầu tư luôn có rủi ro', 'Tiết kiệm không có lãi', 'Đầu tư luôn có lời', 'Không khác gì'],
        answer: 0,
        explanation: 'Đầu tư có thể lời nhiều hơn nhưng cũng có thể mất tiền.',
      ),
      QuizQuestion(
        question: 'Mua cổ phiếu nghĩa là bạn...',
        options: ['Cho công ty vay', 'Sở hữu một phần công ty', 'Gửi tiết kiệm', 'Mua bảo hiểm'],
        answer: 1,
        explanation: 'Cổ đông sở hữu một phần công ty.',
      ),
      QuizQuestion(
        question: 'Nguyên tắc vàng khi đầu tư là gì?',
        options: [
          'Vay tiền để đầu tư',
          'Không đầu tư số tiền không thể chịu mất',
          'Dồn hết vào một mã',
          'Mua khi giá đang tăng mạnh',
        ],
        answer: 1,
        explanation: 'Chỉ đầu tư khoản tiền mà nếu mất bạn vẫn sống ổn.',
      ),
    ],
  ),

  // =========================================================================
  Course(
    id: 'staying-safe',
    number: 10,
    title: 'An toàn tài chính',
    subtitle: 'Nhận diện lừa đảo, bảo vệ thông tin và tài khoản.',
    icon: Icons.shield_rounded,
    tone: CourseTone.coral,
    minutes: 5,
    simId: 'scam',
    objectives: [
      'Nắm các mẹo phòng chống lừa đảo và đánh cắp danh tính',
      'Giữ tiền an toàn khi dùng mạng và ở nhà',
    ],
    cards: [
      LessonCard(
        title: 'Kẻ gian ở khắp nơi',
        body: 'Tin tặc, kẻ lừa đảo, kẻ đánh cắp danh tính luôn tìm cách lấy tiền bạn vất vả '
            'kiếm được - qua điện thoại, tin nhắn, mạng xã hội hay ngay tại cửa hàng.',
        bullets: [
          'Đánh cắp danh tính: lấy thông tin cá nhân của bạn để vay tiền, mở tài khoản đứng tên bạn.',
          'Tự bảo vệ mình là trách nhiệm của chính bạn.',
        ],
      ),
      LessonCard(
        title: 'Câu chuyện của Jeena',
        body: 'Jeena nhận được email/tin nhắn: "Tài khoản của bạn gặp sự cố nghiêm trọng, sẽ bị '
            'khóa nếu không xác minh NGAY qua đường link này." Jeena nên làm gì?',
        bullets: [
          '✗ Bấm link và điền thông tin → có thể dính lừa đảo giả mạo (phishing).',
          '✓ Không bấm link. Tự gọi tổng đài in trên thẻ hoặc mở app chính thức để kiểm tra.',
        ],
        tip: 'Tin nhắn thúc giục "khẩn cấp", "ngay lập tức" là dấu hiệu lừa đảo kinh điển.',
      ),
      LessonCard(
        title: 'Quy tắc vàng ở Việt Nam',
        body: 'Những chiêu lừa phổ biến và cách phòng tránh:',
        bullets: [
          'Không bao giờ đưa mã OTP, mật khẩu, mã PIN cho bất kỳ ai - kể cả người xưng là ngân hàng, công an.',
          'Cẩn thận tin nhắn giả mạo tên thương hiệu, link lạ qua Zalo/Messenger.',
          'Không cài ứng dụng lạ theo hướng dẫn qua điện thoại.',
          '"Việc nhẹ lương cao", "đầu tư lãi khủng" gần như chắc chắn là lừa đảo.',
        ],
      ),
      LessonCard(
        title: 'An toàn khi dùng mạng',
        body: 'Thói quen tốt mỗi ngày:',
        bullets: [
          'Chỉ nhập thông tin trên trang có "https" và biểu tượng ổ khóa.',
          'Cập nhật hệ điều hành, ứng dụng; bật xác thực 2 lớp.',
          'Không để thẻ, giấy tờ, mật khẩu lung tung; hủy giấy tờ tài chính cũ.',
          'Đăng xuất và đóng trình duyệt sau khi giao dịch.',
        ],
        tip: 'Kiểm tra kỹ năng trong "Luyện tập → Thám tử chống lừa đảo".',
      ),
    ],
    quiz: [
      QuizQuestion(
        question: 'Có người gọi xưng là nhân viên ngân hàng và xin mã OTP. Bạn làm gì?',
        options: ['Đọc mã cho họ', 'Từ chối, cúp máy và tự gọi tổng đài chính thức', 'Gửi qua Zalo', 'Hỏi lại tên rồi đưa mã'],
        answer: 1,
        explanation: 'Ngân hàng không bao giờ hỏi OTP. Tự liên hệ số tổng đài chính thức.',
      ),
      QuizQuestion(
        question: 'Tin nhắn "tài khoản sẽ bị khóa, bấm link để xác minh ngay" thường là gì?',
        options: ['Thông báo chính thức', 'Lừa đảo giả mạo (phishing)', 'Quảng cáo', 'Tin khuyến mãi'],
        answer: 1,
        explanation: 'Tạo áp lực khẩn cấp + link lạ là dấu hiệu lừa đảo điển hình.',
      ),
      QuizQuestion(
        question: 'Trang web an toàn để thanh toán thường có dấu hiệu gì?',
        options: ['Nhiều quảng cáo', '"https" và biểu tượng ổ khóa', 'Tên miền lạ', 'Yêu cầu cài app'],
        answer: 1,
        explanation: 'https và ổ khóa cho biết kết nối được mã hóa (vẫn cần kiểm tra tên miền).',
      ),
      QuizQuestion(
        question: 'Nên làm gì với giấy tờ tài chính cũ không cần nữa?',
        options: ['Vứt vào thùng rác', 'Hủy/xé nhỏ', 'Cho bạn giữ', 'Đăng lên mạng'],
        answer: 1,
        explanation: 'Hủy giấy tờ để kẻ gian không lấy được thông tin của bạn.',
      ),
    ],
  ),
];

/// Finds a course by id, or null.
Course? findCourse(String id) {
  for (final c in courses) {
    if (c.id == id) {
      return c;
    }
  }
  return null;
}

/// Short daily tips shown on the home screen (from the toolkit's articles).
const dailyTips = [
  'Trước khi mua, hãy hỏi: "Mình có cần nó ngay hôm nay không?"',
  'Trả cho mình trước: chuyển tiền vào tiết kiệm ngay ngày nhận lương.',
  'Không bao giờ đưa mã OTP cho bất kỳ ai - kể cả "nhân viên ngân hàng".',
  'Đừng đi siêu thị khi đang đói - bạn sẽ mua nhiều hơn dự định.',
  'Quy tắc 72: lấy 72 chia lãi suất để biết bao lâu tiền nhân đôi.',
  'Khi thu nhập tăng, hãy tăng phần tiết kiệm trước tiên.',
  'Luôn đọc kỹ hợp đồng trước khi ký - kể cả gói cước điện thoại.',
];
