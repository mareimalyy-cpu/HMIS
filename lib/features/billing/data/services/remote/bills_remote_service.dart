import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/enum/constants.dart';
import '../../models/bill_model.dart';

class BillsRemoteService {
  final _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<List<BillModel>> getAllBills() async {
    final snap = await _db
        .collection(Constants.bills.name)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => BillModel.fromJson(d.data())).toList();
  }

  Future<List<BillModel>> getBillsForPatient(String patientId) async {
    final snap = await _db
        .collection(Constants.bills.name)
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => BillModel.fromJson(d.data())).toList();
  }

  Future<BillModel> createBill({
    required String patientId,
    required String patientName,
    required String appointmentId,
    required double totalAmount,
    required String createdBy,
  }) async {
    final id = _uuid.v4();
    final bill = BillModel(
      id: id,
      patientId: patientId,
      patientName: patientName,
      appointmentId: appointmentId,
      totalAmount: totalAmount,
      paymentStatus: 'pending',
      createdBy: createdBy,
      createdAt: DateTime.now().toIso8601String(),
    );
    await _db.collection(Constants.bills.name).doc(id).set(bill.toJson());
    return bill;
  }

  Future<void> markAsPaid(String billId) async {
    await _db.collection(Constants.bills.name).doc(billId).update({
      'paymentStatus': 'paid',
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteBill(String billId) async {
    await _db.collection(Constants.bills.name).doc(billId).delete();
  }
}
