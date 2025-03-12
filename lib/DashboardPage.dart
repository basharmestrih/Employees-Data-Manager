import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dashboardpage extends StatefulWidget {
  @override
  _DashboardpageState createState() => _DashboardpageState();
}

class _DashboardpageState extends State<Dashboardpage> {
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _postalCodes = [];

  @override
  void initState() {
    super.initState();
    _fetchPostalCodes();
  }

  Future<void> _fetchPostalCodes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('PostalCodes').select();

      setState(() {
        _postalCodes = response.isNotEmpty ? List<Map<String, dynamic>>.from(response) : [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePostalCodeToSupabase() async {
    try {
      final supabase = Supabase.instance.client;

      String postalCode = _postalCodeController.text.trim();
      double price = double.tryParse(_priceController.text) ?? 0.0;

      if (postalCode.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid postal code.')),
        );
        return;
      }

      await supabase.from('PostalCodes').insert({
        'Postal Code': postalCode,
        'Price': price,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Postal code saved successfully!')),
      );

      _fetchPostalCodes(); // Refresh table after saving
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data: $e')),
      );
    }
  }
@override
Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double leftSectionWidth = screenWidth * 0.3;

  return Scaffold(
    backgroundColor: Colors.grey[200],
    appBar: AppBar(
      backgroundColor: Colors.grey[350],
      title: Text(
        'Postal Code Entry',
        style: GoogleFonts.pompiere(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    ),
    body: Row(
      children: [
        // Left Section (Form and DataTable)
        Container(
          width: leftSectionWidth,  // Set the left section width to 30% of the screen width
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Postal Code & Price',
                style: GoogleFonts.pompiere(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 20),
              _buildTextField('Postal Code', _postalCodeController, keyboardType: TextInputType.number),
              _buildTextField('Price (€)', _priceController, keyboardType: TextInputType.number),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePostalCodeToSupabase,
                child: Text(
                  'Save',
                  style: GoogleFonts.pompiere(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Saved Postal Codes',
                style: GoogleFonts.pompiere(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              // Center the DataTable
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,  // Vertical scrolling enabled for table rows
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Postal Code')),
                            DataColumn(label: Text('Price (€)')),
                          ],
                          rows: _postalCodes.map((item) => DataRow(cells: [
                            // DataCell for Postal Code
                            DataCell(Text('€ ${(item['Postal Code'] ?? 0.0).toString()}')),
                            // DataCell for Price
                            DataCell(Text('€ ${(item['Price'] ?? 0).toStringAsFixed(2)}')),
                          ])).toList(),
                        ),
                      ),
                    ),
            ],
          ),
        ),
        // Vertical Divider (Placed as a separate column)
        Container(
          width: 1,  // Make the divider thin
          color: Colors.black,
          height: MediaQuery.of(context).size.height,  // Divider spans the full height of the screen
        ),
        // Right Section (Empty or additional widgets)
        Expanded(
          child: Container(),  // You can replace this with other content if needed
        ),
      ],
    ),
  );
}










  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
