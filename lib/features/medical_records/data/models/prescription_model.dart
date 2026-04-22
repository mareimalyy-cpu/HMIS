class PrescriptionModel {

  const PrescriptionModel({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as String? ?? '',
      medicationName: json['medicationName'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      instructions: json['instructions'] as String?,
    );
  }
  final String id;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }
}
