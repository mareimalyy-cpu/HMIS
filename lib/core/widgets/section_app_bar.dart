import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class SectionAppBar extends StatelessWidget implements PreferredSizeWidget {

  const SectionAppBar({
    required this.title, super.key,
    this.showBackButton = true,
    this.actions,
  });
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.teal,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.chevron_left,
                color: AppColors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
