class BookingStates {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? selectedDay;
  final String? selectedTime;

  const BookingStates({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.selectedDay,
    this.selectedTime,
  });

  factory BookingStates.initial() => const BookingStates();

  BookingStates copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    String? selectedDay,
    String? selectedTime,
    bool clearError = false,
    bool clearDay = false,
    bool clearTime = false,
  }) {
    return BookingStates(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedDay: clearDay ? null : (selectedDay ?? this.selectedDay),
      selectedTime: clearTime ? null : (selectedTime ?? this.selectedTime),
    );
  }
}
