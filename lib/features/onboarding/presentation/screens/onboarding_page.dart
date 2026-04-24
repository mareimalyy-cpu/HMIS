import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/enum/constants.dart';
import '../../../../core/local_services/local_storage.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../gen/assets.gen.dart';
import '../../../auth/presentation/screens/role_selection_page.dart';

class OnboardingPage extends StatefulWidget {

  const OnboardingPage({super.key});
  static const routeName = '/onboarding';

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  late final ValueNotifier<int> _currentPage = ValueNotifier(0);

  static final _pages = [
    _OnboardingData(
      svg: Assets.images.svg.on1,
      title: LocaleKeys.safe_confidential.tr(),
      description: LocaleKeys
          .rest_assured_your_privacy_and_security_are_our_top_priorities
          .tr(),
    ),
    _OnboardingData(
      svg: Assets.images.svg.on2,
      title: LocaleKeys.easy_booking.tr(),
      description: LocaleKeys.book_appointments_easily_anytime_anywhere.tr(),
    ),
    _OnboardingData(
      svg: Assets.images.svg.on3,
      title: LocaleKeys.find_a_specialist.tr(),
      description: LocaleKeys
          .discover_a_wide_range_of_expert_doctors_across_various_medical_fields
          .tr(),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    LocalStorage.instance.add(Constants.hideOnboarding.name, true);
    context.go(RoleSelectionPage.routeName);
  }

  void _next() {
    if (_currentPage.value < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder<int>(
              valueListenable: _currentPage,
              builder: (context, page, _) => Visibility(
                visible: page < _pages.length - 1,
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AppButton.text(
                      text: LocaleKeys.skip.tr(),
                      onPressed: _completeOnboarding,
                      height: 36,
                      width: 70,
                      textColor: AppColors.teal,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => _currentPage.value = index,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        SvgPicture.asset(page.svg, height: 300),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: ValueListenableBuilder<int>(
                valueListenable: _currentPage,
                builder: (context, page, _) => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: page == index ? 12 : 8,
                          height: page == index ? 12 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: page == index
                                ? AppColors.teal
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: page == _pages.length - 1
                          ? LocaleKeys.register_now.tr()
                          : LocaleKeys.next.tr(),
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {

  const _OnboardingData({
    required this.svg,
    required this.title,
    required this.description,
  });
  final String svg;
  final String title;
  final String description;
}
