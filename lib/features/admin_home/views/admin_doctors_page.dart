import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/search_field.dart';
import '../../auth/models/user_model.dart';
import '../services/admin_remote_service.dart';
import 'widgets/admin_header.dart';

final _adminDoctorsProvider = FutureProvider<List<UserModel>>((ref) async {
  return AdminRemoteService().getAllDoctors();
});

class AdminDoctorsPage extends ConsumerStatefulWidget {
  const AdminDoctorsPage({super.key});

  @override
  ConsumerState<AdminDoctorsPage> createState() => _AdminDoctorsPageState();
}

class _AdminDoctorsPageState extends ConsumerState<AdminDoctorsPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(UserModel doctor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الطبيب'),
        content: Text('هل تريد حذف د.${doctor.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AdminRemoteService().deleteDoctor(doctor.id);
      ref.invalidate(_adminDoctorsProvider);
    }
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
        onSaved: () => ref.invalidate(_adminDoctorsProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncDoctors = ref.watch(_adminDoctorsProvider);

    return Scaffold(
      body: asyncDoctors.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('حدث خطأ: $e')),
        data: (doctors) {
          final filtered = _query.isEmpty
              ? doctors
              : doctors
                  .where((d) =>
                      d.name.contains(_query) ||
                      (d.specialty ?? '').contains(_query) ||
                      d.phone.contains(_query))
                  .toList();

          return RefreshIndicator(
            onRefresh: () => ref.refresh(_adminDoctorsProvider.future),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const AdminHeader(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: SearchField(
                          controller: _searchController,
                          hintText: 'ابحث عن طبيب',
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _DoctorCard(
                        doctor: filtered[index],
                        onDelete: () => _confirmDelete(filtered[index]),
                        onEdit: () => _showEditSheet(filtered[index]),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final UserModel doctor;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _DoctorCard({
    required this.doctor,
    required this.onDelete,
    required this.onEdit,
  });

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
                onTap: onEdit,
              ),
              const SizedBox(height: 8),
              _ActionButton(
                icon: Icons.delete_rounded,
                color: AppColors.danger,
                onTap: onDelete,
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'د.${doctor.name}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'تخصص ${doctor.specialty ?? '---'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(doctor.id.isNotEmpty
                      ? doctor.id.substring(0, 6).toUpperCase()
                      : '---'),
                  const SizedBox(width: 6),
                  Text(
                    'ID',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

class _DoctorEditSheet extends StatefulWidget {
  final UserModel doctor;
  final VoidCallback onSaved;

  const _DoctorEditSheet({required this.doctor, required this.onSaved});

  @override
  State<_DoctorEditSheet> createState() => _DoctorEditSheetState();
}

class _DoctorEditSheetState extends State<_DoctorEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _specialtyCtrl;
  late final TextEditingController _hospitalCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.doctor.name);
    _phoneCtrl = TextEditingController(text: widget.doctor.phone);
    _specialtyCtrl = TextEditingController(text: widget.doctor.specialty ?? '');
    _hospitalCtrl = TextEditingController(text: widget.doctor.hospital ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _specialtyCtrl.dispose();
    _hospitalCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final updated = widget.doctor.copyWith(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      specialty: _specialtyCtrl.text.trim(),
      hospital: _hospitalCtrl.text.trim(),
    );
    await AdminRemoteService().updateDoctor(updated);
    if (mounted) {
      Navigator.pop(context);
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تعديل بيانات الطبيب',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _EditField(controller: _nameCtrl, label: 'الاسم'),
          const SizedBox(height: 10),
          _EditField(controller: _phoneCtrl, label: 'الهاتف'),
          const SizedBox(height: 10),
          _EditField(controller: _specialtyCtrl, label: 'التخصص'),
          const SizedBox(height: 10),
          _EditField(controller: _hospitalCtrl, label: 'المستشفى'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _EditField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.card(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
