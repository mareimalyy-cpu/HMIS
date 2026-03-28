import 'package:flutter/material.dart';
import 'package:hmis/core/widgets/my_text_filed.dart';

class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool autofocus;
  final FocusNode? focusNode;

  const SearchField({
    super.key,
    this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return MyTextField(
      controller: controller,
      hintText: hintText,
      prefixIcon: Icons.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      autofocus: autofocus,
      focusNode: focusNode,
      showClearButton: true,
      textAlign: TextAlign.right,
      textInputAction: TextInputAction.search,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
