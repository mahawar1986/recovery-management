import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  UserModel? _user;
  bool _loading = false;
  String? _error;

  UserModel? get user    => _user;
  bool get loading       => _loading;
  String? get error      => _error;
  bool get isLoggedIn    => _user != null;
  bool get isManager     => _user?.role == UserRole.manager;

  Future<bool> login(String email, String password) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final doc  = await _db.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists) { _error = 'User profile not found.'; _loading = false; notifyListeners(); return false; }
      _user = UserModel.fromFirestore(doc);
      _loading = false; notifyListeners(); return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message; _loading = false; notifyListeners(); return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut(); _user = null; notifyListeners();
  }

  Future<void> checkAuth() async {
    final current = _auth.currentUser;
    if (current == null) return;
    final doc = await _db.collection('users').doc(current.uid).get();
    if (doc.exists) _user = UserModel.fromFirestore(doc);
    notifyListeners();
  }

  Future<bool> createAgent({required String name, required String email, required String mobile, required String employeeId, required String zone, required String password}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final agent = UserModel(uid: cred.user!.uid, name: name, email: email, mobile: mobile, role: UserRole.agent, employeeId: employeeId, zone: zone, managerId: _user!.uid, createdAt: DateTime.now());
      await _db.collection('users').doc(cred.user!.uid).set(agent.toFirestore());
      return true;
    } catch (e) { return false; }
  }
}
