import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/customer_provider.dart';
import '../../providers/target_provider.dart';
import '../../services/excel_service.dart';
import '../../models/customer_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/section_title.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _targetCtrl = TextEditingController();
  List<CustomerModel>? _preview;
  String? _fileName;
  bool _uploading = false;
  String? _msg;

  final _fields = const [
    ['Name',              'Customer full name'],
    ['Father Name',       'Father / husband name'],
    ['Customer ID',       'Unique ID'],
    ['Account Number',    'Loan account number'],
    ['Village Name',      'Village / area / locality'],
    ['Sanctioned Amount', 'Total loan sanctioned'],
    ['Outstanding Amount','Balance remaining'],
    ['Rate of Interest',  'Annual ROI %'],
    ['Penal Interest Rate','Penal % on overdue EMI'],
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx','xls','csv']);
    if (result == null || result.files.single.path == null) return;
    setState(() { _fileName = result.files.single.name; _preview = null; _msg = null; });
    try {
      final rows = await ExcelService.parseFile(result.files.single.path!);
      setState(() => _preview = rows);
    } catch (e) {
      setState(() => _msg = 'Error parsing file: $e');
    }
  }

  Future<void> _import() async {
    if (_preview == null || _preview!.isEmpty) return;
    setState(() { _uploading = true; _msg = null; });
    try {
      await context.read<CustomerProvider>().uploadCustomers(_preview!);
      setState(() { _msg = '✅ ${_preview!.length} customers imported successfully!'; _preview = null; _fileName = null; });
    } catch (e) {
      setState(() => _msg = '❌ Import failed: $e');
    } finally {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TargetProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Target setting
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🎯 Set Yearly Recovery Target', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Current: ₹${tp.yearlyTarget.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: TextField(controller: _targetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Amount (₹)', prefixIcon: Icon(Icons.track_changes)))),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final v = double.tryParse(_targetCtrl.text);
                    if (v != null && v > 0) { await tp.setYearlyTarget(v); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Target updated!'), backgroundColor: AppColors.success)); }
                  },
                  child: const Text('Set'),
                ),
              ]),
            ]),
          ),
        ),

        const SectionTitle('UPLOAD CUSTOMER DATA'),
        if (_msg != null) Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _msg!.startsWith('✅') ? AppColors.successLight : AppColors.dangerLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(_msg!, style: TextStyle(fontWeight: FontWeight.w600, color: _msg!.startsWith('✅') ? AppColors.success : AppColors.danger)),
        ),

        // Drop zone
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity, padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 2, style: BorderStyle.none),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surfaceAlt,
            ),
            child: Column(children: [
              const Icon(Icons.upload_file, size: 48, color: AppColors.primary),
              const SizedBox(height: 10),
              Text(_fileName ?? 'Tap to pick Excel / CSV file', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const Text('.xlsx  ·  .xls  ·  .csv supported', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ]),
          ),
        ),

        // Required fields
        const SectionTitle('REQUIRED COLUMNS'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 8, runSpacing: 8, children: _fields.map((f) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(f[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                Text(f[1], style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ]),
            )).toList()),
          ),
        ),

        // Preview
        if (_preview != null) ...[
          const SectionTitle('PREVIEW'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${_preview!.length} rows detected', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 8),
                ..._preview!.take(3).map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    const Icon(Icons.person_outline, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(child: Text('${c.name} · ${c.accountNumber} · ${c.village}', style: const TextStyle(fontSize: 12))),
                    Text('₹${c.outstandingAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w700)),
                  ]),
                )),
                if (_preview!.length > 3) Text('... and ${_preview!.length - 3} more', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _uploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.cloud_upload),
                    label: Text(_uploading ? 'Importing…' : 'Import All ${_preview!.length} Customers'),
                    onPressed: _uploading ? null : _import,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}
