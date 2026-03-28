import 'dart:convert';

import '../../../../core/enum/constants.dart';
import '../../../../core/local_services/local_storage.dart';
import '../../models/user_model.dart';

class AuthLocalService {
  final LocalStorage _storage;

  AuthLocalService(this._storage);

  Future<void> saveUser(UserModel user) async {
    final jsonString = jsonEncode(user.toJson());
    await _storage.add(Constants.userData.name, jsonString);
    await _storage.add(Constants.userRole.name, user.role.value);
  }

  UserModel? getUser() {
    final jsonString = _storage.get(Constants.userData.name);
    if (jsonString == null) return null;
    final json = jsonDecode(jsonString as String) as Map<String, dynamic>;
    return UserModel.fromJson(json);
  }

  UserRole? getUserRole() {
    final role = _storage.get(Constants.userRole.name);
    if (role == null) return null;
    return UserRole.fromString(role as String);
  }

  Future<void> clearUser() async {
    await _storage.delete(Constants.userData.name);
    await _storage.delete(Constants.userRole.name);
  }
}
