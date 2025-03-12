import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
  
}

class _HomePageState extends State<HomePage> {
  // Controllers for text fields
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _providerIdController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _drivingLicenseController = TextEditingController();
  final TextEditingController _contractTypeController = TextEditingController();
  final TextEditingController _pricePerHourPakketController = TextEditingController();
  final TextEditingController _pricePerStopPakketController = TextEditingController();
  final TextEditingController _pricePerHourSddController = TextEditingController();
  final TextEditingController _priceSundaySddController = TextEditingController();
  final TextEditingController _carController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Dropdown value for Contract
  String? _contractValue;




  // List of contract options
  final List<String> _contractOptions = [
    'fixed',
    'per hour',
    'subcontractor',
  ];

  // Supabase client
  final user = Supabase.instance.client.auth.currentUser;
  String? _contractFileUrl;
  String? _drivingLicenseFileUrl;
  


  // Function to upload file to Supabase storage
Future<String?> uploadFileToSupabase(String field, String fileName) async {
  try {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String uniqueFileName = '$fileName--${result.files.single.name}';

      // Upload file to Supabase Storage
      await _supabase.storage.from('fileuploadtester').upload(uniqueFileName, file);

      // Get public URL
      String fileUrl = _supabase.storage.from('fileuploadtester').getPublicUrl(uniqueFileName);
      return fileUrl;
    }
  } catch (e) {
    print('File upload error: $e');
  }
  return null;
}



  // Function to save data to Supabase
  Future<void> _saveDataToSupabase() async {
    try {
      final user = _supabase.auth.currentUser;
      print(user);
      final response = await _supabase.from('employeesa').insert({
        'id': _idController.text,
        'provider_id': _providerIdController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'date_of_birth': _dateOfBirthController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'contract': _contractValue,
        'iban': _ibanController.text,
        'driving_license': _drivingLicenseController.text,
        'contract_type': _contractTypeController.text,
        'price_per_hour_pakket': _pricePerHourPakketController.text,
        'price_per_stop_pakket': _pricePerStopPakketController.text,
        'price_per_hour_sdd': _pricePerHourSddController.text,
        'price_sunday_sdd': _priceSundaySddController.text,
        'car': _carController.text,
      });

      print('Data saved to Supabase: $response');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data saved successfully!')),
      );
    } catch (e) {
      print('Error saving data to Supabase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data: $e')),
      );
    }
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[200],
    appBar: AppBar(
      backgroundColor: Colors.grey[350],
      title: Text(
        'Dhl Employeers',
        style: GoogleFonts.pompiere(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Enter Employeer Details',
            style: GoogleFonts.pompiere(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Center(
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildTextField('ID', _idController),
                  _buildTextField('Provider ID', _providerIdController),
                  _buildTextField('Last Name', _lastNameController),
                  _buildTextField('First Name', _firstNameController),
                  _buildDateField('Date of Birth', _dateOfBirthController),
                  _buildTextField('Email', _emailController),
                  _buildTextField('Phone', _phoneController),
                  _buildTextField('Address', _addressController),
                  _buildContractDropdown(),
                  _buildTextField('IBAN', _ibanController),
                  _FilePickerField(
                    label: 'Upload Contract',
                    fileUrl: _contractFileUrl,
                    field: 'contract',
                    fileName: 'contract', // Corrected fileName
                    uploadFileToSupabase: uploadFileToSupabase,
                  ),
                  _FilePickerField(
                    label: 'Driving License',
                    fileUrl: _drivingLicenseFileUrl,
                    field: 'driving_license',
                    fileName: 'license', // Corrected fileName
                    uploadFileToSupabase: uploadFileToSupabase,
                  ),
                  _buildTextField('Price per Hour Pakket', _pricePerHourPakketController),
                  _buildTextField('Price per Stop Pakket', _pricePerStopPakketController),
                  _buildTextField('Price per Hour SDD', _pricePerHourSddController),
                  _buildTextField('Price Sunday SDD', _priceSundaySddController),
                  _buildTextField('Car', _carController),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await _saveDataToSupabase(); // Save data to Supabase
            },
            child: Text('Submit',style: GoogleFonts.pompiere(
                    fontWeight: FontWeight.bold,
                  ),),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildTextField(String label, TextEditingController controller) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: TextField(
        controller: controller,
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

  Widget _buildDateField(String label, TextEditingController controller) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue[800]),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.blue),
            onPressed: () => _selectDate(context),
          ),
        ),
        readOnly: true,
      ),
    );
  }

  Widget _buildContractDropdown() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: DropdownButtonFormField<String>(
        value: _contractValue,
        decoration: InputDecoration(
          labelText: 'Contract',
          labelStyle: TextStyle(color: Colors.blue[800]),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        items: _contractOptions.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _contractValue = newValue;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    _idController.dispose();
    _providerIdController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _dateOfBirthController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ibanController.dispose();
    _drivingLicenseController.dispose();
    _contractTypeController.dispose();
    _pricePerHourPakketController.dispose();
    _pricePerStopPakketController.dispose();
    _pricePerHourSddController.dispose();
    _priceSundaySddController.dispose();
    _carController.dispose();
    super.dispose();
  }
}



class _FilePickerField extends StatefulWidget {
  final String label;
  final String? fileUrl;
  final String field;
  final String fileName;
  final Future<String?> Function(String, String) uploadFileToSupabase;

  const _FilePickerField({
    required this.label,
    required this.fileUrl,
    required this.field,
    required this.fileName,
    required this.uploadFileToSupabase,
  });

  @override
  _FilePickerFieldState createState() => _FilePickerFieldState();
}

class _FilePickerFieldState extends State<_FilePickerField> {
  bool isUploading = false;
  //String? uploadedFileUrl; // No longer needed
  String labelText = '';

  @override
  void initState() {
    super.initState();
    labelText = widget.label; // Initialize with the original label
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: TextField(
        controller: TextEditingController(text: widget.fileUrl ?? ''), // Use existing fileUrl
        decoration: InputDecoration(
          labelText: labelText, // Dynamic label text
          suffixIcon: isUploading
              ? Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.blue),
                  onPressed: () async {
                    setState(() {
                      isUploading = true;
                      labelText = 'Uploading...'; // Update label
                    });

                    // Call the upload function with two arguments
                    await widget.uploadFileToSupabase(widget.field, widget.fileName);

                    setState(() {
                      isUploading = false;
                      labelText = 'It\'s done'; // Change label text after upload
                      // } else {  // No longer needed
                      //   labelText = widget.label; // Reset label on failure
                      // }
                    });
                  },
                ),
        ),
        readOnly: true,
      ),
    );
  }
}
