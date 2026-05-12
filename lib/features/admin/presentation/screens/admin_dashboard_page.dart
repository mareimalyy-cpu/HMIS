import 'dart:developer' as dev;
import 'dart:math';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extension/theme_extenison.dart';
import '../../../../core/services/helper.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../booking/data/models/appointment_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_header.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage>
    with TickerProviderStateMixin {
  late final AnimationController _statsCtrl;
  late final AnimationController _chartCtrl;
  late final List<Animation<double>> _statAnims;

  @override
  void initState() {
    super.initState();
    _statsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _chartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _statAnims = List.generate(3, (i) {
      final start = i * 0.2;
      final end = (start + 0.6).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _statsCtrl,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
    });

    _statsCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _chartCtrl.forward();
    });
  }

  @override
  void dispose() {
    _statsCtrl.dispose();
    _chartCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(adminProvider);

    ref.listen(adminProvider, (_, next) {
      final msg = next.value?.errorMessage;
      if (msg != null) GlassySnackbar.showError(context, msg);
    });

    final state = asyncState.value;
    final hasData = state != null;

    if (asyncState.hasError && !hasData) {
      dev.log(
        '🛑 AdminDashboardPage error: ${asyncState.error}',
        error: asyncState.error,
        stackTrace: asyncState.stackTrace,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminProvider.notifier).refresh(),
      color: AppColors.teal,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: AdminHeader()),
          if (asyncState.isLoading && !hasData)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (asyncState.hasError && !hasData)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  '${LocaleKeys.error_e.tr()}: ${asyncState.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            )
          else if (hasData) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _AnimatedStatCard(
                        animation: _statAnims[0],
                        label: LocaleKeys.doctors_count.tr(),
                        count: state.doctorCount,
                        icon: Icons.medical_services_rounded,
                        gradientColors: const [
                          Color(0xFF2096A4),
                          Color(0xFF1B8A9E),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AnimatedStatCard(
                        animation: _statAnims[1],
                        label: LocaleKeys.patients_count.tr(),
                        count: state.patientCount,
                        icon: Icons.people_alt_rounded,
                        gradientColors: const [
                          Color(0xFF4ABCCA),
                          Color(0xFF2096A4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AnimatedStatCard(
                        animation: _statAnims[2],
                        label: LocaleKeys.appointments_stat.tr(),
                        count: state.appointmentCount,
                        icon: Icons.calendar_today_rounded,
                        gradientColors: const [
                          Color(0xFF7BCFCF),
                          Color(0xFF4ABCCA),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: FadeTransition(
                  opacity: _chartCtrl,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _chartCtrl,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: _AppointmentsChart(appointments: state.appointments),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    Text(
                      LocaleKeys.all_appointments_title.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${state.appointments.length}',
                        style: const TextStyle(
                          color: AppColors.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.appointments.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 32,
                  ),
                  child: Center(
                    child: Text(
                      LocaleKeys.no_appointments_yet.tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: state.appointments.length,
                  itemBuilder: (context, i) {
                    final appt = state.appointments[i];
                    return _AnimatedAppointmentCard(
                      index: i,
                      appt: appt,
                      isGlobalLoading: state.isLoading,
                      onDelete: () => ref
                          .read(adminProvider.notifier)
                          .deleteAppointment(appt.id),
                    );
                  },
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ],
      ),
    );
  }
}

// ─── Animated Stat Card ───────────────────────────────────────────────────────

class _AnimatedStatCard extends AnimatedWidget {
  const _AnimatedStatCard({
    required Animation<double> animation,
    required this.label,
    required this.count,
    required this.icon,
    required this.gradientColors,
  }) : super(listenable: animation);

  final String label;
  final int count;
  final IconData icon;
  final List<Color> gradientColors;

  Animation<double> get _anim => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final v = _anim.value.clamp(0.0, 1.0);
    return Transform.scale(
      scale: _anim.value,
      child: Opacity(
        opacity: v,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withValues(alpha: 0.40),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Chart ────────────────────────────────────────────────────────────────────

class _AppointmentsChart extends StatelessWidget {
  const _AppointmentsChart({required this.appointments});
  final List<AppointmentModel> appointments;

  Map<String, int> _getWeekdayCounts() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final counts = {for (var d in days) d: 0};
    for (final appt in appointments) {
      try {
        final parts = appt.date.split('-');
        if (parts.length == 3) {
          final dt = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          final key = days[dt.weekday - 1];
          counts[key] = (counts[key] ?? 0) + 1;
        }
      } catch (_) {}
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final counts = _getWeekdayCounts();
    final maxVal = counts.values
        .fold(0, max)
        .clamp(1, double.maxFinite)
        .toInt();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                LocaleKeys.appointments_stat.tr(),
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _ChartPainter(
                counts: counts,
                maxVal: maxVal,
                isDark: isDark,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.counts,
    required this.maxVal,
    required this.isDark,
  });
  final Map<String, int> counts;
  final int maxVal;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final keys = counts.keys.toList();
    final barWidth = size.width / keys.length;
    final chartH = size.height - 24;

    // Horizontal grid lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.07)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = chartH * (1 - i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final List<Offset> points = [];

    for (var i = 0; i < keys.length; i++) {
      final val = counts[keys[i]] ?? 0;
      final x = barWidth * i + barWidth / 2;
      final barH = maxVal == 0 ? 0.0 : (val / maxVal) * chartH;
      final top = chartH - barH;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - barWidth * 0.3, top, barWidth * 0.6, barH),
          const Radius.circular(5),
        ),
        Paint()
          ..shader =
              LinearGradient(
                colors: [
                  AppColors.teal.withValues(alpha: 0.30),
                  AppColors.teal.withValues(alpha: 0.06),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(
                Rect.fromLTWH(x - barWidth * 0.3, top, barWidth * 0.6, barH),
              )
          ..style = PaintingStyle.fill,
      );

      points.add(Offset(x, top));

      final tp = TextPainter(
        text: TextSpan(
          text: keys[i],
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartH + 8));
    }

    if (points.length > 1) {
      // Smooth cubic bezier line
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (var i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final cpX = (p0.dx + p1.dx) / 2;
        path.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
      }

      // Gradient fill under curve
      final fillPath = Path.from(path)
        ..lineTo(points.last.dx, chartH)
        ..lineTo(points.first.dx, chartH)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            colors: [
              AppColors.teal.withValues(alpha: 0.22),
              AppColors.teal.withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, size.width, chartH))
          ..style = PaintingStyle.fill,
      );

      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.teal
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Dots — white ring + teal fill
    for (final p in points) {
      canvas.drawCircle(p, 5.5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 3.5, Paint()..color = AppColors.teal);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.counts != counts || old.maxVal != maxVal || old.isDark != isDark;
}

// ─── Animated Appointment Card ────────────────────────────────────────────────

class _AnimatedAppointmentCard extends StatefulWidget {
  const _AnimatedAppointmentCard({
    required this.index,
    required this.appt,
    required this.isGlobalLoading,
    required this.onDelete,
  });

  final int index;
  final AppointmentModel appt;
  final bool isGlobalLoading;
  final VoidCallback onDelete;

  @override
  State<_AnimatedAppointmentCard> createState() =>
      _AnimatedAppointmentCardState();
}

class _AnimatedAppointmentCardState extends State<_AnimatedAppointmentCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    final delay = Duration(milliseconds: 70 * min(widget.index, 8));
    Future.delayed(delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _AppointmentCard(
          appt: widget.appt,
          isGlobalLoading: widget.isGlobalLoading,
          onDelete: widget.onDelete,
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appt,
    required this.isGlobalLoading,
    required this.onDelete,
  });
  final AppointmentModel appt;
  final bool isGlobalLoading;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.teal.withValues(alpha: 0.15),
            child: Text(
              appt.patientName.isNotEmpty
                  ? appt.patientName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appt.patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _InfoChip(
                      icon: Icons.person_outline,
                      label: appt.doctorName,
                    ),
                    _InfoChip(
                      icon: Icons.event_outlined,
                      label: '${appt.date}  ${appt.time}',
                    ),
                    if (appt.address != null && appt.address!.isNotEmpty)
                      _InfoChip(
                        icon: Icons.place_outlined,
                        label: appt.address!,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          isGlobalLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.danger,
                  ),
                )
              : IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.danger,
                  iconSize: 22,
                  tooltip: LocaleKeys.delete_booking.tr(),
                ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.teal),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
