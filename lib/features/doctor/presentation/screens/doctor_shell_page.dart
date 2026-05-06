import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/pending_approval_page.dart';
import 'doctor_profile_page.dart';
import 'doctor_records_page.dart';
import 'doctor_home_page.dart';

class DoctorShellPage extends ConsumerStatefulWidget {
  const DoctorShellPage({super.key});
  static const routeName = '/doctor-home';

  @override
  ConsumerState<DoctorShellPage> createState() => _DoctorShellPageState();
}

class _DoctorShellPageState extends ConsumerState<DoctorShellPage> {
  int _currentIndex = 0;

  static const _pages = [
    DoctorHomePage(),
    DoctorRecordsPage(),
    DoctorProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Re-check doctor approval from Firestore every time the shell mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).verifyDoctorApproval();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Guard: redirect if approval is revoked while doctor is in-app
    ref.listen(authProvider, (_, next) {
      final state = next.value;
      if (state == null) return;
      if (state.isPendingApproval ||
          (!state.isAuthenticated && state.currentUser != null)) {
        context.go(PendingApprovalPage.routeName);
      }
    });

    final navItems = [
      const _NavItem(icon: Icons.home_filled, label: ''),
      _NavItem(icon: Icons.calendar_month, label: LocaleKeys.records.tr()),
      _NavItem(icon: Icons.person, label: LocaleKeys.my_account.tr()),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 20,
          top: 12,
          left: 16,
          right: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            final item = navItems[index];
            final isSelected = _currentIndex == index;

            return GestureDetector(
              onTap: () => setState(() => _currentIndex = index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Text(
                        item.label,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Icon(
                      item.icon,
                      size: 24,
                      color: isSelected
                          ? AppColors.white
                          : (isDark ? Colors.grey[400] : Colors.black87),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
