import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/enum/constants.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../models/specialty_model.dart';

class PatientHomeRemoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserModel>> getAllDoctors() async {
    final snapshot = await _firestore
        .collection(Constants.users.name)
        .where('role', isEqualTo: UserRole.doctor.value)
        .get();
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }

  Future<List<UserModel>> getDoctorsBySpecialty(String specialty) async {
    final snapshot = await _firestore
        .collection(Constants.users.name)
        .where('role', isEqualTo: UserRole.doctor.value)
        .where('specialty', isEqualTo: specialty)
        .get();
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }

  Future<List<SpecialtyModel>> getSpecialties() async {
    final snapshot =
        await _firestore.collection(Constants.specialties.name).get();
    if (snapshot.docs.isEmpty) return [];
    return snapshot.docs
        .map((doc) => SpecialtyModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> seedSpecialties() async {
    final batch = _firestore.batch();
    final collection = _firestore.collection(Constants.specialties.name);
    for (final specialty in SpecialtyModel.defaults) {
      batch.set(collection.doc(specialty.id), specialty.toJson());
    }
    await batch.commit();
  }
}
