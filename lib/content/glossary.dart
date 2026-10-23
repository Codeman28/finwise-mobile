// glossary.dart
// ---------------------------------------------------------------------------
// "Từ điển tài chính": key terms from the toolkit's glossary, explained in
// simple Vietnamese. Pure data - the Glossary screen makes it searchable.
// ---------------------------------------------------------------------------

class GlossaryTerm {
  const GlossaryTerm(this.term, this.english, this.meaning);
  final String term;
  final String english;
  final String meaning;
}

const glossary = <GlossaryTerm>[
  GlossaryTerm('Tài khoản', 'Account',
      'Dịch vụ ngân hàng giúp giữ và theo dõi tiền của bạn, phổ biến nhất là tài khoản thanh toán và tài khoản tiết kiệm.'),
  GlossaryTerm('Phí thường niên', 'Annual fee',
      'Khoản phí công ty thẻ tín dụng thu mỗi năm để bạn được sử dụng thẻ.'),
  GlossaryTerm('Lãi suất năm (APR)', 'Annual percentage rate',
      'Tỷ lệ phản ánh tổng chi phí khoản vay trong một năm, gồm lãi suất và phí. APR càng thấp, khoản vay càng rẻ.'),
  GlossaryTerm('Lợi suất năm (APY)', 'Annual percentage yield',
      'Tỷ lệ lợi nhuận bạn nhận được trong một năm từ khoản tiền gửi có lãi, đã tính cả lãi kép.'),
  GlossaryTerm('Tăng giá trị', 'Appreciation',
      'Giá trị của một món đồ (nhà, đất, cổ phiếu) tăng lên so với giá mua ban đầu.'),
  GlossaryTerm('Tài sản', 'Asset',
      'Bất cứ thứ gì có giá trị mà một người hay công ty sở hữu: tiền mặt, nhà, xe, cổ phiếu, thiết bị.'),
  GlossaryTerm('Số dư khả dụng', 'Available balance',
      'Số tiền trong tài khoản mà bạn có thể dùng hoặc rút ngay lúc này.'),
  GlossaryTerm('Trái phiếu', 'Bond',
      'Giấy nợ do doanh nghiệp hoặc Nhà nước phát hành để vay tiền; người mua nhận lãi theo kỳ và nhận lại gốc khi đáo hạn.'),
  GlossaryTerm('Năng lực trả nợ', 'Capacity',
      'Khả năng trả các khoản vay hằng tháng, dựa trên thu nhập và các khoản nợ hiện có.'),
  GlossaryTerm('Lãi vốn', 'Capital gain',
      'Phần chênh lệch khi bán một tài sản cao hơn giá mua. Ví dụ mua cổ phiếu 20.000 ₫, bán 28.000 ₫ → lãi vốn 8.000 ₫/cổ phiếu.'),
  GlossaryTerm('Lỗ vốn', 'Capital loss', 'Phần giá trị bị mất khi bán tài sản thấp hơn giá mua.'),
  GlossaryTerm('Tiền gửi có kỳ hạn', 'Certificate of deposit',
      'Khoản tiết kiệm cam kết gửi trong một thời gian nhất định để có lãi cao hơn; rút trước hạn thường bị giảm lãi.'),
  GlossaryTerm('Tài sản đảm bảo', 'Collateral',
      'Tài sản của người vay mà bên cho vay có quyền thu giữ nếu khoản vay không được trả.'),
  GlossaryTerm('Lãi kép', 'Compound interest',
      'Tiền lãi được tính trên cả tiền gốc lẫn phần lãi đã tích lũy - "lãi mẹ đẻ lãi con".'),
  GlossaryTerm('Tín dụng', 'Credit', 'Khả năng vay tiền hoặc mua trước trả sau dựa trên sự tin tưởng rằng bạn sẽ trả.'),
  GlossaryTerm('Lịch sử tín dụng', 'Credit history',
      'Hồ sơ ghi lại việc bạn vay và trả nợ. Ở Việt Nam do Trung tâm Thông tin Tín dụng Quốc gia (CIC) quản lý.'),
  GlossaryTerm('Hạn mức tín dụng', 'Credit limit', 'Số tiền tối đa bạn được phép chi tiêu hoặc vay trên thẻ tín dụng.'),
  GlossaryTerm('Điểm tín dụng', 'Credit score',
      'Con số đánh giá mức độ đáng tin cậy khi vay tiền, được ngân hàng dùng để quyết định có cho vay hay không.'),
  GlossaryTerm('Thẻ ghi nợ', 'Debit card',
      'Thẻ gắn với tài khoản thanh toán; khi dùng, tiền bị trừ trực tiếp từ tài khoản của bạn.'),
  GlossaryTerm('Nợ', 'Debt', 'Tiền, hàng hóa hay dịch vụ mà bạn đang nợ người khác.'),
  GlossaryTerm('Vỡ nợ', 'Default', 'Không trả được khoản vay theo đúng điều khoản đã thỏa thuận.'),
  GlossaryTerm('Khấu hao / mất giá', 'Depreciation',
      'Giá trị bị giảm dần do tuổi thọ, hao mòn hoặc lỗi thời - ví dụ xe máy, điện thoại.'),
  GlossaryTerm('Chi phí tùy ý', 'Discretionary expense',
      'Khoản chi không thiết yếu mà bạn tự chọn, như xem phim, ăn nhà hàng.'),
  GlossaryTerm('Cổ tức', 'Dividend', 'Phần lợi nhuận công ty chia lại cho cổ đông, bằng tiền hoặc cổ phiếu.'),
  GlossaryTerm('Khả năng kiếm tiền', 'Earning power', 'Số tiền một người có thể kiếm được từ công việc của mình.'),
  GlossaryTerm('Chi phí cố định', 'Fixed expense', 'Khoản chi không đổi mỗi tháng, như tiền phòng, tiền trả góp.'),
  GlossaryTerm('Chi phí linh hoạt', 'Flexible expense',
      'Khoản chi đều đặn nhưng bạn điều chỉnh được mức chi, như ăn uống, xăng xe, quần áo.'),
  GlossaryTerm('Thu nhập gộp', 'Gross income', 'Toàn bộ số tiền kiếm được trước khi trừ thuế và bảo hiểm.'),
  GlossaryTerm('Thu nhập', 'Income', 'Số tiền nhận được trong một khoảng thời gian: lương, tiền bán hàng, lợi nhuận đầu tư.'),
  GlossaryTerm('Lạm phát', 'Inflation', 'Mặt bằng giá cả hàng hóa, dịch vụ tăng lên, khiến cùng số tiền mua được ít hơn.'),
  GlossaryTerm('Lãi suất', 'Interest rate', 'Tỷ lệ phần trăm tính trên số tiền gửi hoặc vay, cho biết giá của việc dùng tiền.'),
  GlossaryTerm('Nợ phải trả', 'Liability', 'Số tiền một cá nhân hay doanh nghiệp đang nợ người khác.'),
  GlossaryTerm('Thu nhập thực nhận', 'Net income', 'Số tiền về tay sau khi đã trừ thuế, bảo hiểm và các khoản khấu trừ khác.'),
  GlossaryTerm('Lừa đảo giả mạo', 'Phishing',
      'Chiêu gửi email, tin nhắn giả danh tổ chức uy tín để lừa bạn bấm link và khai thông tin, mật khẩu, OTP.'),
  GlossaryTerm('Tiền gốc', 'Principal', 'Số tiền ban đầu bạn gửi vào hoặc vay, chưa tính lãi.'),
  GlossaryTerm('Cổ phiếu', 'Stock', 'Chứng nhận sở hữu một phần công ty; giá lên xuống theo kỳ vọng của thị trường.'),
  GlossaryTerm('Đổi hàng', 'Barter', 'Trao đổi trực tiếp hàng hóa hoặc dịch vụ với nhau mà không dùng tiền.'),
  GlossaryTerm('Quy tắc 72', 'Rule of 72', 'Cách tính nhanh số năm để tiền nhân đôi: 72 chia cho lãi suất năm.'),
];
