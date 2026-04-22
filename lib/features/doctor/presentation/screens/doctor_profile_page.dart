import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_app_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/screens/edit_profile_page.dart';
import 'time_slots_page.dart';

class DoctorProfilePage extends ConsumerWidget {
  const DoctorProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: SectionAppBar(
        title: LocaleKeys.doctor_profile.tr(),
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(
              Icons.settings_rounded,
              color: isDark ? Colors.white70 : AppColors.white,
            ),
          ),
        ],
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(LocaleKeys.error_e.tr())),
        data: (state) {
          final user = state.currentUser;
          if (user == null) {
            return Center(child: Text(LocaleKeys.not_logged_in.tr()));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Hero header ────────────────────────────────────────────
                _ProfileHeader(user: user, isDark: isDark),

                const SizedBox(height: 20),

                // ── Edit profile button ────────────────────────────────────
                AppButton.outlined(
                  text: LocaleKeys.edit_profile.tr(),
                  icon: Icons.edit_rounded,
                  height: 46,
                  onPressed: () => context.push(EditProfilePage.routeName),
                ),

                const SizedBox(height: 24),

                // ── Bio ────────────────────────────────────────────────────
                _SectionLabel(LocaleKeys.about.tr()),
                const SizedBox(height: 8),
                _InfoCard(
                  child: Text(
                    user.bio?.isNotEmpty == true
                        ? user.bio!
                        : LocaleKeys.no_bio_available.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          height: 1.6,
                        ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Work schedule info ─────────────────────────────────────
                _SectionLabel(LocaleKeys.work_schedule.tr()),
                const SizedBox(height: 8),
                _InfoCard(
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        text: user.workDays?.join(', ') ??
                            LocaleKeys.not_specified.tr(),
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.access_time_rounded,
                        text:
                            '${user.workHoursStart ?? '--'} – ${user.workHoursEnd ?? '--'}',
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.location_on_rounded,
                        text: user.hospitalAddress?.isNotEmpty == true
                            ? user.hospitalAddress!
                            : LocaleKeys.not_specified.tr(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Manage time slots ──────────────────────────────────────
                AppButton.ghost(
                  text: LocaleKeys.time_slots.tr(),
                  icon: Icons.more_time_rounded,
                  height: 46,
                  onPressed: () => context.push(TimeSlotsPage.routeName),
                ),

                const SizedBox(height: 20),

                // ── Contact info ───────────────────────────────────────────
                _SectionLabel(LocaleKeys.contact_info.tr()),
                const SizedBox(height: 8),
                _InfoCard(
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.mail_rounded,
                        text: user.email,
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.phone_rounded,
                        text: user.phone,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Profile header ──────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {

  const _ProfileHeader({required this.user, required this.isDark});
  final dynamic user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.tealDark, AppColors.teal.withValues(alpha: 0.6)]
              : [AppColors.teal, AppColors.tealDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.dr_username.tr(namedArgs: {'name': user.name}),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (user.specialty?.isNotEmpty == true)
                  Text(
                    user.specialty!,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${user.rating?.toStringAsFixed(1) ?? '0.0'}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    if (user.hospital?.isNotEmpty == true) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.local_hospital_rounded,
                          color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          user.hospital!,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage: (user.imageUrl != null &&
                    user.imageUrl!.isNotEmpty)
                ? NetworkImage(user.imageUrl!) as ImageProvider
                : null,
            child: (user.imageUrl == null || user.imageUrl!.isEmpty)
                ? const Icon(Icons.person_rounded,
                    size: 44, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.accent(context),
          ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.teal),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
