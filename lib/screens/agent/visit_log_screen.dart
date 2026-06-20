import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../models/visit_model.dart';
import '../../models/customer_model.dart';
import '../../utils/app_theme.dart';

class VisitLogScreen extends StatefulWidget {
  final CustomerModel? customer;
  const VisitLogScreen({super.key, this.customer});
  @override
  State<VisitLogScreen> createState() => _VisitLogScreenState();
}

class _VisitLogScreenState extends State<VisitLogScreen> {
  final _remarks  = TextEditingController();
  final _ptpAmt   = TextEditingController();
  VisitOutcome _outcome = VisitOutcome.callBack;
  DateTime? _ptpDate;
  double? _lat, _lng;
  String? _photoPath;
  bool _saving = false;

  Future<void> _getLocation() async {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied) return;
    final pos = await Geolocator.getCurrentPosition();
    setState(() { _lat = pos.latitude; _lng = pos.longitude; });
  }

  Future<void> _pickPhoto() async {
    final img = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 60);
    if (img != null) setState(() => _photoPath = img.path);
  }

  Future<void> _save() async {
    if (widget.customer == null) return;
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final visit = VisitModel(
      id: '', customerId: widget.customer!.id,
      customerName: widget.customer!.name,
      agentId: auth.user!.uid, agentName: auth.user!.name,
      visitDate: DateTime.now(), outcome: _outcome,
      ptpDate: _ptpDate, ptpAmount: double.tryParse(_ptpAmt.text),
      remarks: _remarks.text, latitude: _lat, longitude: _lng,
    );
    await context.read<CustomerProvider>().logVisit(visit);
    if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visit logged!'), backgroundColor: AppColors.success)); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Visit', style: TextStyle(fontWeight: FontWeight.w800)), backgroundColor: AppColors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (widget.customer != null) Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: AppColors.primary),
              title: Text(widget.customer!.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${widget.customer!.accountNumber} · ₹${widget.customer!.outstandingAmount.toStringAsFixed(0)} outstanding'),
            ),
          ),

          const SizedBox(height: 12),
          const Text('Visit Outcome', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: VisitOutcome.values.map((o) => ChoiceChip(
            label: Text(o.name.toUpperCase()),
            selected: _outcome == o,
            onSelected: (_) => setState(() => _outcome = o),
            selectedColor: AppColors.primaryLight,
            labelStyle: TextStyle(color: _outcome == o ? AppColors.primary : AppColors.textMid, fontWeight: FontWeight.w600, fontSize: 11),
          )).toList()),

          if (_outcome == VisitOutcome.ptp) ...[
            const SizedBox(height: 12),
            TextFormField(controller: _ptpAmt, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'PTP Amount (₹)', prefixIcon: Icon(Icons.currency_rupee))),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 3)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
                if (d != null) setState(() => _ptpDate = d);
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(_ptpDate != null ? 'PTP Date: ${_ptpDate!.toLocal().toString().split(' ')[0]}' : 'Select PTP Date'),
            ),
          ],

          const SizedBox(height: 12),
          TextField(controller: _remarks, maxLines: 3, decoration: const InputDecoration(labelText: 'Remarks / Notes', prefixIcon: Icon(Icons.notes), alignLabelWithHint: true)),

          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: _getLocation,
              icon: Icon(Icons.location_on, color: _lat != null ? AppColors.success : AppColors.textMuted),
              label: Text(_lat != null ? 'GPS ✓' : 'Capture GPS', style: TextStyle(color: _lat != null ? AppColors.success : AppColors.textMid)),
            )),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: Icon(Icons.camera_alt, color: _photoPath != null ? AppColors.success : AppColors.textMuted),
              label: Text(_photoPath != null ? 'Photo ✓' : 'Take Photo', style: TextStyle(color: _photoPath != null ? AppColors.success : AppColors.textMid)),
            )),
          ]),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
              child: _saving ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('SUBMIT VISIT LOG', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ),
          ),
        ]),
      ),
    );
  }
}
