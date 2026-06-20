import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { manager, agent }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String mobile;
  final UserRole role;
  final String employeeId;
  final String zone;
  final String managerId;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    required this.uid, required this.name, required this.email,
    required this.mobile, required this.role, this.employeeId = '',
    this.zone = '', this.managerId = '', this.isActive = true,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id, name: d['name'] ?? '', email: d['email'] ?? '',
      mobile: d['mobile'] ?? '',
      role: UserRole.values.firstWhere((e) => e.name == d['role'], orElse: () => UserRole.agent),
      employeeId: d['employeeId'] ?? '', zone: d['zone'] ?? '',
      managerId: d['managerId'] ?? '', isActive: d['isActive'] ?? true,
      createdAt: d['createdAt'] != null ? (d['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name, 'email': email, 'mobile': mobile, 'role': role.name,
    'employeeId': employeeId, 'zone': zone, 'managerId': managerId,
    'isActive': isActive, 'createdAt': Timestamp.fromDate(createdAt),
  };
}
