import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TargetProvider extends ChangeNotifier {
  double _yearlyTarget  = 5000000;
  double _achieved      = 0;
  List<double> _monthly = List.filled(12, 0);

  double get yearlyTarget => _yearlyTarget;
  double get achieved     => _achieved;
  double get remaining    => _yearlyTarget - _achieved;
  double get monthlyTarget => _yearlyTarget / 12;
  int    get achievementPct => _yearlyTarget > 0 ? ((_achieved / _yearlyTarget) * 100).round() : 0;
  List<double> get monthly => _monthly;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _yearlyTarget = prefs.getDouble('yearlyTarget') ?? 5000000;
    final snap = await FirebaseFirestore.instance.collection('collections').get();
    _achieved = snap.docs.fold(0.0, (s, d) => s + ((d.data()['amount'] ?? 0) as num).toDouble());
    notifyListeners();
  }

  Future<void> setYearlyTarget(double target) async {
    _yearlyTarget = target;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('yearlyTarget', target);
    notifyListeners();
  }
}
