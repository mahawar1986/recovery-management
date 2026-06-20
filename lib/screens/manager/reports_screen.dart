import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/section_title.dart';
import '../../widgets/stat_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  String fmt(double n) => n >= 100000 ? '₹${(n/100000).toStringAsFixed(1)}L' : n >= 1000 ? '₹${(n/1000).toStringAsFixed(0)}K' : '₹${n.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CustomerProvider>();
    final npa = cp.customers.where((c) => c.status == 'NPA').toList();
    final ptp = cp.customers.where((c) => c.status == 'PTP' && c.ptpDate != null).toList()
      ..sort((a,b) => a.ptpDate!.compareTo(b.ptpDate!));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: StatCard(label: 'Total Outstanding', value: fmt(cp.totalOutstanding), icon: Icons.currency_rupee, color: AppColors.danger, bg: AppColors.dangerLight)),
          const SizedBox(width: 10),
          Expanded(child: StatCard(label: 'PTP Expected', value: fmt(ptp.fold(0.0,(s,c)=>s+c.ptpAmount)), icon: Icons.handshake_outlined, color: AppColors.success, bg: AppColors.successLight)),
        ]),

        const SectionTitle('NPA ACCOUNTS'),
        ...npa.map((c) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: AppColors.dangerLight, child: Text(c.name[0], style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold))),
            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            subtitle: Text('${c.accountNumber} · ${c.village} · Penal: ${c.penalInterestRate}%'),
            trailing: Text(fmt(c.outstandingAmount), style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w800, fontSize: 13)),
          ),
        )),

        const SectionTitle('UPCOMING PTP'),
        ...ptp.map((c) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: AppColors.warningLight, child: Text(c.name[0], style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold))),
            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            subtitle: Text('PTP Date: ${c.ptpDate?.toLocal().toString().split(' ')[0]}'),
            trailing: Text('+${fmt(c.ptpAmount)}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w800, fontSize: 13)),
          ),
        )),
      ]),
    );
  }
}
