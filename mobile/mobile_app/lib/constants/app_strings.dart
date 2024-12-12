class AppStrings {
  // Tiêu đề ứng dụng
  static const String appName = 'Trợ Thủ Người Mù';
  
  // Nội dung Onboarding
  static const List<String> onboardingTitles = [
    'Chào mừng!',
    'Chụp Ảnh',
    'Trợ Lý Âm Thanh'
  ];

  static const List<String> onboardingDescriptions = [
    'Ứng dụng hỗ trợ người khiếm thị nhận diện môi trường xung quanh',
    'Di chuyển camera để chụp ảnh. Ứng dụng sẽ mô tả chi tiết hình ảnh',
    'Sử dụng giọng nói để điều khiển ứng dụng. Kết quả sẽ được đọc to'
  ];

  // Nút và văn bản chung
  static const String buttonStart = 'Bắt đầu';
  static const String buttonNext = 'Tiếp tục';
  static const String buttonBack = 'Quay lại';

  // Thông báo lỗi
  static const String errorGeneric = 'Đã có lỗi xảy ra';
  static const String errorImageProcessing = 'Không thể xử lý hình ảnh';
  static const String errorVoiceCommand = 'Không thể nhận dạng giọng nói';

  // Gợi ý sử dụng
  static const String hintCaptureImage = 'Chạm để chụp ảnh';
  static const String hintVoiceAssistant = 'Nói "Trợ giúp" để kích hoạt';
}