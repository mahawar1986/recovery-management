import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import '../models/visit_model.dart';

class CustomerProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<CustomerModel> _customers = [];
  List<VisitModel>    _visits    = [];
  bool _loading = false;

  List<CustomerModel> get customers => _customers;
  List<VisitModel>    get visits    => _visits;
  bool get loading => _loading;

  // Analytics getters
  double get totalOutstanding => _customers.fold(0, (s,c) => s + c.outstandingAmount);
  int    get npaCount         => _customers.where((c) => c.status == 'NPA').length;
  List<CustomerModel> get ptpToday {
    final today = DateTime.now();
    return _customers.where((c) => c.ptpDate != null && c.ptpDate!.day == today.day && c.ptpDate!.month == today.month && c.ptpDate!.year == today.year).toList();
  }
  List<CustomerModel> get frequentlyVisited => [..._customers]..sort((a,b) => b.visitCount.compareTo(a.visitCount));
  List<CustomerModel> get highOutstanding   => [..._customers]..sort((a,b) => b.outstandingAmount.compareTo(a.outstandingAmount));
  List<CustomerModel> get lowRecovery       => _customers.where((c) => c.sanctionedAmount > 0 && (c.outstandingAmount / c.sanctionedAmount) > 0.8).toList();

  Future<void> fetchCustomers({String? agentId}) async {
    _loading = true; notifyListeners();
    Query q = _db.collection('customers');
    if (agentId != null) q = q.where('assignedAgentId', isEqualTo: agentId);
    final snap = await q.get();
    _customers = snap.docs.map((d) => CustomerModel.fromFirestore(d)).toList();
    _loading = false; notifyListeners();
  }

  Future<void> fetchVisits({String? customerId, String? agentId}) async {
    Query q = _db.collection('visits');
    if (customerId != null) q = q.where('customerId', isEqualTo: customerId);
    if (agentId != null)    q = q.where('agentId', isEqualTo: agentId);
    final snap = await q.orderBy('visitDate', descending: true).get();
    _visits = snap.docs.map((d) => VisitModel.fromFirestore(d)).toList();
    notifyListeners();
  }

  Future<bool> uploadCustomers(List<CustomerModel> list) async {
    final batch = _db.batch();
    for (final c in list) {
      final ref = _db.collection('customers').doc();
      batch.set(ref, c.copyWith().toFirestore());
    }
    await batch.commit();
    await fetchCustomers();
    return true;
  }

  Future<bool> logVisit(VisitModel visit) async {
    await _db.collection('visits').add(visit.toFirestore());
    await _db.collection('customers').doc(visit.customerId).update({
      'visitCount': FieldValue.increment(1),
      'lastVisitDate': Timestamp.fromDate(visit.visitDate),
      'status': _outcomeToStatus(visit.outcome),
      if (visit.ptpDate != null) 'ptpDate': Timestamp.fromDate(visit.ptpDate!),
      if (visit.ptpAmount != null) 'ptpAmount': visit.ptpAmount,
    });
    await fetchCustomers();
    return true;
  }

  String _outcomeToStatus(VisitOutcome o) {
    switch (o) {
      case VisitOutcome.ptp:      return 'PTP';
      case VisitOutcome.paid:     return 'Active';
      case VisitOutcome.refused:  return 'RTP';
      case VisitOutcome.notMet:   return 'NM';
      default: return 'Active';
    }
  }

  // Village-wise breakdown
  Map<String, Map<String, dynamic>> get villageBreakdown {
    final map = <String, Map<String, dynamic>>{};
    for (final c in _customers) {
      map.putIfAbsent(c.village, () => {'outstanding': 0.0, 'count': 0});
      map[c.village]!['outstanding'] = (map[c.village]!['outstanding'] as double) + c.outstandingAmount;
      map[c.village]!['count'] = (map[c.village]!['count'] as int) + 1;
    }
    return map;
  }
}
