import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../utils/app_theme.dart';

class CustomerTile extends StatelessWidget {
  final CustomerModel customer;
  const CustomerTile({super.key, required this.customer});

  Color get _statusColor => switch (customer.status) {
    'NPA'    => AppColors.danger,
    'PTP'    => AppColors.warning,
    'Active' => AppColors.success,
    _        => AppColors.textMuted,
  };

  String fmt(double n) => n >= 100000 ? '₹${(n/100000).toStringAsFixed(1)}L' : n >= 1000 ? '₹${(n/1000).toStringAsFixed(0)}K' : '₹${n.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: _statusColor.withOpacity(0.15),
        child: Text(customer.name[0], style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold)),
      ),
      title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      subtitle: Text('${customer.accountNumber} · ${customer.village} · S/o ${customer.fatherName}', style: const TextStyle(fontSize: 11)),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(fmt(customer.outstandingAmount), style: TextStyle(color: _statusColor, fontWeight: FontWeight.w800, fontSize: 13)),
        Container(
          margin: const EdgeInsets.only(top: 3),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(color: _statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
          child: Text(customer.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor)),
        ),
      ]),
    ),
  );
}
