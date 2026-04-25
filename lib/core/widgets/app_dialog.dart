import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import 'app_button.dart';

class AppDialogAction {
  const AppDialogAction({
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
  });

  final String label;
  final AppButtonType type;
  final VoidCallback? onPressed;
}

class AppDialog extends StatelessWidget {
  const AppDialog({
    required this.title,

    super.key,
    this.icon,
    this.iconColor,
    this.content,
    this.contentWidget,
    this.actions = const [],
  }) : assert(
         content != null || contentWidget != null,
         'Provide either content or contentWidget',
       );

  final String title;
  final IconData? icon;
  final Color? iconColor;
  final String? content;
  final Widget? contentWidget;
  final List<AppDialogAction> actions;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    IconData? icon,
    Color? iconColor,
    String? content,
    Widget? contentWidget,
    List<AppDialogAction> actions = const [],
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => AppDialog(
        title: title,
        icon: icon,
        iconColor: iconColor,
        content: content,
        contentWidget: contentWidget,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedIconColor = iconColor ?? AppColors.teal;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surface(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──────────────────────────────────────────────────────
            if (icon != null) ...[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: resolvedIconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: resolvedIconColor, size: 28),
              ),
              const SizedBox(height: 16),
            ],

            // ── Title ─────────────────────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // ── Content ───────────────────────────────────────────────────
            if (content != null)
              Text(
                content!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ?contentWidget,

            if (actions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  for (int i = 0; i < actions.length; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                        child: AppButton(
                          text: actions[i].label,
                          onPressed: actions[i].onPressed,
                          type: actions[i].type,
                          height: 44,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
