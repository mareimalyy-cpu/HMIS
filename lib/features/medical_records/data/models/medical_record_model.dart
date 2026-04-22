class MedicalRecordModel {

  const MedicalRecordModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.diagnosis, required this.symptoms, required this.treatment, required this.visitDate, required this.createdBy, required this.createdAt, this.appointmentId,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'] as String? ?? '',
      patientId: json['patientId'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
      appointmentId: json['appointmentId'] as String?,
      diagnosis: json['diagnosis'] as String? ?? '',
      symptoms: json['symptoms'] as String? ?? '',
      treatment: json['treatment'] as String? ?? '',
      visitDate: json['visitDate'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String? appointmentId;
  final String diagnosis;
  final String symptoms;
  final String treatment;
  final String visitDate;
  final String createdBy;
  final String createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'appointmentId': appointmentId,
      'diagnosis': diagnosis,
      'symptoms': symptoms,
      'treatment': treatment,
      'visitDate': visitDate,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }

  MedicalRecordModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? doctorName,
    String? appointmentId,
    String? diagnosis,
    String? symptoms,
    String? treatment,
    String? visitDate,
    String? createdBy,
    String? createdAt,
  }) {
    return MedicalRecordModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      appointmentId: appointmentId ?? this.appointmentId,
      diagnosis: diagnosis ?? this.diagnosis,
      symptoms: symptoms ?? this.symptoms,
      treatment: treatment ?? this.treatment,
      visitDate: visitDate ?? this.visitDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
