import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/helper.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/my_text_filed.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../auth/data/models/user_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_header.dart';

class AdminDoctorsPage extends ConsumerStatefulWidget {
  const AdminDoctorsPage({super.key});

  @override
  ConsumerState<AdminDoctorsPage> createState() => _AdminDoctorsPageState();
}

class _AdminDoctorsPageState extends ConsumerState<AdminDoctorsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(UserModel doctor) {
    AppDialog.show(
      context: context,
      title: LocaleKeys.delete_doctor.tr(),
      icon: Icons.delete_outline_rounded,
      iconColor: AppColors.danger,
      content: LocaleKeys.delete_doctor_confirm
          .tr(namedArgs: {'name': doctor.name}),
      actions: [
        AppDialogAction(
          label: LocaleKeys.cancelButton.tr(),
          type: AppButtonType.outlined,
          onPressed: () => Navigator.pop(context),
        ),
        AppDialogAction(
          label: LocaleKeys.delete.tr(),
          type: AppButtonType.danger,
          onPressed: () {
            Navigator.pop(context);
            ref.read(adminProvider.notifier).deleteDoctor(doctor.id);
          },
        ),
      ],
    );
  }

  void _showEditSheet(UserModel doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DoctorEditSheet(
        doctor: doctor,
        onSaved: (updated) =>
            ref.read(adminProvider.notifier).updateDoctor(updated),
      ),
    );
  }

  void _confirmApprove(UserModel doctor, String adminId) {
    AppDialog.show(
      context: context,
      title: LocaleKeys.approve.tr(),
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.teal,
      content:
          '${LocaleKeys.approve.tr()} ${LocaleKeys.dr_prefix.tr(namedArgs: {'name': doctor.name})}?',
      actions: [
        AppDialogAction(
          label: LocaleKeys.cancelButton.tr(),
          type: AppButtonType.outlined,
          onPressed: () => Navigator.pop(context),
        ),
        AppDialogAction(
          label: LocaleKeys.approve.tr(),
          onPressed: () {
            Navigator.pop(context);
            ref.read(adminProvider.notifier).approveDoctor(doctor.id, adminId);
          },
        ),
      ],
    );
  }

  void _confirmReject(UserModel doctor, String adminId) {
    AppDialog.show(
      context: context,
      title: LocaleKeys.reject.tr(),
      icon: Icons.cancel_outlined,
      iconColor: AppColors.danger,
      content:
          '${LocaleKeys.reject.tr()} ${LocaleKeys.dr_prefix.tr(namedArgs: {'name': doctor.name})}?',
      actions: [
        AppDialogAction(
          label: LocaleKeys.cancelButton.tr(),
          type: AppButtonType.outlined,
          onPressed: () => Navigator.pop(context),
        ),
        AppDialogAction(
          label: LocaleKeys.reject.tr(),
          type: AppButtonType.danger,
          onPressed: () {
            context.pop();
            ref.read(adminProvider.notifier).rejectDoctor(doctor.id, adminId);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(adminProvider);

    ref.listen(adminProvider, (_, next) {
      final msg = next.value?.errorMessage;
      if (msg != null) GlassySnackbar.showError(context, msg);
    });

    const adminId = ''; // admin self-id not exposed here; provider handles it
    final state = asyncState.value;
    final hasData = state != null;

    bool matchesQuery(UserModel d) =>
        d.name.contains(_query) ||
        (d.specialty ?? '').contains(_query) ||
        d.phone.contains(_query);

    final filteredApproved = !hasData
        ? const <UserModel>[]
        : _query.isEmpty
            ? state.doctors
            : state.doctors.where(matchesQuery).toList();

    final filteredPending = !hasData
        ? const <UserModel>[]
        : _query.isEmpty
            ? state.pendingDoctors
            : state.pendingDoctors.where(matchesQuery).toList();

    final pendingCount = state?.pendingDoctors.length ?? 0;
    final isLoading = state?.isLoading ?? false;

    final tabBar = TabBar(
      controller: _tabController,
      labelColor: AppColors.teal,
      unselectedLabelColor: Colors.grey,
      indicatorColor: AppColors.teal,
      tabs: [
        Tab(text: LocaleKeys.approved_doctors.tr()),
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(LocaleKeys.pending_doctors.tr()),
              if (pendingCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$pendingCount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    Widget bodyForState() {
      // Loading: show spinner inside a scrollable so refresh works
      if (asyncState.isLoading && !hasData) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: CircularProgressIndicator()),
          ],
        );
      }
      // Error: show error inside a scrollable so refresh works
      if (asyncState.hasError && !hasData) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Center(
              child: Text('${LocaleKeys.error_e.tr()}: ${asyncState.error}'),
            ),
          ],
        );
      }
      // Data (or stale data while refreshing): show the tabs
      return TabBarView(
        controller: _tabController,
        children: [
          _TabContent(
            isEmpty: filteredApproved.isEmpty,
            emptyText: LocaleKeys.no_doctors_found.tr(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: filteredApproved.length,
              itemBuilder: (_, i) => _DoctorCard(
                doctor: filteredApproved[i],
                isLoading: isLoading,
                onDelete: () => _confirmDelete(filteredApproved[i]),
                onEdit: () => _showEditSheet(filteredApproved[i]),
              ),
            ),
          ),
          _TabContent(
            isEmpty: filteredPending.isEmpty,
            emptyText: LocaleKeys.no_doctors_found.tr(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: filteredPending.length,
              itemBuilder: (_, i) => _PendingDoctorCard(
                doctor: filteredPending[i],
                isLoading: isLoading,
                onApprove: () =>
                    _confirmApprove(filteredPending[i], adminId),
                onReject: () => _confirmReject(filteredPending[i], adminId),
              ),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminProvider.notifier).refresh(),
      color: AppColors.teal,
      child: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          const SliverToBoxAdapter(child: AdminHeader()),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SearchField(
                controller: _searchController,
                hintText: LocaleKeys.search_doctor_hint.tr(),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(tabBar),
          ),
        ],
        body: bodyForState(),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    required this.isEmpty,
    required this.emptyText,
    required this.child,
  });

  final bool isEmpty;
  final String emptyText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isEmpty) return child;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Text(emptyText,
                style: const TextStyle(color: Colors.grey)),
          ),
        ),
      ],
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}

// ─── Approved doctor card ──────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {

  const _DoctorCard({
    required this.doctor,
    required this.isLoading,
    required this.onDelete,
    required this.onEdit,
  });
  final UserModel doctor;
  final bool isLoading;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            children: [
              _ActionButton(
                icon: Icons.edit_rounded,
                color: AppColors.teal,
                onTap: isLoading ? null : onEdit,
              ),
              const SizedBox(height: 8),
              _ActionButton(
                icon: Icons.delete_rounded,
                color: AppColors.danger,
                onTap: isLoading ? null : onDelete,
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                LocaleKeys.dr_prefix.tr(namedArgs: {'name': doctor.name}),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(doctor.specialty ?? '---',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(doctor.id.isNotEmpty
                      ? doctor.id.substring(0, 6).toUpperCase()
                      : '---'),
                  const SizedBox(width: 6),
                  Text('ID',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(doctor.phone),
                  const SizedBox(width: 6),
                  Icon(Icons.phone_in_talk, size: 16, color: Colors.grey[600]),
                ],
              ),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.cardBackground,
            backgroundImage: doctor.imageUrl != null
                ? NetworkImage(doctor.imageUrl!)
                : null,
            child: doctor.imageUrl == null
                ? const Icon(Icons.person, size: 28, color: Colors.grey)
                : null,
          ),
        ],
      ),
    );
  }
}

// ─── Pending doctor card ───────────────────────────────────────────────────

class _PendingDoctorCard extends StatelessWidget {

  const _PendingDoctorCard({
    required this.doctor,
    required this.isLoading,
    required this.onApprove,
    required this.onReject,
  });
  final UserModel doctor;
  final bool isLoading;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  LocaleKeys.pending_badge.tr(),
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.cardBackground,
                backgroundImage: doctor.imageUrl != null
                    ? NetworkImage(doctor.imageUrl!)
                    : null,
                child: doctor.imageUrl == null
                    ? const Icon(Icons.person, size: 24, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.dr_prefix
                        .tr(namedArgs: {'name': doctor.name}),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    doctor.specialty ?? '---',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    doctor.hospital ?? '---',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            doctor.phone,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton.danger(
                  text: LocaleKeys.reject.tr(),
                  onPressed: isLoading ? null : onReject,
                  height: 40,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  text: LocaleKeys.approve.tr(),
                  onPressed: isLoading ? null : onApprove,
                  height: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey : color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

// ─── Edit sheet ────────────────────────────────────────────────────────────

class _DoctorEditSheet extends StatefulWidget {

  const _DoctorEditSheet({required this.doctor, required this.onSaved});
  final UserModel doctor;
  final void Function(UserModel updated) onSaved;

  @override
  State<_DoctorEditSheet> createState() => _DoctorEditSheetState();
}

class _DoctorEditSheetState extends State<_DoctorEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _specialtyCtrl;
  late final TextEditingController _hospitalCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.doctor.name);
    _phoneCtrl = TextEditingController(text: widget.doctor.phone);
    _specialtyCtrl =
        TextEditingController(text: widget.doctor.specialty ?? '');
    _hospitalCtrl =
        TextEditingController(text: widget.doctor.hospital ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _specialtyCtrl.dispose();
    _hospitalCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.doctor.copyWith(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      specialty: _specialtyCtrl.text.trim(),
      hospital: _hospitalCtrl.text.trim(),
    );
    Navigator.pop(context);
    widget.onSaved(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LocaleKeys.edit_doctor_data.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _EditField(controller: _nameCtrl, label: LocaleKeys.name.tr()),
            const SizedBox(height: 10),
            _EditField(controller: _phoneCtrl, label: LocaleKeys.phone.tr()),
            const SizedBox(height: 10),
            _EditField(
                controller: _specialtyCtrl,
                label: LocaleKeys.specialty.tr()),
            const SizedBox(height: 10),
            _EditField(
                controller: _hospitalCtrl, label: LocaleKeys.hospital.tr()),
            const SizedBox(height: 20),
            AppButton.primary(
              text: LocaleKeys.save.tr(),
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {

  const _EditField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return MyTextField(
      controller: controller,
      hintText: label,
    );
  }
}
