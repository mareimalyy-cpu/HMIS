import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/services/helper.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../generated/locale_keys.g.dart';
import '../../data/models/user_model.dart';
import '../providers/auth_provider.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({
    required this.email,
    required this.password,
    super.key,
  });

  static const routeName = '/verify-email';

  final String email;
  final String password;

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState
    extends ConsumerState<EmailVerificationPage> {
  final _resentEmail = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _resentEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.value?.isLoading ?? false;

    ref.listen(authProvider, (_, next) {
      final state = next.value;
      if (state == null) return;

      if (state.errorMessage != null) {
        GlassySnackbar.showError(context, state.errorMessage!);
      }

      if (state.isAuthenticated && state.currentUser != null) {
        final role = state.currentUser!.role;
        switch (role) {
          case UserRole.doctor:
            context.go('/doctor-home');
          case UserRole.admin:
            context.go('/admin-home');
          case UserRole.receptionist:
            context.go('/receptionist-home');
          case UserRole.patient:
            context.go('/patient-home');
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.email_verification_title.tr()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_unread_outlined,
                size: 48,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              LocaleKeys.check_your_email.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              LocaleKeys.email_verification_body
                  .tr(namedArgs: {'email': widget.email}),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            AppButton.primary(
              text: LocaleKeys.i_verified.tr(),
              isLoading: isLoading,
              onPressed: isLoading
                  ? null
                  : () => ref
                        .read(authProvider.notifier)
                        .checkEmailVerified(
                          email: widget.email,
                          password: widget.password,
                        ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: _resentEmail,
              builder: (_, resent, _) => AppButton.outlined(
                text: resent
                    ? '${LocaleKeys.email_resent.tr()} ✓'
                    : LocaleKeys.resend_email.tr(),
                onPressed: resent
                    ? null
                    : () async {
                        await ref
                            .read(authProvider.notifier)
                            .sendEmailVerification();
                        _resentEmail.value = true;
                        if (context.mounted) {
                          GlassySnackbar.showSuccess(
                            context,
                            LocaleKeys.email_resent.tr(),
                          );
                        }
                      },
              ),
            ),
            const SizedBox(height: 24),
            AppButton.text(
              text: LocaleKeys.back_to_login.tr(),
              onPressed: () => context.pop(),
              textColor: Colors.grey,
              height: 36,
            ),
          ],
        ),
      ),
    );
  }
}
