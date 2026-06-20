import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String name;
  final String fatherName;
  final String customerId;
  final String accountNumber;
  final String village;
  final double sanctionedAmount;
  final double outstandingAmount;
  final double rateOfInterest;
  final double penalInterestRate;
  final String status; // NPA, PTP, Active, RTP, NM
  final String assignedAgent;
  final String assignedAgentId;
  final DateTime? ptpDate;
  final double ptpAmount;
  final int visitCount;
  final DateTime? lastVisitDate;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.fatherName,
    required this.customerId,
    required this.accountNumber,
    required this.village,
    required this.sanctionedAmount,
    required this.outstandingAmount,
    required this.rateOfInterest,
    required this.penalInterestRate,
    this.status = 'Active',
    this.assignedAgent = '',
    this.assignedAgentId = '',
    this.ptpDate,
    this.ptpAmount = 0,
    this.visitCount = 0,
    this.lastVisitDate,
    required this.createdAt,
  });

  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      id: doc.id,
      name: d['name'] ?? '',
      fatherName: d['fatherName'] ?? '',
      customerId: d['customerId'] ?? '',
      accountNumber: d['accountNumber'] ?? '',
      village: d['village'] ?? '',
      sanctionedAmount: (d['sanctionedAmount'] ?? 0).toDouble(),
      outstandingAmount: (d['outstandingAmount'] ?? 0).toDouble(),
      rateOfInterest: (d['rateOfInterest'] ?? 0).toDouble(),
      penalInterestRate: (d['penalInterestRate'] ?? 0).toDouble(),
      status: d['status'] ?? 'Active',
      assignedAgent: d['assignedAgent'] ?? '',
      assignedAgentId: d['assignedAgentId'] ?? '',
      ptpDate: d['ptpDate'] != null ? (d['ptpDate'] as Timestamp).toDate() : null,
      ptpAmount: (d['ptpAmount'] ?? 0).toDouble(),
      visitCount: d['visitCount'] ?? 0,
      lastVisitDate: d['lastVisitDate'] != null ? (d['lastVisitDate'] as Timestamp).toDate() : null,
      createdAt: d['createdAt'] != null ? (d['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name, 'fatherName': fatherName, 'customerId': customerId,
    'accountNumber': accountNumber, 'village': village,
    'sanctionedAmount': sanctionedAmount, 'outstandingAmount': outstandingAmount,
    'rateOfInterest': rateOfInterest, 'penalInterestRate': penalInterestRate,
    'status': status, 'assignedAgent': assignedAgent, 'assignedAgentId': assignedAgentId,
    'ptpDate': ptpDate != null ? Timestamp.fromDate(ptpDate!) : null,
    'ptpAmount': ptpAmount, 'visitCount': visitCount,
    'lastVisitDate': lastVisitDate != null ? Timestamp.fromDate(lastVisitDate!) : null,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  CustomerModel copyWith({String? status, double? outstandingAmount, DateTime? ptpDate, double? ptpAmount, int? visitCount, DateTime? lastVisitDate, String? assignedAgent, String? assignedAgentId}) {
    return CustomerModel(
      id: id, name: name, fatherName: fatherName, customerId: customerId,
      accountNumber: accountNumber, village: village, sanctionedAmount: sanctionedAmount,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      rateOfInterest: rateOfInterest, penalInterestRate: penalInterestRate,
      status: status ?? this.status,
      assignedAgent: assignedAgent ?? this.assignedAgent,
      assignedAgentId: assignedAgentId ?? this.assignedAgentId,
      ptpDate: ptpDate ?? this.ptpDate, ptpAmount: ptpAmount ?? this.ptpAmount,
      visitCount: visitCount ?? this.visitCount, lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      createdAt: createdAt,
    );
  }
}
