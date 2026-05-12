import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locker_provider.dart';
import '../theme/app_theme.dart';
import 'send_screen.dart';
import 'receive_screen.dart';
import 'manage_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LockerProvider>().loadDashboard();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => context.read<LockerProvider>().loadDashboard(),
            color: AppColors.primary,
            backgroundColor: AppColors.card,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimens.paddingMD),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildStatsSection(),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Chức Năng Chính'),
                      const SizedBox(height: 16),
                      _buildMainFeatures(context),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Trạng Thái Tủ'),
                      const SizedBox(height: 16),
                      _buildLockersGrid(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.lock_clock, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TỦ THÔNG MINH', style: AppTextStyles.displayMedium),
              Text(
                'Smart Locker Management',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => context.read<LockerProvider>().loadDashboard(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Consumer<LockerProvider>(
      builder: (context, provider, _) {
        final stats = provider.stats;
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Tổng Ô Tủ',
                    value: stats?.totalLockers.toString() ?? '--',
                    icon: Icons.grid_view_rounded,
                    gradient: AppGradients.primaryGradient,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Ô Trống',
                    value: stats?.availableLockers.toString() ?? '--',
                    icon: Icons.lock_open_rounded,
                    gradient: AppGradients.receiveGradient,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Đang Lưu',
                    value: stats?.packagesStored.toString() ?? '--',
                    icon: Icons.inventory_2_rounded,
                    gradient: AppGradients.sendGradient,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Đã Nhận',
                    value: stats?.packagesReceived.toString() ?? '--',
                    icon: Icons.check_circle_rounded,
                    gradient: AppGradients.manageGradient,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.titleMedium),
      ],
    );
  }

  Widget _buildMainFeatures(BuildContext context) {
    return Column(
      children: [
        _FeatureCard(
          title: 'Gửi Hàng',
          subtitle: 'Lưu hàng vào tủ thông minh',
          icon: Icons.upload_rounded,
          gradient: AppGradients.sendGradient,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SendScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          title: 'Lấy Hàng',
          subtitle: 'Nhận hàng từ tủ bằng mã PIN',
          icon: Icons.download_rounded,
          gradient: AppGradients.receiveGradient,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReceiveScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          title: 'Quản Lý',
          subtitle: 'Xem toàn bộ đơn hàng & tủ',
          icon: Icons.admin_panel_settings_rounded,
          gradient: AppGradients.manageGradient,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManageScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildLockersGrid() {
    return Consumer<LockerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (provider.lockers.isEmpty) {
          return GlassCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 40, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text('Không thể tải dữ liệu', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      provider.error ?? 'Kiểm tra kết nối mạng',
                      style: AppTextStyles.labelMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: provider.lockers.length,
          itemBuilder: (context, index) {
            final locker = provider.lockers[index];
            return _LockerTile(locker: locker);
          },
        );
      },
    );
  }
}

// ==================== CHILD WIDGETS ====================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.displayMedium.copyWith(fontSize: 22),
                ),
                Text(title, style: AppTextStyles.labelMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(AppDimens.radiusLG),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LockerTile extends StatelessWidget {
  final dynamic locker;

  const _LockerTile({required this.locker});

  @override
  Widget build(BuildContext context) {
    final isAvailable = locker.status == 'available';
    final color = isAvailable ? AppColors.accentGreen : AppColors.accentOrange;

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAvailable ? Icons.lock_open_rounded : Icons.lock_rounded,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            locker.lockerNumber,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isAvailable ? 'Trống' : 'Có hàng',
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
