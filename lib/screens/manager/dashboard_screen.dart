import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/customer_provider.dart';
import '../../providers/target_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/section_title.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String fmt(double n) => n >= 100000 ? '₹${(n/100000).toStringAsFixed(1)}L' : n >= 1000 ? '₹${(n/1000).toStringAsFixed(0)}K' : '₹${n.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CustomerProvider>();
    final tp = context.watch<TargetProvider>();

    return RefreshIndicator(
      onRefresh: () async { await cp.fetchCustomers(); await tp.load(); },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Achievement ring card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                SizedBox(
                  width: 100, height: 100,
                  child: Stack(alignment: Alignment.center, children: [
                    PieChart(PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 0,
                      sections: [
                        PieChartSectionData(value: tp.achievementPct.toDouble(), color: AppColors.teal, radius: 14, showTitle: false),
                        PieChartSectionData(value: (100 - tp.achievementPct).toDouble(), color: AppColors.border, radius: 14, showTitle: false),
                      ],
                    )),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('${tp.achievementPct}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      const Text('Target', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                    ]),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('FY 2026–27 Target', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  Text(fmt(tp.achieved), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  Text('of ${fmt(tp.yearlyTarget)}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: tp.achievementPct / 100, backgroundColor: AppColors.border, color: AppColors.teal, minHeight: 6, borderRadius: BorderRadius.circular(99)),
                  const SizedBox(height: 4),
                  Text('Remaining: ${fmt(tp.remaining)}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ])),
              ]),
            ),
          ),

          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: StatCard(label: 'Outstanding', value: fmt(cp.totalOutstanding), icon: Icons.currency_rupee, color: AppColors.danger, bg: AppColors.dangerLight)),
            const SizedBox(width: 10),
            Expanded(child: StatCard(label: 'NPA Accounts', value: '${cp.npaCount}', icon: Icons.warning_amber, color: AppColors.warning, bg: AppColors.warningLight)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: StatCard(label: 'PTP Today', value: '${cp.ptpToday.length}', icon: Icons.event_available, color: AppColors.purple, bg: AppColors.purpleLight)),
            const SizedBox(width: 10),
            Expanded(child: StatCard(label: 'Total Accounts', value: '${cp.customers.length}', icon: Icons.people, color: AppColors.teal, bg: AppColors.tealLight)),
          ]),

          const SectionTitle('AI RECOMMENDATIONS'),
          _RecoCard(title: 'Upcoming PTP Accounts', icon: Icons.event, color: AppColors.warning,
            items: cp.ptpToday.take(3).map((c) => '${c.name} · ₹${c.ptpAmount.toStringAsFixed(0)}').toList()),
          const SizedBox(height: 8),
          _RecoCard(title: 'High Outstanding', icon: Icons.trending_up, color: AppColors.danger,
            items: cp.highOutstanding.take(3).map((c) => '${c.name} · ${fmt(c.outstandingAmount)}').toList()),
          const SizedBox(height: 8),
          _RecoCard(title: 'Low Recovery — Needs Attention', icon: Icons.priority_high, color: AppColors.purple,
            items: cp.lowRecovery.take(3).map((c) => '${c.name} · ${c.village}').toList()),
        ]),
      ),
    );
  }
}

class _RecoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  const _RecoCard({required this.title, required this.icon, required this.color, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ]),
          const SizedBox(height: 8),
          ...items.map((s) => Padding(padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              Icon(Icons.circle, size: 6, color: color.withOpacity(0.5)),
              const SizedBox(width: 8),
              Expanded(child: Text(s, style: const TextStyle(fontSize: 12, color: AppColors.textMid))),
            ]))),
          if (items.isEmpty) const Text('No items', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ]),
      ),
    );
  }
}
