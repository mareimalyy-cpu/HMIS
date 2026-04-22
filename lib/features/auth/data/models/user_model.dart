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
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      city: json['city'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'patient'),
      isActive: json['isActive'] as bool? ?? true,
      age: json['age'] as int?,
      specialty: json['specialty'] as String?,
      hospital: json['hospital'] as String?,
      hospitalAddress: json['hospitalAddress'] as String?,
      bio: json['bio'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      workDays: (json['workDays'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      workHoursStart: json['workHoursStart'] as String?,
      workHoursEnd: json['workHoursEnd'] as String?,
      doctorStatus: json['doctorStatus'] != null
          ? DoctorStatus.fromString(json['doctorStatus'] as String)
          : null,
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] as String?,
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
