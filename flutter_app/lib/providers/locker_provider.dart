import 'package:flutter/material.dart';
import '../models/locker_model.dart';
import '../services/api_service.dart';

class LockerProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<LockerModel> _lockers = [];
  List<PackageModel> _packages = [];
  StatsModel? _stats;
  bool _isLoading = false;
  String? _error;

  List<LockerModel> get lockers => _lockers;
  List<PackageModel> get packages => _packages;
  StatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<PackageModel> get storedPackages =>
      _packages.where((p) => p.status == 'stored').toList();
  List<PackageModel> get receivedPackages =>
      _packages.where((p) => p.status == 'received').toList();

  Future<void> loadDashboard() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadLockers(),
        _loadStats(),
        _loadPackages(),
      ]);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadLockers() async {
    final result = await _api.getAllLockers();
    _lockers = (result['data'] as List)
        .map((j) => LockerModel.fromJson(j))
        .toList();
  }

  Future<void> _loadStats() async {
    final result = await _api.getStats();
    _stats = StatsModel.fromJson(result['data']);
  }

  Future<void> _loadPackages() async {
    final result = await _api.getAllPackages();
    _packages = (result['data'] as List)
        .map((j) => PackageModel.fromJson(j))
        .toList();
  }

  Future<Map<String, dynamic>> sendPackage({
    required String senderName,
    required String senderDob,
    required String senderPhone,
    String? receiverName,
    String? receiverPhone,
    String? description,
    double? weight,
  }) async {
    final result = await _api.sendPackage(
      senderName: senderName,
      senderDob: senderDob,
      senderPhone: senderPhone,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      description: description,
      weight: weight,
    );
    await loadDashboard();
    return result;
  }

  Future<Map<String, dynamic>> receivePackage({
    required String lockerNumber,
    required String pinCode,
    String? receiverPhone,
  }) async {
    final result = await _api.receivePackage(
      lockerNumber: lockerNumber,
      pinCode: pinCode,
      receiverPhone: receiverPhone,
    );
    await loadDashboard();
    return result;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
