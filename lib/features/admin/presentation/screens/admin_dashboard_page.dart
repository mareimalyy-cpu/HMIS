import 'dart:math';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/helper.dart';
import '../../../../generated/locale_keys.g.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../booking/data/models/appointment_model.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_header.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override

  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(adminProvider);

    ref.listen(adminProvider, (_, next) {
      final msg = next.value?.errorMessage;
      if (msg != null) GlassySnackbar.showError(context, msg);
    });

    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('${LocaleKeys.error_e.tr()}: $e')),
      data: (state) => RefreshIndicator(
        onRefresh: () => ref.read(adminProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: AdminHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: LocaleKeys.doctors_count.tr(),
                        count: state.doctorCount,
                        icon: Icons.medical_services_rounded,
                        color: const Color(0xFF5BC8C8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        label: LocaleKeys.patients_count.tr(),
                        count: state.patientCount,
                        icon: Icons.people_alt_rounded,
                        color: const Color(0xFF4ABCCA),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        label: LocaleKeys.appointments_stat.tr(),
                        count: state.appointmentCount,
                        icon: Icons.calendar_today_rounded,
                        color: const Color(0xFF7BCFCF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _AppointmentsChart(appointments: state.appointments),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  LocaleKeys.all_appointments_title.tr(),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _AppointmentsTable(
                appointments: state.appointments,
                isLoading: state.isLoading,
                onDelete: (appt) =>
                    ref.read(adminProvider.notifier).deleteAppointment(appt.id),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {

  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

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
    final maxVal =
        counts.values.fold(0, max).clamp(1, double.maxFinite).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.teal,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(LocaleKeys.appointments_stat.tr(),
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              Text(
                LocaleKeys.appointments_stat.tr(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _ChartPainter(counts: counts, maxVal: maxVal),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {

  _ChartPainter({required this.counts, required this.maxVal});
  final Map<String, int> counts;
  final int maxVal;

  @override
  void paint(Canvas canvas, Size size) {
    final keys = counts.keys.toList();
    final barWidth = size.width / keys.length;
    final chartH = size.height - 24;

    final barPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.teal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.fill;

    final List<Offset> points = [];

    for (var i = 0; i < keys.length; i++) {
      final val = counts[keys[i]] ?? 0;
      final x = barWidth * i + barWidth / 2;
      final barH = maxVal == 0 ? 0.0 : (val / maxVal) * chartH;
      final top = chartH - barH;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - barWidth * 0.3, top, barWidth * 0.6, barH),
          const Radius.circular(4),
        ),
        barPaint,
      );

      points.add(Offset(x, top));

      final tp = TextPainter(
        text: TextSpan(
          text: keys[i],
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartH + 6));
    }

    if (points.length > 1) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AppointmentsTable extends StatelessWidget {

  const _AppointmentsTable({
    required this.appointments,
    required this.isLoading,
    required this.onDelete,
  });
  final List<AppointmentModel> appointments;
  final bool isLoading;
  final void Function(AppointmentModel) onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(LocaleKeys.col_name.tr(),
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text(LocaleKeys.col_doctor.tr(),
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text(LocaleKeys.col_schedule.tr(),
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text(LocaleKeys.col_clinic_location.tr(),
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text(LocaleKeys.col_bookings.tr(),
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...appointments.map((appt) => _AppointmentRow(
                appt: appt,
                isGlobalLoading: isLoading,
                onDelete: () => onDelete(appt),
              )),
        ],
      ),
    );
  }
}

class _AppointmentRow extends StatelessWidget {

  const _AppointmentRow({
    required this.appt,
    required this.isGlobalLoading,
    required this.onDelete,
  });
  final AppointmentModel appt;
  final bool isGlobalLoading;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              appt.patientName,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.teal, fontSize: 12),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(appt.doctorName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11)),
                Text(appt.doctorSpecialty,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(appt.date,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11)),
                Text(appt.time,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            child: Text(appt.address ?? '---',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            child: isGlobalLoading
                ? const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : AppButton.danger(
                    text: LocaleKeys.delete_booking.tr(),
                    onPressed: onDelete,
                    height: 36,
                    borderRadius: 8,
                    fontSize: 11,
                  ),
          ),
        ],
      ),
    );
  }
}
