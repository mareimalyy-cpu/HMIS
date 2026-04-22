class BillModel {

  const BillModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.appointmentId,
    required this.totalAmount,
    required this.createdBy, required this.createdAt, this.paymentStatus = 'pending',
    this.updatedAt,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      appointmentId: json['appointmentId'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
    );
  }
  final String id;
  final String patientId;
  final String patientName;
  final String appointmentId;
  final double totalAmount;
  final String paymentStatus; // paid | pending
  final String createdBy;
  final String createdAt;
  final String? updatedAt;

  bool get isPaid => paymentStatus == 'paid';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'appointmentId': appointmentId,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  BillModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? appointmentId,
    double? totalAmount,
    String? paymentStatus,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      appointmentId: appointmentId ?? this.appointmentId,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
