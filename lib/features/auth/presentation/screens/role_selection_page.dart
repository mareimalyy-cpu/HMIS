import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../generated/locale_keys.g.dart';
import '../../data/models/user_model.dart';
import 'login_page.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});
  static const routeName = '/role-selection';

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _cardsCtrl;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _cardsFade;
  late final Animation<Offset> _cardsSlide;

  String _typedText = '';
  Timer? _typeTimer;
  bool _typewriterStarted = false;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _logoScale = Tween<double>(
      begin: 0.72,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _cardsFade = CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeOut);
    _cardsSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeOutCubic));

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 450), _cardsCtrl.forward);
  }

  void _startTypewriter(String text) {
    _typeTimer?.cancel();
    int i = 0;
    _typeTimer = Timer.periodic(const Duration(milliseconds: 55), (t) {
      if (i < text.length) {
        if (mounted) setState(() => _typedText = text.substring(0, ++i));
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _cardsCtrl.dispose();
    _typeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final welcomeText = LocaleKeys.welcome_tonhmis.tr();

    if (!_typewriterStarted) {
      _typewriterStarted = true;
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) _startTypewriter(welcomeText);
      });
    }

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.png.roleBk.path),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withValues(alpha: 0.12),
            BlendMode.modulate,
          ),
        )
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Logo + typewriter welcome ──────────────────────────
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Hero(
                            tag: 'app_logo',
                            child: Assets.images.png.appLogo.image(
                              height: size.height * 0.14,
                            ),
                          ),
                          const SizedBox(height: 28),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: _typedText,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.teal,
                                    height: 1.4,
                                  ),
                              children: [
                                if (_typedText.length < welcomeText.length)
                                  TextSpan(
                                    text: '|',
                                    style: TextStyle(
                                      color: AppColors.teal.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Role cards ─────────────────────────────────────────
              FadeTransition(
                opacity: _cardsFade,
                child: SlideTransition(
                  position: _cardsSlide,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      MediaQuery.paddingOf(context).bottom + 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          LocaleKeys.choose_your_role.tr(),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          LocaleKeys.login_to_continue.tr(),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _RoleCard(
                                icon: Icons.medical_services_rounded,
                                label: LocaleKeys.i_am_a_doctor.tr(),
                                description: LocaleKeys.doctor_role_desc.tr(),
                                color: AppColors.teal,
                                image: Assets.images.png.doc,
                                onTap: () => context.push(
                                  LoginPage.routeName,
                                  extra: UserRole.doctor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _RoleCard(
                                icon: Icons.person_rounded,
                                label: LocaleKeys.i_am_a_patient.tr(),
                                description: LocaleKeys.patient_role_desc.tr(),
                                color: const Color(0xFF4ABCCA),
                                onTap: () => context.push(
                                  LoginPage.routeName,
                                  extra: UserRole.patient,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Role card ─────────────────────────────────────────────────────────────────

class _RoleCard extends StatefulWidget {
  const _RoleCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
    this.image,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final AssetGenImage? image;
  final VoidCallback onTap;

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> with TickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final AnimationController _glowCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
    _glow = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedBuilder(
          animation: _glow,
          builder: (context, child) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.color.withValues(
                  alpha: 0.20 + 0.20 * _glow.value,
                ),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(
                    alpha: 0.06 + 0.14 * _glow.value,
                  ),
                  blurRadius: 14 + 10 * _glow.value,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          ),
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: widget.image != null
                    ? widget.image!.image(fit: BoxFit.cover)
                    : Icon(widget.icon, size: 34, color: widget.color),
              ),
              const SizedBox(height: 14),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                widget.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
