import 'dart:convert';

import '../../../../../core/local_services/local_storage.dart';
import '../../../../auth/data/models/user_model.dart';

class PatientHomeLocalService {

  PatientHomeLocalService(this._storage);
  final LocalStorage _storage;
  static const _doctorsKey = 'cached_doctors';

  Future<void> saveDoctors(List<UserModel> doctors) async {
    final jsonList = doctors.map((d) => jsonEncode(d.toJson())).toList();
    await _storage.add(_doctorsKey, jsonList);
  }

  List<UserModel>? getDoctors() {
    final data = _storage.get(_doctorsKey);
    if (data == null) return null;
    final jsonList = (data as List).cast<String>();
    return jsonList
        .map((s) => UserModel.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }
}
