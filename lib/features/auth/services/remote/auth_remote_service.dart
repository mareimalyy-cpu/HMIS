import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    return _getUserFromFirestore(credential.user!.uid);
  }

  Future<UserModel> loginWithGoogle() async {
    final googleUser = await GoogleSignIn.instance.authenticate();
    final idToken = googleUser.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);

    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user!;

    final doc = await _firestore
        .collection(Constants.users.name)
        .doc(firebaseUser.uid)
        .get();

    if (doc.exists) return UserModel.fromJson(doc.data()!);

    // New Google user — partial profile, patient by default
    final user = UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      phone: '',
      city: '',
      imageUrl: firebaseUser.photoURL,
      role: UserRole.patient,
    );
    await _firestore
        .collection(Constants.users.name)
        .doc(firebaseUser.uid)
        .set(user.toJson());
    return user;
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

  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection(Constants.users.name)
        .doc(user.id)
        .update(user.toJson());
  }

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _getUserFromFirestore(firebaseUser.uid);
  }

  Future<void> logout() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    final doc =
        await _firestore.collection(Constants.users.name).doc(uid).get();
    if (!doc.exists) throw Exception('User not found in database');
    return UserModel.fromJson(doc.data()!);
  }
}
