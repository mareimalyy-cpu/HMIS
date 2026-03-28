class AppointmentModel {
  final String id;
  final String patientId;
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
  final String? address;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    this.patientImageUrl,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    this.doctorImageUrl,
    required this.date,
    required this.time,
    required this.number,
    this.symptoms = '',
    this.status = 'pending',
    this.address,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
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
      status: json['status'] as String? ?? 'pending',
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
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
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? patientId,
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
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
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
    );
  }
}
