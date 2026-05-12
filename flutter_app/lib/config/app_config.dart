/// ============================================================
///  app_config.dart — Cấu hình kết nối server
/// ============================================================
///
///  ĐỂ THAY ĐỔI SERVER:
///  - Đổi [baseUrl] sang địa chỉ server thực
///  - Ví dụ: 'https://api.yourserver.com'
///
///  MÔI TRƯỜNG:
///  - Docker (production) : API_BASE_URL=''  → relative path, nginx proxy
///  - Localhost (dev)     : http://localhost:3500
///  - Android Emulator   : http://10.0.2.2:3500
///  - Server thực        : https://your-domain.com
/// ============================================================

class AppConfig {
  AppConfig._(); // Không cho khởi tạo

  // ----------------------------------------------------------
  //  🔧 CẤU HÌNH SERVER — Chỉnh sửa tại đây khi đổi server
  // ----------------------------------------------------------

  /// Base URL của backend API.
  /// Hiện đang dùng localhost:3000 (chế độ phát triển).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  /// Mặc định cho từng môi trường — đổi dòng active khi cần.
  ///
  /// Docker: dùng rỗng (đường dẫn tương đối) → nginx tự proxy /api/ → backend
  /// Dev   : dùng full URL để trỏ thẳng tới backend
  static const String _defaultBaseUrl =
      'http://localhost:3500'; // ← Dev local (không dùng Docker)
  // '';                          // ← Docker: nginx proxy (relative path)
  // 'http://10.0.2.2:3500';     // ← Android Emulator
  // 'https://api.yourserver.com'; // ← Production Server

  // ----------------------------------------------------------
  //  ⚙️ Cài đặt HTTP
  // ----------------------------------------------------------

  /// Thời gian chờ tối đa mỗi request (giây).
  static const Duration requestTimeout = Duration(seconds: 15);

  /// Header mặc định cho mọi request.
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ----------------------------------------------------------
  //  📡 Endpoints — Không cần thay đổi khi đổi server
  // ----------------------------------------------------------
  static const String lockersEndpoint         = '/api/lockers';
  static const String lockersAvailableEndpoint = '/api/lockers/available';
  static const String packagesEndpoint        = '/api/packages';
  static const String packagesSendEndpoint    = '/api/packages/send';
  static const String packagesReceiveEndpoint = '/api/packages/receive';
  static const String statsEndpoint           = '/api/stats';
  static const String logsEndpoint            = '/api/logs';
}
