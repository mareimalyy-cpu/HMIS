import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/specialty_model.dart';
import '../../data/services/remote/patient_home_remote_service.dart';

final specialtiesProvider = FutureProvider<List<SpecialtyModel>>((ref) async {
  final service = PatientHomeRemoteService();
  final remote = await service.getSpecialties();
  return remote.isEmpty ? SpecialtyModel.defaults : remote;
});
