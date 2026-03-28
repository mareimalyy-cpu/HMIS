import 'dart:convert';

import '../../../../core/local_services/local_storage.dart';
import '../../../booking/models/appointment_model.dart';

class DoctorHomeLocalService {
  final LocalStorage _storage;
  static const _todayKey = 'cached_today_appointments';
  static const _allKey = 'cached_all_appointments';

  DoctorHomeLocalService(this._storage);

  Future<void> saveTodayAppointments(List<AppointmentModel> list) async {
    final jsonList = list.map((a) => jsonEncode(a.toJson())).toList();
    await _storage.add(_todayKey, jsonList);
  }

  List<AppointmentModel>? getTodayAppointments() {
    final data = _storage.get(_todayKey);
    if (data == null) return null;
    return (data as List)
        .cast<String>()
        .map((s) =>
            AppointmentModel.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAllAppointments(List<AppointmentModel> list) async {
    final jsonList = list.map((a) => jsonEncode(a.toJson())).toList();
    await _storage.add(_allKey, jsonList);
  }

  List<AppointmentModel>? getAllAppointments() {
    final data = _storage.get(_allKey);
    if (data == null) return null;
    return (data as List)
        .cast<String>()
        .map((s) =>
            AppointmentModel.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }
}
