import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/customer_tile.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _search = '';
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CustomerProvider>();
    final filtered = cp.customers.where((c) {
      final matchFilter = _filter == 'All' || c.status == _filter;
      final matchSearch = _search.isEmpty ||
        c.name.toLowerCase().contains(_search) ||
        c.accountNumber.contains(_search) ||
        c.village.toLowerCase().contains(_search) ||
        c.customerId.contains(_search);
      return matchFilter && matchSearch;
    }).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
            decoration: const InputDecoration(
              hintText: 'Search name, account, village…',
              prefixIcon: Icon(Icons.search), contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: ['All','NPA','PTP','Active','RTP','NM'].map((f) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                label: Text(f), selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
                selectedColor: AppColors.primaryLight,
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(color: _filter == f ? AppColors.primary : AppColors.textMid, fontWeight: FontWeight.w600),
              ),
            )).toList()),
          ),
        ]),
      ),
      Expanded(
        child: cp.loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : filtered.isEmpty
            ? const Center(child: Text('No customers found', style: TextStyle(color: AppColors.textMuted)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filtered.length,
                itemBuilder: (_, i) => CustomerTile(customer: filtered[i]),
              ),
      ),
    ]);
  }
}
