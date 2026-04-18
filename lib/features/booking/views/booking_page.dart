import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hmis/core/services/helper.dart';
import 'package:hmis/generated/locale_keys.g.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/my_text_filed.dart';
import '../../../core/widgets/section_app_bar.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import 'booking_success_page.dart';

class BookingPage extends ConsumerStatefulWidget {
  static const routeName = '/booking';

  final UserModel doctor;

  const BookingPage({super.key, required this.doctor});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  final _symptomsController = TextEditingController();

  List<String> get _availableDays => widget.doctor.workDays?.isNotEmpty == true
      ? widget.doctor.workDays!
      : [
          'Saturday',
          'Sunday',
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
        ];

  List<String> get _timeSlots => _generateTimeSlots(
    widget.doctor.workHoursStart ?? '04:00 PM',
    widget.doctor.workHoursEnd ?? '08:00 PM',
  );

  List<String> _generateTimeSlots(String start, String end) {
    try {
      final fmt = DateFormat('hh:mm a');
      var current = fmt.parse(start);
      final endTime = fmt.parse(end);
      final slots = <String>[];
      while (!current.isAfter(endTime)) {
        slots.add(DateFormat('hh:mm a').format(current));
        current = current.add(const Duration(minutes: 30));
      }
      return slots.isEmpty
          ? [
              '04:00 PM',
              '04:30 PM',
              '05:00 PM',
              '05:30 PM',
              '06:00 PM',
              '06:30 PM',
              '07:00 PM',
              '07:30 PM',
            ]
          : slots;
    } catch (_) {
      return [
        '04:00 PM',
        '04:30 PM',
        '05:00 PM',
        '05:30 PM',
        '06:00 PM',
        '06:30 PM',
        '07:00 PM',
        '07:30 PM',
      ];
    }
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bookingAsync = ref.watch(bookingProvider);
    final booking = bookingAsync.value;
    final currentUser = authState.value?.currentUser;
    final cardColor = AppColors.card(context);
    final textColor = Theme.of(context).colorScheme.onSurface;
    final isLoading = booking?.isLoading ?? false;
    final selectedDay = booking?.selectedDay;
    final selectedTime = booking?.selectedTime;

    ref.listen(bookingProvider, (_, next) {
      final s = next.value;
      if (s == null) return;
      if (s.errorMessage != null) {
        GlassySnackbar.showError(context, s.errorMessage!);
        ref.read(bookingProvider.notifier).reset();
      }
      if (s.isSuccess) {
        ref.read(bookingProvider.notifier).reset();
        context.go(BookingSuccessPage.routeName);
      }
    });

    return Scaffold(
      appBar: SectionAppBar(title: LocaleKeys.book_with_doctor.tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Doctor Mini Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.doctor.specialty ?? '',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
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
                LocaleKeys.booking_details.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Patient Name (read-only)
              Text(
                LocaleKeys.patient_name.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentUser?.name ?? '',
                  textAlign: TextAlign.right,
                ),
              ),

              const SizedBox(height: 12),

              // Phone (read-only)
              Text(
                LocaleKeys.phone.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentUser?.phone ?? '',
                  textAlign: TextAlign.right,
                ),
              ),

              const SizedBox(height: 12),

              // Symptoms
              Text(
                LocaleKeys.symptoms.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              MyTextField(
                controller: _symptomsController,
                hintText: LocaleKeys.describe_your_symptoms.tr(),
                textAlign: TextAlign.right,
                fillColor: cardColor,
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Day Selection
              Text(
                LocaleKeys.select_day.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableDays.map((day) {
                  final isSelected = selectedDay == day;
                  return ChoiceChip(
                    label: Text(day),
                    selected: isSelected,
                    selectedColor: AppColors.teal,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: cardColor,
                    onSelected: isLoading
                        ? null
                        : (_) =>
                              ref.read(bookingProvider.notifier).selectDay(day),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Time Selection
              Text(
                LocaleKeys.select_time.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots.map((time) {
                  final isSelected = selectedTime == time;
                  return ChoiceChip(
                    label: Text(time),
                    selected: isSelected,
                    selectedColor: AppColors.teal,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: cardColor,
                    onSelected: isLoading
                        ? null
                        : (_) => ref
                              .read(bookingProvider.notifier)
                              .selectTime(time),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              AppButton.primary(
                text: LocaleKeys.confirm_booking.tr(),
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () {
                        if (selectedDay == null || selectedTime == null) {
                          GlassySnackbar.showError(
                            context,
                            LocaleKeys.please_select_a_day_and_time.tr(),
                          );
                          return;
                        }
                        if (currentUser == null) return;
                        ref
                            .read(bookingProvider.notifier)
                            .submitBooking(
                              patient: currentUser,
                              doctor: widget.doctor,
                              dayName: selectedDay,
                              time: selectedTime,
                              symptoms: _symptomsController.text.trim(),
                            );
                      },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
