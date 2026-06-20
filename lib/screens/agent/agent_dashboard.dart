import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/section_title.dart';
import '../../widgets/customer_tile.dart';

class AgentDashboard extends StatelessWidget {
  const AgentDashboard({super.key});
  String fmt(double n) => n >= 100000 ? '₹${(n/100000).toStringAsFixed(1)}L' : n >= 1000 ? '₹${(n/1000).toStringAsFixed(0)}K' : '₹${n.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final cp  = context.watch<CustomerProvider>();
    final auth = context.watch<AuthProvider>();
    return RefreshIndicator(
      onRefresh: () => cp.fetchCustomers(agentId: auth.user?.uid),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.teal, Color(0xFF0F766E)]), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.person, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(auth.user?.name ?? 'Agent', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('ID: ${auth.user?.employeeId ?? '—'} · ${auth.user?.zone ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('🟢 Active', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
            ]),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: StatCard(label: 'Assigned', value: '${cp.customers.length}', icon: Icons.assignment, color: AppColors.primary, bg: AppColors.primaryLight)),
            const SizedBox(width: 10),
            Expanded(child: StatCard(label: 'Outstanding', value: fmt(cp.totalOutstanding), icon: Icons.currency_rupee, color: AppColors.danger, bg: AppColors.dangerLight)),
          ]),
          const SectionTitle('UPCOMING PTP'),
          ...cp.ptpToday.take(5).map((c) => CustomerTile(customer: c)),
          if (cp.ptpToday.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('No PTP due today', style: TextStyle(color: AppColors.textMuted)))),
          const SectionTitle('HIGH PRIORITY'),
          ...cp.highOutstanding.take(3).map((c) => CustomerTile(customer: c)),
        ]),
      ),
    );
  }
}
