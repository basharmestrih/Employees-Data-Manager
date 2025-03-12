import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';



class Bozpakpage extends StatefulWidget {
  @override
  _BozpakpageState createState() => _BozpakpageState();
}

class _BozpakpageState extends State<Bozpakpage> {
  final TextEditingController _chauffeurController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _successfulStopsController = TextEditingController();
  final TextEditingController _successfulEenhController = TextEditingController();
  final TextEditingController _unsuccessfulStopsController = TextEditingController();
  final TextEditingController _unsuccessfulEenhController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final double _defaultStopsTotal = 1.8;
  final double _defaultEenhTotal = 0.15;
  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();


  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Supabase.instance.client.from('Bozpak').select('*');
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
  Future<void> _saveDataToSupabase() async {
  try {
    final supabase = Supabase.instance.client;
    String enteredPostalCode = _postalCodeController.text.trim();

    // Step 1: Query the postalcodes table to get the price
    final response = await supabase
        .from('PostalCodes')
        .select('Price')
        .eq('Postal Code', enteredPostalCode)
        .maybeSingle(); // Fetch a single result if exists

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Postal code not found in database!')),
      );
      return; // Stop execution if postal code is not found
    }

    double postalCodePrice = (response['Price'] as num).toDouble(); // Convert price to double

    // Step 2: Get user inputs
    int successfulStops = int.tryParse(_successfulStopsController.text) ?? 0;
    int successfulEenh = int.tryParse(_successfulEenhController.text) ?? 0;
    int unsuccessfulStops = int.tryParse(_unsuccessfulStopsController.text) ?? 0;
    int unsuccessfulEenh = int.tryParse(_unsuccessfulEenhController.text) ?? 0;

    // Step 3: Calculate the total amount using the given formula
    double bedrag = ((successfulStops - unsuccessfulStops) * postalCodePrice) +
                    ((successfulEenh - unsuccessfulEenh) * 0.15);

    // Step 4: Format the date
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Step 5: Insert data into the Bozpak table
     await supabase.from('Bozpak').insert({
        'Date': formattedDate,
        'Chauffeur': _chauffeurController.text,
        'Postal Code': _postalCodeController.text,
        'Successful Stops': successfulStops,
        'Successful Eenh': successfulEenh,
        'Unsuccessful Stops': unsuccessfulStops,
        'Unsuccessful Eenh': unsuccessfulEenh,
        'Stops Total': _defaultStopsTotal,
        'Eenh Total': _defaultEenhTotal,
        'Bedrag': bedrag,
      });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data saved successfully!')),
    );
    _fetchData();

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save data: $e')),
    );
  }
}

  void _scrollDown() {
  _scrollController.animateTo(
    _scrollController.position.maxScrollExtent,
    duration: Duration(seconds: 1),
    curve: Curves.easeOut,
  );
}

void _scrollUp() {
  _scrollController.animateTo(
    _scrollController.position.minScrollExtent,
    duration: Duration(seconds: 1),
    curve: Curves.easeOut,
  );
}


  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue[800]),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }






@override
Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double inputSectionWidth = screenWidth * 0.16;  // 30% of the screen width

  return Scaffold(
    backgroundColor: Colors.grey[200],
    appBar: AppBar(
      backgroundColor: Colors.grey[350],
      title: Text(
        'Driver Data Entry',
        style: GoogleFonts.pompiere(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    ),
    floatingActionButton: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    Container(
      width:30,
      height: 30,
      child: FloatingActionButton(
        onPressed: _scrollUp,
        child: Icon(Icons.arrow_upward),
        backgroundColor: Colors.blue[800],
      ),
    ),
    SizedBox(height: 10), // Space between buttons
    Container(
      width:30,
      height: 30,
      child: FloatingActionButton(
        onPressed: _scrollDown,
        child: Icon(Icons.arrow_downward),
        backgroundColor: Colors.blue[800],
      ),
    ),
  ],
),

    body: Row(
      crossAxisAlignment: CrossAxisAlignment.start,  // Aligns everything to the top
      children: [
        // Left Section - Input Fields
        Container(
          width: inputSectionWidth,  // Fixed width (30% of screen)
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Driver Details',
                style: GoogleFonts.pompiere(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 20),
                         Text('Select Date:',  style: GoogleFonts.pompiere(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),),
            SizedBox(height: 10),
            Row(
              children: [
                Text(DateFormat('yyyy-MM-dd').format(_selectedDate), style: TextStyle(fontSize: 18)),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),
              _buildTextField('Chauffeur', _chauffeurController),
              _buildTextField('Postal Code', _postalCodeController, keyboardType: TextInputType.number),
              _buildTextField('Successful Stops', _successfulStopsController, keyboardType: TextInputType.number),
              _buildTextField('Successful Eenh', _successfulEenhController, keyboardType: TextInputType.number),
              _buildTextField('Unsuccessful Stops', _unsuccessfulStopsController, keyboardType: TextInputType.number),
              _buildTextField('Unsuccessful Eenh', _unsuccessfulEenhController, keyboardType: TextInputType.number),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveDataToSupabase,
                child: Text(
                  'Submit',
                  style: GoogleFonts.pompiere(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Divider between sections
        VerticalDivider(
          color: Colors.black,
          thickness: 3,
          width: 1,
        ),

        // Right Section - Data Table
        
      Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Aligns content to the top
    children: [
      Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Driver Records',
            style: GoogleFonts.pompiere(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ),
      ),

      // Added header row
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child:
         Row(
          children: [
            SizedBox(width:440),
            Text('Successful', textAlign: TextAlign.center, style: TextStyle(  decoration: TextDecoration.underline,fontSize: 12, fontWeight: FontWeight.bold)),
             SizedBox(width:110),
            Text('Not Successful', textAlign: TextAlign.center, style: TextStyle(  decoration: TextDecoration.underline,fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(width:115),
            Text('Price', textAlign: TextAlign.center, style: TextStyle(  decoration: TextDecoration.underline,fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),

      // Data Table
      Expanded(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  controller: _scrollController, 
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Chauffeur')),
                      DataColumn(label: Text('P.Code')),
                  
                      // First group (Successful)
                      DataColumn(label: Text('Stops')),
                      DataColumn(label: Text('Eenh')),
                  
                      // Second group (Not Successful)
                      DataColumn(label: Text('Stops')),
                      DataColumn(label: Text('Eenh')),
                  
                      // Third group (Price)
                      DataColumn(label: Text('Stops')),
                      DataColumn(label: Text('Eenh')),
                      DataColumn(label: Text('Bedrag')),
                    ],
                    rows: _employees.map((item) => DataRow(cells: [
                      DataCell(Text(item['Date'] ?? 'N/A')),
                      DataCell(Text(item['Chauffeur'] ?? 'N/A')),
                      DataCell(Text((item['Postal Code'] ?? 0).toString())),
                  
                      // Successful
                      DataCell(Text((item['Successful Stops'] ?? 0).toString())),
                      DataCell(Text((item['Successful Eenh'] ?? 0).toString())),
                  
                      // Not Successful
                      DataCell(Text((item['Unsuccessful Stops'] ?? 0).toString())),
                      DataCell(Text((item['Unsuccessful Eenh'] ?? 0).toString())),
                  
                      // Price
                      DataCell(Text('€ ${(item['Stops Total'] ?? 0).toString()}')),
                      DataCell(Text('€ ${(item['Eenh Total'] ?? 0).toString()}')),
                      DataCell(Text('€ ${(item['Bedrag'] ?? 0.0).toString()}')),
                    ])).toList(),
                  ),
                ),
              ),
      ),
    ],
  ),
),

      ],
    ),
  );
}
}