import '../../../doctor/data/models/time_slot_model.dart';
import '../../../attachments/data/models/booking_attachment.dart';

class BookingStates {

  const BookingStates({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.attachments = const [],
    this.availableSlots = const [],
    this.isSlotsLoading = false,
    this.slotsError,
    this.selectedSlot,
  });

  factory BookingStates.initial() => const BookingStates();
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final List<BookingAttachment> attachments;

  // Slot selection (replaces selectedDay / selectedTime)
  final List<TimeSlotModel> availableSlots;
  final bool isSlotsLoading;
  final String? slotsError;
  final TimeSlotModel? selectedSlot;

  bool get isUploading => attachments.any((a) => a.isUploading);
  List<String> get attachmentUrls =>
      attachments.where((a) => a.url != null).map((a) => a.url!).toList();

  /// Slots grouped by date string (yyyy-MM-dd) for UI rendering.
  Map<String, List<TimeSlotModel>> get slotsByDate {
    final map = <String, List<TimeSlotModel>>{};
    for (final slot in availableSlots) {
      final dt = DateTime.tryParse(slot.startTime);
      if (dt == null) continue;
      final key =
          '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(slot);
    }
    return map;
  }

  BookingStates copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<BookingAttachment>? attachments,
    List<TimeSlotModel>? availableSlots,
    bool? isSlotsLoading,
    String? slotsError,
    TimeSlotModel? selectedSlot,
    bool clearError = false,
    bool clearSlotsError = false,
    bool clearSelectedSlot = false,
  }) {
    return BookingStates(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      attachments: attachments ?? this.attachments,
      availableSlots: availableSlots ?? this.availableSlots,
      isSlotsLoading: isSlotsLoading ?? this.isSlotsLoading,
      slotsError:
          clearSlotsError ? null : (slotsError ?? this.slotsError),
      selectedSlot:
          clearSelectedSlot ? null : (selectedSlot ?? this.selectedSlot),
    );
  }
}
