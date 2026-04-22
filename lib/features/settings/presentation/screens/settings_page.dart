import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extension/font_size.dart';
import '../../../../core/extension/language.dart';
import '../../../../core/extension/theme_mode.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_app_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(settingsProvider);

    return Scaffold(
      appBar: SectionAppBar(title: 'settings'.tr()),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('error_e'.tr())),
        data: (state) => Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // --- Appearance Section ---
                _SectionHeader(title: 'appearance'.tr()),
                const SizedBox(height: 12),

                // Theme Mode Expandable
                _ExpandableSettingsTile<Thememode>(
                  icon: Icons.brightness_6_outlined,
                  title: 'theme_mode'.tr(),
                  currentValue: state.mode,
                  items: Thememode.values,
                  labelBuilder: (item) => item.displayName,
                  onSelected: (item) =>
                      ref.read(settingsProvider.notifier).changeThemeMode(item),
                ),
                const SizedBox(height: 12),

                // Font Size Expandable
                _ExpandableSettingsTile<FontSizes>(
                  icon: Icons.text_fields_rounded,
                  title: 'font_size'.tr(),
                  currentValue: state.fontSize,
                  items: FontSizes.values,
                  labelBuilder: (item) => item.displayName,
                  onSelected: (item) =>
                      ref.read(settingsProvider.notifier).changeFontSize(item),
                ),

                const SizedBox(height: 24),

                // --- Localization Section ---
                _SectionHeader(title: 'localization'.tr()),
                const SizedBox(height: 12),

                // Language Expandable
                _ExpandableSettingsTile<Language>(
                  icon: Icons.language_rounded,
                  title: 'app_language'.tr(),
                  currentValue: state.language,
                  items: Language.values,
                  labelBuilder: (item) => Language.getLanguageName(item),
                  onSelected: (item) {
                    ref.read(settingsProvider.notifier).changeLanguage(item);
                    context.setLocale(Language.getLanguageLocale(item));
                  },
                ),

                const SizedBox(height: 24),

                // --- System Section ---
                _SectionHeader(title: 'system'.tr()),
                const SizedBox(height: 12),

                // Notifications Switch
                _SettingsSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'push_notifications'.tr(),
                  value: state.notifications,
                  onChanged: (val) => ref
                      .read(settingsProvider.notifier)
                      .changeNotifications(enabled: val),
                ),

                const SizedBox(height: 40),

                // Logout Button
                _LogoutButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/role-selection');
                  },
                ),
              ],
            ),

            // Global loading indicator for settings changes
            if (state.isLoading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  color: AppColors.teal,
                  minHeight: 3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Expandable Logic Widget ---

class _ExpandableSettingsTile<T> extends StatelessWidget {
  const _ExpandableSettingsTile({
    required this.icon,
    required this.title,
    required this.currentValue,
    required this.items,
    required this.labelBuilder,
    required this.onSelected,
  });
  final IconData icon;
  final String title;
  final T currentValue;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.teal, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            labelBuilder(currentValue),
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          trailing: const Icon(Icons.expand_more_rounded, size: 22),
          childrenPadding: const EdgeInsets.only(
            bottom: 12,
            left: 16,
            right: 16,
          ),
          children: items.map((item) {
            final isSelected = item == currentValue;
            return ListTile(
              onTap: () => onSelected(item),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: isSelected
                  ? AppColors.teal.withValues(alpha: 0.08)
                  : null,
              title: Text(
                labelBuilder(item),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.teal : null,
                ),
              ),
              trailing: isSelected
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.teal,
                      size: 20,
                    )
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// --- Simple Switch Tile ---

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.teal, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        trailing: Switch.adaptive(value: value, onChanged: onChanged),
      ),
    );
  }
}

// --- Helper Components ---

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
        letterSpacing: 1.2,
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton.danger(
      text: 'sign_out'.tr(),
      onPressed: onPressed,
      icon: Icons.logout_rounded,
      borderRadius: 16,
    );
  }
}
