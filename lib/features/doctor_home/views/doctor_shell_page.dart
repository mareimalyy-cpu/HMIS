import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hmis/generated/locale_keys.g.dart';

import '../../../core/themes/app_colors.dart';
import '../../doctor_profile/views/doctor_profile_page.dart';
import '../../doctor_records/views/doctor_records_page.dart';
import 'doctor_home_page.dart';

class DoctorShellPage extends StatelessWidget {
  static const routeName = '/doctor-home';

  const DoctorShellPage({super.key});

  static final _currentIndex = ValueNotifier<int>(0);

  static const _pages = [
    DoctorHomePage(),
    DoctorRecordsPage(),
    DoctorProfilePage(),
  ];

  static final _navItems = [
    _NavItem(icon: Icons.home_filled, labelKey: LocaleKeys.home.tr()),
    _NavItem(icon: Icons.calendar_month, labelKey: LocaleKeys.records.tr()),
    _NavItem(icon: Icons.person, labelKey: LocaleKeys.my_account.tr()),
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
