class TimeSlotModel {

  const TimeSlotModel({
    required this.id,
    required this.doctorId,
    required this.startTime,
    required this.endTime,
    required this.createdAt, this.isBooked = false,
    this.appointmentId,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: json['id'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      isBooked: json['isBooked'] as bool? ?? false,
      appointmentId: json['appointmentId'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
  final String id;
  final String doctorId;
  final String startTime;
  final String endTime;
  final bool isBooked;
  final String? appointmentId;
  final String createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'startTime': startTime,
      'endTime': endTime,
      'isBooked': isBooked,
      'appointmentId': appointmentId,
      'createdAt': createdAt,
    };
  }

  TimeSlotModel copyWith({
    String? id,
    String? doctorId,
    String? startTime,
    String? endTime,
    bool? isBooked,
    String? appointmentId,
    String? createdAt,
    bool clearAppointment = false,
  }) {
    return TimeSlotModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBooked: isBooked ?? this.isBooked,
      appointmentId: clearAppointment ? null : (appointmentId ?? this.appointmentId),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
