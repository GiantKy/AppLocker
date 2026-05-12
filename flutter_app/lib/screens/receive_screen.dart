import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locker_provider.dart';
import '../theme/app_theme.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _lockerCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _isLoading = false;
  bool _showResult = false;
  Map<String, dynamic>? _result;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _lockerCtrl.dispose();
    _pinCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final result = await context.read<LockerProvider>().receivePackage(
        lockerNumber: _lockerCtrl.text.trim().toUpperCase(),
        pinCode: _pinCtrl.text.trim(),
        receiverPhone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      );

      setState(() {
        _result = result['data'];
        _showResult = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _reset() {
    _formKey.currentState?.reset();
    _lockerCtrl.clear();
    _pinCtrl.clear();
    _phoneCtrl.clear();
    setState(() {
      _showResult = false;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppGradients.receiveGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text('Lấy Hàng', style: AppTextStyles.titleLarge),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: _showResult ? _buildSuccessView() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.paddingMD),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Illustration
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppGradients.receiveGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGreen.withOpacity(0.3),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  const Text(
                    'Nhập Thông Tin Để Lấy Hàng',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nhập số ô tủ và mã PIN được cung cấp khi gửi',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            GlassCard(
              child: Column(
                children: [
                  // Locker number
                  AppTextField(
                    label: 'Số Ô Tủ *',
                    hint: 'VD: L01, L02...',
                    icon: Icons.grid_view_rounded,
                    controller: _lockerCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Vui lòng nhập số ô tủ'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // PIN code with custom styling
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mã PIN *',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pinCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          letterSpacing: 12,
                          fontWeight: FontWeight.w800,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Vui lòng nhập mã PIN';
                          }
                          if (v.length != 4) return 'Mã PIN gồm 4 chữ số';
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '••••',
                          hintStyle: const TextStyle(
                            fontSize: 28,
                            letterSpacing: 12,
                            color: AppColors.textMuted,
                          ),
                          prefixIcon: const Icon(
                            Icons.pin_rounded,
                            color: AppColors.accentGreen,
                            size: 20,
                          ),
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.cardLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                            borderSide: const BorderSide(
                                color: AppColors.accentGreen, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                            borderSide:
                                const BorderSide(color: AppColors.error),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  AppTextField(
                    label: 'Số Điện Thoại',
                    hint: 'Không bắt buộc',
                    icon: Icons.phone_rounded,
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            GradientButton(
              text: 'XÁC NHẬN LẤY HÀNG',
              gradient: AppGradients.receiveGradient,
              icon: Icons.download_rounded,
              isLoading: _isLoading,
              onPressed: _submit,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    final data = _result!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.paddingMD),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppGradients.receiveGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGreen.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Lấy Hàng Thành Công!', style: AppTextStyles.displayMedium),
          const SizedBox(height: 4),
          Text(
            'Vui lòng lấy hàng khỏi tủ',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 28),
          GlassCard(
            child: Column(
              children: [
                _InfoRow(
                  label: 'Số Ô Tủ',
                  value: data['locker_number'] ?? '',
                  icon: Icons.grid_view_rounded,
                ),
                const Divider(color: AppColors.divider, height: 24),
                _InfoRow(
                  label: 'Người Gửi',
                  value: data['sender_name'] ?? '',
                  icon: Icons.person_rounded,
                ),
                const Divider(color: AppColors.divider, height: 24),
                _InfoRow(
                  label: 'SĐT Người Gửi',
                  value: data['sender_phone'] ?? '',
                  icon: Icons.phone_rounded,
                ),
                const Divider(color: AppColors.divider, height: 24),
                _InfoRow(
                  label: 'Ngày Gửi',
                  value: _formatDate(data['sent_at']),
                  icon: Icons.calendar_today_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'LẤY TIẾP',
            gradient: AppGradients.receiveGradient,
            icon: Icons.refresh_rounded,
            onPressed: _reset,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusMD),
              ),
            ),
            child: const Text('Về Trang Chủ',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.accentGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelMedium),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}
