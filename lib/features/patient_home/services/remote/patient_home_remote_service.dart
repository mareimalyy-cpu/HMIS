import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/enum/constants.dart';
import '../../../auth/models/user_model.dart';

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
}
