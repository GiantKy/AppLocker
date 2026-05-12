import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/locker_provider.dart';
import '../services/local_storage_service.dart';
import '../theme/app_theme.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _receiverNameCtrl = TextEditingController();
  final _receiverPhoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _storage = LocalStorageService();
  bool _draftRestored = false;   // hiển thị banner thông báo draft

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

    // Lắng nghe thay đổi để lưu draft tự động
    // ⚠️ _dobCtrl cũng phải có listener để lưu khi date picker thay đổi
    for (final ctrl in [
      _nameCtrl, _dobCtrl, _phoneCtrl,
      _receiverNameCtrl, _receiverPhoneCtrl, _descCtrl,
    ]) {
      ctrl.addListener(_saveDraft);
    }

    // Load draft đã lưu (nếu có)
    _loadDraft();
  }

  @override
  void dispose() {
    for (final ctrl in [
      _nameCtrl, _dobCtrl, _phoneCtrl,
      _receiverNameCtrl, _receiverPhoneCtrl, _descCtrl,
    ]) {
      ctrl.removeListener(_saveDraft);
    }
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _phoneCtrl.dispose();
    _receiverNameCtrl.dispose();
    _receiverPhoneCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ─── Draft helpers ──────────────────────────────────────────────────────
  Future<void> _loadDraft() async {
    final draft = await _storage.loadSendFormDraft();
    if (draft == null) return;
    setState(() {
      _nameCtrl.text         = draft['sender_name']    ?? '';
      _dobCtrl.text          = draft['sender_dob']     ?? '';
      _phoneCtrl.text        = draft['sender_phone']   ?? '';
      _receiverNameCtrl.text = draft['receiver_name']  ?? '';
      _receiverPhoneCtrl.text= draft['receiver_phone'] ?? '';
      _descCtrl.text         = draft['description']    ?? '';
      _draftRestored = true;
    });
  }

  Future<void> _saveDraft() async {
    await _storage.saveSendFormDraft(
      senderName:    _nameCtrl.text.trim(),
      senderDob:     _dobCtrl.text.trim(),
      senderPhone:   _phoneCtrl.text.trim(),
      receiverName:  _receiverNameCtrl.text.trim(),
      receiverPhone: _receiverPhoneCtrl.text.trim(),
      description:   _descCtrl.text.trim(),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      // Listener trên _dobCtrl sẽ tự động gọi _saveDraft()
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // 💾 Capture provider trước khi await (tránh dùng context sau async gap)
    final provider = context.read<LockerProvider>();

    // 💾 Lưu toàn bộ dữ liệu ngay trước khi gửi
    // Đảm bảo không mất dữ liệu dù API có thất bại
    await _saveDraft();
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final result = await provider.sendPackage(
        senderName: _nameCtrl.text.trim(),
        senderDob: _dobCtrl.text.trim(),
        senderPhone: _phoneCtrl.text.trim(),
        receiverName: _receiverNameCtrl.text.trim().isEmpty
            ? null
            : _receiverNameCtrl.text.trim(),
        receiverPhone: _receiverPhoneCtrl.text.trim().isEmpty
            ? null
            : _receiverPhoneCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
      );

      // ✅ Gửi thành công → xóa dữ liệu tạm
      await _storage.clearSendFormDraft();

      if (!mounted) return;
      setState(() {
        _result = result['data'];
        _showResult = true;
        _isLoading = false;
        _draftRestored = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _reset() {
    _formKey.currentState?.reset();
    _nameCtrl.clear();
    _dobCtrl.clear();
    _phoneCtrl.clear();
    _receiverNameCtrl.clear();
    _receiverPhoneCtrl.clear();
    _descCtrl.clear();
    setState(() {
      _showResult = false;
      _result = null;
      _draftRestored = false;
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
                gradient: AppGradients.sendGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.upload_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text('Gửi Hàng', style: AppTextStyles.titleLarge),
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

  /// Banner thông báo đã khôi phục dữ liệu còn dang dở
  Widget _buildDraftBanner() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _draftRestored
          ? Container(
              key: const ValueKey('draft_banner'),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusMD),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.restore_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Đã khôi phục thông tin chưa gửi từ lần trước',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _reset();
                      _storage.clearSendFormDraft();
                    },
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('no_banner')),
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
            _buildDraftBanner(),
            // Sender info section
            _buildSectionHeader(
              icon: Icons.person_rounded,
              title: 'Thông Tin Người Gửi',
              subtitle: 'Vui lòng điền đầy đủ thông tin',
              gradient: AppGradients.sendGradient,
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  AppTextField(
                    label: 'Họ và Tên *',
                    hint: 'Nguyễn Văn A',
                    icon: Icons.badge_rounded,
                    controller: _nameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Vui lòng nhập họ tên'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Ngày Sinh *',
                    hint: 'DD/MM/YYYY',
                    icon: Icons.cake_rounded,
                    controller: _dobCtrl,
                    readOnly: true,
                    onTap: _pickDate,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Vui lòng chọn ngày sinh'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Số Điện Thoại *',
                    hint: '0901234567',
                    icon: Icons.phone_rounded,
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Vui lòng nhập số điện thoại';
                      }
                      if (!RegExp(r'^[0-9]{9,11}$').hasMatch(v.trim())) {
                        return 'Số điện thoại không hợp lệ';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Optional receiver info
            _buildSectionHeader(
              icon: Icons.person_pin_rounded,
              title: 'Thông Tin Người Nhận',
              subtitle: 'Không bắt buộc',
              gradient: AppGradients.receiveGradient,
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: [
                  AppTextField(
                    label: 'Tên Người Nhận',
                    hint: 'Trần Thị B',
                    icon: Icons.person_outline_rounded,
                    controller: _receiverNameCtrl,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'SĐT Người Nhận',
                    hint: '0901234567',
                    icon: Icons.phone_outlined,
                    controller: _receiverPhoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Mô Tả Hàng Hóa',
                    hint: 'Quần áo, sách, thiết bị...',
                    icon: Icons.description_outlined,
                    controller: _descCtrl,
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            GradientButton(
              text: 'XÁC NHẬN GỬI HÀNG',
              gradient: AppGradients.sendGradient,
              icon: Icons.send_rounded,
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
          // Success icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppGradients.sendGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
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
          const Text('Gửi Hàng Thành Công!', style: AppTextStyles.displayMedium),
          const SizedBox(height: 4),
          Text(
            'Hàng đã được lưu vào tủ',
            style: AppTextStyles.bodyMedium,
          ),

          const SizedBox(height: 28),

          // Result card
          GlassCard(
            child: Column(
              children: [
                _ResultRow(
                  label: 'Số Ô Tủ',
                  value: data['locker_number'] ?? '',
                  icon: Icons.grid_view_rounded,
                  highlight: true,
                ),
                const Divider(color: AppColors.divider, height: 24),
                _ResultRow(
                  label: 'Mã PIN',
                  value: data['pin_code'] ?? '',
                  icon: Icons.pin_rounded,
                  highlight: true,
                  isPrimary: true,
                ),
                const Divider(color: AppColors.divider, height: 24),
                _ResultRow(
                  label: 'Người Gửi',
                  value: data['sender_name'] ?? '',
                  icon: Icons.person_rounded,
                ),
                const Divider(color: AppColors.divider, height: 24),
                _ResultRow(
                  label: 'Số Điện Thoại',
                  value: data['sender_phone'] ?? '',
                  icon: Icons.phone_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          GlassCard(
            color: AppColors.warning.withOpacity(0.05),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vui lòng lưu lại MÃ PIN và SỐ Ô TỦ để lấy hàng!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          GradientButton(
            text: 'GỬI THÊM',
            gradient: AppGradients.sendGradient,
            icon: Icons.add_rounded,
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

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.titleMedium),
            Text(subtitle, style: AppTextStyles.labelMedium),
          ],
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;
  final bool isPrimary;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isPrimary ? AppColors.accent : AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelMedium),
              const SizedBox(height: 2),
              Text(
                value,
                style: highlight
                    ? TextStyle(
                        fontSize: isPrimary ? 24 : 18,
                        fontWeight: FontWeight.w800,
                        color: isPrimary ? AppColors.accent : AppColors.textPrimary,
                        letterSpacing: isPrimary ? 4 : 1,
                      )
                    : AppTextStyles.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
