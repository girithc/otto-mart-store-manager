import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:store/utils/constants.dart';
import 'package:store/utils/network/service.dart';
import 'package:http/http.dart' as http;

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({super.key});

  @override
  _VendorListScreenState createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getVendorList();
  }

  Future<void> getVendorList() async {
    // Fetch the list of vendors from the server
    final networkService = NetworkService();
    Map<String, dynamic> data = {};

    //final response = await networkService.postWithAuth('/vendor-list', additionalData: data);

    final response = await http.get(Uri.parse('$baseUrl/vendor-list'));
    if (response.statusCode == 200) {
      // Handle the response
      print("Response: ${response.body} ");
    } else {
      // Handle the error
    }
  }

  void _showAddVendorForm() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Scaffold(
          key: _scaffoldMessengerKey,
          appBar: AppBar(
            title: const Text('Add Vendor'),
            surfaceTintColor: Colors.white,
            centerTitle: true,
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: FormBuilder(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  FormBuilderTextField(
                    name: 'name',
                    decoration: InputDecoration(
                      labelText: 'Name',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 25),
                  FormBuilderTextField(
                    name: 'brand',
                    decoration: InputDecoration(
                      labelText: 'Brand',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 25),
                  FormBuilderDropdown(
                    name: 'delivery_frequency',
                    decoration: InputDecoration(
                      labelText: 'Delivery Frequency',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: _requiredValidator,
                    items: ['Once', 'Twice', 'Thrice', 'All Days']
                        .map((frequency) => DropdownMenuItem(
                            value: frequency, child: Text(frequency)))
                        .toList(),
                  ),
                  const SizedBox(height: 25),
                  FormBuilderDropdown(
                    name: 'delivery_day',
                    decoration: InputDecoration(
                      labelText: 'Delivery Day',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: _requiredValidator,
                    items: [
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday',
                      'Saturday',
                      'Sunday'
                    ]
                        .map((day) =>
                            DropdownMenuItem(value: day, child: Text(day)))
                        .toList(),
                  ),
                  const SizedBox(height: 25),
                  FormBuilderTextField(
                    name: 'mode_of_communication',
                    decoration: InputDecoration(
                      labelText: 'Mode Of Communication',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 25),
                  FormBuilderTextField(
                    name: 'notes',
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.saveAndValidate()) {
                        print(_formKey.currentState!.value);
                        Navigator.pop(context); // Close the bottom sheet
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      backgroundColor:
                          const Color(0xFF6200EE), // Background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Add Vendor",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        );
      },
    );

    InputDecoration inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor List'),
      ),
      body: const Center(
        child: Text('Add your vendors here!'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVendorForm,
        backgroundColor: Colors.deepPurpleAccent,
        tooltip: 'Add Vendor',
        child: const Icon(
          Icons.person_add_sharp,
          color: Colors.white,
        ),
      ),
    );
  }
}
