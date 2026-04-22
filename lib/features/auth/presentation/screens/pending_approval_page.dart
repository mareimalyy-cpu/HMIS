import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

class PendingApprovalPage extends ConsumerWidget {

  const PendingApprovalPage({super.key});
  static const routeName = '/pending-approval';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.value?.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 60,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                LocaleKeys.pending_approval.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              if (user != null)
                Text(
                  LocaleKeys.dr_prefix.tr(namedArgs: {'name': user.name}),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              const SizedBox(height: 12),
              Text(
                LocaleKeys.approval_pending_message.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      height: 1.6,
                    ),
              ),
              const SizedBox(height: 48),
              const _InfoCard(
                icon: Icons.check_circle_outline,
                color: AppColors.success,
                text: 'Your documents are under review by our medical team.',
              ),
              const SizedBox(height: 12),
              const _InfoCard(
                icon: Icons.notifications_outlined,
                color: AppColors.teal,
                text: 'You will receive a notification once your account is approved.',
              ),
              const SizedBox(height: 48),
              AppButton.outlined(
                text: LocaleKeys.sign_out.tr(),
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go(LoginPage.routeName);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {

  const _InfoCard({
    required this.icon,
    required this.color,
    required this.text,
  });
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
