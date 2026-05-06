import 'package:flutter/material.dart';

import '../../../auth/data/models/user_model.dart';
import 'specialty_model.dart';

class PatientHomeStates {

  const PatientHomeStates({
    this.currentUser,
    this.specialties = const [],
    this.allDoctors = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  factory PatientHomeStates.initial() => PatientHomeStates(
        specialties: SpecialtyModel.defaults,
      );
  final UserModel? currentUser;
  final List<SpecialtyModel> specialties;
  final List<UserModel> allDoctors;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  // Derived getters
  String get greeting => 'Welcome, ${currentUser?.name ?? ''}';

  List<UserModel> get filteredDoctors {
    if (searchQuery.isEmpty) return allDoctors;
    final query = searchQuery.toLowerCase();
    return allDoctors
        .where((d) =>
            d.name.toLowerCase().contains(query) ||
            (d.specialty?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  List<UserModel> doctorsBySpecialty(String specialtyId) {
    final specialty = specialties.firstWhere(
      (s) => s.id == specialtyId,
      orElse: () => SpecialtyModel(
        id: specialtyId,
        nameEn: '',
        nameAr: '',
        imageUrl: '',
        color: const Color(0xFF000000),
      ),
    );
    final candidates = {
      specialtyId.toLowerCase(),
      specialty.nameEn.toLowerCase(),
      specialty.nameAr.toLowerCase(),
    }..remove('');

    return allDoctors
        .where((d) => candidates.contains(d.specialty?.toLowerCase() ?? ''))
        .toList();
  }

  PatientHomeStates copyWith({
    UserModel? currentUser,
    List<SpecialtyModel>? specialties,
    List<UserModel>? allDoctors,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PatientHomeStates(
      currentUser: currentUser ?? this.currentUser,
      specialties: specialties ?? this.specialties,
      allDoctors: allDoctors ?? this.allDoctors,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
