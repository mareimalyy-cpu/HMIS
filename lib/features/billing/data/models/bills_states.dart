import 'bill_model.dart';

class BillsStates {

  const BillsStates({
    this.bills = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory BillsStates.initial() => const BillsStates();
  final List<BillModel> bills;
  final bool isLoading;
  final String? errorMessage;

  List<BillModel> get paidBills => bills.where((b) => b.isPaid).toList();
  List<BillModel> get pendingBills => bills.where((b) => !b.isPaid).toList();
  double get totalRevenue =>
      paidBills.fold(0, (sum, b) => sum + b.totalAmount);

  BillsStates copyWith({
    List<BillModel>? bills,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BillsStates(
      bills: bills ?? this.bills,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
