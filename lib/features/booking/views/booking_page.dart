import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hmis/core/services/helper.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/my_text_filed.dart';
import '../../../core/widgets/section_app_bar.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class BookingPage extends ConsumerStatefulWidget {
  static const routeName = '/booking';

  final UserModel doctor;

  const BookingPage({super.key, required this.doctor});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  final _symptomsController = TextEditingController();
  String? _selectedDay;
  String? _selectedTime;

  List<String> get _availableDays => widget.doctor.workDays ?? [];

  List<String> get _timeSlots {
    // Generate 30-min slots between work hours
    final start = widget.doctor.workHoursStart ?? '04:00 PM';
    final end = widget.doctor.workHoursEnd ?? '08:00 PM';
    return _generateTimeSlots(start, end);
  }

  List<String> _generateTimeSlots(String start, String end) {
    // Simple time slot generation
    return [
      '04:00PM',
      '04:30PM',
      '05:00PM',
      '05:30PM',
      '06:00PM',
      '06:30PM',
      '07:00PM',
      '07:30PM',
    ];
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.value?.currentUser;

    return Scaffold(
      appBar:  SectionAppBar(title: 'book_with_doctor'.tr()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Doctor Mini Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${widget.doctor.rating?.toInt() ?? 0}'),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.doctor.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.doctor.specialty ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: widget.doctor.imageUrl != null
                        ? NetworkImage(widget.doctor.imageUrl!)
                        : null,
                    child: widget.doctor.imageUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 24,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Booking Form Title
            Text(
              'booking_details'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Patient Name (read-only)
            Text('patient_name'.tr(), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(currentUser?.name ?? '', textAlign: TextAlign.right),
            ),

            const SizedBox(height: 12),

            // Phone (read-only)
            Text('phone'.tr(), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(currentUser?.phone ?? '', textAlign: TextAlign.right),
            ),

            const SizedBox(height: 12),

            // Symptoms
            Text('symptoms'.tr(), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            MyTextField(
              controller: _symptomsController,
              hintText: 'describe_your_symptoms'.tr(),
              textAlign: TextAlign.right,
              fillColor: AppColors.cardBackground,
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Day Selection
            Text('select_day'.tr(), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableDays.map((day) {
                final isSelected = _selectedDay == day;
                return ChoiceChip(
                  label: Text(day),
                  selected: isSelected,
                  selectedColor: AppColors.teal,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: AppColors.cardBackground,
                  onSelected: (_) => setState(() => _selectedDay = day),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Time Selection
            Text('select_time'.tr(), style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeSlots.map((time) {
                final isSelected = _selectedTime == time;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.teal
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Confirm Button
            CustomButton(
              text: 'confirm_booking'.tr(),
              grideantColor: AppColors.teal,
              onPressed: () {
                if (_selectedDay == null || _selectedTime == null) {
                  GlassySnackbar.showError(
                    context,
                    'please_select_a_day_and_time'.tr(),
                  );
                  return;
                }
                // Navigate to success
                context.go('/booking-success');
              },
            ),
          ],
        ),
      ),
    );
  }
}
