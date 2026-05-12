import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _base = AppConfig.baseUrl;
  final Duration _timeout = AppConfig.requestTimeout;

  Map<String, String> get _headers => AppConfig.defaultHeaders;

  // ===================== LOCKERS =====================
  Future<Map<String, dynamic>> getAllLockers() async {
    final response = await http
        .get(Uri.parse('$_base${AppConfig.lockersEndpoint}'), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getAvailableLockers() async {
    final response = await http
        .get(Uri.parse('$_base${AppConfig.lockersAvailableEndpoint}'), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(response);
  }

  // ===================== PACKAGES =====================
  Future<Map<String, dynamic>> sendPackage({
    required String senderName,
    required String senderDob,
    required String senderPhone,
    String? receiverName,
    String? receiverPhone,
    String? description,
    double? weight,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_base${AppConfig.packagesSendEndpoint}'),
          headers: _headers,
          body: jsonEncode({
            'sender_name': senderName,
            'sender_dob': senderDob,
            'sender_phone': senderPhone,
            'receiver_name': receiverName,
            'receiver_phone': receiverPhone,
            'description': description,
            'weight': weight,
          }),
        )
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> receivePackage({
    required String lockerNumber,
    required String pinCode,
    String? receiverPhone,
  }) async {
    final response = await http
        .post(
          Uri.parse('$_base${AppConfig.packagesReceiveEndpoint}'),
          headers: _headers,
          body: jsonEncode({
            'locker_number': lockerNumber,
            'pin_code': pinCode,
            'receiver_phone': receiverPhone,
          }),
        )
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getAllPackages({String? status, String? phone}) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (phone != null) params['phone'] = phone;

    final uri = Uri.parse('$_base${AppConfig.packagesEndpoint}').replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await http.get(uri, headers: _headers).timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await http
        .get(Uri.parse('$_base${AppConfig.statsEndpoint}'), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getLogs() async {
    final response = await http
        .get(Uri.parse('$_base${AppConfig.logsEndpoint}'), headers: _headers)
        .timeout(_timeout);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Lỗi không xác định');
    }
  }
}
