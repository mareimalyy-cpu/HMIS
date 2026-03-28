import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hmis/core/enum/constants.dart';

import '../../models/user_model.dart';

class AuthRemoteService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    return _getUserFromFirestore(uid);
  }

  Future<UserModel> registerPatient({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String city,
    required int age,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final user = UserModel(
      id: uid,
      name: name,
      email: email,
      phone: phone,
      city: city,
      role: UserRole.patient,
      age: age,
    );

    await _firestore.collection(Constants.users.name).doc(uid).set(user.toJson());
    return user;
  }

  Future<UserModel> registerDoctor({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String specialty,
    required String hospital,
    required String hospitalAddress,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final user = UserModel(
      id: uid,
      name: name,
      email: email,
      phone: phone,
      role: UserRole.doctor,
      specialty: specialty,
      hospital: hospital,
      hospitalAddress: hospitalAddress,
      rating: 0,
      workDays: [],
    );

    await _firestore.collection(Constants.users.name).doc(uid).set(user.toJson());
    return user;
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection(Constants.users.name).doc(uid).get();
    if (!doc.exists) {
      throw Exception('User not found in database');
    }
    return UserModel.fromJson(doc.data()!);
  }

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _getUserFromFirestore(firebaseUser.uid);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
