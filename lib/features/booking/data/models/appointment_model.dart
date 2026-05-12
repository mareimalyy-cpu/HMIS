import 'package:cloud_firestore/cloud_firestore.dart';

// ───────────────────────────────────────────────────────────────────────────
// Defensive JSON parsers — tolerate Firestore Timestamps, legacy types, and
// manual edits in the Firebase console. Never throw on a type mismatch.
// ───────────────────────────────────────────────────────────────────────────

/// Reads any value as a String, never returns null.
/// - String → as-is
/// - Timestamp → "yyyy-MM-dd"
/// - DateTime → "yyyy-MM-dd"
/// - num/bool → toString()
/// - null → fallback
String _str(dynamic v, [String fallback = '']) {
  if (v == null) return fallback;
  if (v is String) return v;
  if (v is Timestamp) {
    final d = v.toDate();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
  if (v is DateTime) {
    return '${v.year.toString().padLeft(4, '0')}-'
        '${v.month.toString().padLeft(2, '0')}-'
        '${v.day.toString().padLeft(2, '0')}';
  }
  return v.toString();
}

/// Reads as nullable String. Empty string → null.
String? _strOrNull(dynamic v) {
  if (v == null) return null;
  final s = _str(v);
  return s.isEmpty ? null : s;
}

/// Reads a timestamp-shaped field as an ISO 8601 String.
String? _readTimestampString(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  if (v is Timestamp) return v.toDate().toIso8601String();
  if (v is DateTime) return v.toIso8601String();
  return v.toString();
}

/// Reads any value as an int. Parses strings, floors doubles, defaults on fail.
int _int(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

/// Reads any value as a `List<String>`. Tolerates non-string elements.
List<String> _strList(dynamic v) {
  if (v is List) return v.map(_str).where((s) => s.isNotEmpty).toList();
  return const [];
}

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
      id: _str(json['id']),
      patientId: _str(json['patientId']),
      patientUserId: _str(json['patientUserId']),
      patientName: _str(json['patientName']),
      patientPhone: _str(json['patientPhone']),
      patientImageUrl: _strOrNull(json['patientImageUrl']),
      doctorId: _str(json['doctorId']),
      doctorName: _str(json['doctorName']),
      doctorSpecialty: _str(json['doctorSpecialty']),
      doctorImageUrl: _strOrNull(json['doctorImageUrl']),
      date: _str(json['date']),
      time: _str(json['time']),
      number: _int(json['number']),
      symptoms: _str(json['symptoms']),
      status: _str(json['status'], 'scheduled'),
      address: _strOrNull(json['address']),
      timeSlotId: _strOrNull(json['timeSlotId']),
      actorRole: _str(json['actorRole'], 'patient'),
      createdBy: _strOrNull(json['createdBy']),
      updatedAt: _readTimestampString(json['updatedAt']),
      attachments: _strList(json['attachments']),
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
