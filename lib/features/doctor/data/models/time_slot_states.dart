import 'time_slot_model.dart';

class TimeSlotStates {

  const TimeSlotStates({
    this.slots = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory TimeSlotStates.initial() => const TimeSlotStates();
  final List<TimeSlotModel> slots;
  final bool isLoading;
  final String? errorMessage;

  List<TimeSlotModel> get availableSlots =>
      slots.where((s) => !s.isBooked).toList();

  TimeSlotStates copyWith({
    List<TimeSlotModel>? slots,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TimeSlotStates(
      slots: slots ?? this.slots,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
