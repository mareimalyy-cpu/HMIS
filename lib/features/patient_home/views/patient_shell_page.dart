import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../../patient_profile/views/patient_profile_page.dart';
import '../../patient_appointments/views/patient_appointments_page.dart';
import '../../search/views/search_page.dart';
import 'patient_home_page.dart';

class PatientShellPage extends StatelessWidget {
  static const routeName = '/patient-home';

  const PatientShellPage({super.key});

  static final _currentIndex = ValueNotifier<int>(0);

  static const _pages = [
    PatientHomePage(),
    SearchPage(),
    PatientAppointmentsPage(),
    PatientProfilePage(),
  ];

  static const _navItems = [
    _NavItem(icon: Icons.home_filled, labelKey: 'home'),
    _NavItem(icon: Icons.search, labelKey: 'search'),
    _NavItem(icon: Icons.calendar_month, labelKey: 'appointments'),
    _NavItem(icon: Icons.person, labelKey: 'my_account'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<int>(
      valueListenable: _currentIndex,
      builder: (context, currentIndex, _) {
        return Scaffold(
          body: IndexedStack(index: currentIndex, children: _pages),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Theme.of(context).colorScheme.surface
                  : Colors.white,
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
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = currentIndex == index;

                return GestureDetector(
                  onTap: () => _currentIndex.value = index,
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
                            item.labelKey.tr(),
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
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final String labelKey;

  const _NavItem({required this.icon, required this.labelKey});
}
