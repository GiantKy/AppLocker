import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locker_provider.dart';
import '../models/locker_model.dart';
import '../theme/app_theme.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LockerProvider>().loadDashboard();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
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
                gradient: AppGradients.manageGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text('Quản Lý', style: AppTextStyles.titleLarge),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => context.read<LockerProvider>().loadDashboard(),
          ),
        ],
        elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Đang Lưu'),
            Tab(text: 'Đã Nhận'),
            Tab(text: 'Tủ'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildPackageList(filterStatus: 'stored'),
                _buildPackageList(filterStatus: 'received'),
                _buildLockerGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppDimens.paddingMD),
      child: TextField(
        controller: _searchCtrl,
        style: AppTextStyles.bodyLarge,
        onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, SĐT...',
          hintStyle: AppTextStyles.bodyMedium,
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textMuted, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppColors.textMuted, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.cardLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMD),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPackageList({required String filterStatus}) {
    return Consumer<LockerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        var list = provider.packages
            .where((p) => p.status == filterStatus)
            .toList();

        if (_searchQuery.isNotEmpty) {
          list = list.where((p) {
            return p.senderName.toLowerCase().contains(_searchQuery) ||
                p.senderPhone.contains(_searchQuery) ||
                p.lockerNumber.toLowerCase().contains(_searchQuery) ||
                p.receiverName.toLowerCase().contains(_searchQuery);
          }).toList();
        }

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  filterStatus == 'stored'
                      ? Icons.inventory_2_outlined
                      : Icons.check_circle_outline,
                  size: 48,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 12),
                Text(
                  _searchQuery.isEmpty ? 'Không có dữ liệu' : 'Không tìm thấy',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppDimens.paddingMD),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _PackageCard(package: list[i]),
        );
      },
    );
  }

  Widget _buildLockerGrid() {
    return Consumer<LockerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final lockers = provider.lockers;

        return Column(
          children: [
            // Legend
            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingMD),
              child: Row(
                children: [
                  _LegendItem(
                    color: AppColors.accentGreen,
                    label: 'Trống (${lockers.where((l) => l.status == 'available').length})',
                  ),
                  const SizedBox(width: 20),
                  _LegendItem(
                    color: AppColors.accentOrange,
                    label: 'Có hàng (${lockers.where((l) => l.status == 'occupied').length})',
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(AppDimens.paddingMD),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: lockers.length,
                itemBuilder: (context, i) => _LockerDetailTile(locker: lockers[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PackageModel package;

  const _PackageCard({required this.package});

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: package.isStored
                      ? AppGradients.sendGradient
                      : AppGradients.receiveGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  package.lockerNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              StatusBadge(status: package.status),
              const Spacer(),
              Text(
                _formatDate(package.sentAt),
                style: AppTextStyles.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  package.senderName,
                  style: AppTextStyles.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.phone_rounded,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(package.senderPhone, style: AppTextStyles.bodyMedium),
            ],
          ),
          if (package.receiverName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_pin_rounded,
                    size: 16, color: AppColors.accentGreen),
                const SizedBox(width: 6),
                Text(
                  'Nhận: ${package.receiverName}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ],
          if (package.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.description_outlined,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    package.description,
                    style: AppTextStyles.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LockerDetailTile extends StatelessWidget {
  final LockerModel locker;

  const _LockerDetailTile({required this.locker});

  @override
  Widget build(BuildContext context) {
    final isAvailable = locker.isAvailable;
    final color = isAvailable ? AppColors.accentGreen : AppColors.accentOrange;

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAvailable ? Icons.lock_open_rounded : Icons.lock_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            locker.lockerNumber,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          StatusBadge(status: locker.status),
          const SizedBox(height: 4),
          Text(
            locker.size.toUpperCase(),
            style: TextStyle(
              color: color.withOpacity(0.6),
              fontSize: 9,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
