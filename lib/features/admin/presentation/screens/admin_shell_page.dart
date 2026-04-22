import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../billing/presentation/screens/bills_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_doctors_page.dart';
import 'admin_patients_page.dart';

class AdminShellPage extends StatelessWidget {

  const AdminShellPage({super.key});
  static const routeName = '/admin-home';

  static final _currentIndex = ValueNotifier<int>(0);

  static const _pages = [
    AdminDashboardPage(),
    AdminPatientsPage(),
    AdminDoctorsPage(),
    BillsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final labels = [
      LocaleKeys.dashboard.tr(),
      LocaleKeys.manage_patients.tr(),
      LocaleKeys.manage_doctors.tr(),
      LocaleKeys.manage_bills.tr(),
    ];
    const icons = [
      Icons.bar_chart_rounded,
      Icons.people_alt_rounded,
      Icons.medical_services_rounded,
      Icons.receipt_long_rounded,
    ];

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
              bottom: MediaQuery.of(context).padding.bottom + 12,
              top: 12,
              left: 16,
              right: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(labels.length, (index) {
                final isSelected = currentIndex == index;
                return GestureDetector(
                  onTap: () => _currentIndex.value = index,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 14 : 10,
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
                            labels[index],
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Icon(
                          icons[index],
                          size: 22,
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
