import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/customer_tile.dart';

class AgentCustomers extends StatefulWidget {
  const AgentCustomers({super.key});
  @override
  State<AgentCustomers> createState() => _AgentCustomersState();
}

class _AgentCustomersState extends State<AgentCustomers> {
  String _search = '';
  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CustomerProvider>();
    final filtered = cp.customers.where((c) => _search.isEmpty || c.name.toLowerCase().contains(_search) || c.accountNumber.contains(_search)).toList();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          onChanged: (v) => setState(() => _search = v.toLowerCase()),
          decoration: const InputDecoration(hintText: 'Search customer…', prefixIcon: Icon(Icons.search)),
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: filtered.length,
          itemBuilder: (_, i) => CustomerTile(customer: filtered[i]),
        ),
      ),
    ]);
  }
}
