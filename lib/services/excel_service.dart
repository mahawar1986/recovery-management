import 'dart:io';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import '../models/customer_model.dart';

class ExcelService {
  /// Parse .xlsx or .csv and return list of CustomerModel
  static Future<List<CustomerModel>> parseFile(String filePath) async {
    final ext = filePath.split('.').last.toLowerCase();
    if (ext == 'csv') return _parseCsv(filePath);
    return _parseExcel(filePath);
  }

  static Future<List<CustomerModel>> _parseExcel(String path) async {
    final bytes = File(path).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables.values.first;
    final rows  = sheet.rows;
    if (rows.isEmpty) return [];

    // Map header row
    final headers = rows[0].map((c) => c?.value?.toString().toLowerCase().trim() ?? '').toList();
    final List<CustomerModel> result = [];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      String cell(String key) {
        final idx = _findCol(headers, key);
        return idx >= 0 && idx < row.length ? (row[idx]?.value?.toString().trim() ?? '') : '';
      }
      double num(String key) => double.tryParse(cell(key).replaceAll(',', '')) ?? 0;

      if (cell('name').isEmpty) continue;
      result.add(CustomerModel(
        id: '', name: cell('name'), fatherName: cell('father name'),
        customerId: cell('customer id'), accountNumber: cell('account number'),
        village: cell('village name'), sanctionedAmount: num('sanctioned amount'),
        outstandingAmount: num('outstanding amount'), rateOfInterest: num('rate of interest'),
        penalInterestRate: num('penal interest rate'), createdAt: DateTime.now(),
      ));
    }
    return result;
  }

  static Future<List<CustomerModel>> _parseCsv(String path) async {
    final input  = File(path).readAsStringSync();
    final fields = const CsvToListConverter(eol: '\n').convert(input);
    if (fields.isEmpty) return [];

    final headers = fields[0].map((c) => c.toString().toLowerCase().trim()).toList();
    final List<CustomerModel> result = [];

    for (int i = 1; i < fields.length; i++) {
      final row = fields[i];
      String cell(String key) {
        final idx = _findCol(headers, key);
        return idx >= 0 && idx < row.length ? row[idx].toString().trim() : '';
      }
      double num(String key) => double.tryParse(cell(key).replaceAll(',', '')) ?? 0;

      if (cell('name').isEmpty) continue;
      result.add(CustomerModel(
        id: '', name: cell('name'), fatherName: cell('father name'),
        customerId: cell('customer id'), accountNumber: cell('account number'),
        village: cell('village name'), sanctionedAmount: num('sanctioned amount'),
        outstandingAmount: num('outstanding amount'), rateOfInterest: num('rate of interest'),
        penalInterestRate: num('penal interest rate'), createdAt: DateTime.now(),
      ));
    }
    return result;
  }

  static int _findCol(List<String> headers, String key) =>
    headers.indexWhere((h) => h.contains(key.toLowerCase()));

  /// Generate sample Excel template
  static List<List<String>> get sampleTemplate => [
    ['Name','Father Name','Customer ID','Account Number','Village Name','Sanctioned Amount','Outstanding Amount','Rate of Interest','Penal Interest Rate'],
    ['Ramesh Kumar','Suresh Kumar','C001','ACC-10001','Sultanpur','150000','82000','12.5','3'],
    ['Sunita Devi','Mohan Lal','C002','ACC-10002','Rampur','80000','5000','11.0','2'],
  ];
}
