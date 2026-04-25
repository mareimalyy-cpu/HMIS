class AppointmentModel {

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName, required this.patientPhone, required this.doctorId, required this.doctorName, required this.doctorSpecialty, required this.date, required this.time, required this.number, this.patientUserId = '',
    this.patientImageUrl,
    this.doctorImageUrl,
    this.symptoms = '',
    this.status = 'scheduled',
    this.address,
    this.timeSlotId,
    this.actorRole = 'patient',
    this.createdBy,
    this.updatedAt,
    this.attachments = const [],
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      patientUserId: json['patientUserId'] as String? ?? '',
      patientName: json['patientName'] as String? ?? '',
      patientPhone: json['patientPhone'] as String? ?? '',
      patientImageUrl: json['patientImageUrl'] as String?,
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      doctorSpecialty: json['doctorSpecialty'] as String? ?? '',
      doctorImageUrl: json['doctorImageUrl'] as String?,
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      number: json['number'] as int? ?? 0,
      symptoms: json['symptoms'] as String? ?? '',
      status: json['status'] as String? ?? 'scheduled',
      address: json['address'] as String?,
      timeSlotId: json['timeSlotId'] as String?,
      actorRole: json['actorRole'] as String? ?? 'patient',
      createdBy: json['createdBy'] as String?,
      updatedAt: json['updatedAt'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
  final String id;
  final String patientId;
  final String patientUserId;
  final String patientName;
  final String patientPhone;
  final String? patientImageUrl;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String? doctorImageUrl;
  final String date;
  final String time;
  final int number;
  final String symptoms;
  final String status;
  // scheduled | completed | cancelled | no_show | pending
  final String? address;
  final String? timeSlotId;
  final String actorRole;
  // patient | receptionist | admin
  final String? createdBy;
  final String? updatedAt;
  final List<String> attachments;

  /// True when the appointment date is today or already passed.
  bool get isAppointmentDue {
    try {
      final parts = date.split('-');
      if (parts.length != 3) return false;
      final apptDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return !apptDate.isAfter(today);
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientUserId': patientUserId,
      'patientName': patientName,
      'patientPhone': patientPhone,
      'patientImageUrl': patientImageUrl,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorImageUrl': doctorImageUrl,
      'date': date,
      'time': time,
      'number': number,
      'symptoms': symptoms,
      'status': status,
      'address': address,
      'timeSlotId': timeSlotId,
      'actorRole': actorRole,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      'attachments': attachments,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? patientUserId,
    String? patientName,
    String? patientPhone,
    String? patientImageUrl,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    String? doctorImageUrl,
    String? date,
    String? time,
    int? number,
    String? symptoms,
    String? status,
    String? address,
    String? timeSlotId,
    String? actorRole,
    String? createdBy,
    String? updatedAt,
    List<String>? attachments,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientUserId: patientUserId ?? this.patientUserId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      patientImageUrl: patientImageUrl ?? this.patientImageUrl,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorImageUrl: doctorImageUrl ?? this.doctorImageUrl,
      date: date ?? this.date,
      time: time ?? this.time,
      number: number ?? this.number,
      symptoms: symptoms ?? this.symptoms,
      status: status ?? this.status,
      address: address ?? this.address,
      timeSlotId: timeSlotId ?? this.timeSlotId,
      actorRole: actorRole ?? this.actorRole,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      attachments: attachments ?? this.attachments,
    );
  }
}
