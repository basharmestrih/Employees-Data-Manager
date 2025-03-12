import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseScreen extends StatefulWidget {
  @override
  _DatabaseScreenState createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _employees = [];
  Map<String, TextEditingController> _controllers = {};
  int? _editingIndex;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _supabase.from('employeesa').select('*');
      setState(() {
        _employees = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateData(int index) async {
    final employee = _employees[index];
    Map<String, dynamic> updatedData = {};

    for (var key in _controllers.keys) {
      updatedData[key] = _controllers[key]!.text;
    }

    try {
      await _supabase.from('employeesa').update(updatedData).eq('id', employee['id']);
      _fetchData();
      setState(() {
        _editingIndex = null;
      });
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Employees Data',
          style: GoogleFonts.pompiere(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        backgroundColor: Colors.grey[100],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.swipe_left),
                      onPressed: () {
                        _scrollController.animateTo(
                          _scrollController.offset - 200,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.swipe_right),
                      onPressed: () {
                        _scrollController.animateTo(
                          _scrollController.offset + 200,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    child: DataTable(
                      columnSpacing: 20,
                      dataRowHeight: 50,
                      columns: [
                        DataColumn(label: Text('Manage')),
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('First Name')),
                        DataColumn(label: Text('Last Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Address')),
                        DataColumn(label: Text('Contract')),
                        DataColumn(label: Text('IBAN')),
                        DataColumn(label: Text('Price/Hour Pakket')),
                        DataColumn(label: Text('Price/Stop Pakket')),
                        DataColumn(label: Text('Price/Hour SDD')),
                        DataColumn(label: Text('Price Sunday SDD')),
                        DataColumn(label: Text('Car')),
                      ],
                      rows: _employees.map((employee) {
                        int index = _employees.indexOf(employee);
                        return DataRow(cells: [
                          DataCell(
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _editingIndex = index;
                                  _initializeControllers(employee);
                                });
                                _showEditDialog(context, employee, index);
                              },
                              child: Text('Edit'),
                            ),
                          ),
                          DataCell(Text(employee['id'].toString())),
                          DataCell(Text(employee['first_name'])),
                          DataCell(Text(employee['last_name'])),
                          DataCell(Text(employee['email'])),
                          DataCell(Text(employee['phone'])),
                          DataCell(Text(employee['address'])),
                          DataCell(Text(employee['contract'])),
                          DataCell(Text(employee['iban'])),
                          DataCell(Text(employee['price_per_hour_pakket'].toString())),
                          DataCell(Text(employee['price_per_stop_pakket'].toString())),
                          DataCell(Text(employee['price_per_hour_sdd'].toString())),
                          DataCell(Text(employee['price_sunday_sdd'].toString())),
                          DataCell(Text(employee['car'])),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _initializeControllers(Map<String, dynamic> employee) {
    _controllers.clear();
    employee.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value?.toString() ?? '');
    });
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> employee, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Employee'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < employee.keys.length; i += 2)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[employee.keys.elementAt(i)],
                          decoration: InputDecoration(labelText: employee.keys.elementAt(i)),
                        ),
                      ),
                      if (i + 1 < employee.keys.length)
                        SizedBox(width: 60), // Space between fields
                      if (i + 1 < employee.keys.length)
                        Expanded(
                          child: TextField(
                            controller: _controllers[employee.keys.elementAt(i + 1)],
                            decoration: InputDecoration(labelText: employee.keys.elementAt(i + 1)),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateData(index);
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
