import 'package:cloud_firestore/cloud_firestore.dart';

// ───────────────────────────────────────────────────────────────────────────
// Defensive JSON parsers — tolerate Firestore Timestamps, legacy types, and
// manual edits in the Firebase console. Never throw on a type mismatch.
// ───────────────────────────────────────────────────────────────────────────

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

String? _strOrNull(dynamic v) {
  if (v == null) return null;
  final s = _str(v);
  return s.isEmpty ? null : s;
}

int? _intOrNull(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

double? _doubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

bool _bool(dynamic v, [bool fallback = false]) {
  if (v == null) return fallback;
  if (v is bool) return v;
  if (v is String) return v.toLowerCase() == 'true';
  if (v is num) return v != 0;
  return fallback;
}

List<String>? _strListOrNull(dynamic v) {
  if (v == null) return null;
  if (v is List) return v.map(_str).where((s) => s.isNotEmpty).toList();
  return null;
}

String? _readTimestampString(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  if (v is Timestamp) return v.toDate().toIso8601String();
  if (v is DateTime) return v.toIso8601String();
  return v.toString();
}

enum UserRole {
  doctor,
  patient,
  admin,
  receptionist;

  String get value => name;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.patient,
    );
  }
}

enum DoctorStatus {
  pending,
  approved,
  rejected;

  String get value => name;

  static DoctorStatus fromString(String value) {
    return DoctorStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DoctorStatus.pending,
    );
  }
}

class UserModel {

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role, this.city = '',
    this.imageUrl,
    this.isActive = true,
    this.age,
    this.specialty,
    this.hospital,
    this.hospitalAddress,
    this.bio,
    this.rating,
    this.workDays,
    this.workHoursStart,
    this.workHoursEnd,
    this.doctorStatus,
    this.approvedBy,
    this.approvedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _str(json['id']),
      name: _str(json['name']),
      email: _str(json['email']),
      phone: _str(json['phone']),
      city: _str(json['city']),
      imageUrl: _strOrNull(json['imageUrl']),
      role: UserRole.fromString(_str(json['role'], 'patient')),
      isActive: _bool(json['isActive'], true),
      age: _intOrNull(json['age']),
      specialty: _strOrNull(json['specialty']),
      hospital: _strOrNull(json['hospital']),
      hospitalAddress: _strOrNull(json['hospitalAddress']),
      bio: _strOrNull(json['bio']),
      rating: _doubleOrNull(json['rating']),
      workDays: _strListOrNull(json['workDays']),
      workHoursStart: _strOrNull(json['workHoursStart']),
      workHoursEnd: _strOrNull(json['workHoursEnd']),
      doctorStatus: json['doctorStatus'] != null
          ? DoctorStatus.fromString(_str(json['doctorStatus']))
          : null,
      approvedBy: _strOrNull(json['approvedBy']),
      approvedAt: _readTimestampString(json['approvedAt']),
    );
  }

  factory UserModel.initial() => const UserModel(
    id: '',
    name: '',
    email: '',
    phone: '',
    role: UserRole.patient,
  );
  final String id;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String? imageUrl;
  final UserRole role;
  final bool isActive;

  // Patient-specific fields
  final int? age;

  // Doctor-specific fields
  final String? specialty;
  final String? hospital;
  final String? hospitalAddress;
  final String? bio;
  final double? rating;
  final List<String>? workDays;
  final String? workHoursStart;
  final String? workHoursEnd;

  // Doctor approval fields
  final DoctorStatus? doctorStatus;
  final String? approvedBy;
  final String? approvedAt;

  bool get isPendingApproval =>
      role == UserRole.doctor && doctorStatus == DoctorStatus.pending;

  bool get isApprovedDoctor =>
      role == UserRole.doctor && doctorStatus == DoctorStatus.approved;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? city,
    String? imageUrl,
    UserRole? role,
    bool? isActive,
    int? age,
    String? specialty,
    String? hospital,
    String? hospitalAddress,
    String? bio,
    double? rating,
    List<String>? workDays,
    String? workHoursStart,
    String? workHoursEnd,
    DoctorStatus? doctorStatus,
    String? approvedBy,
    String? approvedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      age: age ?? this.age,
      specialty: specialty ?? this.specialty,
      hospital: hospital ?? this.hospital,
      hospitalAddress: hospitalAddress ?? this.hospitalAddress,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      workDays: workDays ?? this.workDays,
      workHoursStart: workHoursStart ?? this.workHoursStart,
      workHoursEnd: workHoursEnd ?? this.workHoursEnd,
      doctorStatus: doctorStatus ?? this.doctorStatus,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'imageUrl': imageUrl,
      'role': role.value,
      'isActive': isActive,
      'age': age,
      'specialty': specialty,
      'hospital': hospital,
      'hospitalAddress': hospitalAddress,
      'bio': bio,
      'rating': rating,
      'workDays': workDays,
      'workHoursStart': workHoursStart,
      'workHoursEnd': workHoursEnd,
      'doctorStatus': doctorStatus?.value,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt,
    };
  }
}
