import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_colors.dart';
import '../../auth/models/user_model.dart';
import '../../booking/models/appointment_model.dart';
import '../services/admin_remote_service.dart';
import 'widgets/admin_header.dart';

class _AdminDashboardData {
  final List<UserModel> doctors;
  final List<UserModel> patients;
  final List<AppointmentModel> appointments;

  _AdminDashboardData({
    required this.doctors,
    required this.patients,
    required this.appointments,
  });
}

final _adminDashboardProvider =
    FutureProvider<_AdminDashboardData>((ref) async {
  final svc = AdminRemoteService();
  final results = await Future.wait([
    svc.getAllDoctors(),
    svc.getAllPatients(),
    svc.getAllAppointments(),
  ]);
  return _AdminDashboardData(
    doctors: results[0] as List<UserModel>,
    patients: results[1] as List<UserModel>,
    appointments: results[2] as List<AppointmentModel>,
  );
});

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_adminDashboardProvider);

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('حدث خطأ: $e')),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(_adminDashboardProvider.future),
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
                          label: 'عدد الاطباء',
                          count: data.doctors.length,
                          icon: Icons.medical_services_rounded,
                          color: const Color(0xFF5BC8C8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'عدد المرضي',
                          count: data.patients.length,
                          icon: Icons.people_alt_rounded,
                          color: const Color(0xFF4ABCCA),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'عدد الكشفات',
                          count: data.appointments.length,
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
                  child: _AppointmentsChart(
                      appointments: data.appointments),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'الكشفات',
                    textAlign: TextAlign.right,
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _AppointmentsTable(
                  appointments: data.appointments,
                  onDelete: (appt) async {
                    await AdminRemoteService()
                        .deleteAppointment(appt.id);
                    ref.invalidate(_adminDashboardProvider);
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

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
  final List<AppointmentModel> appointments;

  const _AppointmentsChart({required this.appointments});

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
    final maxVal = counts.values.fold(0, max).clamp(1, double.maxFinite).toInt();

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
                      )),
                  const SizedBox(width: 4),
                  const Text('Appointments',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
              const Text(
                'Appointments Over Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
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
  final Map<String, int> counts;
  final int maxVal;

  _ChartPainter({required this.counts, required this.maxVal});

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

      // Bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - barWidth * 0.3, top, barWidth * 0.6, barH),
          const Radius.circular(4),
        ),
        barPaint,
      );

      points.add(Offset(x, top));

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: keys[i],
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartH + 6));
    }

    // Line
    if (points.length > 1) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    // Dots
    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AppointmentsTable extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final Future<void> Function(AppointmentModel) onDelete;

  const _AppointmentsTable({
    required this.appointments,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Header row
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                    child: Text('الاسم',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('الطبيب',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('المواعيد',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('موقع العيادة',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('الحجزات',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...appointments.map((appt) => _AppointmentRow(
                appt: appt,
                onDelete: () => onDelete(appt),
              )),
        ],
      ),
    );
  }
}

class _AppointmentRow extends StatefulWidget {
  final AppointmentModel appt;
  final VoidCallback onDelete;

  const _AppointmentRow({required this.appt, required this.onDelete});

  @override
  State<_AppointmentRow> createState() => _AppointmentRowState();
}

class _AppointmentRowState extends State<_AppointmentRow> {
  bool _loading = false;

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
            child: Text(widget.appt.patientName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.teal, fontSize: 12)),
          ),
          Expanded(
            child: Column(
              children: [
                Text(widget.appt.doctorName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11)),
                Text(widget.appt.doctorSpecialty,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(widget.appt.date,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11)),
                Text(widget.appt.time,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            child: Text(widget.appt.address ?? '---',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : TextButton(
                    onPressed: () async {
                      setState(() => _loading = true);
                       widget.onDelete();
                      if (mounted) setState(() => _loading = false);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('حذف الحجز',
                        style: TextStyle(
                            color: Colors.white, fontSize: 11)),
                  ),
          ),
        ],
      ),
    );
  }
}
