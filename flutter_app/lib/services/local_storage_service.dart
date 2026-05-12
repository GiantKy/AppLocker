import 'package:shared_preferences/shared_preferences.dart';

/// Service lưu trữ tạm thời dữ liệu form trước khi gửi lên server.
/// Dữ liệu sẽ bị xóa sau khi push thành công.
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // ─── Keys ────────────────────────────────────────────────────────────────
  static const String _keyPrefix = 'draft_send_';
  static const String keySenderName    = '${_keyPrefix}sender_name';
  static const String keySenderDob     = '${_keyPrefix}sender_dob';
  static const String keySenderPhone   = '${_keyPrefix}sender_phone';
  static const String keyReceiverName  = '${_keyPrefix}receiver_name';
  static const String keyReceiverPhone = '${_keyPrefix}receiver_phone';
  static const String keyDescription   = '${_keyPrefix}description';

  static const List<String> _allDraftKeys = [
    keySenderName,
    keySenderDob,
    keySenderPhone,
    keyReceiverName,
    keyReceiverPhone,
    keyDescription,
  ];

  // ─── Save ─────────────────────────────────────────────────────────────────
  /// Lưu tất cả trường của form gửi hàng vào bộ nhớ tạm.
  Future<void> saveSendFormDraft({
    required String senderName,
    required String senderDob,
    required String senderPhone,
    String? receiverName,
    String? receiverPhone,
    String? description,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySenderName,    senderName);
    await prefs.setString(keySenderDob,     senderDob);
    await prefs.setString(keySenderPhone,   senderPhone);
    await prefs.setString(keyReceiverName,  receiverName  ?? '');
    await prefs.setString(keyReceiverPhone, receiverPhone ?? '');
    await prefs.setString(keyDescription,   description   ?? '');
  }

  // ─── Load ─────────────────────────────────────────────────────────────────
  /// Đọc toàn bộ draft form. Trả về null nếu chưa có dữ liệu nào được lưu.
  Future<Map<String, String>?> loadSendFormDraft() async {
    final prefs = await SharedPreferences.getInstance();

    // Chỉ trả về dữ liệu nếu có ít nhất 1 trường bắt buộc đã được lưu
    final senderName = prefs.getString(keySenderName) ?? '';
    if (senderName.isEmpty) return null;

    return {
      'sender_name':    senderName,
      'sender_dob':     prefs.getString(keySenderDob)     ?? '',
      'sender_phone':   prefs.getString(keySenderPhone)   ?? '',
      'receiver_name':  prefs.getString(keyReceiverName)  ?? '',
      'receiver_phone': prefs.getString(keyReceiverPhone) ?? '',
      'description':    prefs.getString(keyDescription)   ?? '',
    };
  }

  /// Kiểm tra xem có dữ liệu draft nào chưa gửi không.
  Future<bool> hasSendFormDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(keySenderName) ?? '';
    return name.isNotEmpty;
  }

  // ─── Clear ────────────────────────────────────────────────────────────────
  /// Xóa toàn bộ dữ liệu draft sau khi gửi thành công.
  Future<void> clearSendFormDraft() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _allDraftKeys) {
      await prefs.remove(key);
    }
  }
}
