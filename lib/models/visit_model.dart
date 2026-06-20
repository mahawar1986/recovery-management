import 'package:cloud_firestore/cloud_firestore.dart';

enum VisitOutcome { ptp, paid, refused, notMet, callBack }

class VisitModel {
  final String id;
  final String customerId;
  final String customerName;
  final String agentId;
  final String agentName;
  final DateTime visitDate;
  final VisitOutcome outcome;
  final double? collectedAmount;
  final DateTime? ptpDate;
  final double? ptpAmount;
  final String remarks;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;

  VisitModel({
    required this.id, required this.customerId, required this.customerName,
    required this.agentId, required this.agentName, required this.visitDate,
    required this.outcome, this.collectedAmount, this.ptpDate, this.ptpAmount,
    this.remarks = '', this.photoUrl, this.latitude, this.longitude,
  });

  factory VisitModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return VisitModel(
      id: doc.id, customerId: d['customerId'] ?? '', customerName: d['customerName'] ?? '',
      agentId: d['agentId'] ?? '', agentName: d['agentName'] ?? '',
      visitDate: (d['visitDate'] as Timestamp).toDate(),
      outcome: VisitOutcome.values.firstWhere((e) => e.name == d['outcome'], orElse: () => VisitOutcome.callBack),
      collectedAmount: d['collectedAmount']?.toDouble(),
      ptpDate: d['ptpDate'] != null ? (d['ptpDate'] as Timestamp).toDate() : null,
      ptpAmount: d['ptpAmount']?.toDouble(),
      remarks: d['remarks'] ?? '', photoUrl: d['photoUrl'],
      latitude: d['latitude']?.toDouble(), longitude: d['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'customerId': customerId, 'customerName': customerName,
    'agentId': agentId, 'agentName': agentName,
    'visitDate': Timestamp.fromDate(visitDate), 'outcome': outcome.name,
    'collectedAmount': collectedAmount, 'ptpDate': ptpDate != null ? Timestamp.fromDate(ptpDate!) : null,
    'ptpAmount': ptpAmount, 'remarks': remarks, 'photoUrl': photoUrl,
    'latitude': latitude, 'longitude': longitude,
  };
}
